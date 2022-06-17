//
//  FriendsTableViewCell.swift
//  firstApp-withoutStoryboard
//
//  Created by Ke4a on 30.01.2022.
//

import UIKit

/// Ячейка таблицы FriendsViewController.
final class FriendsTableViewCell: UITableViewCell {
    // MARK: - Private Properties
    private let fullNameLabel: UILabel = {
        let text = UILabel()
        text.translatesAutoresizingMaskIntoConstraints = false
        text.backgroundColor = .white
        return text
    }()

    private let avatarView: AvatarView = {
        let imageView = AvatarView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    // MARK: - Static Properties
    static var identifier: String = "FriendsTableViewCell"

    // MARK: - Initializers
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Prepare For Reuse
    override func prepareForReuse() {
        super.prepareForReuse()
        fullNameLabel.text = nil
        avatarView.prepareForReuse()
    }

    // MARK: - Public Methods
    /// Конфигурация ячейки.
    /// - Parameter friend: Друг.
    func configure(friend: RLMFriend) {
        fullNameLabel.text = "\(friend.firstName) \(friend.lastName)"
        avatarView.loadImage(friend.avatar)
    }

    // MARK: - Setting UI Method
    /// Настройка Ui.
    private func setupUI() {
        contentView.addSubview(avatarView)
        let topConstraint: NSLayoutConstraint = avatarView.topAnchor.constraint(
            equalTo: contentView.topAnchor,
            constant: 4)
        topConstraint.priority = UILayoutPriority(rawValue: 999)
        let bottomConstraint: NSLayoutConstraint = avatarView.bottomAnchor.constraint(
            equalTo: contentView.bottomAnchor,
            constant: -4)
        bottomConstraint.priority = UILayoutPriority(rawValue: 999)

        NSLayoutConstraint.activate([
            avatarView.widthAnchor.constraint(equalToConstant: 82),
            avatarView.heightAnchor.constraint(equalToConstant: 82),
            topConstraint,
            bottomConstraint,
            avatarView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            avatarView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])

        contentView.addSubview(fullNameLabel)
        NSLayoutConstraint.activate([
            fullNameLabel.leadingAnchor.constraint(equalTo: avatarView.trailingAnchor, constant: 8),
            fullNameLabel.centerYAnchor.constraint(equalTo: avatarView.centerYAnchor),
            fullNameLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16)
        ])
    }
}
