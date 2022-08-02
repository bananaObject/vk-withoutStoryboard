//
//  ScreenModuleBuilder.swift
//  vk-withoutStoryboard
//
//  Created by Ke4a on 22.07.2022.
//

import UIKit

class ScreenModuleBuilder {
    
    // MARK: - Static Methods

    static func startScreenBuild() -> (UIViewController & StartViewInput) {
        let interactor = StartInteractor()
        let router = StartRouter()
        let presenter = StartPresenter(interactor, router)

        let viewController = StartViewController(presenter: presenter)

        router.viewController = viewController
        presenter.viewInput = viewController

        return viewController
    }

    static func loginScreenBuild() -> (UIViewController & LoginViewInput) {
        let interactor = LoginInteractor()
        let router = LoginRouter()
        let presenter = LoginPresenter(interactor, router)

        let viewController = LoginViewController(presenter: presenter)

        router.viewController = viewController
        presenter.viewInput = viewController

        return viewController
    }

    static func mainScreenBuild() -> UIViewController {
        let viewController = TabBarViewController()
        return viewController
    }

    static func favoriteGroupsScreenBuild() -> (UIViewController & FavoriteGroupsViewInput) {
        let api = Api()

        let realm = RealmLayer()

        let interactor = FavoriteGroupsInteractor(api, realm)
        let router = FavoriteGroupsRouter()
        let presenter = FavoriteGroupsPresenter(interactor, router)

        interactor.presenter = presenter

        let viewController = FavoriteGroupsViewController(presenter)

        router.viewController = viewController
        presenter.viewInput = viewController

        return viewController
    }

    static func catalogGroupsScreenBuild() -> (UIViewController & CatalogGroupsViewInput) {
        let api = Api()

        let interactor = CatalogGroupsInteractor(api)
        let router = CatalogGroupsRouter()
        let presenter = CatalogGroupsPresenter(interactor, router)

        let viewController = CatalogGroupsViewController(presenter: presenter)

        router.viewController = viewController
        presenter.viewInput = viewController

        return viewController
    }
}
