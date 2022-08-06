//
//  UpdatesRows.swift
//  vk-withoutStoryboard
//
//  Created by Ke4a on 04.08.2022.
//

import Foundation

struct UpdatesIndexsHelper {
    var updateAll: Bool
    var delete: [IndexPath] = []
    var insert: [IndexPath] = []
    var reload: [IndexPath] = []

    var deleteIndexSet: IndexSet {
        IndexSet(delete.map { $0.section })
    }

    var insertIndexSet: IndexSet {
        IndexSet(insert.map { $0.section })
    }

    var reloadIndexSet: IndexSet {
        IndexSet(reload.map { $0.section })
    }

    init(updateAll: Bool = false ) {
        self.updateAll = updateAll
    }
}
