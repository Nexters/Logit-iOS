//
//  ExperienceResponse.swift
//  Logit
//
//  Created by 임재현 on 1/30/26.
//

import Foundation

struct ExperienceResponse: Decodable {
    // 공통 필드
    let category: String
    let createdAt: String
    let endDate: String?
    let experienceType: String
    let formatType: String?
    let id: String
    let startDate: String
    let tags: String
    let title: String
    let updatedAt: String
    let userId: String

    // STAR 전용 (optional)
    let situation: String?
    let task: String?
    let action: String?
    let result: String?

    // PSI 전용 (optional)
    let problem: String?
    let solution: String?
    let insight: String?

    // FREE 전용 (optional)
    let content: String?

    enum CodingKeys: String, CodingKey {
        case category
        case createdAt = "created_at"
        case endDate = "end_date"
        case experienceType = "experience_type"
        case formatType = "format_type"
        case id
        case startDate = "start_date"
        case tags
        case title
        case updatedAt = "updated_at"
        case userId = "user_id"
        case situation
        case task
        case action
        case result
        case problem
        case solution
        case insight
        case content
    }
}
