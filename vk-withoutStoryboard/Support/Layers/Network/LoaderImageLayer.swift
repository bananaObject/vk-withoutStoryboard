//
//  LoaderImageLayer.swift
//  vk-withoutStoryboard
//
//  Created by Ke4a on 08.03.2022.
//

import UIKit

protocol LoaderImage {
    static var shared: LoaderImage { get }
    func loadAsync(url: String, cache: Cache) async throws -> UIImage
}

// перечисление режимов работы кэширования
enum Cache {
    case fileCache
    case nsCache
    case off
}

/// Singleton для загрузки изображения  с возможностью кеширования.
final class LoaderImageLayer {
    // MARK: - Private Properties
    private let cacheFileImage = PhotoFileCacheLayer()
    private let cacheNSImage = PhotoNSCacheLayer(limit: 40)

    private let httpSession = URLSession(configuration: URLSessionConfiguration.default)

    // MARK: - Static Properties
    ///  Singleton
    static var shared = LoaderImageLayer()

    // MARK: - Private Initializers
    private init() {}

    // MARK: - Public Methods
    /// Загрузка изображения по url адресу с возможным кэшированием и получение изображения из кэша.
    /// - Parameters:
    ///   - url: Url адрес изображения.
    ///   - cache: режим  кэширования.
    ///
    ///  По умолчанию кэширование изображение отключено.
    func loadAsync(url: String, cache: Cache) async throws -> UIImage {
        // Проверяем url
        guard let url = URL(string: url) else {
            throw RequestError.invalidURL
        }

        var image: UIImage

        // если кэширование включено, проверяем есть ли изобюражение в кэше
        switch cache {
        case .fileCache:
            if let imageCache = cacheFileImage.images[url.absoluteString] {
                image = imageCache
            } else if let imageCache: UIImage = cacheFileImage.getImage(for: url) {
                image = imageCache
            }
        case .nsCache:
            if let imageCache: UIImage = cacheNSImage.getImage(for: url.absoluteURL) {
                // если есть отдаем фото из кэша
                image = imageCache
            }
        case .off:
            break
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"

        let (data, response) = try await URLSession.shared.data(for: request, delegate: nil)

        guard let response = response as? HTTPURLResponse else {
            throw RequestError.noResponse
        }

        switch response.statusCode {
        case 200...299:
            guard let imageResponse = UIImage(data: data) else { throw MyError.imageError }
            image = imageResponse
        case 401:
            throw RequestError.unauthorized
        default:
            throw RequestError.unexpectedStatusCode
        }

        return image
    }
}
