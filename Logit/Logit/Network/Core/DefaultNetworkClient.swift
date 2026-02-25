//
//  DefaultNetworkClient.swift
//  Logit
//
//  Created by 임재현 on 1/30/26.
//

import Foundation

class DefaultNetworkClient: NetworkClient {
    private let baseURL: String
    private let tokenManager: TokenManager

    init(
        baseURL: String = Config.baseURL,
        tokenManager: TokenManager = .shared
    ) {
        self.baseURL = baseURL
        self.tokenManager = tokenManager
    }
    
    
    func request<T: Decodable>(
        endpoint: Endpoint,
        body: Encodable? = nil
    ) async throws -> T {
        let data = try await performRequest(endpoint: endpoint, body: body)
        
        do {
            let decoded = try JSONDecoder().decode(T.self, from: data)
            return decoded
        } catch {
            throw APIError.decodingError(error)
        }
    }
    
    func request(
        endpoint: Endpoint,
        body: Encodable? = nil
    ) async throws {
        _ = try await performRequest(endpoint: endpoint, body: body)
    }
    
    
    private func performRequest(
        endpoint: Endpoint,
        body: Encodable?,
        isRetry: Bool = false
    ) async throws -> Data {
        // 1. URLRequest 생성
        var request = try createURLRequest(endpoint: endpoint, body: body)
        
        // 2. 토큰 추가 (없으면 즉시 인증 실패 처리)
        guard let accessToken = tokenManager.accessToken else {
            NotificationCenter.default.post(name: .authenticationRequired, object: nil)
            throw APIError.unauthorized(message: "로그인이 필요합니다.")
        }
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        
        NetworkLogger.logRequest(request, body: body)
        
        // 3. 요청 실행
        let (data, response) = try await URLSession.shared.data(for: request)
        
        // 4. 응답 검증
        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }
        
        NetworkLogger.logResponse(httpResponse, data: data)
        
        // 5. 상태 코드 처리
        switch httpResponse.statusCode {
        case 200...299:
            return data
            
        case 400:
            let error = try parseErrorResponse(from: data)
            throw APIError.badRequest(message: error)
            
        case 401:
            // 토큰 만료 - 재시도 1회만
            if !isRetry {
                try await refreshAccessToken()
                return try await performRequest(endpoint: endpoint, body: body, isRetry: true)
            } else {
                let error = try parseErrorResponse(from: data)
                throw APIError.unauthorized(message: error)
            }
            
        case 403:
            let error = try parseErrorResponse(from: data)
            throw APIError.forbidden(message: error)
            
        case 404:
            let error = try parseErrorResponse(from: data)
            throw APIError.notFound(message: error)
            
        case 422:
            let validationErrors = try parseValidationErrors(from: data)
            throw APIError.validationError(errors: validationErrors)
            
        case 500...599:
            let error = try? parseErrorResponse(from: data)
            throw APIError.serverError(message: error ?? "서버 오류가 발생했습니다.")
            
        default:
            let error = try? parseErrorResponse(from: data)
            throw APIError.unknown(statusCode: httpResponse.statusCode, message: error)
        }
    }
    
    private func createURLRequest(
        endpoint: Endpoint,
        body: Encodable?
    ) throws -> URLRequest {
        // URL 생성
        guard let url = URL(string: baseURL + endpoint.path) else {
            throw APIError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = endpoint.method.rawValue
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Body 추가
        if let body = body {
            do {
                request.httpBody = try JSONEncoder().encode(body)
            } catch {
                throw APIError.networkError(error)
            }
        }
        
        return request
    }
    
    private func parseErrorResponse(from data: Data) throws -> String {
        let errorResponse = try JSONDecoder().decode(ErrorResponse.self, from: data)
        
        switch errorResponse.detail {
        case .string(let message):
            return message
        case .validationErrors:
            return "검증 오류가 발생했습니다."
        }
    }
    
    private func parseValidationErrors(from data: Data) throws -> [ValidationError] {
        let errorResponse = try JSONDecoder().decode(ErrorResponse.self, from: data)
        
        switch errorResponse.detail {
        case .validationErrors(let details):
            return details.map { ValidationError(from: $0) }
        case .string:
            return []
        }
    }
    
    
    private func refreshAccessToken() async throws {
        // 이미 갱신 중인 task가 있으면 결과를 공유 (중복 요청 방지)
        if let task = tokenManager.sharedRefreshTask {
            return try await task.value
        }

        let task = Task<Void, Error> {
            guard let refreshToken = tokenManager.refreshToken else {
                throw APIError.unauthorized(message: "Refresh token이 없습니다.")
            }

            // API 스펙: Authorization: Bearer {refresh_token} 헤더로 요청
            var request = try createURLRequest(
                endpoint: AuthEndpoint.refreshToken,
                body: nil
            )
            request.setValue("Bearer \(refreshToken)", forHTTPHeaderField: "Authorization")

            let (data, response) = try await URLSession.shared.data(for: request)

            guard let httpResponse = response as? HTTPURLResponse,
                  httpResponse.statusCode == 200 else {
                throw APIError.unauthorized(message: "토큰 갱신에 실패했습니다.")
            }

            // 서버가 새 access token + refresh token 모두 body로 반환
            let tokenResponse = try JSONDecoder().decode(TokenResponse.self, from: data)
            if let newRefresh = tokenResponse.refreshToken {
                tokenManager.saveTokens(access: tokenResponse.accessToken, refresh: newRefresh)
            } else {
                tokenManager.updateAccessToken(tokenResponse.accessToken)
            }
        }

        tokenManager.sharedRefreshTask = task

        do {
            try await task.value
            tokenManager.sharedRefreshTask = nil
        } catch {
            tokenManager.sharedRefreshTask = nil
            tokenManager.clearTokens()
            // refresh 완전 실패 → 로그인 화면으로 이동
            NotificationCenter.default.post(name: .authenticationRequired, object: nil)
            throw error
        }
    }
}


struct TokenResponse: Decodable {
    let accessToken: String
    let refreshToken: String?
}

struct Empty: Encodable {}
