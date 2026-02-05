//
//  NetworkLogger.swift
//  Logit
//
//  Created by 임재현 on 2/5/26.
//

import Foundation

enum NetworkLogger {
    static var isEnabled = true
    
    // 민감 정보 마스킹 옵션
    static var maskSensitiveData = false  // true면 토큰 일부만 표시
    
    static func logRequest(_ request: URLRequest, body: Encodable? = nil) {
        guard isEnabled else { return }
        
        print("\n ============ REQUEST ============")
        print("URL: \(request.url?.absoluteString ?? "nil")")
        print("Method: \(request.httpMethod ?? "nil")")
        
        //  Headers (Token 포함)
        if let headers = request.allHTTPHeaderFields, !headers.isEmpty {
            print("\n📋 Headers:")
            headers.forEach { key, value in
                if key == "Authorization" {
                    // Token 마스킹 처리
                    let displayValue = maskSensitiveData ? maskToken(value) : value
                    print("  \(key): \(displayValue)")
                } else {
                    print("  \(key): \(value)")
                }
            }
        }
        
        if let body = body {
            print("\n Body:")
            print(body.toPrettyJSON())
        } else if let bodyData = request.httpBody,
                  let bodyString = String(data: bodyData, encoding: .utf8) {
            print("\n Body:")
            print(bodyString)
        }
        
        print("====================================\n")
    }
    
    static func logResponse(_ response: HTTPURLResponse, data: Data) {
        guard isEnabled else { return }
        
        print("\n ============ RESPONSE ===========")
        print("Status: \(response.statusCode)")
        print("URL: \(response.url?.absoluteString ?? "nil")")
        
        // Response Headers (새로 발급된 토큰 있을 수도)
        if let headers = response.allHeaderFields as? [String: String], !headers.isEmpty {
            print("\n📋 Response Headers:")
            headers.forEach { key, value in
                if key.lowercased().contains("authorization") || key.lowercased().contains("token") {
                    let displayValue = maskSensitiveData ? maskToken(value) : value
                    print("  \(key): \(displayValue)")
                } else {
                    print("  \(key): \(value)")
                }
            }
        }
        
        if let responseString = String(data: data, encoding: .utf8) {
            print("\n Body:")
            
            // JSON이면 pretty print
            if let jsonData = responseString.data(using: .utf8),
               let jsonObject = try? JSONSerialization.jsonObject(with: jsonData),
               let prettyData = try? JSONSerialization.data(withJSONObject: jsonObject, options: .prettyPrinted),
               let prettyString = String(data: prettyData, encoding: .utf8) {
                print(prettyString)
            } else {
                print(responseString)
            }
        }
        
        print("====================================\n")
    }
    
    static func logError(_ error: Error, request: URLRequest) {
        guard isEnabled else { return }
        
        print("\n❌ ============ ERROR ==============")
        print("URL: \(request.url?.absoluteString ?? "nil")")
        print("Error: \(error.localizedDescription)")
        
        if let apiError = error as? APIError {
            print("API Error: \(apiError)")
        }
        
        print("====================================\n")
    }
    
    // Token 마스킹 헬퍼 함수
    private static func maskToken(_ token: String) -> String {
        // "Bearer eyJhbGc..." -> "Bearer eyJ...c..." (앞 3자, 뒤 3자만 표시)
        if token.hasPrefix("Bearer ") {
            let actualToken = token.replacingOccurrences(of: "Bearer ", with: "")
            if actualToken.count > 10 {
                let prefix = String(actualToken.prefix(3))
                let suffix = String(actualToken.suffix(3))
                return "Bearer \(prefix)***...(masked)...***\(suffix)"
            }
        }
        
        // 일반 토큰
        if token.count > 10 {
            let prefix = String(token.prefix(3))
            let suffix = String(token.suffix(3))
            return "\(prefix)***...(masked)...***\(suffix)"
        }
        
        return "***(masked)***"
    }
}

extension NetworkLogger {
    // 토큰 상태만 따로 확인
    static func logTokenStatus(accessToken: String?, refreshToken: String?) {
        guard isEnabled else { return }
        
        print("\n ========== TOKEN STATUS ==========")
        
        if let accessToken = accessToken {
            let display = maskSensitiveData ? maskToken(accessToken) : accessToken
            print("Access Token: \(display)")
            print("Length: \(accessToken.count) characters")
        } else {
            print("Access Token: nil ")
        }
        
        if let refreshToken = refreshToken {
            let display = maskSensitiveData ? maskToken(refreshToken) : refreshToken
            print("Refresh Token: \(display)")
            print("Length: \(refreshToken.count) characters")
        } else {
            print("Refresh Token: nil")
        }
        
        print("====================================\n")
    }
}


extension Encodable {
    func toPrettyJSON() -> String {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        
        guard let data = try? encoder.encode(self),
              let string = String(data: data, encoding: .utf8) else {
            return "Failed to encode"
        }
        return string
    }
}
