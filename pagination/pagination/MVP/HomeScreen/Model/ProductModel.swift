//
//  ProductModel.swift
//  pagination
//
//  Created by Harshit Parikh on 09/08/18.
//  Copyright © 2018 Harshit Parikh. All rights reserved.
//

import Foundation

struct ProductModel: Decodable {
    var page: Int
    var perPage: Int
    var total: Int
    var totalPages: Int
    var userInfoModel: [UserInfoModel]
    
    var isPaginationRequired: Bool {
        return total > userInfoModel.count
    }
    
    private enum CodingKeys: String, CodingKey {
        case page
        case perPage = "per_page"
        case total
        case totalPages = "total_pages"
        case userInfoModel = "data"
    }
}

struct UserInfoModel: Decodable {
    var id: Int
    var firstName: String
    var lastName: String
    var userImage: String
    private enum CodingKeys: String, CodingKey {
        case id
        case firstName = "first_name"
        case lastName = "last_name"
        case userImage = "avatar"
    }
}
