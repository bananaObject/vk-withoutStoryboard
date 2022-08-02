//
//  CatalogGroupsPresenter.swift
//  vk-withoutStoryboard
//
//  Created by Ke4a on 23.07.2022.
//

import UIKit

protocol CatalogGroupsViewInput {
    var viewModels: [GroupViewModel] { get set }
    func loadingAnimation(_ on: Bool)
    func updateTableView(for index: IndexPath?)
}

protocol CatalogGroupsViewOutput {
    func fetchCatalog()
    func updateSearchText(_ text: String)
    func loadImageAsync(for index: IndexPath, model: GroupViewModel)
    func selectGroup(_ group: GroupViewModel)
}

class CatalogGroupsPresenter {
    
    // MARK: - Public Properties

    weak var viewInput: (UIViewController & CatalogGroupsViewInput)?

    // MARK: - Private Properties

    private var interactor: CatalogGroupsInteractorInput
    private let router: CatalogGroupsRouterInput

    // MARK: - Initialization

    init(_ interactor: CatalogGroupsInteractorInput,
         _ router: CatalogGroupsRouterInput
    ) {
        self.interactor = interactor
        self.router = router
    }

    // MARK: - Private Methods

    private func fetchGroupsAsync() {
        Task(priority: .background) {
            let response = try await interactor.requestGroupsAsync()
            let viewModels = interactor.convertToViewModels(response)
            self.viewInput?.viewModels = viewModels

            await MainActor.run {
                self.viewInput?.updateTableView(for: nil)
                self.viewInput?.loadingAnimation(false)
            }
        }
    }
}

// MARK: - CatalogGroupsViewOutput

extension CatalogGroupsPresenter: CatalogGroupsViewOutput {

    // MARK: - Public Methods

    func fetchCatalog() {
        viewInput?.loadingAnimation(true)
        fetchGroupsAsync()
    }

    func updateSearchText(_ text: String) {
        interactor.searchText = text
    }

    func selectGroup(_ group: GroupViewModel) {
        // let selectGroup: GroupModel = provider.data[indexPath.row]
        // self.service.firebaseSelectGroup(selectGroup)
        router.popViewController()
    }

    func loadImageAsync(for index: IndexPath, model: GroupViewModel) {
        if model.imageData == nil {
            Task(priority: .background) {
                let data = await interactor.loadImageDataAsync(url: model.photo200)

                self.viewInput?.viewModels[index.row].imageData = data

                await MainActor.run {
                    self.viewInput?.updateTableView(for: index)
                }
            }
        }
    }
}
