//
//  ChatHistoryResponse.swift
//  Logit
//
//  Created by 임재현 on 2/4/26.
//

import Foundation

struct ChatHistoryResponse: Decodable {
    let projectName: String
    let projectCreatedAt: String
    let questionId: String
    let question: String
    let answer: String
    let chats: [ChatMessage]
    let experienceIds: [String]
    let nextCursor: String?
    let hasMore: Bool
    let remainingChats: Int
    
    enum CodingKeys: String, CodingKey {
        case projectName = "project_name"
        case projectCreatedAt = "project_created_at"
        case questionId = "question_id"
        case question
        case answer
        case chats
        case experienceIds = "experience_ids"
        case nextCursor = "next_cursor"
        case hasMore = "has_more"
        case remainingChats = "remaining_chats"
    }
}


struct ChatMessage: Decodable {
    let id: String
    let role: ChatRole
    let content: String
    let isDraft: Bool
    let createdAt: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case role
        case content
        case isDraft = "is_draft"
        case createdAt = "created_at"
    }
}

enum ChatRole: String, Decodable {
    case user
    case assistant
}
