//
//  ResponseModel.swift
//  PaginationTraining
//
//  Created by Pooyan J on 5/29/25.
//

import Foundation

struct ResponseModel: Codable {
    
    var count: Int
    var next: String
    var previous: String?
    var results: [Item]
    
    struct Item: Codable {
        var name: String
        var url: String
    }
}
