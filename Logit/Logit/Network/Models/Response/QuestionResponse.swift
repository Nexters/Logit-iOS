//
//  QuestionResponse.swift
//  Logit
//
//  Created by 임재현 on 1/31/26.
//

import Foundation

struct QuestionResponse: Decodable {
    let answer: String?
    let id: String
    let maxLength: Int
    let question: String
    
    enum CodingKeys: String, CodingKey {
        case answer
        case id
        case maxLength = "max_length"
        case question
    }
}
