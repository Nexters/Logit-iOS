//
//  UpdateExperienceRequest.swift
//  Logit
//
//  Created by 임재현 on 1/30/26.
//

import Foundation

struct UpdateExperienceRequest: Encodable {
    let action: String?
    let category: String?
    let endDate: String?
    let experienceType: String?
    let result: String?
    let situation: String?
    let startDate: String?
    let task: String?
    let title: String?
    
    enum CodingKeys: String, CodingKey {
        case action
        case category
        case endDate = "end_date"
        case experienceType = "experience_type"
        case result
        case situation
        case startDate = "start_date"
        case task
        case title
    }
}
