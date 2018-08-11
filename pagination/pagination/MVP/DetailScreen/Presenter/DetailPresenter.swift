//
//  DetailPresenter.swift
//  pagination
//
//  Created by Harshit Parikh on 11/08/18.
//  Copyright © 2018 Harshit Parikh. All rights reserved.
//

import Foundation

protocol DetailPresenterProtocol: class {
    
}

class DetailPresenter {
    
    // MARK: - Properties
    var view: DetailPresenterProtocol?
    
    // MARK: - Methods
    /// Initial setup of presenter
    init(view: DetailPresenterProtocol?) {
        self.view = view
    }
    
}
