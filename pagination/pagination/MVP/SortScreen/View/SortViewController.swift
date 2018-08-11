//
//  SortViewController.swift
//  pagination
//
//  Created by Harshit Parikh on 10/08/18.
//  Copyright © 2018 Harshit Parikh. All rights reserved.
//

import UIKit

protocol SortViewControllerProtocol: class {
    func selectedSort(index: Int)
}

class SortViewController: UIViewController {

    // MARK: - Properties
    private var presenter: SortPresenter!
    weak var delegate: SortViewControllerProtocol?
    static let shared = SortViewController()
    var selectedSort: Int = -1
    
    // MARK: - Outlets
    @IBOutlet weak var tableView: UITableView!
    
    
    // MARK: - Button Actions
    
    
    // MARK: - App life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupPresenter()
        registerTableCell()
        setupTableView()

    }
    
    /// Function to setup presenter
    private func setupPresenter() {
        self.presenter = SortPresenter(view: self)
        if SortViewController.shared.selectedSort >= 0 {
            presenter.setupPrefilledSelectedSort(index: SortViewController.shared.selectedSort)
        }
    }
    
    /// Function to register table cell
    private func registerTableCell() {
        self.tableView.registerCell(SortTableViewCell.identifier)
    }
    
    /// Function to setup table view
    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = 50
    }
    
}

extension SortViewController: UITableViewDelegate, UITableViewDataSource {
    // MARK: - Tableview methods
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return presenter.numberOfRows
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: SortTableViewCell.identifier) else {
            fatalError()
        }
        let cellDataModel = presenter.dataModel(indexPath: indexPath)
        if let cell = cell as? SortTableViewCell, let viewModel = cellDataModel as? SortTableViewCellModel {
            cell.setupView(viewModel: viewModel)
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        SortViewController.shared.selectedSort = indexPath.row
        presenter.setCellSelected(index: indexPath.row)
    }
}

extension SortViewController: SortPresenterProtocol {
    func reloadTableView() {
        self.tableView.reloadData()
    }
    
    func navigateToPreviousVC() {
        DispatchQueue.main.async {
            self.dismiss(animated: true, completion: {
                self.delegate?.selectedSort(index: SortViewController.shared.selectedSort)
            })
        }
    }
}
