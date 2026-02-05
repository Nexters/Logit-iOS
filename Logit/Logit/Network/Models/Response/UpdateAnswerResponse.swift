//
//  UpdateAnswerResponse.swift
//  Logit
//
//  Created by 임재현 on 2/4/26.
//

import Foundation

struct UpdateAnswerResponse: Decodable {
    let questionId: String
    let answer: String
    
    enum CodingKeys: String, CodingKey {
        case questionId = "question_id"
        case answer
    }
}
