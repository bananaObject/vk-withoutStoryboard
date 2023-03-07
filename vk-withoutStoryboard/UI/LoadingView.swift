//
//  LoadingView.swift
//  vk-withoutStoryboard
//
//  Created by Ke4a on 07.02.2022.
//

import UIKit

// MARK: - Extension
extension LoadingView {
    enum Color {
        case blue
        case white
    }

    // MARK: - DotLabel
    fileprivate class DotLabel: UILabel {
        override init(frame: CGRect) {
            super.init(frame: frame)
            translatesAutoresizingMaskIntoConstraints = false
            font = UIFont.systemFont(ofSize: 16)
            text = "●"
        }

        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }
}

/// View анимация загрузки.
///
///  Анимация - Три точки.
final class LoadingView: UIView {
    // MARK: - Private Properties
    private let dot1 = DotLabel()
    private let dot2 = DotLabel()
    private let dot3 = DotLabel()

    private var dotArray: [DotLabel] {
        [dot1, dot2, dot3]
    }

    // MARK: - Initializers
    /// Кастомный init. Выбор фона для анимации.
    /// - Parameter background: цвет фона
    init(_ backgroundColor: Color = .white) {
        super.init(frame: .zero)
        setupUI(backgroundColor)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Setting UI Method
    /// Настройка view.
    /// - Parameter color: цвет фона.
    private func setupUI(_ color: Color) {
        self.isHidden = true

        let dotColor: UIColor
        let backgroundColor: UIColor

        switch color {
        case .blue:
            dotColor = .white
            backgroundColor = .vkColor
        case .white:
            dotColor = .vkColor
            backgroundColor = .white
        }

        self.backgroundColor = backgroundColor

        dotArray.forEach { dot in
            dot.textColor = dotColor
            addSubview(dot)
        }

        NSLayoutConstraint.activate([
            dot1.centerYAnchor.constraint(equalTo: centerYAnchor),
            dot2.centerYAnchor.constraint(equalTo: centerYAnchor),
            dot3.centerYAnchor.constraint(equalTo: centerYAnchor),

            dot2.centerXAnchor.constraint(equalTo: centerXAnchor),
            dot1.trailingAnchor.constraint(equalTo: dot2.leadingAnchor, constant: -2),
            dot3.leadingAnchor.constraint(equalTo: dot2.trailingAnchor, constant: 2)
        ])
    }

    // MARK: - Public Methods
    /// Запуск анимации.
    /// - Parameter work: вкл/выкл.
    func animation(_ work: Bool) {
        switch work {
        case true:
            self.isHidden = false

            var delay: Double = 0

            dotArray.forEach { dot in
                UIView.animate(withDuration: 0.4, delay: delay, options: [.repeat, .autoreverse]) {
                    dot.alpha = 0
                }

                delay += 0.2
            }
        case false:
            self.isHidden = true

            dotArray.forEach { dot in
                dot.layer.removeAllAnimations()
                dot.alpha = 1
            }
        }
    }
}
