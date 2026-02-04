//
//  QuestionReposiotry.swift
//  Logit
//
//  Created by 임재현 on 1/31/26.
//

import Foundation

protocol QuestionRepository {
    /// 문항 생성
    func createQuestion(projectId: String, request: CreateQuestionRequest) async throws -> QuestionResponse
}

class DefaultQuestionRepository: QuestionRepository {
    
    private let networkClient: NetworkClient
    
    init(networkClient: NetworkClient) {
        self.networkClient = networkClient
    }
    
    // 문항 생성
    func createQuestion(projectId: String, request: CreateQuestionRequest) async throws -> QuestionResponse {
        return try await networkClient.request(
            endpoint: QuestionEndpoint.createQuestion(projectId: projectId),
            body: request
        )
    }
}
