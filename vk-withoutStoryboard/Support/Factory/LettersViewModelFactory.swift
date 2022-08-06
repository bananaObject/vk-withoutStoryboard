//
//  LettersViewModelFactory.swift
//  vk-withoutStoryboard
//
//  Created by Ke4a on 05.08.2022.
//

import Foundation

class LettersViewModelFactory {
    lazy var friendFactory = FriendsViewModelFactory()

    func constructViewModels(from letters: [RLMLetter]) -> [LetterViewModel] {
        return letters.compactMap { getViewModel(from: $0) }
    }

    func getViewModel(from letter: RLMLetter) -> LetterViewModel {
        let friends: [FriendViewModel] = friendFactory.constructViewModels(from: Array(letter.items))
        
        return LetterViewModel(name: letter.name, items: friends)
    }
}
