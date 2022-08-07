//
//  GroupTableViewCell.swift
//  vk-withoutStoryboard
//
//  Created by Ke4a on 31.01.2022.
//

import UIKit

final class GroupTableViewCell: UITableViewCell {
    // MARK: - Visual Components

    private lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.backgroundColor = .white
        label.numberOfLines = 0
        return label
    }()

    private lazy var groupImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    // MARK: - Static Properties

    static let identifier = "GroupTableViewCell"

    // MARK: - Initialization

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Prepare For Reuse

    override func prepareForReuse() {
        super.prepareForReuse()
        nameLabel.text = nil
        groupImageView.image = nil
    }

    // MARK: - Setting UI Methods

    /// Setting UI
    private func setupUI() {
        contentView.addSubview(groupImageView)

        let topConstraint: NSLayoutConstraint = groupImageView.topAnchor.constraint(
            equalTo: contentView.topAnchor,
            constant: 4)
        topConstraint.priority = UILayoutPriority(rawValue: 999)
        let bottomConstraint: NSLayoutConstraint = groupImageView.bottomAnchor.constraint(
            equalTo: contentView.bottomAnchor,
            constant: -4)
        bottomConstraint.priority = UILayoutPriority(rawValue: 999)

        NSLayoutConstraint.activate([
            groupImageView.widthAnchor.constraint(equalToConstant: 82),
            groupImageView.heightAnchor.constraint(equalToConstant: 82),
            topConstraint,
            bottomConstraint,
            groupImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            groupImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])

        contentView.addSubview(nameLabel)
        NSLayoutConstraint.activate([
            nameLabel.leadingAnchor.constraint(equalTo: groupImageView.trailingAnchor, constant: 8),
            nameLabel.centerYAnchor.constraint(equalTo: groupImageView.centerYAnchor),
            nameLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16)
        ])
    }

    // MARK: - Public Methods
    
    /// Cell configuration.
    /// - Parameter group: viewModel
    func configure(group model: GroupViewModel) {
        nameLabel.text = model.name
        
        if let dataImage = model.imageData {
            groupImageView.image = UIImage(data: dataImage)
        }
    }
}
