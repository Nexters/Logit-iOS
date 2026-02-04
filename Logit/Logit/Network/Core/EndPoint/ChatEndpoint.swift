//
//  ChatEndpoint.swift
//  Logit
//
//  Created by 임재현 on 2/4/26.
//

import Foundation

enum ChatEndpoint: Endpoint {
    case sendMessage  // 메시지 전송 (SSE 스트리밍)
    
    var path: String {
        switch self {
        case .sendMessage:
            return "/api/v1/projects/chats"
        }
    }
    
    var method: HTTPMethod {
        switch self {
        case .sendMessage:
            return .post
        }
    }
}
