//
//  StartViewController.swift
//  vk-withoutStoryboard
//
//  Created by Ke4a on 07.03.2022.
//

import UIKit

/// Стартовый экран.
///
/// Проверяется работоспособность токена.
final class StartViewController: UIViewController {

    // MARK: - Computed Properties

    private let loadingView: LoadingView = {
        let view = LoadingView(.blue)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    // MARK: - Private Properties

    private let presenter: StartViewOutput

    // MARK: - Initialization

    init(presenter: StartViewOutput) {
        self.presenter = presenter
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        checkToken()
    }

    // MARK: - Setting UI Method

    /// Настройка UI.
    private func setupUI() {
        view.addSubview(loadingView)
        NSLayoutConstraint.activate([
            loadingView.topAnchor.constraint(equalTo: view.topAnchor),
            loadingView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            loadingView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            loadingView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }

    // MARK: - Private Methods

    private func checkToken() {
        presenter.selectScreen()
    }
}

// MARK: - StartViewInput

extension StartViewController: StartViewInput {
    func loadAnimation(_ on: Bool) {
        Task { @MainActor in
            if on {
                self.loadingView.animation(.on)
            } else {
                self.loadingView.animation(.off)
            }
        }
    }
}
