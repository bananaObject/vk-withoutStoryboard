//
//  MyError.swift
//  vk-withoutStoryboard
//
//  Created by Ke4a on 27.05.2022.
//

import Foundation

enum MyError: Error {
    case realmError
    case requestFail
    case decodeError
    case imageError
    case tokenNotValid
}
