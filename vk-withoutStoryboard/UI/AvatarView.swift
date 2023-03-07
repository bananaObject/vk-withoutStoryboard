//
//  AvatarView.swift
//  vk-withoutStoryboard
//
//  Created by Ke4a on 01.02.2022.
//

import PromiseKit
import UIKit

/// View аватар друга.
final class AvatarView: UIView {
    // MARK: - Private Properties
    private var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    // MARK: - Initializers
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        addGestureRecognizer()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Setting UI Method
    /// Настройка UI.
    private func setupUI() {
        addSubview(imageView)

        imageView.contentMode = .scaleAspectFit
        imageView.isUserInteractionEnabled = true
        imageView.backgroundColor = .white
        // Обрезание изображения за пределами слоя
        imageView.clipsToBounds = true
        layer.borderWidth = 1
        layer.borderColor = UIColor.vkColor.cgColor
        // Кастомизация аватарки
        layer.shadowColor = UIColor.gray.cgColor
        layer.shadowOffset = CGSize(width: 3, height: 3)
        layer.shadowRadius = 3
        layer.shadowOpacity = 0.5
    }

    /// Размер слоя для обрезания изображения.
    override func layoutSubviews() {
        super.layoutSubviews()

        let radius = frame.size.width / 2
        layer.cornerRadius = radius
        imageView.layer.cornerRadius = radius
        imageView.frame = bounds
    }

    // MARK: - Prepare For Reuse
    /// Сброс текста при Reuse.
    func prepareForReuse() {
        imageView.image = nil
    }

    // MARK: - Public Methods
    /// Получение изображения по url.
    /// - Parameter url: Адрес изображения.
    ///
    /// Включено повтороное получение изображение из кэша
    func loadImage(_ url: String) {
        Task(priority: .background) {
            do {
                self.imageView.image = try await LoaderImageLayerProxy.shared.loadAsync(url: url, cache: .fileCache)
            } catch {
                print(error)
            }
        }
    }

    // MARK: - Private Methods
    /// Добавление действия на тап по аватару.
    private func addGestureRecognizer() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(clickAnimation))
        imageView.addGestureRecognizer(tap)
    }

    /// Promise animation
    ///  Чтоб исправить callback hell
    /// - Parameter translationX: увеличение
    private func animationContinuation(translationX: CGFloat) async {
        return await withCheckedContinuation { continuation in
            UIView.animate(
                withDuration: 0.3,
                delay: 0,
                usingSpringWithDamping: 0,
                initialSpringVelocity: 0.7,
                options: [.autoreverse ]) {
                self.transform = CGAffineTransform(translationX: translationX, y: 0)
            } completion: { _ in
                self.transform = .identity
                continuation.resume()
            }
        }
    }

    // MARK: - Actions
    /// Анимация аватара.
    @objc private func clickAnimation() {
        Task(priority: .utility) {
            await self.animationContinuation(translationX: 1)
            await self.animationContinuation(translationX: -1)
        }
    }
}
