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
        
}


class DefaultExperienceRepository: ExperienceRepository {
    
    private let networkClient: NetworkClient
    
    init(networkClient: NetworkClient) {
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
}
