//
//  StartInteractor.swift
//  vk-withoutStoryboard
//
//  Created by Ke4a on 22.07.2022.
//

import Foundation

protocol StartInteractorInput {
    func checkTokenAsync() async throws
}

class StartInteractor: RequestBase {

    // MARK: - Private Methods

    private func requestCheckTokenAsync() async throws -> Bool {
        let data = try await requestBase(endpoint: .getUser)

        let json: [String: Any]? = try JSONSerialization.jsonObject(
            with: data,
            options: .mutableContainers
        ) as? [String: Any]

        let result = json?.keys.contains("response") ?? false

        return result
    }
}

// MARK: - StartInteractorInput

extension StartInteractor: StartInteractorInput {

    // MARK: - Public Methods

    func checkTokenAsync() async throws {
        let tokenIsValid = try await requestCheckTokenAsync()

        if !tokenIsValid {
            throw MyError.tokenNotValid
        }
    }
}
