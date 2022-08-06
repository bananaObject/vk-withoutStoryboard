//
//  PhotoModel.swift
//  vk-withoutStoryboard
//
//  Created by Ke4a on 17.03.2022.
//

import RealmSwift
import UIKit

final class Size: Object, Decodable {
    @objc dynamic var height: Int
    @objc dynamic var url: String
    @objc dynamic var type: String
    @objc dynamic var width: Int

    // вычисляемый параметр aspectRatio для фото
    var aspectRatio: CGFloat { return CGFloat(height) / CGFloat(width) }

    override class func primaryKey() -> String? {
        return "url"
    }
}

/// Модель фото для Realm.
final class RLMPhoto: Object, Decodable, RealmModel {
    @objc dynamic var id: Int = 0
    @objc dynamic var ownerId: Int = 0
    @objc dynamic var text: String = ""
    @objc dynamic var date = Date()
    @objc dynamic var albumId: Int = 0
    dynamic var sizes = List<Size>()
    @objc dynamic var hasTags = false

    private enum CodingKeys: String, CodingKey {
        case albumId = "album_id"
        case date
        case id
        case ownerId = "owner_id"
        case sizes
        case text
        case hasTags = "has_tags"
    }

    override class func primaryKey() -> String? {
        return "id"
    }

    override class func ignoredProperties() -> [String] {
        return ["albumId"]
    }

    // связь 1 вариант
    @objc dynamic var owner: RLMFriend?

    // связь 2 вариант
    // автоматически линкует при дабавление в список у хозяина через append
    // let owner = LinkingObjects(fromType:FriendModel.self, property: "photos")
}
