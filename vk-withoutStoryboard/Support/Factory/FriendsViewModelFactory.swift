//
//  FriendsViewModelFactory.swift
//  vk-withoutStoryboard
//
//  Created by Ke4a on 03.08.2022.
//

import Foundation

class FriendsViewModelFactory {
    func constructViewModels(from groups: [RLMFriend]) -> [FriendViewModel] {
        return groups.compactMap { getViewModel(from: $0) }
    }

    private func getViewModel(from friend: RLMFriend) -> FriendViewModel {
        return FriendViewModel(id: friend.id,
                               firstName: friend.firstName,
                               lastName: friend.lastName,
                               avatar: friend.avatar)
    }
}
