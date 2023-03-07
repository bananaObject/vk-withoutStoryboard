//
//  CatalogGroupsRouter.swift
//  vk-withoutStoryboard
//
//  Created by Ke4a on 23.07.2022.
//

import UIKit

protocol CatalogGroupsRouterInput {
    func popViewController()
}

class CatalogGroupsRouter: CatalogGroupsRouterInput {

    // MARK: - Public Properties
    
    weak var viewController: UIViewController?

    // MARK: - Public Methods

    func popViewController() {
        viewController?.navigationController?.popViewController(animated: true)
    }
}
