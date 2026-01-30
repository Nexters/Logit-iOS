//
//  ProjectRepository.swift
//  Logit
//
//  Created by 임재현 on 1/30/26.
//

import Foundation

protocol ProjectRepository {
    /// 프로젝트  생성
    func createProject(request: CreateProjectRequest) async throws -> ProjectResponse
}


final class DefaultProjectRepository: ProjectRepository {
    private let networkClient: NetworkClient
    
    init(networkClient: NetworkClient = DefaultNetworkClient()) {
        self.networkClient = networkClient
    }
    
    // 프로젝트 생성
    func createProject(request: CreateProjectRequest) async throws -> ProjectResponse {
        return try await networkClient.request(
            endpoint: ProjectEndpoint.createProject,
            body: request
        )
    }
}
