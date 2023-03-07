//
//  GroupModel.swift
//  vk-withoutStoryboard
//
//  Created by Ke4a on 17.03.2022.
//

import Foundation
import RealmSwift

/// Модель группы для Realm.
final class RLMGroup: Object, Decodable, ModelApiMark {
    @objc dynamic var id: Int = 0
    @objc dynamic var type: String = ""
    @objc dynamic var name: String = ""
    @objc dynamic var screenName: String = ""
    @objc dynamic var photo200: String = ""
    @objc dynamic var isAdmin: Int = 0
    @objc dynamic var isAdvertiser: Int = 0
    @objc dynamic var isClosed: Int = 0
    @objc dynamic var isMember: Int = 0
    @objc dynamic var photo100: String = ""
    @objc dynamic var photo50: String = ""

    private enum CodingKeys: String, CodingKey {
        case id
        case isAdmin = "is_admin"
        case isAdvertiser = "is_advertiser"
        case isClosed = "is_closed"
        case isMember = "is_member"
        case name
        case photo100 = "photo_100"
        case photo200 = "photo_200"
        case photo50 = "photo_50"
        case screenName = "screen_name"
        case type
    }

    override class func primaryKey() -> String? {
        return "id"
    }
    
    static func == (lhs: RLMGroup, rhs: RLMGroup) -> Bool {
        lhs.id == rhs.id &&
        lhs.isAdmin == rhs.isAdmin &&
        lhs.isAdvertiser == rhs.isAdvertiser &&
        lhs.isClosed == rhs.isClosed &&
        lhs.isMember == rhs.isMember &&
        lhs.name == rhs.name &&
        lhs.photo100 == rhs.photo100 &&
        lhs.photo200 == rhs.photo200 &&
        lhs.photo50 == rhs.photo50 &&
        lhs.screenName == rhs.screenName &&
        lhs.type == rhs.type
    }
}
