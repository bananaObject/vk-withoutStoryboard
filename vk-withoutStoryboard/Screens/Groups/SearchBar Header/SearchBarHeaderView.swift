//
//  SearchBarHeaderView.swift
//  vk-withoutStoryboard
//
//  Created by Ke4a on 04.02.2022.
//

import UIKit

/// Static header searchBar.
///
/// Two types of installation:
/// - hidden search string with function of animation of appearance and disappearance.
/// - constant.
final class SearchBarHeaderView: UIView {
    // MARK: - Public Properties

    var delegate: UISearchBarDelegate? {
        get {
            searchBar.delegate
        }

        set {
            searchBar.delegate = newValue
        }
    }

    // MARK: - Visual Components

    private lazy var searchBar: UISearchBar = {
        let searchbar = UISearchBar()
        searchbar.translatesAutoresizingMaskIntoConstraints = false
        return searchbar
    }()

    // MARK: - Private Properties

    private var heightConstraint: NSLayoutConstraint?

    /// Переключатель режима.
    private var isOpen: Bool = false

    // MARK: - Initializers

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Setting UI Method

    ///  Setup UI.
    private func setupUI() {
        searchBar.backgroundColor = .clear
        searchBar.backgroundImage = UIImage()
        searchBar.placeholder = "Введите название группы"
        searchBar.searchTextField.textColor = #colorLiteral(red: 0.2624342442, green: 0.4746298194, blue: 0.7327683568, alpha: 1)
        searchBar.searchTextField.leftView = nil

        self.addSubview(searchBar)

        NSLayoutConstraint.activate([
            searchBar.topAnchor.constraint(equalTo: topAnchor),
            searchBar.bottomAnchor.constraint(equalTo: bottomAnchor),
            searchBar.leadingAnchor.constraint(equalTo: leadingAnchor),
            searchBar.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])
    }

    /// Set initial height.
    /// - Parameter height: The height of the search string.
    func setHeightConstraint(_ height: CGFloat) {
        heightConstraint = NSLayoutConstraint(item: self,
                                              attribute: .height,
                                              relatedBy: .equal,
                                              toItem: nil,
                                              attribute: .notAnAttribute,
                                              multiplier: 1,
                                              constant: height)
        addConstraint(heightConstraint!)

        // If the initial height is 0, then it will be hidden.
        if height == 0 {
            searchBar.alpha = 0
        }
    }

    /// Toggle hide search Bar.
    func switchSearchBar() {
        switch isOpen {
        case false:
            // change the height and recalculate the constraint
            self.heightConstraint?.constant = 40
            self.layoutIfNeeded()

            UIView.animate(withDuration: 0.3, delay: 0.3, options: .curveEaseIn) {
                self.searchBar.alpha = 1
            }
        case true:
            UIView.animate(withDuration: 0.3, delay: 0.3, options: .curveEaseIn) {
                self.searchBar.alpha = 0
            } completion: { _ in
                // change the height and recalculate the constraint
                self.heightConstraint?.constant = 0
                self.layoutIfNeeded()
            }
        }

        self.isOpen.toggle()
    }
}
