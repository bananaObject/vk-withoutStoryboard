//
//  LoginViewController.swift
//  vk-withoutStoryboard
//
//  Created by Ke4a on 25.02.2022.
//

import UIKit
import WebKit

/// Экран авторизации пользователя.
final class LoginViewController: UIViewController {

    // MARK: - Visual Components

    fileprivate lazy var logoImage: UIImageView = {
        let nameImage = "vkLogo"
        let image: UIImage? = UIImage(named: nameImage)
        let imageView = UIImageView(image: image)
        imageView.tintColor = .white
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    fileprivate lazy var loginButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Войти", for: .normal)
        button.layer.cornerRadius = 5
        button.backgroundColor = .tertiarySystemBackground
        button.tintColor = .vkColor
        button.addTarget(self, action: #selector(loginButtonActions), for: .touchUpInside)
        return button
    }()
    
    fileprivate lazy var webView: WKWebView = {
        let webConfiguration = WKWebViewConfiguration()
        let view = WKWebView(frame: .zero, configuration: webConfiguration)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    // MARK: - Private Properties

    fileprivate let presenter: LoginViewOutput

    // MARK: - Initialization

    init(presenter: LoginViewOutput) {
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
        webView.navigationDelegate = self
    }

    // MARK: - Setting UI Method

    /// Setting UI.
    private func setupUI() {
        view.backgroundColor = .vkColor
        
        view.addSubview(logoImage)
        NSLayoutConstraint.activate([
            logoImage.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])

        view.addSubview(loginButton)
        NSLayoutConstraint.activate([
            loginButton.topAnchor.constraint(equalTo: logoImage.bottomAnchor, constant: 20),
            loginButton.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            loginButton.heightAnchor.constraint(equalToConstant: 50),
            loginButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 10),
            loginButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -10)
        ])
    }
    /// Setting  WebView.
    private func setupWebView() {
        // удаление лого и кнопки
        logoImage.removeFromSuperview()
        loginButton.removeFromSuperview()

        view.backgroundColor = .white
        view.addSubview(webView)
        NSLayoutConstraint.activate([
            webView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            webView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            webView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            webView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor)
        ])
    }
    
    // MARK: - Actions

    @objc private  func loginButtonActions() {
        setupWebView()
        presenter.viewDidLoadWebView()
    }
}

// MARK: - WebViewDelegate

extension LoginViewController: WKNavigationDelegate {
    func webView(
        _ webView: WKWebView,
        decidePolicyFor navigationResponse: WKNavigationResponse,
        decisionHandler: @escaping (WKNavigationResponsePolicy) -> Void
    ) {
        guard let url: URL = navigationResponse.response.url, url.path == "/blank.html",
              let fragment = url.fragment else {
            decisionHandler(.allow)
            return
        }
        
        decisionHandler(.cancel)

        presenter.saveToken(fragment)
        presenter.openMainScreen()
    }
}

// MARK: - LoginViewInput

extension LoginViewController: LoginViewInput {
    /// Launching WebView on the VKontakte login page.
    /// - Parameter request: URLRequest
    func loadWebView(_ request: URLRequest) {
        webView.load(request)
    }
}
