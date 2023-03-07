//
//  LoaderImageLayerProxy.swift
//  vk-withoutStoryboard
//
//  Created by Ke4a on 26.06.2022.
//

import UIKit

class LoaderImageLayerProxy: LoaderImage {
    static var shared: LoaderImage = LoaderImageLayerProxy()

    private init() {}

    func loadAsync(url: String, cache: Cache) async throws -> UIImage {
        let image = try await LoaderImageLayer.shared.loadAsync(url: url, cache: cache)
        return image
    }
}
