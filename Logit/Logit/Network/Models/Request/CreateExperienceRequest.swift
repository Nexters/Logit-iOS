//
//  CreateExperienceRequest.swift
//  Logit
//
//  Created by 임재현 on 1/30/26.
//

import Foundation

struct CreateExperienceRequest: Encodable {
    let action: String
    let endDate: String?
    let experienceType: String
    let formatType: String
    let result: String
    let situation: String
    let startDate: String
    let tags: String
    let task: String
    let title: String

    enum CodingKeys: String, CodingKey {
        case action
        case endDate = "end_date"
        case experienceType = "experience_type"
        case formatType = "format_type"
        case result
        case situation
        case startDate = "start_date"
        case tags
        case task
        case title
    }
}
