//
//  LoaderImageLayerProxy.swift
//  vk-withoutStoryboard
//
//  Created by Ke4a on 26.06.2022.
//

import Foundation
import UIKit

class LoaderImageLayerProxy:LoaderImage {
    static var shared: LoaderImage = LoaderImageLayerProxy()

    private init() {}

    func loadAsync(url: String, cache: Cache) async throws -> UIImage {
        print("load image url: \(url)")
        if let image = try await LoaderImageLayer.shared.loadAsync(url: url, cache: cache) as? UIImage {
            return image
        } else {
            return UIImage()
        }
    }
}
