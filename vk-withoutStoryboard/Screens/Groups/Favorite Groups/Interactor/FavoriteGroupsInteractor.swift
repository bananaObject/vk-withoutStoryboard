//
//  FavoriteGroupsInteractor.swift
//  vk-withoutStoryboard
//
//  Created by Ke4a on 01.08.2022.
//

import Foundation
import RealmSwift

protocol FavoriteGroupsInteractorInput {
    /// SearchBar text.
    var searchText: String { get set }

    /// Fetch groups from api.
    /// - Returns: Realm model group.
    func requestGroupsAsync() async throws -> [RLMGroup]

    /// Сonvert to viewModels.
    /// - Parameter rmls: Realm results
    /// - Returns: Group viewModel.
    func convertToViewModels(_ rmls: Results<RLMGroup>) -> [GroupViewModel]

    /// Save realmModel in db.
    /// - Parameter newGroups: array realmModel.
    func saveInRealm(_ newGroups: [RLMGroup])

    /// Delete group in db.
    /// - Parameter group: группы
    func deleteInRealm(_ group: GroupViewModel)

    /// Registers a block to be called each time the collection changes in db.
    func createNotificationToken()

    /// Load image async.
    /// - Parameter url: string url image.
    /// - Returns: Optional image data.
    func loadImageDataAsync(url: String) async -> Data?
}

protocol FavoriteGroupsInteractorOutput {
    func updateViewModels(_ models: [GroupViewModel])
    func updateView(_ from: UpdatesIndexPaths?)
}

class FavoriteGroupsInteractor: FavoriteGroupsInteractorInput {

    // MARK: - Public Properties

    var presenter: FavoriteGroupsInteractorOutput?

    var searchText: String = "" {
        didSet {
            let models = convertToViewModels(realmData)

            presenter?.updateViewModels(models)
            presenter?.updateView(nil)
        }
    }

    // MARK: - Private Properties

    private var realmData: Results<RLMGroup> {
        if searchText.isEmpty {
            return realm.read(RLMGroup.self)
        }

        return realm.read(RLMGroup.self).filter("name CONTAINS[cd] %@", searchText)
    }

    private let network: ApiLayer
    private let realm: RealmLayer

    private let groupsFactory = GroupsViewModelFactory()
    private var notificationToken: NotificationToken?

    // MARK: - Initialization

    init(_ apiLayer: ApiLayer, _ realmLayer: RealmLayer) {
        self.network = apiLayer
        self.realm = realmLayer
    }

    deinit {
        notificationToken?.invalidate()
    }

    // MARK: - Public Methods

    func requestGroupsAsync() async throws -> [RLMGroup] {
        let result = await network.sendRequestList(endpoint: .getGroups, responseModel: RLMGroup.self)

        switch result {
        case .success(let response):
            return response.items
        case .failure(let error):
            print(error)
            throw error
        }
    }

    func convertToViewModels(_ rmls: Results<RLMGroup>) -> [GroupViewModel] {
        let result = Array(rmls)
        return groupsFactory.constructViewModels(from: result)
    }

    func saveInRealm(_ newGroups: [RLMGroup]) {
        // Groups from which the user left, but they are still present in the database
        let oldValues: [RLMGroup] = self.realm.read(RLMGroup.self).filter { oldGroup in
            !newGroups.contains { $0.id == oldGroup.id }
        }

        // Deleting groups the user has logged out of
        if !oldValues.isEmpty {
            self.realm.delete(objects: oldValues)
        }

        // Adding new groups or updating data of old groups
        self.realm.create(objects: newGroups)
    }

    func deleteInRealm(_ group: GroupViewModel) {
        guard let group = realmData.first(where: { $0.id == group.id }) else { return }
        realm.delete(object: group)
    }

    func createNotificationToken() {
        // Subscription to db changes
        // You can also subscribe to changes to a specific object
        notificationToken = realmData.observe { result in
            switch result {
                // At initialization
            case .initial(let RLMGroups):

                let viewModels = self.convertToViewModels(RLMGroups)
                self.presenter?.updateViewModels(viewModels)

                // At changes db
            case .update(let RLMGroups,
                         let deletions,
                         let insertions,
                         let modifications):
                let viewModels = self.convertToViewModels(RLMGroups)
#warning("Иправить ошибку при использование вместе поиска и удаление ячейки")
#warning("Иправить баг что добавляется новая группа в конец списка")
                let deletionsIndexPath: [IndexPath] = deletions.map { IndexPath(row: $0, section: 0) }
                let insertionsIndexPath: [IndexPath] = insertions.map { IndexPath(row: $0, section: 0) }
                let modificationsIndexPath: [IndexPath] = modifications.map { IndexPath(row: $0, section: 0) }
                let indexPath = UpdatesIndexPaths(delete: deletionsIndexPath,
                                                  insert: insertionsIndexPath,
                                                  reload: modificationsIndexPath)

                self.presenter?.updateViewModels(viewModels)
                self.presenter?.updateView(indexPath)
                // Ar error
            case .error(let error):
                print(error)
            }
        }
    }

    func loadImageDataAsync(url: String) async -> Data? {
        do {
            return  try await LoaderImageLayer.shared.loadAsync(url: url, cache: .off).pngData()
        } catch {
            return nil
        }
    }
}
