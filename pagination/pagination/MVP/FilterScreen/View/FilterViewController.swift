//
//  FilterViewController.swift
//  CraftBeer
//
//  Created by Harshit Parikh on 30/06/18.
//  Copyright © 2018 Harshit Parikh. All rights reserved.
//

import UIKit

protocol FilterViewControllerProtocol: class {
    func selectedFilter(index: Int)
}

class FilterViewController: UIViewController {

    // MARK: - Properties
    private var presenter: FilterPresenter!
    static let shared = FilterViewController()
    private var filterSelected: Int = -1
    weak var delegate: FilterViewControllerProtocol?
    
    // MARK: - Outlets
    @IBOutlet weak var tableView: UITableView!
    
    
    // MARK: - Button Actions
    
    
    
    // MARK: - App life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        presenterSetup()
        registerTableCell()
        setupTableView()
    }

    // MARK: - Functions
    private func presenterSetup() {
        self.presenter = FilterPresenter(with: self)
        if FilterViewController.shared.filterSelected >= 0 {
            presenter.setupPrefilledSelectedSort(index: FilterViewController.shared.filterSelected)
        }
    }
    
    private func registerTableCell() {
        self.tableView.registerCell(SortTableViewCell.identifier)
    }
    
    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = 50
    }
}

extension FilterViewController: UITableViewDelegate, UITableViewDataSource {
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
        FilterViewController.shared.filterSelected = indexPath.row
        self.filterSelected = indexPath.row
        presenter.setCellSelected(index: indexPath.row)
    }
}

extension FilterViewController: FilterViewProtocol {
    func reloadTableView() {
        self.tableView.reloadData()
    }
    
    func navigateToPreviousVC() {
        DispatchQueue.main.async {
            self.dismiss(animated: true, completion: {
                self.delegate?.selectedFilter(index: self.filterSelected)
            })
        }
    }
}

