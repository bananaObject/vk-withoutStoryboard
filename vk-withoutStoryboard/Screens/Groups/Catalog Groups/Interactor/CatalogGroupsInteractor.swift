//
//  CatalogGroupsInteractor.swift
//  vk-withoutStoryboard
//
//  Created by Ke4a on 23.07.2022.
//

import UIKit
// import Firebase

protocol CatalogGroupsInteractorInput {
    var searchText: String { get set }
    func requestGroupsAsync() async throws -> [RLMGroup]
    func convertToViewModels(_ rmls: [RLMGroup]) -> [GroupViewModel]
    func loadImageDataAsync(url: String) async -> Data?
    // func firebaseSelectGroup(_ selectGroup: GroupModel)
}

class CatalogGroupsInteractor: CatalogGroupsInteractorInput {

    // MARK: - Public Properties

    var searchText = ""

    // MARK: - Private Properties

    private let groupsFactory = GroupsViewModelFactory()

    /// Firebase.
    // private let ref: DatabaseReference = Database.database().reference(withPath: "Groups")

    private let network: ApiLayer

    // MARK: - Initialization

    init(_ apiLayer: ApiLayer ) {
        self.network = apiLayer
    }

    // MARK: - Public Methods

    /// Запрос каталога групп из api.
    /// - Parameters:
    ///   - searchText: Поиск группы по названию, по умолчанию nil.
    func requestGroupsAsync() async throws -> [RLMGroup] {
        let result: Result<ResponseList<RLMGroup>, RequestError>

        if searchText.isEmpty {
            // Получение каталога групп
            result = await self.network.sendRequestList(
                endpoint: ApiEndpoint.getCatalogGroups,
                responseModel: RLMGroup.self)
        } else {
            result = await self.network.sendRequestList(
                endpoint: ApiEndpoint.getSearchGroup(searchText: searchText),
                responseModel: RLMGroup.self)
        }

        // Поиск определенных групп по ключевому слову
        switch result {
        case .success(let response):
            return response.items
        case .failure(let error):
            print(error)
            throw error
        }
    }

    func convertToViewModels(_ rmls: [RLMGroup]) -> [GroupViewModel] {
        return groupsFactory.constructViewModels(from: rmls)
    }
    
    /// Отправка названия выбранной группы пользователя  в firebase.
    /// - Parameter selectGroup: Выбранная группа.
    //    private func firebaseSelectGroup(_ selectGroup: GroupModel){
    //        //  Id пользователя
    //        guard let id: String = Keychain.shared.get(.id) else { return }
    //
    //        // Получение данных по id пользователя, отправка id и название группы
    //        ref.child(id).getData { error, snapshot in
    //            var groups: [String : String]? = snapshot.value as? [String:String]
    //            groups?[String(selectGroup.id)] = selectGroup.name
    //            let groupsRef: DatabaseReference = self.ref.child(id)
    //            groupsRef.setValue(groups)
    //        }
    //    }

    func loadImageDataAsync(url: String) async -> Data? {
        do {
            return  try await LoaderImageLayer.shared.loadAsync(url: url, cache: .off).pngData()
        } catch {
            return nil
        }
    }
}
