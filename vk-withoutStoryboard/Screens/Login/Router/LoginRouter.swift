//
//  LoginRouter.swift
//  vk-withoutStoryboard
//
//  Created by Ke4a on 22.07.2022.
//

import UIKit

protocol LoginRouterInput {
    func openMainScreen()
}

class LoginRouter: LoginRouterInput {
    
    // MARK: - Public Properties

    weak var viewController: UIViewController?

    // MARK: - Public Methods

    func openMainScreen() {
        let controller = ScreenModuleBuilder.mainScreenBuild()
        controller.modalPresentationStyle = .fullScreen
        self.viewController?.present(controller, animated: false, completion: nil)
    }
}
