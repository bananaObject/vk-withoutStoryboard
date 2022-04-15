//
//  LetterModel.swift
//  vk-withoutStoryboard
//
//  Created by Ke4a on 20.03.2022.
//

import Foundation
import RealmSwift

/// Модель секции с друзьями для Realm.
@objcMembers class LetterModel: Object{
    @objc dynamic var name: String = ""
    dynamic var items = List<FriendModel>()
    
    override class func primaryKey() -> String? {
        return "name"
    }
}