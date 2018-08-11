//
//  SortPresenter.swift
//  pagination
//
//  Created by Harshit Parikh on 11/08/18.
//  Copyright © 2018 Harshit Parikh. All rights reserved.
//

import Foundation

protocol SortPresenterProtocol: class {
    func reloadTableView()
    func navigateToPreviousVC()
}

class SortPresenter {
    
    // MARK: - Properties
    enum SortSection {
        case lowToHigh
        case highToLow
        case alphabeticalAscending
        case alphabeticalDescending
        
        var identifier: String {
            switch self {
            case .lowToHigh, .highToLow:
                return SortTableViewCell.identifier
            case .alphabeticalAscending, .alphabeticalDescending:
                return SortTableViewCell.identifier
            }
        }
    }
    
    private var sortSectionArr: [SortSection] = [.lowToHigh, .highToLow, .alphabeticalAscending, .alphabeticalDescending]
    private var sortDataModels = [SortSection: CellDataModelProtocol]()
    private var view: SortPresenterProtocol?

    var numberOfRows: Int {
        return sortSectionArr.count
    }
    
    /// Initial setup of presenter
    init(view: SortPresenterProtocol?) {
        self.view = view
        setupQuestionCellModel()
    }
    
    /// Get identifier of cells
    /// - Parameters:
    ///   - indexPath: takes the indexpath to return model
    /// - Returns: user detail model for selected index
    func dataModel(indexPath: IndexPath) -> CellDataModelProtocol {
        let section = sortSectionArr[indexPath.row]
        return sortDataModels[section]!
    }
    
    /// Setup cells
    private func setupQuestionCellModel() {
        for section in sortSectionArr {
            sortDataModels[section] = sortViewModel(for: section)
        }
    }
    
    // MARK: - Setup initial cell model
    private func sortViewModel(for section: SortSection) -> CellDataModelProtocol {
        switch section {
        case .lowToHigh:
            let viewModel = SortTableViewCellModel(identifier: section.identifier, title: "User Id", subTitle: "Low To High")
            return viewModel
        case .highToLow:
            let viewModel = SortTableViewCellModel(identifier: section.identifier, title: "User Id", subTitle: "High To Low")
            return viewModel
        case .alphabeticalAscending:
            let viewModel = SortTableViewCellModel(identifier: section.identifier, title: "Sort Firstname", subTitle: "A-Z")
            return viewModel
        case .alphabeticalDescending:
            let viewModel = SortTableViewCellModel(identifier: section.identifier, title: "Sort Firstname", subTitle: "Z-A")
            return viewModel
        }
    }
    
    /// Function to setup prefill selected sort
    /// - Parameters:
    ///   - index: index of selected sort
    func setupPrefilledSelectedSort(index: Int) {
        for i in 0 ..<  sortDataModels.count {
            let sectionIndex = sortSectionArr[i]
            if var viewModel = sortDataModels[sectionIndex] as? SortTableViewCellModel {
                viewModel.isSortSelected = i == index
                sortDataModels[sectionIndex] = viewModel
            }
        }
        self.view?.reloadTableView()
    }
    
    /// Function to setup selected sort
    /// - Parameters:
    ///   - index: index of selected sort
    func setCellSelected(index: Int) {
        for i in 0 ..<  sortDataModels.count {
            let sectionIndex = sortSectionArr[i]
            if var viewModel = sortDataModels[sectionIndex] as? SortTableViewCellModel {
                viewModel.isSortSelected = i == index
                sortDataModels[sectionIndex] = viewModel
            }
        }
        self.view?.navigateToPreviousVC()
    }
}
