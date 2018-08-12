//
//  FilterPresenter.swift
//  CraftBeer
//
//  Created by Harshit Parikh on 30/06/18.
//  Copyright © 2018 Harshit Parikh. All rights reserved.
//

import Foundation


protocol FilterViewProtocol: class {
    func reloadTableView()
    func navigateToPreviousVC()
}

class FilterPresenter {
    // MARK: - Variables
    enum FilterSection {
        case applyColorFilter
        case resetFilter
        
        var identifier: String {
            switch self {
            case .applyColorFilter, .resetFilter:
                return SortTableViewCell.identifier
            }
        }
    }
    
    private var filterSectionArr: [FilterSection] = [.applyColorFilter, .resetFilter]
    private var filterDataModels = [FilterSection: CellDataModelProtocol]()
    private var view: FilterViewProtocol?
    
    var numberOfRows: Int {
        return filterSectionArr.count
    }
    
    /// Initial setup of presenter
    init(with view: FilterViewProtocol?) {
        self.view = view
        setupQuestionCellModel()
    }
    
    /// Get identifier of cells
    func dataModel(indexPath: IndexPath) -> CellDataModelProtocol {
        let section = filterSectionArr[indexPath.row]
        return filterDataModels[section]!
    }
    
    /// Setup cells
    private func setupQuestionCellModel() {
        for section in filterSectionArr {
            filterDataModels[section] = filterViewModel(for: section)
        }
    }
    
    // MARK: - Setup initial cell model
    private func filterViewModel(for section: FilterSection) -> CellDataModelProtocol {
        switch section {
        case .applyColorFilter:
            let viewModel = SortTableViewCellModel(identifier: section.identifier, title: "Filter Type", subTitle: "Color")
            return viewModel
        case .resetFilter:
            let viewModel = SortTableViewCellModel(identifier: section.identifier, title: "Reset Filter", subTitle: "")
            return viewModel
        }
    }
    
    func setupPrefilledSelectedSort(index: Int) {
        for i in 0 ..<  filterDataModels.count {
            let sectionIndex = filterSectionArr[i]
            if var viewModel = filterDataModels[sectionIndex] as? SortTableViewCellModel {
                viewModel.isSortSelected = i == index
                filterDataModels[sectionIndex] = viewModel
            }
        }
        self.view?.reloadTableView()
    }
    
    func setCellSelected(index: Int) {
        for i in 0 ..<  filterDataModels.count {
            let sectionIndex = filterSectionArr[i]
            if var viewModel = filterDataModels[sectionIndex] as? SortTableViewCellModel {
                viewModel.isSortSelected = i == index
                filterDataModels[sectionIndex] = viewModel
            }
        }
        self.view?.navigateToPreviousVC()
    }
    
}
