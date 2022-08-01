//
//  StartPresenter.swift
//  vk-withoutStoryboard
//
//  Created by Ke4a on 22.07.2022.
//

import UIKit

protocol StartViewInput {
    func loadAnimation(_ on: Bool)
}

protocol StartViewOutput {
    func selectScreen()
}

class StartPresenter {
    
    // MARK: - Public Properties

    weak var viewInput: (UIViewController & StartViewInput)?

    // MARK: - Private Properties

    private let interactor: StartInteractorInput
    private let router: StartRouterInput

    // MARK: - Initialization

    init(_ interactor: StartInteractorInput, _ router: StartRouterInput) {
        self.interactor = interactor
        self.router = router
    }

    // MARK: - Public Methods

    private func checkToken() {
        Task { @MainActor in
            do {
                let tokenIsValid = try await interactor.checkToken()
                
                if tokenIsValid {
                    router.openMainScreen()
                } else {
                    router.openLoginScreen()
                }
            } catch {
                print(error)
                router.openLoginScreen()
            }
            viewInput?.loadAnimation(false)
        }
    }
}

extension StartPresenter: StartViewOutput {
    func selectScreen() {
        viewInput?.loadAnimation(true)
        checkToken()
    }
}
