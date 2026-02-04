//
//  SendMessageRequest.swift
//  Logit
//
//  Created by 임재현 on 2/4/26.
//

import Foundation

struct SendMessageRequest: Encodable {
    let content: String
    let experienceIds: [String]
    let questionId: String
    
    enum CodingKeys: String, CodingKey {
        case content
        case experienceIds = "experience_ids"
        case questionId = "question_id"
    }
}
