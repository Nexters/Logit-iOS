//
//  ProjectListItemResponse.swift
//  Logit
//
//  Created by 임재현 on 1/30/26.
//

import Foundation

struct ProjectListItemResponse: Decodable {
    let id: String
    let company: String
    let jobPosition: String
    let updatedAt: String
    let questionId: String?
    
    enum CodingKeys: String, CodingKey {
        case id
        case company
        case jobPosition = "job_position"
        case updatedAt = "updated_at"
        case questionId = "question_id"
    }
}
