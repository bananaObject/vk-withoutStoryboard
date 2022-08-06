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
    func updateTableView(_ from: UpdatesIndexsHelper?)
    func updateTableView(_ from: IndexPath)
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

            await MainActor.run {
                self.viewInput?.updateTableView(index)
            }
        }
    }
}

// MARK: - FavoriteGroupsInteractorOutput

extension FavoriteGroupsPresenter: FavoriteGroupsInteractorOutput {
    func updateViewModels(_ models: UpdateViewModelsHelper<GroupViewModel>, _ index: UpdatesIndexsHelper) {
        if index.updateAll {
            viewInput?.viewModels = models.updateAll
            viewInput?.updateTableView(nil)

            return
        }

        var models = models

        index.delete.forEach { index in
            viewInput?.viewModels.remove(at: index.row)
        }

        index.reload.forEach { index in
            let group = models.reload.removeFirst()
            viewInput?.viewModels[index.row] = group
        }

        index.insert.forEach { index in
            let group = models.insert.removeFirst()
            viewInput?.viewModels.insert(group, at: index.row)
        }

        viewInput?.updateTableView(index)
    }
}
