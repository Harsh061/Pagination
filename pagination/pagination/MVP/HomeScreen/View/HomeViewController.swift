//
//  HomeViewController.swift
//  pagination
//
//  Created by Harshit Parikh on 09/08/18.
//  Copyright © 2018 Harshit Parikh. All rights reserved.
//

import UIKit

class HomeViewController: UIViewController {

    // MARK: - Properties
    lazy var slideTransitioningDelegate: SlideInPresentationManager = SlideInPresentationManager()
    let searchController = UISearchController(searchResultsController: nil)
    private var presenter: HomePresenter!
    private var filteredArray: [UserInfoModel] = []
    lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(self.handleRefresh(_:)), for: UIControlEvents.valueChanged)
        refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        return refreshControl
    }()
    
    // MARK: - Outlets
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var noResultLabel: UILabel!
    
    // MARK: - Button Actions
    @IBAction func sortBtnAction(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let vc = storyboard.instantiateViewController(withIdentifier: SortViewController.identifier) as? SortViewController {
            slideTransitioningDelegate.direction = .bottom
            vc.transitioningDelegate = slideTransitioningDelegate
            vc.modalPresentationStyle = .custom
            vc.delegate = self
            self.navigationController?.present(vc, animated: true, completion: nil)
        }
    }
    
    // MARK: - App life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        initialSetup()
    }
    
    // MARK: - Functions
    private func initialSetup() {
        setUpNavigationTitle()
        presenterSetup()
        setUpSearchController()
        registerTableCell()
        setupTableView()
        getAllUserData()
        registerForPreviewing(with: self, sourceView: tableView)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.navigationBar.isHidden = false
    }
    
    /// Function to setup navigation title
    private func setUpNavigationTitle() {
        self.title = "Contacts"
        UINavigationBar.appearance().titleTextAttributes = [NSAttributedStringKey.foregroundColor : UIColor.white]
        self.navigationController?.navigationBar.barTintColor = UIColor(red: 0 / 255.0, green: 84 / 255.0, blue: 147 / 255.0, alpha: 1.0)
        self.navigationController?.navigationBar.tintColor = UIColor(red: 0 / 255.0, green: 84 / 255.0, blue: 147 / 255.0, alpha: 1.0)
    }
    
    /// Function to setup presenter
    private func presenterSetup() {
        self.presenter = HomePresenter(with: self)
    }
    
    /// Function to setup search controller
    private func setUpSearchController() {
        // Setup the Search Controller
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Enter User Name..."
        searchController.searchBar.barTintColor = UIColor.white
        searchController.searchBar.tintColor = UIColor.white
        // TextField Color Customization
        if let textFieldInsideSearchBar = searchController.searchBar.value(forKey: "searchField") as? UITextField {
            UITextField.appearance(whenContainedInInstancesOf: [UISearchBar.self]).defaultTextAttributes = [NSAttributedStringKey.foregroundColor.rawValue: UIColor.black]
            if let backgroundview = textFieldInsideSearchBar.subviews.first {
                
                // Background color
                backgroundview.backgroundColor = UIColor.white
                
                // Rounded corner
                backgroundview.layer.cornerRadius = 10;
                backgroundview.clipsToBounds = true;
            }
        }
        navigationItem.searchController = searchController
        definesPresentationContext = true
        
    }
    
    /// Function to register table cell
    private func registerTableCell() {
        self.tableView.registerCell(ProductTableViewCell.identifier)
    }
    
    /// Function to setup table view
    private func setupTableView() {
        // Add Refresh Control to Table View
        if #available(iOS 10.0, *) {
            tableView.refreshControl = refreshControl
        } else {
            tableView.addSubview(refreshControl)
        }
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 300
    }
    
    /// Function to handle pull to refresh
    @objc func handleRefresh(_ sender: UIRefreshControl) {
        presenter.reset()
        presenter.getAllUsersList()
        refreshControl.endRefreshing()
    }
    
    /// Function to get all user data
    private func getAllUserData() {
        presenter.getAllUsersList()
    }
    
    /// Function to check if search bar is empty or not
    /// - Returns: bool
    func searchBarIsEmpty() -> Bool {
        // Returns true if the text is empty or nil
        return searchController.searchBar.text?.isEmpty ?? true
    }
    
    /// Function to filter search text
    func filterContentForSearchText(_ searchText: String, scope: String = "All") {
        if let userModelArray = presenter.getAllUserArray() {
            filteredArray = userModelArray.filter({( model : UserInfoModel) -> Bool in
                let userName = model.firstName + " " + model.lastName
                return userName.lowercased().contains(searchText.lowercased())
            })
            tableView.reloadData()
        }
    }
    
    /// Function to check if filtering is active
    /// - Returns: bool
    func isFiltering() -> Bool {
        return searchController.isActive && !searchBarIsEmpty()
    }
    
}

