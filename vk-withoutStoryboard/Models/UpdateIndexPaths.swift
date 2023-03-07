//
//  UpdateIndexPaths.swift
//  vk-withoutStoryboard
//
//  Created by Ke4a on 04.08.2022.
//

import Foundation

actor RealmUpdateActor {
    var update = UpdateViewModels()
    var indexPath = UpdateIndexPaths()

    enum Row {
        case insert
        case delete
        case reload
    }

    func append(_ indeces: [IndexPath], row: Row) {
        switch row {
        case .reload:
            indexPath.reloadRows = indeces
        case .delete:
            indexPath.deleteRows = indeces
        case .insert:
            indexPath.insertRows = indeces
        }
    }

    func append(_ groups: [GroupViewModel], row: Row) {
        switch row {
        case .reload:
            update.reload = groups
        case .delete:
            break
        case .insert:
            update.insert = groups
        }
    }
}

struct UpdateIndexPaths {
    var updateAll: Bool
    var deleteRows: [IndexPath] = []
    var insertRows: [IndexPath] = []
    var reloadRows: [IndexPath] = []

    init(updateAll: Bool = false ) {
        self.updateAll = updateAll
    }
}
