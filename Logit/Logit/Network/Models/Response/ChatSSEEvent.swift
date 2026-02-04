//
//  ChatSSEEvent.swift
//  Logit
//
//  Created by 임재현 on 2/4/26.
//

import Foundation

enum ChatSSEEvent {
    case content(String)
    case done(chatId: String, isDraft: Bool, remainingChats: Int)
    case error(String)
}

struct ChatContentEvent: Decodable {
    let type: String
    let content: String
}

struct ChatDoneEvent: Decodable {
    let type: String
    let chatId: String
    let isDraft: Bool
    let remainingChats: Int
    
    enum CodingKeys: String, CodingKey {
        case type
        case chatId = "chat_id"
        case isDraft = "is_draft"
        case remainingChats = "remaining_chats"
    }
}

struct ChatErrorEvent: Decodable {
    let type: String
    let message: String
}
