//
//  CreateQuestionRequest.swift
//  Logit
//
//  Created by 임재현 on 1/31/26.
//

import Foundation

struct CreateQuestionRequest: Encodable {
    let maxLength: Int
    let question: String
    
    enum CodingKeys: String, CodingKey {
        case maxLength = "max_length"
        case question
    }
}
