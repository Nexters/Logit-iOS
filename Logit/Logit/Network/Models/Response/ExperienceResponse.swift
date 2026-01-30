//
//  ExperienceResponse.swift
//  Logit
//
//  Created by 임재현 on 1/30/26.
//

import Foundation

struct ExperienceResponse: Decodable {
    let action: String
    let category: String
    let createdAt: String
    let endDate: String
    let experienceType: String
    let id: String
    let result: String
    let situation: String
    let startDate: String
    let tags: String
    let task: String
    let title: String
    let updatedAt: String
    let userId: String
    
    enum CodingKeys: String, CodingKey {
        case action
        case category
        case createdAt = "created_at"
        case endDate = "end_date"
        case experienceType = "experience_type"
        case id
        case result
        case situation
        case startDate = "start_date"
        case tags
        case task
        case title
        case updatedAt = "updated_at"
        case userId = "user_id"
    }
}
