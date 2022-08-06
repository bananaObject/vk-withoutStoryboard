//
//  FriendModel.swift
//  vk-withoutStoryboard
//
//  Created by Ke4a on 17.03.2022.
//

import Foundation
import RealmSwift
/// Модель друга для Realm.
@objcMembers
final class RLMFriend: Object, Decodable, RealmModel {
    dynamic var id: Int = 0
    dynamic var firstName: String = ""
    dynamic var lastName: String = ""
    dynamic var online: Int = 0
    dynamic var avatar: String = ""
    dynamic var isClosed = false
    dynamic var accessClosed = false
    dynamic var trackCode: String = ""

    enum CodingKeys: String, CodingKey {
        case id
        case firstName = "first_name"
        case lastName = "last_name"
        case online
        case avatar = "photo_100"
        case isClosed = "is_closed"
        case accessClosed = "can_access_closed"
        case trackCode = "track_code"
    }

    // связь 2 вариант
    // var photosModel = List<PhotoModel>()

    /// ключ добавления, не даст добавить повторов
    /// - Returns: строку названием  идентификатора
    override class func primaryKey() -> String? {
        return "id"
    }

    /// индексируемое свойство, получение объекта по свойству.
    /// - Returns: массив параметров
    override class func indexedProperties() -> [String] {
        // Получение данных станет быстрее, запись замедлится.
        // Стараться индексировать по одному полю.
        return ["id"]
    }

    /// игнорирование определенных параметров при записи в базу данных
    /// - Returns: массив параметров которые не будут записаны
    override class func ignoredProperties() -> [String] {
        return ["isClosed", "accessClosed", "trackCode"]
    }
}
