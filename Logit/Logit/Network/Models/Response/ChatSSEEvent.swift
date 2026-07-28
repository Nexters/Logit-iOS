//
//  ChatSSEEvent.swift
//  Logit
//
//  Created by 임재현 on 2/4/26.
//

import Foundation

enum ChatSSEEvent {
    case content(String)
    case done(chatId: String, isDraft: Bool, draftLimitExceeded: Bool, tokenBalance: Int, tokensUsed: Int)
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
    let draftLimitExceeded: Bool
    let tokenBalance: Int
    let tokensUsed: Int

    enum CodingKeys: String, CodingKey {
        case type
        case chatId = "chat_id"
        case isDraft = "is_draft"
        case draftLimitExceeded = "draft_limit_exceeded"
        case tokenBalance = "token_balance"
        case tokensUsed = "tokens_used"
    }
}

struct ChatErrorEvent: Decodable {
    let type: String
    let message: String
}
