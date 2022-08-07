//
//  UpdatesViewModelsHelper.swift
//  vk-withoutStoryboard
//
//  Created by Ke4a on 01.08.2022.
//

import Foundation

struct UpdatesViewModelsHelper<T: ViewModel> {
    var updateAll: [T] = []
    var reload: [T] = []
    var insert: [T] = []
}
