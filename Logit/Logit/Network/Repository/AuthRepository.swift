//
//  AuthRepository.swift
//  Logit
//
//  Created by 임재현 on 2/22/26.
//

import Foundation

protocol AuthRepository {
    func appleLogin(request: AppleLoginRequest) async throws -> AppleLoginResponse
    func googleLogin(request: GoogleLoginRequest) async throws -> AppleLoginResponse
    func logout() async throws
}

class DefaultAuthRepository: AuthRepository {

    private let networkClient: NetworkClient
    private let tokenManager: TokenManager
    private let baseURL: String

    init(
        networkClient: NetworkClient = DefaultNetworkClient(),
        tokenManager: TokenManager = .shared,
        baseURL: String = Config.baseURL
    ) {
        self.networkClient = networkClient
        self.tokenManager = tokenManager
        self.baseURL = baseURL
    }

    func appleLogin(request: AppleLoginRequest) async throws -> AppleLoginResponse {
        return try await networkClient.request(
            endpoint: AuthEndpoint.appleLogin,
            body: request
        )
    }

    func googleLogin(request: GoogleLoginRequest) async throws -> AppleLoginResponse {
        return try await networkClient.request(
            endpoint: AuthEndpoint.googleLogin,
            body: request
        )
    }

    // Authorization 헤더에 refresh_token을 사용하는 특수 케이스
    func logout() async throws {
        guard let refreshToken = tokenManager.refreshToken else {
            throw APIError.unauthorized(message: "Refresh token이 없습니다.")
        }

        guard let url = URL(string: baseURL + AuthEndpoint.logout.path) else {
            throw APIError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = AuthEndpoint.logout.method.rawValue
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(refreshToken)", forHTTPHeaderField: "Authorization")

        let body = LogoutRequest(
            authorization: "Bearer \(refreshToken)",
            refreshToken: refreshToken
        )
        request.httpBody = try JSONEncoder().encode(body)

        let (_, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }

        guard (200...299).contains(httpResponse.statusCode) else {
            throw APIError.unknown(statusCode: httpResponse.statusCode, message: nil)
        }

        tokenManager.clearTokens()
    }
}
