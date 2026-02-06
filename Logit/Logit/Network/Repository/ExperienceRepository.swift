//
//  ExperienceRepository.swift
//  Logit
//
//  Created by 임재현 on 1/30/26.
//

import Foundation

protocol ExperienceRepository {
    /// 경험 등록
    func createExperience(_ request: CreateExperienceRequest) async throws -> ExperienceResponse
    /// 경험 목록 조회
    func getExperienceList(limit: Int, offset: Int) async throws -> ExperienceListResponse
    /// 경험 검색
    func searchExperiences(query: String, limit: Int) async throws -> ExperienceSearchResponse
    /// 경험 상세검색
    func getExperienceDetail(experienceId: String) async throws -> ExperienceResponse
    /// 경험  수정
    func updateExperience(experienceId: String, request: UpdateExperienceRequest) async throws -> ExperienceResponse
    /// 경험  삭제
    func deleteExperience(experienceId: String) async throws
    /// 문항 매칭 경험 조회
    func getMatchingExperiences(questionId: String) async throws -> MatchingExperiencesResponse
}


class DefaultExperienceRepository: ExperienceRepository {
    
    private let networkClient: NetworkClient
    
    init(networkClient: NetworkClient = DefaultNetworkClient()) {
        self.networkClient = networkClient
    }
  
    // 경험 등록
    func createExperience(_ request: CreateExperienceRequest) async throws -> ExperienceResponse {
        return try await networkClient.request(
            endpoint: ExperienceEndpoint.createExperience,
            body: request
        )
    }
    // 경험 목록 조회
    func getExperienceList(limit: Int = 100, offset: Int = 0) async throws -> ExperienceListResponse {
            // Query parameter는 endpoint에서 처리하거나 여기서 URL에 추가
            return try await networkClient.request(
                endpoint: ExperienceEndpoint.getExperienceList(limit: limit, offset: offset),
                body: nil as Empty?
            )
        }
    
    // 경험 검색
    func searchExperiences(query: String, limit: Int = 10) async throws -> ExperienceSearchResponse {
        return try await networkClient.request(
            endpoint: ExperienceEndpoint.searchExperiences(query: query, limit: limit),
            body: nil as Empty?
        )
    }
    
    // 경험 상세 조회
    func getExperienceDetail(experienceId: String) async throws -> ExperienceResponse {
        return try await networkClient.request(
            endpoint: ExperienceEndpoint.getExperienceDetail(experienceId: experienceId),
            body: nil as Empty?
        )
    }
    
    // 경험 상세 조회
    func updateExperience(experienceId: String, request: UpdateExperienceRequest) async throws -> ExperienceResponse {
        return try await networkClient.request(
            endpoint: ExperienceEndpoint.updateExperience(experienceId: experienceId),
            body: request
        )
    }
    
    // 경험 삭제
    func deleteExperience(experienceId: String) async throws {
        try await networkClient.request(
            endpoint: ExperienceEndpoint.deleteExperience(experienceId: experienceId),
            body: nil as Empty?
        )
    }
    
    // 문항 매칭 경험 조회
    func getMatchingExperiences(questionId: String) async throws -> MatchingExperiencesResponse {
        return try await networkClient.request(
            endpoint: ExperienceEndpoint.getMatchingExperiences(questionId: questionId),
            body: nil as Empty?
        )
    }
}
