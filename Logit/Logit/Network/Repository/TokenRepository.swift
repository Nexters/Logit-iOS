//
//  TokenRepository.swift
//  Logit
//

import Foundation

protocol TokenRepository {
    func getBalance() async throws -> TokenBalanceResponse
}

class DefaultTokenRepository: TokenRepository {

    private let networkClient: NetworkClient

    init(networkClient: NetworkClient = DefaultNetworkClient()) {
        self.networkClient = networkClient
    }

    func getBalance() async throws -> TokenBalanceResponse {
        return try await networkClient.request(
            endpoint: TokenEndpoint.getBalance,
            body: nil
        )
    }
}
