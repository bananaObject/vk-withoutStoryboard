//
//  CatalogGroupsViewController.swift
//  vk-withoutStoryboard
//
//  Created by Ke4a on 31.01.2022.
//

import UIKit

final class CatalogGroupsViewController: UIViewController {

    // MARK: - Visual Components

    private let tableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()

    private let loadingView: LoadingView = {
        let view = LoadingView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private let searchBar: SearchBarHeaderView =  {
        let searchBar = SearchBarHeaderView()
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        return searchBar
    }()

    // MARK: - Public Properties

    var viewModels: [GroupViewModel] = []

    // MARK: - Private Properties

    private let presenter: CatalogGroupsViewOutput

    // MARK: - Initialization

    init(presenter: CatalogGroupsViewOutput) {
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
        presenter.fetchCatalog()

        tableView.register(GroupTableViewCell.self, forCellReuseIdentifier: GroupTableViewCell.identifier)
        tableView.delegate = self
        tableView.dataSource = self
        searchBar.delegate = self
    }

    // MARK: - Setting UI Method

    /// Настройка UI.
    private func setupUI() {
        title = "Catalog Groups"

        view.addSubview(searchBar)
        NSLayoutConstraint.activate([
            searchBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            searchBar.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            searchBar.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor)
        ])
        searchBar.setHeightConstraint(40)

        view.addSubview(tableView)
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: searchBar.bottomAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor)
        ])

        view.addSubview(loadingView)
        NSLayoutConstraint.activate([
            loadingView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            loadingView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            loadingView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            loadingView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor)
        ])
    }
}

// MARK: - CatalogGroupsViewInput

extension CatalogGroupsViewController: CatalogGroupsViewInput {

    // MARK: - Public Methods

    func updateTableView(for index: IndexPath? = nil) {
        guard let index = index else {
            tableView.reloadData()
            return
        }

        tableView.reloadRows(at: [index], with: .none)
    }

    func loadingAnimation(_ on: Bool) {
        loadingView.animation(on)
    }
}

// MARK: - UITableViewDelegate

extension CatalogGroupsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let model = viewModels[indexPath.row]
        presenter.selectGroup(model)
    }
}

// MARK: - UITableViewDataSource

extension CatalogGroupsViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModels.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell: GroupTableViewCell = tableView.dequeueReusableCell(
            withIdentifier: GroupTableViewCell.identifier
        ) as? GroupTableViewCell else { preconditionFailure("CatalogGroupsViewController.dequeueReusableCell Error") }

        let model = viewModels[indexPath.row]
        
        presenter.loadImageAsync(for: indexPath, model: model)

        cell.configure(group: model)
        return cell
    }
}

// MARK: - UISearchBarDelegate

extension CatalogGroupsViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        presenter.updateSearchText(searchText)
        
        // debounce для текста поиска, выполняется когда прекратится ввод данных
        NSObject.cancelPreviousPerformRequests(
            withTarget: self as Any,
            selector: #selector(searchDebounceAction),
            object: nil)
        perform(#selector(searchDebounceAction), with: nil, afterDelay: 1)
    }

    // MARK: - Actions

    @objc private func searchDebounceAction() {
        // Eсли текст поиска пустой, то загружается общий каталог групп.

        presenter.fetchCatalog()
    }
}
