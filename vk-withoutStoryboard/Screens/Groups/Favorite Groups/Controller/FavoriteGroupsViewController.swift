//
//  FavoriteGroupsViewController.swift
//  firstApp-withoutStoryboard
//
//  Created by Ke4a on 30.01.2022.
//

import UIKit

final class FavoriteGroupsViewController: UIViewController {

    // MARK: - Visual Components

    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()

    private lazy var loadingView: LoadingView = {
        let view = LoadingView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private lazy var searchBarHeader: SearchBarHeaderView  =  {
        let searchbar = SearchBarHeaderView()
        searchbar.translatesAutoresizingMaskIntoConstraints = false
        return searchbar
    }()

    // MARK: - Public Properties

    var viewModels: [GroupViewModel] = []

    // MARK: - Private Properties

    private let presenter: FavoriteGroupsViewOutput

    // MARK: - Initialization

    init(_ presenter: FavoriteGroupsViewOutput) {
        self.presenter = presenter
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
        setupRightBarButton()

        presenter.createNotificationToken()
        presenter.requestGroups()

        tableView.register(GroupTableViewCell.self, forCellReuseIdentifier: GroupTableViewCell.identifier)

        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.searchBarHeader.delegate = self
    }

    // MARK: - Setting UI Methods

    /// Setting UI Methods.
    private func setupUI() {
        self.title = "Groups"

        self.view.addSubview(searchBarHeader)
        searchBarHeader.setHeightConstraint(0)
        NSLayoutConstraint.activate([
            searchBarHeader.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            searchBarHeader.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            searchBarHeader.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor)
        ])

        self.view.addSubview(self.tableView)
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: searchBarHeader.bottomAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor)
        ])

        view.addSubview(loadingView)
        NSLayoutConstraint.activate([
            loadingView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            loadingView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            loadingView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            loadingView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor)
        ])
    }

    /// Setting RightBar Button.
    private func setupRightBarButton() {
        let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addButtonAction))
        addButton.tintColor = .black
        navigationItem.setRightBarButton(addButton, animated: true)

        let searchButton = UIBarButtonItem(
            barButtonSystemItem: .search,
            target: self,
            action: #selector(searchButtonAction))
        searchButton.tintColor = .black
        navigationItem.setLeftBarButton(searchButton, animated: true)
    }

    // MARK: - Actions

    @objc private func searchButtonAction() {
        searchBarHeader.switchSearchBar()
    }

    @objc private func addButtonAction() {
        presenter.openCatalogGroups()
    }
}

// MARK: - FavoriteGroupsViewInput

extension FavoriteGroupsViewController: FavoriteGroupsViewInput {
    func updateTableView(_ from: UpdatesIndexPaths? = nil) {
        guard let indexPath = from else {
            tableView.reloadData()
            return
        }

        tableView.beginUpdates()
        tableView.deleteRows(at: indexPath.deleteRows, with: .automatic)
        tableView.insertRows(at: indexPath.insertRows, with: .automatic)
        tableView.reloadRows(at: indexPath.reloadRows, with: .automatic)
        tableView.endUpdates()
    }

    func loadingAnimation(_ on: Bool) {
        loadingView.animation(on)
    }
}

// MARK: - UITableViewDataSource

extension FavoriteGroupsViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModels.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell: GroupTableViewCell = tableView.dequeueReusableCell(
            withIdentifier: GroupTableViewCell.identifier
        ) as? GroupTableViewCell else {
            preconditionFailure("FavoriteGroupsViewController.dequeueReusableCell Error") }
        let group = viewModels[indexPath.row]

        cell.configure(group: group)

        presenter.loadImageAsync(for: indexPath, from: group)

        return cell
    }
}

// MARK: - UITableViewDelegate

extension FavoriteGroupsViewController: UITableViewDelegate {
    func tableView(
        _ tableView: UITableView,
        trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath
    ) -> UISwipeActionsConfiguration? {
        let delete: UIContextualAction = deleteAction(at: indexPath)
        return UISwipeActionsConfiguration(actions: [delete])
    }

    // MARK: - SwipeActions

    private func deleteAction(at indexPath: IndexPath) -> UIContextualAction {
        let action = UIContextualAction(style: .destructive, title: "Delete") { [weak self] _, _, _ in
            guard let group = self?.viewModels[indexPath.row] else { return }
            
            self?.presenter.deleteInRealm(group)
        }
        action.backgroundColor = .red
        action.image = UIImage(systemName: "trash.fill")
        return action
    }
}

// MARK: - UISearchBarDelegate

extension FavoriteGroupsViewController: UISearchBarDelegate {
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        self.presenter.updateSearchText("")
    }

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        self.presenter.updateSearchText(searchText)
    }
}
