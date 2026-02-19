//
//  ProjectResponse.swift
//  Logit
//
//  Created by 임재현 on 1/30/26.
//

import Foundation

struct ProjectResponse: Decodable {
    let id: String
    let company: String
    let jobPosition: String
    let recruitNotice: String
    let dueDate: String?
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

struct ProjectCreateResponse: Decodable {
    let project: ProjectDetail
    let questions: [QuestionDetail]
    
    struct ProjectDetail: Decodable {
        let id: String
        let company: String
        let jobPosition: String
        let recruitNotice: String
        let dueDate: String?
        let userId: String
        let createdAt: String
        let updatedAt: String
        let deletedAt: String?
        
        enum CodingKeys: String, CodingKey {
            case id
            case company
            case jobPosition = "job_position"
            case recruitNotice = "recruit_notice"
            case dueDate = "due_date"
            case userId = "user_id"
            case createdAt = "created_at"
            case updatedAt = "updated_at"
            case deletedAt = "deleted_at"
        }
    }
    
    struct QuestionDetail: Decodable {
        let id: String
        let question: String
        let maxLength: Int
        let answer: String?
        
        enum CodingKeys: String, CodingKey {
            case id
            case question
            case maxLength = "max_length"
            case answer
        }
    }
}
