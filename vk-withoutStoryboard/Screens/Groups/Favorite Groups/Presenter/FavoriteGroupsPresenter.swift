//
//  FavoriteGroupsPresenter.swift
//  vk-withoutStoryboard
//
//  Created by Ke4a on 01.08.2022.
//

import UIKit

protocol FavoriteGroupsViewInput {
    var viewModels: [GroupViewModel] { get set }
    func loadingAnimation(_ on: Bool)
    func updateTableView(_ from: UpdatesIndexPaths?)
}

protocol FavoriteGroupsViewOutput {
    func requestGroups()
    func openCatalogGroups()
    func updateSearchText(_ text: String)
    func createNotificationToken()
    func deleteInRealm(_ group: GroupViewModel)
    func loadImageAsync(for index: IndexPath, from group: GroupViewModel) 
}

class FavoriteGroupsPresenter {
    // MARK: - Public Properties

    weak var viewInput: (UIViewController & FavoriteGroupsViewInput)?

    // MARK: - Private Properties

    private var interactor: FavoriteGroupsInteractorInput
    private let router: FavoriteGroupsRouterInput

    // MARK: - Initialization

    init(_ interactor: FavoriteGroupsInteractorInput, _ router: FavoriteGroupsRouterInput) {
        self.interactor = interactor
        self.router = router
    }
}

// MARK: - FavoriteGroupsViewOutput

extension FavoriteGroupsPresenter: FavoriteGroupsViewOutput {
    // MARK: - Public Methods

    func requestGroups() {
        Task(priority: .background) {
            let response = try await interactor.requestGroupsAsync()

            await MainActor.run {
                self.interactor.saveInRealm(response)
                self.viewInput?.updateTableView(nil)
                self.viewInput?.loadingAnimation(false)
            }
        }
    }

    func openCatalogGroups() {
        router.presentCatalogGroupsVC()
    }

    func updateSearchText(_ text: String) {
        interactor.searchText = text
    }

    func createNotificationToken() {
        interactor.createNotificationToken()
    }

    func deleteInRealm(_ group: GroupViewModel) {
        interactor.deleteInRealm(group)
    }

    func loadImageAsync(for index: IndexPath, from group: GroupViewModel) {
        guard group.imageData == nil else { return }
        
        Task(priority: .background) {
            let data = await interactor.loadImageDataAsync(url: group.photo200)
            self.viewInput?.viewModels[index.row].imageData = data

            let indexPath = UpdatesIndexPaths(reload: [index])

            await MainActor.run {
                self.viewInput?.updateTableView(indexPath)
            }
        }
    }
}

// MARK: - FavoriteGroupsInteractorOutput

extension FavoriteGroupsPresenter: FavoriteGroupsInteractorOutput {
    func updateView(_ from: UpdatesIndexPaths?) {
        viewInput?.updateTableView(from)
    }
    
    func updateViewModels(_ models: [GroupViewModel]) {
        viewInput?.viewModels = models
    }
}