extension HomeViewController: UITableViewDelegate, UITableViewDataSource, UIViewControllerPreviewingDelegate {
    
    // MARK: - Tableview methods
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var rowCount = 0
        if isFiltering() {
            rowCount = self.filteredArray.count
        } else {
            rowCount = self.presenter.numberOfRows
        }
        if rowCount > 0 {
            self.noResultLabel.isHidden = true
        } else {
            self.noResultLabel.isHidden = false
        }
        return rowCount
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: ProductTableViewCell.identifier) as? ProductTableViewCell else {
            fatalError("Cell not found")
        }
        if let cellModel = presenter.getUserDataModelAtIndex(index: indexPath.row) {
            let userIndexData: UserInfoModel
            if isFiltering() {
                userIndexData = filteredArray[indexPath.row]
            } else {
                userIndexData = cellModel
            }
            cell.setupData(model: userIndexData)
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let cellModel = presenter.getUserDataModelAtIndex(index: indexPath.row) {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            if let vc = storyboard.instantiateViewController(withIdentifier: DetailViewController.identifier) as? DetailViewController {
                vc.userModel = cellModel
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {

        if (tableView.contentOffset.y + tableView.frame.size.height) >= tableView.contentSize.height - 20 {
            presenter.paginationHit()
        }
    }
    
    private func createDetailViewControllerIndexPath(indexPath: IndexPath) -> DetailViewController {
        
        let detailViewController = DetailViewController(nibName: DetailViewController.identifier, bundle: nil)
        if let cellModel = presenter.getUserDataModelAtIndex(index: indexPath.row) {
            detailViewController.userModel = cellModel
        }
        return detailViewController
    }
    
    public func previewingContext(_ previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {
        guard let indexPath = tableView.indexPathForRow(at: location) else {
            return nil
        }
        let detailViewController = createDetailViewControllerIndexPath(indexPath: indexPath)
        return detailViewController
    }

    public func previewingContext(_ previewingContext: UIViewControllerPreviewing, commit viewControllerToCommit: UIViewController) {
        navigationController?.pushViewController(viewControllerToCommit, animated: true)
    }
}

extension HomeViewController: UISearchBarDelegate {
    // MARK: - UISearchBar Delegate
    func searchBar(_ searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
        filterContentForSearchText(searchBar.text!, scope: searchBar.scopeButtonTitles![selectedScope])
    }
}

extension HomeViewController: UISearchResultsUpdating {
    // MARK: - UISearchResultsUpdating Delegate
    func updateSearchResults(for searchController: UISearchController) {
        filterContentForSearchText(searchController.searchBar.text!)
    }
}

extension HomeViewController: HomePresenterProtocol, AlertViewProtocol {
    
    func reloadTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        self.tableView.reloadData()
    }
    
    func showError(title: String, message: String) {
        showAlert(title: title, message: message)
    }
}

extension HomeViewController: SortViewControllerProtocol {
    func selectedSort(index: Int) {
        presenter.sortUserArray(index: index) { (success) in
            if success {
                self.tableView.reloadData()
            }
        }
    }
}
