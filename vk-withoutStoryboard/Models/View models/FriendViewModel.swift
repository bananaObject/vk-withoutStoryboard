//
//  FriendViewModel.swift
//  vk-withoutStoryboard
//
//  Created by Ke4a on 03.08.2022.
//

import Foundation

struct FriendViewModel: ViewModel {
    let id: Int
    let firstName: String
    let lastName: String
    let avatar: String
    var imageData: Data?
}
