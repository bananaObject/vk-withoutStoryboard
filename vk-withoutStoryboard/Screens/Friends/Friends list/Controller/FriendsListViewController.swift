//
//  FriendsListViewController.swift
//  vk-withoutStoryboard
//
//  Created by Ke4a on 30.01.2022.
//

import RealmSwift
import UIKit

final class FriendsListViewController: UIViewController {

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

    // MARK: - Public Properties

    var viewModels: [LetterViewModel] = []

    // MARK: - Private Methods

    private let presenter: FriendsListViewOutput

    // MARK: - Initialization

    init(_ presenter: FriendsListViewOutput) {
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

        presenter.createNotificationToken()
        presenter.fetchFriends()

        tableView.register(FriendsTableViewCell.self, forCellReuseIdentifier: FriendsTableViewCell.identifier)
        tableView.register(FriendsHeaderSectionTableView.self,
                           forHeaderFooterViewReuseIdentifier: FriendsHeaderSectionTableView.identifier)
        tableView.delegate = self
        tableView.dataSource = self
    }

    // MARK: - Setting UI Method

    private func setupUI() {
        tableView.sectionIndexColor = .vkColor
        tableView.sectionHeaderTopPadding = 5
        tableView.sectionIndexBackgroundColor = .white

        title = "Friends"

        view.addSubview(tableView)
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
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

// MARK: - FriendsListViewInput

extension FriendsListViewController: FriendsListViewInput {
    func updateTableView(_ from: UpdatesIndexsHelper?) {
        guard let updateIndexSet = from else {
            tableView.reloadData()
            return
        }

        tableView.beginUpdates()
        tableView.insertSections(updateIndexSet.insertIndexSet, with: .automatic)
        tableView.reloadSections(updateIndexSet.reloadIndexSet, with: .automatic)
        tableView.deleteSections(updateIndexSet.deleteIndexSet, with: .automatic)
        tableView.endUpdates()
    }

    func updateRow(_ from: IndexPath) {
        tableView.beginUpdates()
        tableView.reloadRows(at: [from], with: .none)
        tableView.endUpdates()
    }

    func loadingAnimation(_ on: Bool) {
        loadingView.animation(on)
    }
}

// MARK: - UITableViewDataSource

extension FriendsListViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        viewModels.count
    }

    func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        return viewModels.map { $0.name.uppercased() }
    }

    func tableView(_ tableView: UITableView,
                   sectionForSectionIndexTitle title: String,
                   at index: Int
    ) -> Int {
        tableView.scrollToRow(at: .init(row: 0, section: index), at: .top, animated: true)
        return index
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModels[section].items.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell: FriendsTableViewCell = tableView.dequeueReusableCell(
            withIdentifier: FriendsTableViewCell.identifier
        ) as? FriendsTableViewCell else { return UITableViewCell() }
        let friend = viewModels[indexPath.section].items[indexPath.row]
        cell.configure(friend: friend)

        presenter.loadImageAsync(from: indexPath, for: friend)

        return cell
    }
}

// MARK: - UITableViewDelegate
extension FriendsListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let header: FriendsHeaderSectionTableView = tableView.dequeueReusableHeaderFooterView(
            withIdentifier: FriendsHeaderSectionTableView.identifier
        ) as? FriendsHeaderSectionTableView else { return UITableViewCell() }
        let letter: String = viewModels[section].name.uppercased()
        header.configure(letter)
        return header
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        didSelectRowAction(indexPath)
    }

    func tableView(
        _ tableView: UITableView,
        trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath
    ) -> UISwipeActionsConfiguration? {
        let delete: UIContextualAction = deleteAction(at: indexPath)
        return UISwipeActionsConfiguration(actions: [delete])
    }

    private func didSelectRowAction(_ indexPath: IndexPath) {
        //        let friend: RLMFriend = provider.data[indexPath.section].items[indexPath.row]
        //
        //        let friendCollectionVC = FriendCollectionViewController()
        //        friendCollectionVC.configure(friendId: friend.id)
        //        navigationController?.pushViewController(friendCollectionVC, animated: true)
    }

    /// Swipe action to remove a friend from the cell.
    /// - Parameter indexPath: Friend's index.
    /// - Returns: UIContextualAction for tableView
    private func deleteAction(at indexPath: IndexPath) -> UIContextualAction {
        let action = UIContextualAction(style: .destructive, title: "Delete") { [self] _, _, _ in
            let friend = viewModels[indexPath.section].items[indexPath.row]
            presenter.deleteFriend(friend)
            // In the future, I will add the removal of a friend in the api.
        }
        action.backgroundColor = #colorLiteral(red: 1, green: 0.3464992942, blue: 0.4803417176, alpha: 1)
        action.image = UIImage(systemName: "trash.fill")
        return action
    }
}
