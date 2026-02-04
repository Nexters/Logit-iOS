//
//  ChatRepository.swift
//  Logit
//
//  Created by 임재현 on 2/4/26.
//

import Foundation

protocol ChatRepository {
    /// 메시지 전송 (SSE 스트리밍)
    func sendMessage(
        projectId: String,
        request: SendMessageRequest
    ) -> AsyncThrowingStream<ChatSSEEvent, Error>
}

class DefaultChatRepository: ChatRepository {
    
    private let sseClient: SSEClient
    
    init(sseClient: SSEClient) {
        self.sseClient = sseClient
    }
    
    // 메시지 전송 (SSE 스트리밍)
    func sendMessage(
        projectId: String,
        request: SendMessageRequest
    ) -> AsyncThrowingStream<ChatSSEEvent, Error> {
        return sseClient.stream(
            endpoint: ChatEndpoint.sendMessage,
            body: request
        )
    }
}
