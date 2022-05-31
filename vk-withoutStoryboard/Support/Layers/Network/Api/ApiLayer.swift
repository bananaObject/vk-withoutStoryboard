//
//  HTTPClient.swift
//  vk-withoutStoryboard
//
//  Created by Ke4a on 17.05.2022.
//

import Foundation

protocol ApiLayer: RequestBase {
    func sendRequestList<T: ModelApiMark>(
        endpoint: ApiEndpoint,
        responseModel: T.Type
    ) async -> Result<ResponseList<T>, RequestError>
}

extension ApiLayer {
    func sendRequestList<T: ModelApiMark>(
        endpoint: ApiEndpoint,
        responseModel: T.Type
    ) async -> Result<ResponseList<T>, RequestError> {
        do {
            let data = try await requestBase(endpoint: endpoint)
            let decodeResult = try await self.decodeResponse(data: data, decodeModel: T.self)
            return .success(decodeResult)
        } catch let error as RequestError {
            return .failure(error)
        } catch {
            return .failure(.unknown)
        }
    }

    private func decodeResponse<T: ModelApiMark>(data: Data, decodeModel: T.Type) async throws -> ResponseList<T> {
        do {
            let decoder = JSONDecoder()

            let json: [String: Any]? = try JSONSerialization.jsonObject(
                with: data,
                options: .mutableContainers
            ) as? [String: Any]
            let responseJson: [String: Any]? = json?["response"] as? [String: Any]

            // Если запрос новости, то дополнительно приходят профили и группы
            if decodeModel == NewsPostModel.self {
                // Многопоточный парсинг данных.
                let profilesTask = Task<[NewsProfileModel], Error> {
                    let data = try JSONSerialization.data(
                        withJSONObject: responseJson?["profiles"] as Any)
                    return try decoder.decode([NewsProfileModel].self, from: data)
                }

                let groupsTask = Task<[NewsGroupModel], Error> {
                    let data = try JSONSerialization.data(
                        withJSONObject: responseJson?["groups"] as Any)
                    return try decoder.decode([NewsGroupModel].self, from: data)
                }

                let itemsTask = Task<[T], Error> {
                    let data = try JSONSerialization.data(withJSONObject: responseJson?["items"] as Any)
                    return try decoder.decode([T].self, from: data)
                }

                let nextFrom = responseJson?["next_from"] as? String

                let profiles = try await profilesTask.value
                let groups = try await groupsTask.value
                let items = try await itemsTask.value

                return ResponseList(items, profiles, groups, nextFrom)
            } else {
                let itemsTask = Task<[T], Error> {
                    let data = try JSONSerialization.data(withJSONObject: responseJson?["items"] as Any)
                    return try decoder.decode([T].self, from: data)
                }

                let items = try await itemsTask.value
                return ResponseList(items)
            }
        } catch {
            throw RequestError.decode
        }
    }
}
