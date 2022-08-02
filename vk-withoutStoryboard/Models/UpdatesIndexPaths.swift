//
//  UpdateIndexPath.swift
//  vk-withoutStoryboard
//
//  Created by Ke4a on 01.08.2022.
//

import Foundation

struct UpdatesIndexPaths {
    let deleteRows: [IndexPath]
    let insertRows: [IndexPath]
    let reloadRows: [IndexPath]

    init(delete: [IndexPath] = [], insert: [IndexPath] = [], reload: [IndexPath] = []) {
        self.deleteRows = delete
        self.insertRows = insert
        self.reloadRows = reload
    }
}
