//
//  ProjectDetailResponse.swift
//  Logit
//
//  Created by 임재현 on 1/30/26.
//

import Foundation

struct ProjectDetailResponse: Decodable {
    let id: String
    let company: String
    let jobPosition: String
    let recruitNotice: String
    let dueDate: String
    let userId: String
    let createdAt: String
    let updatedAt: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case company
        case jobPosition = "job_position"
        case recruitNotice = "recruit_notice"
        case dueDate = "due_date"
        case userId = "user_id"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}
