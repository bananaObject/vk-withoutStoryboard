//
//  LoginInteractor.swift
//  vk-withoutStoryboard
//
//  Created by Ke4a on 22.07.2022.
//

import Foundation
// import Firebase

protocol LoginInteractorInput {
    var urlRequest: URLRequest? { get }
    func saveToken(_ fragment: String)
}

class LoginInteractor: LoginInteractorInput {
    
    // MARK: - Public Methods

    var urlRequest: URLRequest? {
        // Данные для загрузки страницы
        var urlComponents = URLComponents()
        urlComponents.scheme = "https"
        urlComponents.host = "oauth.vk.com"
        urlComponents.path = "/authorize"
        urlComponents.queryItems = [
            URLQueryItem(name: "client_id", value: "8088608"),
            URLQueryItem(name: "display", value: "mobile"),
            URLQueryItem(name: "redirect_uri", value: "https://oauth.vk.com/blank.html"),
            URLQueryItem(name: "scope", value: "offline, friends, photos, groups, wall"),
            URLQueryItem(name: "response_type", value: "token")
        ]

        guard let url = urlComponents.url else { return nil }

        // Загрузка страницы
        return URLRequest(url: url)
    }
/*
    private let ref: DatabaseReference = Database.database().reference(withPath: "Authorized_Id")

    /// Отправка  id авторизированных пользователей в firebase.
    /// - Parameter id: Autorized user id.
    private func firebaseAutorizedId(_ id: String){
        let autorizedId: LoginAutorized = LoginAutorized(id)
        let autorizedRef: DatabaseReference = self.ref.child(autorizedId.userId)
        autorizedRef.setValue(autorizedId.toAnyObject())
    }
*/
    func saveToken(_ fragment: String) {
        // Полученные параметры из ответа WebView
        let params: [String: String] = fragment
            .components(separatedBy: "&")
            .map { $0.components(separatedBy: "=") }
            .reduce([String: String]()) { result, param in
                var dict = result
                let key = param[0]
                let value = param[1]
                dict[key] = value
                return dict
            }

        // Запись токена и id
        if let token: String = params["access_token"], let id: String = params["user_id"] {
            KeychainLayer.shared.set(token, key: .token)
            KeychainLayer.shared.set(id, key: .id)

            // service.firebaseAutorizedId(id)
        }
    }
}
