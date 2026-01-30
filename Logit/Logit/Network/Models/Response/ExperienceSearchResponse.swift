//
//  ExperienceSearchResponse.swift
//  Logit
//
//  Created by 임재현 on 1/30/26.
//

import Foundation

struct ExperienceSearchResponse: Decodable {
    let query: String
    let results: [ExperienceSearchResult]
    let total: Int
}

struct ExperienceSearchResult: Decodable {
    let experience: ExperienceResponse
    let score: Double
}
