//
//  ApiVKModel.swift
//  vk-withoutStoryboard
//
//  Created by Ke4a on 27.02.2022.
//

import Foundation

/// Дженерик ответ  сервера.
final class ResponseItem<T: RealmModel>: Decodable {
    let response: T

    private enum CodingKeys: String, CodingKey {
        case response
    }
}

struct ResponseHelper {
    let profiles: [NewsProfileModel]?
    let groups: [NewsGroupModel]?
    let nextFrom: String?

    init( _ profiles: [NewsProfileModel]?, _ groups: [NewsGroupModel]?, _ nextfrom: String? ) {
        self.profiles = profiles
        self.groups = groups
        self.nextFrom = nextfrom
    }
}

/// Дженерик ответ  сервера  api для списка.
final class ResponseList<T: RealmModel> {
    let items: [T]

    var helper: ResponseHelper?

    init(
        _ items: [T],
        _ profiles: [NewsProfileModel]? = nil,
        _ groups: [NewsGroupModel]? = nil,
        _ nextFrom: String? = nil
    ) {
        self.items = items

        if profiles == nil, groups == nil {
            helper = nil
        } else {
            helper = ResponseHelper(profiles, groups, nextFrom)
        }
    }
}
