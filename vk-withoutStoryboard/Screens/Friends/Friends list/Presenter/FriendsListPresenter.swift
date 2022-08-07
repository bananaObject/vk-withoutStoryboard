//
//  FriendsListPresenter.swift
//  vk-withoutStoryboard
//
//  Created by Ke4a on 03.08.2022.
//

import RealmSwift
import UIKit

protocol FriendsListViewInput {
    var viewModels: [LetterViewModel] { get set }
    func updateTableView(_ from: UpdatesIndexsHelper?)
    func updateRow(_ from: IndexPath)
    func loadingAnimation(_ on: Bool)
}

protocol FriendsListViewOutput {
    func fetchFriends()
    func createNotificationToken()
    func openFriendPhotos()
    func deleteFriend(_ friend: FriendViewModel)
    func loadImageAsync(from index: IndexPath, for friend: FriendViewModel)
}

class FriendsListPresenter {
    // MARK: - Public Properties

    weak var viewInput: (UIViewController & FriendsListViewInput)?

    // MARK: - Private Properties

    private let interactor: FriendsListInteractorInput
    private let router: FriendsListRouterInput

    // MARK: - Initialization

    init(_ interactor: FriendsListInteractorInput, _ router: FriendsListRouterInput) {
        self.interactor = interactor
        self.router = router
    }

    // MARK: - Private Methods

    private func fetchFriendsAsync() {
        Task(priority: .background) {
            do {
                let friends = try await self.interactor.requestFriendsAsync()

                await MainActor.run {
                    self.interactor.saveInRealm(friends)
                }
            } catch {
                print(error)
            }

            await MainActor.run {
                viewInput?.loadingAnimation(false)
            }
        }
    }
}

// MARK: - FriendsListViewOutput

extension FriendsListPresenter: FriendsListViewOutput {
    func fetchFriends() {
        viewInput?.loadingAnimation(true)
        fetchFriendsAsync()
    }

    func createNotificationToken() {
        interactor.createNotificationToken()
    }

    func openFriendPhotos() {
        // router.presentFriendPhotosVC(<#T##friend: RLMFriend##RLMFriend#>)
    }

    func deleteFriend(_ friend: FriendViewModel) {
        interactor.deleteFriend(friend)
    }

    func loadImageAsync(from index: IndexPath, for friend: FriendViewModel) {
        guard friend.imageData == nil else { return }

        Task(priority: .background) {
            let data = await interactor.loadImageDataAsync(url: friend.avatar)
            self.viewInput?.viewModels[index.section].items[index.row].imageData = data

            await MainActor.run {
                self.viewInput?.updateRow(index)
            }
        }
    }
}

// MARK: - FriendsListInteractorOutput

extension FriendsListPresenter: FriendsListInteractorOutput {
    func updateViewModels(_ models: UpdatesViewModelsHelper<LetterViewModel>, _ indeces: UpdatesIndexsHelper) {
        if indeces.updateAll {
            viewInput?.viewModels = models.updateAll
            viewInput?.updateTableView(nil)

            return
        }

        var models = models

        indeces.insert.forEach { index in
            let letter = models.insert.removeFirst()
            viewInput?.viewModels.insert(letter, at: index.section)
        }

        indeces.delete.forEach { index in
            viewInput?.viewModels.remove(at: index.section)
        }

        indeces.reload.forEach { index in
            let letter = models.reload.removeFirst()

            viewInput?.viewModels[index.section] = letter
        }

        viewInput?.updateTableView(indeces)
    }
}
