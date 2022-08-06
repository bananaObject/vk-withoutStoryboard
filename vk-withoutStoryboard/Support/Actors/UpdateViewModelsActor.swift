//
//  UpdateViewModelsActor.swift
//  vk-withoutStoryboard
//
//  Created by Ke4a on 04.08.2022.
//

import Foundation

actor UpdateViewModelsActor<T: ViewModel> {
    var models = UpdateViewModelsHelper<T>()
    var indexs = UpdatesIndexsHelper()

    enum Update {
        case insert
        case delete
        case reload
    }

    func append(_ indeces: [IndexPath], to: Update) {
        switch to {
        case .reload:
            indexs.reload += indeces
        case .delete:
            indexs.delete += indeces
        case .insert:
            indexs.insert += indeces
        }
    }

    func append(_ viewModels: [T], to: Update) {
        switch to {
        case .reload:
            models.reload += viewModels
        case .insert:
            models.insert += viewModels
        case .delete:
            break
        }
    }
}
