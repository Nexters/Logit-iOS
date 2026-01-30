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
    /// 프로젝트  목록 조회
    func getProjectList(skip: Int, limit: Int) async throws -> [ProjectListItemResponse]
    /// 프로젝트  상세 조회
    func getProjectDetail(projectId: String) async throws -> ProjectDetailResponse
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
    
    // 프로젝트 목록조회
    func getProjectList(skip: Int, limit: Int) async throws -> [ProjectListItemResponse] {
        return try await networkClient.request(
            endpoint: ProjectEndpoint.getProjectList(skip: skip, limit: limit),
            body: nil
        )
    }
    
    //프로젝트 상세조회
    func getProjectDetail(projectId: String) async throws -> ProjectDetailResponse {
        return try await networkClient.request(
            endpoint: ProjectEndpoint.getProjectDetail(projectId: projectId),
            body: nil
        )
    }
}
