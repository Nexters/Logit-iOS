//
//  AuthRepository.swift
//  Logit
//
//  Created by 임재현 on 2/22/26.
//

import Foundation

protocol AuthRepository {
    func appleLogin(request: AppleLoginRequest) async throws -> AppleLoginResponse
}

class DefaultAuthRepository: AuthRepository {

    private let networkClient: NetworkClient

    init(networkClient: NetworkClient = DefaultNetworkClient()) {
        self.networkClient = networkClient
    }

    func appleLogin(request: AppleLoginRequest) async throws -> AppleLoginResponse {
        return try await networkClient.request(
            endpoint: AuthEndpoint.appleLogin,
            body: request
        )
    }
}
