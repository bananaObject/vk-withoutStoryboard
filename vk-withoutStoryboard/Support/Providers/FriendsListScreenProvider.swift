//
//  FriendsListScreenProvider.swift
//  vk-withoutStoryboard
//
//  Created by Ke4a on 01.04.2022.
//

import Foundation
import PromiseKit
import RealmSwift

/// Провайдер для FriendsViewController.
final class FriendsListScreenProvider: ApiLayer {
    // MARK: - Public Properties
    private var realm = RealmLayer()
    
    /// Получение из бд секции с друзьями.
    var data: Results<RLMLetter> {
        self.realm.read(RLMLetter.self).sorted(byKeyPath: "name", ascending: true)
    }
    
    // MARK: - Initializers
    init() {
        // путь к файлу realm
        realm.printUrlFile()
    }
    
    // MARK: - Public Methods
    ///  Заполнение данных друзей
    /// - Parameter loadView:  view loading animations
    func fetchData(_ loadView: LoadingView) {
        loadView.animation(.on)

        Task(priority: .background) {
            do {
                let friends = try await self.requestAsync()
                await self.saveInRealm(friends)
            } catch {
                print(error)
            }

            await MainActor.run {
                    loadView.animation(.off)
            }
        }
    }
    
    /// Удаление друзей из базы данных.
    /// - Parameter objects: список друзей.
    func deleteInRealm<T: Object>(objects: [T]) {
        self.realm.delete(objects: objects)
    }

    // MARK: - Private Methods
    /// Запрос списка друзей из api.
    ///
    /// Друзья сохраняются  в бд.
    private func requestAsync() async throws -> [RLMFriend] {
        let result = await sendRequestList(endpoint: ApiEndpoint.getFriends, responseModel: RLMFriend.self)

        switch result {
        case.success(let result):
            return result.items
        case .failure(let error):
           throw error
        }
    }

    /// Сохранение друзей в бд.
    /// - Parameter friendsFromApi: Список друзей.
    ///
    /// Написал сложную логику сохранение друзей, чтоб уменьшить траназцикцию записи.
    /// (на 1500 объектов было 45 сек, стало 4 сек)
    @MainActor
    private func saveInRealm(_ friendsFromApi: [RLMFriend]) {
        // список для обновления данных старых друзей
        var friendsUpdate: [RLMFriend] = []
        // список для обнавления существующих секций
        var alphabetUpdate: [(RLMLetter, RLMFriend)] = []
        // список секций другом которые надо создать
        var newAlphabet: [RLMLetter] = []

        // список друзей из бд в данный момент
        let oldDBFriends: Results<RLMFriend> = self.realm.read(RLMFriend.self)

        // список друзей которых надо удалить из бд
        let deleteFriends: [RLMFriend] = oldDBFriends.filter { friend in
            !friendsFromApi.contains { $0.id == friend.id }
        }

        // проходим по друзьям из api для распределения по нужным спискам для последующей работы.
        friendsFromApi.forEach { newFriend in
            // Проверям друга из api в списке друзей из бд
            if oldDBFriends.contains(where: { $0.id == newFriend.id }) {
                // если друг есть в бд то добавляем в список для обнавления данных
                friendsUpdate.append(newFriend)
            } else {
                // Если друга нет в бд.
                // Получаем первую буквы фамилии друга для секции
                guard let letterNameFriend: String = newFriend.lastName.first?.lowercased() else { return }
                // Проверка есть ли уже секция с буквой друга
                self.realm.read(RLMLetter.self, key: letterNameFriend) { result in
                    switch result {
                    case .success(let letter):
                        // добавляю друга в список для обновления списка друзей существующих секций
                        alphabetUpdate.append((letter, newFriend))
                    case .failure:
                        // проверяю есть ли секция в массиве не сохраненных данных бд
                        if let indexSection: Int = newAlphabet.firstIndex(where: { $0.name == letterNameFriend }) {
                            // если есть то добавляю друга в секциию
                            newAlphabet[indexSection].items.append(newFriend)
                        } else {
                            // создаю секцию
                            let letter = RLMLetter()
                            letter.name = letterNameFriend
                            // добавляю друга в секцию
                            letter.items.append(newFriend)
                            // добавляю секцию в список которые надо создать
                            newAlphabet.append(letter)
                        }
                    }
                }
            }
        }

        // обновляем данные старых друзей
        self.realm.create(objects: friendsUpdate)

        self.realm.writeTransction {
            // добавляю новых друзей в существующие секции
            alphabetUpdate.forEach { letter, newfriend in
                letter.items.append(newfriend)
            }
        }

        // добавляю в бд новые секции с друзьями
        self.realm.create(objects: newAlphabet)

        // удаление друзей
        self.deleteInRealm(objects: deleteFriends)
    }
}
