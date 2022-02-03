//
//  FriendCollectionViewCell.swift
//  firstApp-withoutStoryboard
//
//  Created by Ke4a on 31.01.2022.
//

import UIKit

class FriendCollectionViewCell: UICollectionViewCell {
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        return imageView
    }()
    
    private let likeView: LikePhoto = {
        let view = LikePhoto()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    private var indexImage:Int?
    static let identifier = "FriendCollectionViewCell"
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        imageView.image = nil
    }
    
    var delegate: FriendCollectionViewCellDelegate?
    private func setupUI(){
        addSubview(imageView)
        let topConstraint = imageView.topAnchor.constraint(equalTo: contentView.topAnchor)
        topConstraint.priority = UILayoutPriority(rawValue: 999)
        let bottomConstraint = imageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        bottomConstraint.priority = UILayoutPriority(rawValue: 999)
        
        NSLayoutConstraint.activate([
            imageView.widthAnchor.constraint(equalToConstant: 160),
            imageView.heightAnchor.constraint(equalToConstant: 160),
            topConstraint,
            bottomConstraint,
            imageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
        ])
        
        addSubview(likeView)
        NSLayoutConstraint.activate([
            likeView.widthAnchor.constraint(equalToConstant: 25),
            likeView.heightAnchor.constraint(equalToConstant: 25),
            likeView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
            likeView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8)
        ])
    }
    
    func configure(_ image:ImageModel, index: Int){
        indexImage = index
        imageView.image = UIImage(named: image.name)
        likeView.configure(image.like, youLike: image.youLike)
        likeView.addTarget(self, action: #selector(likePhotoAction), for: .valueChanged)
    }

    @objc private func likePhotoAction(){
        guard let like = likeView.youLike, let index = indexImage else {
            return
        }
        delegate?.actionLikePhoto(like, indexPhoto: index)
    }
}

protocol FriendCollectionViewCellDelegate: AnyObject{
    func actionLikePhoto(_ like:Bool, indexPhoto: Int)
}
