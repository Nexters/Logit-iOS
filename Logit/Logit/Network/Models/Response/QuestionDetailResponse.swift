//
//  QuestionDetailResponse.swift
//  Logit
//
//  Created by 임재현 on 2/4/26.
//

import Foundation

struct QuestionDetailResponse: Decodable {
    let answer: String
    let createdAt: String
    let id: String
    let maxLength: Int
    let projectId: String
    let question: String
    let updatedAt: String
    let userId: String
    
    enum CodingKeys: String, CodingKey {
        case answer
        case createdAt = "created_at"
        case id
        case maxLength = "max_length"
        case projectId = "project_id"
        case question
        case updatedAt = "updated_at"
        case userId = "user_id"
    }
}
