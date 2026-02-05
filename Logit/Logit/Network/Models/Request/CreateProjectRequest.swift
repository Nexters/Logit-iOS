//
//  CreateProjectRequest.swift
//  Logit
//
//  Created by 임재현 on 1/30/26.
//

import Foundation

struct CreateProjectRequest: Encodable {
    let company: String
    let companyTalent: String
    let dueDate: String?
    let jobPosition: String
    let questions: [QuestionRequest]
    let recruitNotice: String
    
    enum CodingKeys: String, CodingKey {
        case company
        case companyTalent = "company_talent"
        case dueDate = "due_date"
        case jobPosition = "job_position"
        case questions
        case recruitNotice = "recruit_notice"
    }
}

struct QuestionRequest: Encodable {
    let maxLength: Int
    let question: String
    
    enum CodingKeys: String, CodingKey {
        case maxLength = "max_length"
        case question
    }
}
