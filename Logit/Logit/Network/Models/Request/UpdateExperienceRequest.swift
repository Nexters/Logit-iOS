//
//  UpdateExperienceRequest.swift
//  Logit
//
//  Created by 임재현 on 1/30/26.
//

import Foundation

struct UpdateExperienceRequest: Encodable {
    // 공통
    let endDate: String?
    let experienceType: String?
    let formatType: String?
    let startDate: String?
    let tags: String?
    let title: String?

    // STAR
    let situation: String?
    let task: String?
    let action: String?
    let result: String?

    // PSI
    let problem: String?
    let solution: String?
    let insight: String?

    // FREE
    let content: String?

    enum CodingKeys: String, CodingKey {
        case endDate = "end_date"
        case experienceType = "experience_type"
        case formatType = "format_type"
        case startDate = "start_date"
        case tags
        case title
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
