//
//  ReportRepository.swift
//  Logit
//
//  Created by 임재현 on 2/21/26.
//

import Foundation

protocol ReportRepository {
    /// 경험 요약 조회
    func getExperienceSummary() async throws -> ExperienceSummaryResponse
}

// MARK: - Implementation
class DefaultReportRepository: ReportRepository {
    
    private let networkClient: NetworkClient
    
    init(networkClient: NetworkClient = DefaultNetworkClient()) {
        self.networkClient = networkClient
    }

    // 경험 요약 조회
    func getExperienceSummary() async throws -> ExperienceSummaryResponse {
        return try await networkClient.request(
            endpoint: ReportEndpoint.getExperienceSummary,
            body: nil as Empty?
        )
    }
}
