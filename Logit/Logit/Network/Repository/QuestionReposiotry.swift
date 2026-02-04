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
    /// 문항 목록 조회
    func getQuestionList(projectId: String) async throws -> [QuestionResponse]
    /// 문항 상세 조회
    func getQuestionDetail(projectId: String, questionId: String) async throws -> QuestionDetailResponse
    /// 문항 수정
    func updateQuestion(projectId: String, questionId: String, request: UpdateQuestionRequest) async throws -> QuestionDetailResponse
    /// 문항 삭제
    func deleteQuestion(projectId: String, questionId: String) async throws
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
    
    // 문항 목록 조회
    func getQuestionList(projectId: String) async throws -> [QuestionResponse] {
        return try await networkClient.request(
            endpoint: QuestionEndpoint.getQuestionList(projectId: projectId),
            body: nil
        )
    }
    
    // 문항 상세 조회
    func getQuestionDetail(projectId: String, questionId: String) async throws -> QuestionDetailResponse {
        return try await networkClient.request(
            endpoint: QuestionEndpoint.getQuestionDetail(projectId: projectId, questionId: questionId),
            body: nil
        )
    }
    
    // 문항 수정
    func updateQuestion(projectId: String, questionId: String, request: UpdateQuestionRequest) async throws -> QuestionDetailResponse {
        return try await networkClient.request(
            endpoint: QuestionEndpoint.updateQuestion(projectId: projectId, questionId: questionId),
            body: request
        )
    }
    
    // 문항 삭제
    func deleteQuestion(projectId: String, questionId: String) async throws {
        try await networkClient.request(
            endpoint: QuestionEndpoint.deleteQuestion(projectId: projectId, questionId: questionId),
            body: nil
        )
    }
}
