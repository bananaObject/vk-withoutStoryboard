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

    private lazy var loadingView: LoadingView = {
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
        presenter.selectScreen()
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
}

// MARK: - StartViewInput

extension StartViewController: StartViewInput {
    func loadingAnimation(_ on: Bool) {
        self.loadingView.animation(on)
    }
}
