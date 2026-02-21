//
//  APIEndpoint.swift
//  Logit
//
//  Created by 임재현 on 1/30/26.
//

import Foundation

enum AuthEndpoint: Endpoint {
    // Auth
    case googleLogin     // 구글 로그인
    case googleCallback  // 구글 콜백
    case appleLogin      // 애플 로그인 (모바일)
    case refreshToken    // 액세스토큰 갱신
    case logout          // 로그아웃

    var path: String {
        switch self {
        case .googleLogin:
            return "/api/v1/auth/google"
        case .googleCallback:
            return "/api/v1/auth/google/callback"
        case .appleLogin:
            return "/api/v1/auth/apple/mobile"
        case .refreshToken:
            return "/api/v1/auth/refresh"
        case .logout:
            return "/api/v1/auth/logout"
        }
    }

    var method: HTTPMethod {
        switch self {
        case .googleLogin, .googleCallback:
            return .get
        case .appleLogin, .refreshToken, .logout:
            return .post
        }
    }
}
