//
//  UserRepository.swift
//  Logit
//
//  Created by 임재현 on 1/31/26.
//

import Foundation

protocol UserRepository {
    /// 현재 사용자 정보 조회
    func getCurrentUser() async throws -> UserResponse
    /// 현재 사용자 계정 삭제
    func deleteCurrentUser() async throws
    /// 현재 사용자 정보 수정
    func updateCurrentUser(request: UpdateUserRequest) async throws -> UserResponse
    /// 특정 사용자 정보 조회
    func getUserById(userId: String) async throws -> UserResponse
}

class DefaultUserRepository: UserRepository {
    
    private let networkClient: NetworkClient
    
    init(networkClient: NetworkClient) {
        self.networkClient = networkClient
    }
    
    // 현재 사용자 정보 조회
    func getCurrentUser() async throws -> UserResponse {
        return try await networkClient.request(
            endpoint: UserEndpoint.getCurrentUser,
            body: nil
        )
    }
    
    // 현재 사용자 계정 삭제
    func deleteCurrentUser() async throws {
        try await networkClient.request(
            endpoint: UserEndpoint.deleteCurrentUser,
            body: nil
        )
    }
    
    // 현재 사용자 정보 수정
    func updateCurrentUser(request: UpdateUserRequest) async throws -> UserResponse {
        return try await networkClient.request(
            endpoint: UserEndpoint.updateCurrentUser,
            body: request
        )
    }
    
    // 특정 사용자 정보 조회
    func getUserById(userId: String) async throws -> UserResponse {
        return try await networkClient.request(
            endpoint: UserEndpoint.getUserById(userId: userId),
            body: nil
        )
    }
}
