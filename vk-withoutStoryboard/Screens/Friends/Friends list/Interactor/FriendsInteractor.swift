//
//  FriendsListInteractor.swift
//  vk-withoutStoryboard
//
//  Created by Ke4a on 03.08.2022.
//

import Foundation
import RealmSwift

protocol FriendsListInteractorInput {
    func requestFriendsAsync() async throws -> [RLMFriend]
    func deleteFriend(_ friend: FriendViewModel)
    func saveInRealm(_ friends: [RLMFriend])
    func createNotificationToken()
    func loadImageDataAsync(url: String) async -> Data?
}

protocol FriendsListInteractorOutput: AnyObject {
    func updateViewModels(_ models: UpdatesViewModelsHelper<LetterViewModel>, _ index: UpdatesIndexsHelper)
}

class FriendsListInteractor {
    // MARK: - Public Properties

    weak var presenter: FriendsListInteractorOutput?

    // MARK: - Private Computed Properties

    /// Получение из бд секции с друзьями.
    private var data: Results<RLMLetter> {
        self.realm.read(RLMLetter.self).sorted(byKeyPath: "name", ascending: true)
    }

    // MARK: - Private Properties

    private let network: Api
    private let realm: RealmLayer
    private let letterFactory = LettersViewModelFactory()
    private var token: NotificationToken?

    // MARK: - Initialization

    init(_ api: Api, _ realm: RealmLayer) {
        self.network = api
        self.realm = realm
    }

    // MARK: - Private Methods

    private func convertToViewModels(_ rmls: [RLMLetter]) -> [LetterViewModel] {
        return letterFactory.constructViewModels(from: rmls)
    }

    private func getViewModel(from letter: RLMLetter) -> LetterViewModel {
        return letterFactory.getViewModel(from: letter)
    }

}

// MARK: - FriendsListInteractorInput

extension FriendsListInteractor: FriendsListInteractorInput {

    func requestFriendsAsync() async throws -> [RLMFriend] {
        let result = await network.sendRequestList(endpoint: ApiEndpoint.getFriends, responseModel: RLMFriend.self)

        switch result {
        case.success(let result):
            return result.items
        case .failure(let error):
            throw error
        }
    }

    func deleteFriend(_ friend: FriendViewModel) {
        guard let friendRealm = realm.read(RLMFriend.self).first(where: { $0.id == friend.id }) else { return }

        self.realm.delete(object: friendRealm)
    }

    /// Saving friends in the database.
    /// - Parameter friendsFromApi: List of friends.
    ///
    /// Wrote complex logic to save friends to reduce write transaction.
    /// (for 1500 objects it was 45 sec, now 4 sec)
    func saveInRealm(_ friendsFromApi: [RLMFriend]) {
        // list to update old friends data
        var friendsUpdate: [RLMFriend] = []
        // list to update old sections
        var alphabetUpdate: [(RLMLetter, RLMFriend)] = []
        // list of sections with a friend to create
        var newAlphabet: [RLMLetter] = []

        // list of friends from the database
        let oldDBFriends: Results<RLMFriend> = self.realm.read(RLMFriend.self)

        // list of friends to be removed from the database
        let deleteFriends: [RLMFriend] = oldDBFriends.filter { friend in
            !friendsFromApi.contains { $0.id == friend.id }
        }

        // pass through friends received from api and distribute across arrays
        friendsFromApi.forEach { newFriend in
            // Check friend from api in the list of friends from the base
            if oldDBFriends.contains(where: { $0.id == newFriend.id }) {
                // if there is a friend in the database, then add him to the list to update the data
                friendsUpdate.append(newFriend)
            } else {
                // If the friend is not in the database.
                // Get the first letter of the friend's last name for the future section
                guard let letterNameFriend: String = newFriend.lastName.first?.lowercased() else { return }
                // Check if there is already a section with a letter
                self.realm.read(RLMLetter.self, key: letterNameFriend) { result in
                    switch result {
                    case .success(let letter):
                        // add a friend to the list to update the list of friends of existing sections
                        alphabetUpdate.append((letter, newFriend))
                    case .failure:
                        // check if there is a section in the array of unsaved database data
                        if let indexSection: Int = newAlphabet.firstIndex(where: { $0.name == letterNameFriend }) {
                            // if there is, add a friend to the section
                            newAlphabet[indexSection].items.append(newFriend)
                        } else {
                            // create section
                            let letter = RLMLetter()
                            letter.name = letterNameFriend
                            // add a friend to the section
                            letter.items.append(newFriend)
                            // add a section to the list to create
                            newAlphabet.append(letter)
                        }
                    }
                }
            }
        }

        // update old friends data
        self.realm.create(objects: friendsUpdate)

        self.realm.writeTransction {
            // add new friends to existing sections
            alphabetUpdate.forEach { letter, newfriend in
                letter.items.append(newfriend)
            }
        }

        // add new sections with friends to the database
        self.realm.create(objects: newAlphabet)

        // deleting friends that the user no longer has
        self.realm.delete(objects: deleteFriends)
    }

