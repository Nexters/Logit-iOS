//
//  ProjectListItemResponse.swift
//  Logit
//
//  Created by 임재현 on 1/30/26.
//

import Foundation

struct ProjectListItemResponse: Decodable, Identifiable {
    let id: String
    let company: String
    let jobPosition: String
    let updatedAt: String
    let questionId: String?
    
    let completedQuestions: Int
    let totalQuestions: Int
    let dueDate: String

    enum CodingKeys: String, CodingKey {
        case id
        case company
        case jobPosition = "job_position"
        case updatedAt = "updated_at"
        case questionId = "question_id"
        case completedQuestions = "completed_questions"
        case totalQuestions = "total_questions"
        case dueDate = "due_date"
    }
}
