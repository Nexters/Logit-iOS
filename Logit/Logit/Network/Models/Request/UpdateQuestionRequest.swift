//
//  UpdateQuestionRequest.swift
//  Logit
//
//  Created by 임재현 on 2/4/26.
//

import Foundation

struct UpdateQuestionRequest: Encodable {
    let answer: String?
    let maxLength: Int?
    let question: String?
    let isCompleted: Bool?

    enum CodingKeys: String, CodingKey {
        case answer
        case maxLength = "max_length"
        case question
        case isCompleted = "is_completed"
    }

    init(answer: String? = nil, maxLength: Int? = nil, question: String? = nil, isCompleted: Bool? = nil) {
        self.answer = answer
        self.maxLength = maxLength
        self.question = question
        self.isCompleted = isCompleted
    }
}