    /// Registers a block that will be called every time a section changes in the database.
    func createNotificationToken() {
        token = data.observe { [weak self] result in
            guard let self = self else { return }

            switch result {
            case .initial(let letterRealm):
                let letters = Array(letterRealm)

                let update = UpdatesViewModelsHelper(updateAll: self.convertToViewModels(letters))
                let index = UpdatesIndexsHelper(updateAll: true)

                self.presenter?.updateViewModels(update, index)
            case .update(let letterRealm, let deletions, let insertions, let modifications):

                let RLMsLetter = Array(letterRealm)

                let actor = UpdateViewModelsActor<LetterViewModel>()

                Task { @MainActor in
                    await withTaskGroup(of: Void.self) { group in

                        if !deletions.isEmpty {
                            group.addTask(priority: .background) {
                                let indeces = deletions.map { IndexPath(row: 0, section: $0) }
                                await actor.append(indeces, to: .delete)
                            }
                        }

                        if !insertions.isEmpty {
                            group.addTask { @MainActor in
                                var update: [LetterViewModel] = []

                                let indeces: [IndexPath] = insertions.map { index in
                                    let letter = RLMsLetter[index]
                                    update.append(self.getViewModel(from: letter))
                                    return IndexPath(row: 0, section: index)
                                }

                                await actor.append(indeces, to: .insert)
                                await actor.append(update, to: .insert)
                            }
                        }

                        if !modifications.isEmpty {
                            group.addTask {  @MainActor [weak self] in
                                guard let self = self else { return }

                                lazy var deleteLetter: [RLMLetter] = []
                                lazy var deleteIndex: [IndexPath] = []

                                var update: [LetterViewModel] = []

                                let indeces: [IndexPath] = modifications.compactMap { index in
                                    let letter = RLMsLetter[index]

                                    if letter.items.isEmpty {
                                        deleteLetter.append(letter)
                                        deleteIndex.append(IndexPath(row: 0, section: index))
                                        return nil
                                    }

                                    update.append(self.getViewModel(from: letter))
                                    return IndexPath(row: 0, section: index)
                                }

                                if !deleteLetter.isEmpty || !deleteIndex.isEmpty, let token = self.token {
                                    self.realm.deleteWithoutNotifying(objects: deleteLetter, token: token)

                                    await actor.append(deleteIndex, to: .delete)
                                }

                                await actor.append(indeces, to: .reload)
                                await actor.append(update, to: .reload)
                            }
                        }
                    }

                    await self.presenter?.updateViewModels(actor.models, actor.indexs)
                }
            case .error(let error):
                print(error)
            }
        }
    }

    func loadImageDataAsync(url: String) async -> Data? {
        do {
            return  try await LoaderImageLayer.shared.loadAsync(url: url, cache: .fileCache).pngData()
        } catch {
            return nil
        }
    }
}
