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

protocol FavoriteGroupsInteractorOutput: AnyObject {
    func updateViewModels(_ models: UpdateViewModelsHelper<GroupViewModel>, _ index: UpdatesIndexsHelper)
}

class FavoriteGroupsInteractor {

    // MARK: - Public Properties

    weak var presenter: FavoriteGroupsInteractorOutput?

    var searchText: String = "" {
        didSet {
            let models = constructViewModels(RMLData)

            let update = UpdateViewModelsHelper(updateAll: models)
            let index = UpdatesIndexsHelper(updateAll: true)

            presenter?.updateViewModels(update, index)
        }
    }

    // MARK: - Private Properties

    private var RMLData: Results<RLMGroup> {
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

    // MARK: - Private Methods

    private func constructViewModels(_ rmls: Results<RLMGroup>) -> [GroupViewModel] {
        let result = Array(rmls)
        return groupsFactory.constructViewModels(from: result)
    }

    private func getViewModel(_ rml: RLMGroup) -> GroupViewModel {
        groupsFactory.getViewModel(from: rml)
    }
}

extension FavoriteGroupsInteractor: FavoriteGroupsInteractorInput {
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

    func saveInRealm(_ newGroups: [RLMGroup]) {
        // Groups that the user left or the group data was updated, but they are still present in the database
        let oldValues: [RLMGroup] = self.realm.read(RLMGroup.self).filter { oldGroup in
            return !newGroups.contains(where: { $0.id == oldGroup.id })
        }

        // Deleting groups the user has logged out of or the group data was updated
        if !oldValues.isEmpty {
            self.realm.delete(objects: oldValues)
        }

        // Adding new groups or updating data of old groups
        self.realm.create(objects: newGroups)
    }

    func deleteInRealm(_ group: GroupViewModel) {
        guard let group = RMLData.first(where: { $0.id == group.id }) else { return }
        realm.delete(object: group)
    }

    func createNotificationToken() {
        // Subscription to db changes
        // You can also subscribe to changes to a specific object
        notificationToken = RMLData.observe { result in
            switch result {
                // At initialization
            case .initial(let RLMGroups):
                let viewModels = self.constructViewModels(RLMGroups)

                let update = UpdateViewModelsHelper(updateAll: viewModels)
                let index = UpdatesIndexsHelper(updateAll: true)

                self.presenter?.updateViewModels(update, index)
                // At changes db
            case .update(let RLMGroups,
                         let deletions,
                         let insertions,
                         let modifications):
#warning("Иправить ошибку при использование вместе поиска и удаление ячейки")
#warning("Иправить баг что добавляется новая группа в конец списка")
                Task { @MainActor in
                    let actor = UpdateViewModelsActor<GroupViewModel>()
                    let RLMs = Array(RLMGroups)
                    // concurrent processing
                    await withTaskGroup(of: Void.self) { group in
                        if !deletions.isEmpty {
                            group.addTask(priority: .background) {
                                let indeces = deletions.map { IndexPath(row: $0, section: 0) }
                                await actor.append(indeces, to: .delete)
                            }
                        }

                        if !insertions.isEmpty {
                            group.addTask { @MainActor in
                                var groups: [GroupViewModel] = []

                                let indeces: [IndexPath] = insertions.map { index in
                                    let group = self.getViewModel(RLMs[index])
                                    groups.append(group)

                                    return IndexPath(row: index, section: 0)
                                }

                                await actor.append(indeces, to: .insert)
                                await actor.append(groups, to: .insert)
                            }
                        }

                        if !modifications.isEmpty {
                            group.addTask { @MainActor in
                                var groups: [GroupViewModel] = []

                                let indeces: [IndexPath] = modifications.map { index in
                                    let group = self.getViewModel(RLMs[index])
                                    groups.append(group)

                                    return IndexPath(row: index, section: 0)
                                }

                                await actor.append(indeces, to: .reload)
                                await actor.append(groups, to: .reload)
                            }
                        }
                    }
                    await self.presenter?.updateViewModels(actor.models, actor.indexs)
                }
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
