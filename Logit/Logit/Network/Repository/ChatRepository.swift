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
    
    /// 채팅 히스토리 조회
    func getChatHistory(
        projectId: String,
        questionId: String,
        cursor: String?,
        size: Int
    ) async throws -> ChatHistoryResponse
    
    /// 자기소개서 답변 업데이트
    func updateAnswer(
        projectId: String,
        chatId: String,
        request: UpdateAnswerRequest
    ) async throws -> UpdateAnswerResponse
}

class DefaultChatRepository: ChatRepository {
    
    private let sseClient: SSEClient
    private let networkClient: NetworkClient
    
    init(
        sseClient: SSEClient,
        networkClient: NetworkClient
    ) {
        self.sseClient = sseClient
        self.networkClient = networkClient
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
    
    // 채팅 히스토리 조회
    func getChatHistory(
        projectId: String,
        questionId: String,
        cursor: String? = nil,
        size: Int = 20
    ) async throws -> ChatHistoryResponse {
        return try await networkClient.request(
            endpoint: ChatEndpoint.getChatHistory(
                questionId: questionId,
                cursor: cursor,
                size: size
            ),
            body: nil
        )
    }
    
    // 자기소개서 답변 업데이트
    func updateAnswer(
        projectId: String,
        chatId: String,
        request: UpdateAnswerRequest
    ) async throws -> UpdateAnswerResponse {
        return try await networkClient.request(
            endpoint: ChatEndpoint.updateAnswer(
                chatId: chatId
            ),
            body: request
        )
    }
}
