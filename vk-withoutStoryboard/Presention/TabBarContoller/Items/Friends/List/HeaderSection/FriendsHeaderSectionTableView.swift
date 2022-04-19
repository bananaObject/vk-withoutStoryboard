//
//  FriendsHeaderSectionTableView.swift
//  vk-withoutStoryboard
//
//  Created by Ke4a on 03.02.2022.
//

import UIKit

/// Header section.
class FriendsHeaderSectionTableView: UITableViewHeaderFooterView{
    private let label: UILabel = {
        let text:UILabel = UILabel()
        text.translatesAutoresizingMaskIntoConstraints = false
        text.alpha = 0.7
        text.textColor = #colorLiteral(red: 0.2624342442, green: 0.4746298194, blue: 0.7327683568, alpha: 1)
        return text
    }()
    
    static let identifier: String = "FriendsHeaderSectionTableView"
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        label.text = nil
    }
    
    /// Задать текст  Header  секции.
    /// - Parameter text: Текст.
    func setText(_ text: String){
        label.text = text
    }
    
    /// Настройка UI.
    private func setupUI(){
        contentView.addSubview(label)
        
        let top: NSLayoutConstraint = label.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 2)
        top.priority = UILayoutPriority(999)
        
        NSLayoutConstraint.activate([
            top,
            label.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -2),
            label.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 30),
            label.heightAnchor.constraint(equalToConstant: 20),
            label.widthAnchor.constraint(equalToConstant: 30)
        ])
    }
}