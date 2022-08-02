//
//  GroupsViewModelFactory.swift
//  vk-withoutStoryboard
//
//  Created by Ke4a on 17.06.2022.
//

import Foundation

class GroupsViewModelFactory {
    func constructViewModels(from groups: [RLMGroup]) -> [GroupViewModel] {
        return groups.compactMap { getViewModel(from: $0) }
    }

    private func getViewModel(from group: RLMGroup) -> GroupViewModel {
        return GroupViewModel(
            id: group.id,
            type: group.type,
            name: group.name,
            screenName: group.screenName,
            photo200: group.photo200)
    }
}
