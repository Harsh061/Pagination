//
//  HomePresenter.swift
//  pagination
//
//  Created by Harshit Parikh on 09/08/18.
//  Copyright © 2018 Harshit Parikh. All rights reserved.
//

import Foundation

protocol HomePresenterProtocol: class {
    func reloadTableView()
    func showError(title: String, message: String)
}

class HomePresenter {
    
    // MARK: - Properties
    private var view: HomePresenterProtocol?
    private var productModel: ProductModel?
    private var page: Int = 1
    
    var numberOfRows: Int {
        return productModel?.userInfoModel.count ?? 0
    }
    
    
    // MARK: - Methods
    /// Initial setup of presenter
    init(with view: HomePresenterProtocol?) {
        self.view = view
    }
    
    /// Function to reset pagination data
    func reset() {
        SortViewController.shared.selectedSort = -1
        page = 1
    }
    
    /// Function for pagination hit
    func paginationHit() {
        if self.productModel?.isPaginationRequired == true {
            page += 1
            self.getAllUsersList(isFromPagination: true)
        }
    }
    
    
    /// Function to get the user model for the particular index
    /// - Parameters:
    ///   - indexPath: takes the indexpath to return model
    /// - Returns: user detail model for selected index
    func getUserDataModelAtIndex(index: Int) -> UserInfoModel? {
        if let model = self.productModel?.userInfoModel {
            return model[index]
        }
        return nil
    }
    
    /// Function to get user array all together
    /// - Returns: entire user array
    func getAllUserArray() -> [UserInfoModel]? {
        if let model = self.productModel?.userInfoModel, model.count > 0 {
            return model
        }
        return nil
    }
    
    /// Function to get all users list
    /// - Parameters:
    ///   - isFromPagination: takes the bool as input
    func getAllUsersList(isFromPagination: Bool = false) {
        if Reachability.isConnectedToNetwork(){
            ProgressHUD.present(animated: true)
            let apiPath = "users?page=\(page)"
            HTTPRequest(method: .get, path: apiPath, parameters: nil, encoding: EncodingType.json, files: nil).config(isIndicatorEnable: false, isAlertEnable: false).handler(httpModel: true, delay: 0.3, completion: { (response) in
                ProgressHUD.dismiss(animated: true)
                guard let error = response.error else {
                    if let data = response.value as? Data {
                        do {
                            let productsData = try JSONDecoder().decode(ProductModel.self, from: data)
                            if !isFromPagination {
                                self.productModel = productsData
                            } else {
                                self.productModel?.userInfoModel += productsData.userInfoModel
                            }
                            self.view?.reloadTableView()
                        } catch DecodingError.keyNotFound(let key, let context) {
                            print("Missing key \(key)")
                            print("Debug description \(context.debugDescription)")
                        } catch DecodingError.valueNotFound(let type, let context) {
                            print("Missing Value \(type)")
                            print("Debug description \(context.debugDescription)")
                        } catch DecodingError.typeMismatch(let key, let value) {
                            print("Missing key \(key)")
                            print("Missing Value \(value)")
                        } catch let error {
                            self.view?.showError(title: "", message: error.localizedDescription)
                        }
                    }
                    return
                }
                self.view?.showError(title: "", message: error.localizedDescription)
            })
        } else {
            self.view?.showError(title: "", message: "No Internet Connection available.")
        }
        
    }

    /// Function to sort all users list
    /// - Parameters:
    ///   - index: selected sort index
    func sortUserArray(index: Int, completionHandler:@escaping (Bool) -> ()) {
        switch index {
        case 0:
            if var model = self.productModel {
                model.userInfoModel = model.userInfoModel.sorted(by: { $0.id < $1.id })
                self.productModel?.userInfoModel = model.userInfoModel
            }
            completionHandler(true)
        case 1:
            if var model = self.productModel {
                model.userInfoModel = model.userInfoModel.sorted(by: { $0.id > $1.id })
                self.productModel?.userInfoModel = model.userInfoModel
            }
            completionHandler(true)
        case 2:
            if var model = self.productModel {
                model.userInfoModel = model.userInfoModel.sorted(by: { $0.firstName < $1.firstName })
                self.productModel?.userInfoModel = model.userInfoModel
            }
            completionHandler(true)
        case 3:
            if var model = self.productModel {
                model.userInfoModel = model.userInfoModel.sorted(by: { $0.firstName > $1.firstName })
                self.productModel?.userInfoModel = model.userInfoModel
            }
            completionHandler(true)
        default:
            break
        }
    }

}
