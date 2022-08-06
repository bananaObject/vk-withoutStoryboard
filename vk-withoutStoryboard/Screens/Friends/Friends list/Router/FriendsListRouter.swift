//
//  FriendsListRouter.swift
//  vk-withoutStoryboard
//
//  Created by Ke4a on 02.08.2022.
//

import UIKit

protocol FriendsListRouterInput {
    func presentFriendPhotosVC(_ friend: RLMFriend)
}

class FriendsListRouter: FriendsListRouterInput {
    weak var viewController: UIViewController?

    func presentFriendPhotosVC(_ friend: RLMFriend) {
        let vc = ScreenModuleBuilder.friendPhotosScreenBuild()
        viewController?.navigationController?.pushViewController(vc, animated: true)
    }
}
