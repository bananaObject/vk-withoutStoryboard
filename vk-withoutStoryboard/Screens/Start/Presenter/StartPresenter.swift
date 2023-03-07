//
//  StartPresenter.swift
//  vk-withoutStoryboard
//
//  Created by Ke4a on 22.07.2022.
//

import UIKit

protocol StartViewInput {
    func loadingAnimation(_ on: Bool)
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

    private func checkTokenAsync() {
        Task(priority: .background) {
            do {
                try await interactor.checkTokenAsync()

                await MainActor.run {
                    router.openMainScreen()
                }
            } catch {
                print(error)

                await MainActor.run {
                    router.openLoginScreen()
                }
            }

            await MainActor.run {
                viewInput?.loadingAnimation(false)
            }
        }
    }
}

extension StartPresenter: StartViewOutput {
    func selectScreen() {
        viewInput?.loadingAnimation(true)
        checkTokenAsync()
    }
}
