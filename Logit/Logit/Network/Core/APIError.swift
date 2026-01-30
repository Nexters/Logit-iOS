//
//  APIError.swift
//  Logit
//
//  Created by 임재현 on 1/30/26.
//

import Foundation

enum APIError {
    case invalidURL
    case invalidResponse
    case badRequest(message: String) // 400
    case unauthorized(message: String)  // 401
    case forbidden(message: String) // 403
    case notFound(message: String)  // 404
    case validationError(errors: [ValidationError]) // 422
    case serverError(message: String) // 500
    case networkError(Error)
    case decodingError(Error)
    case unknown(statusCode: Int, message: String?)
    
    var localizedDescription: String {
        switch self {
        case .invalidURL:
            return "잘못된 URL입니다."
        case .invalidResponse:
            return "잘못된 응답입니다."
        case .badRequest(let message):
            return message
        case .unauthorized(let message):
            return message
        case .forbidden(let message):
            return message
        case .notFound(let message):
            return message
        case .validationError(let errors):
            return errors.map { $0.message }.joined(separator: "\n")
        case .serverError(let message):
            return message
        case .networkError(let error):
            return "네트워크 오류: \(error.localizedDescription)"
        case .decodingError(let error):
            return "데이터 파싱 오류: \(error.localizedDescription)"
        case .unknown(let statusCode, let message):
            if let message = message {
                return "알 수 없는 오류 (코드: \(statusCode)): \(message)"
            } else {
                return "알 수 없는 오류 (코드: \(statusCode))"
            }
        }
    }
    
}

struct ErrorResponse: Decodable {
    let detail: DetailType
    
    enum DetailType: Decodable {
        case string(String)
        case validationErrors([ValidationErrorDetail])
        
        init(from decoder: Decoder) throws {
            let container = try decoder.singleValueContainer()
            
            // String으로 파싱 시도
            if let stringValue = try? container.decode(String.self) {
                self = .string(stringValue)
                return
            }
            
            // ValidationError 배열로 파싱 시도
            if let arrayValue = try? container.decode([ValidationErrorDetail].self) {
                self = .validationErrors(arrayValue)
                return
            }
            
            throw DecodingError.typeMismatch(
                DetailType.self,
                DecodingError.Context(
                    codingPath: decoder.codingPath,
                    debugDescription: "Expected String or [ValidationErrorDetail]"
                )
            )
        }
    }
}

struct ValidationErrorDetail: Decodable {
    let loc: [String]
    let msg: String
    let type: String
}

struct ValidationError {
    let field: String
    let message: String
    let type: String
    
    init(from detail: ValidationErrorDetail) {
        // loc에서 필드명 추출 (예: ["body", "email"] -> "email")
        self.field = detail.loc.last ?? "unknown"
        self.message = detail.msg
        self.type = detail.type
    }
}
