//
//  ExperienceSummaryResponse.swift
//  Logit
//
//  Created by 임재현 on 2/21/26.
//

import Foundation

struct ExperienceSummaryResponse: Decodable {
    let typeCounts: [TypeCount]
    let categoryCounts: [CategoryCount]
    let tagCounts: [TagCount]
    let total: Int
    
    enum CodingKeys: String, CodingKey {
        case typeCounts = "type_counts"
        case categoryCounts = "category_counts"
        case tagCounts = "tag_counts"
        case total
    }
}

struct TypeCount: Decodable {
    let type: String
    let count: Int
}

struct CategoryCount: Decodable {
    let category: String
    let count: Int
}

struct TagCount: Decodable {
    let tag: String
    let count: Int
}
