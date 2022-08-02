//
//  TabBarViewController.swift
//  firstApp-withoutStoryboard
//
//  Created by Ke4a on 27.01.2022.
//

import UIKit

final class TabBarViewController: UITabBarController {
    // MARK: - Private Properties
    private let friendsScreen: UIViewController = {
        let image = UIImage(systemName: "person.3.sequence")
        let imageFill = UIImage(systemName: "person.3.fill")
        let tarBarItem = UITabBarItem(title: "Friends", image: image, selectedImage: imageFill)

        let viewController = UINavigationController(rootViewController: FriendsViewController())
        viewController.view.backgroundColor = .white
        viewController.tabBarItem = tarBarItem
        return viewController
    }()

    private let groupsScreen: UIViewController = {
        let image = UIImage(systemName: "crown")
        let imageFill = UIImage(systemName: "crown.fill")
        let tarBarItem = UITabBarItem(title: "Groups", image: image, selectedImage: imageFill)

        let viewController = UINavigationController(rootViewController: ScreenModuleBuilder.favoriteGroupsScreenBuild())
        viewController.view.backgroundColor = .white
        viewController.tabBarItem = tarBarItem
        return viewController
    }()

    private let newsScreen: UIViewController = {
        let image = UIImage(systemName: "newspaper")
        let imageFill = UIImage(systemName: "newspaper.fill")
        let tarBarItem = UITabBarItem(title: "News", image: image, selectedImage: imageFill)

        let viewController = UINavigationController(rootViewController: NewsTableViewController())
        viewController.view.backgroundColor = .white
        viewController.tabBarItem = tarBarItem
        return viewController
    }()

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }

    // MARK: - Setting UI Method
    /// Настройка UI.
    private func setupUI() {
        tabBar.tintColor = .vkColor
        tabBar.backgroundColor = .white
        viewControllers = [friendsScreen, newsScreen, groupsScreen]
    }
}
