//
//  MatchingExperiencesResponse.swift
//  Logit
//
//  Created by 임재현 on 1/30/26.
//

import Foundation

struct MatchingExperiencesResponse: Decodable {
    let experiences: [MatchingExperience]
    let total: Int
}

struct MatchingExperience: Decodable {
    let experience: ExperienceResponse
    let similarityScore: Double
    
    enum CodingKeys: String, CodingKey {
        case experience
        case similarityScore = "similarity_score"
    }
}
