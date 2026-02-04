//
//  ChatEndpoint.swift
//  Logit
//
//  Created by 임재현 on 2/4/26.
//

import Foundation

enum ChatEndpoint: Endpoint {
    case sendMessage  // 메시지 전송 (SSE 스트리밍)
    case getChatHistory(questionId: String, cursor: String?, size: Int)  // 채팅 히스토리 조회
    case updateAnswer(chatId: String)                   // 자기소개서 답변 업데이트
    
    var path: String {
        switch self {
        case .sendMessage:
            return "/api/v1/projects/chats"
            
        case .getChatHistory(let questionId, let cursor, let size):
            var path = "/api/v1/projects/chats/\(questionId)"
            
            var queryItems: [String] = []
            
            // size 설정 (1~100 범위 제한)
            let validSize = min(max(size, 1), 100)
            queryItems.append("size=\(validSize)")
            
            // cursor가 있으면 추가
            if let cursor = cursor {
                let encodedCursor = cursor.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? cursor
                queryItems.append("cursor=\(encodedCursor)")
            }
            
            if !queryItems.isEmpty {
                path += "?" + queryItems.joined(separator: "&")
            }
            
            return path
            
        case .updateAnswer(let chatId):
            return "/api/v1/projects/chats/\(chatId)/answer"
        }
    }
    
    var method: HTTPMethod {
        switch self {
        case .sendMessage:
            return .post
        case .getChatHistory:
            return .get
        case .updateAnswer:
            return .patch
        }
    }
}
