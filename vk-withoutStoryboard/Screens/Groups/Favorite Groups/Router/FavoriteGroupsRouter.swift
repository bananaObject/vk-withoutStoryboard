//
//  FavoriteGroupsRouter.swift
//  vk-withoutStoryboard
//
//  Created by Ke4a on 01.08.2022.
//

import UIKit

protocol FavoriteGroupsRouterInput {
    func presentCatalogGroupsVC()
}

class FavoriteGroupsRouter: FavoriteGroupsRouterInput {

    // MARK: - Public Properties

    weak var viewController: UIViewController?

    // MARK: - Public Methods

    func presentCatalogGroupsVC() {
        let vc = ScreenModuleBuilder.catalogGroupsScreenBuild()
        viewController?.navigationController?.pushViewController(vc, animated: false)
    }
}
