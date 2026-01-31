//
//  UserEndpoint.swift
//  Logit
//
//  Created by 임재현 on 1/31/26.
//

import Foundation

enum UserEndpoint: Endpoint {
    case getCurrentUser              // 현재 사용자 정보 조회
    case deleteCurrentUser           // 현재 사용자 계정 삭제
    case updateCurrentUser           // 현재 사용자 정보 수정
    case getUserById(userId: String) // 특정 사용자 정보 조회
    
    var path: String {
        switch self {
        case .getCurrentUser:
            return "/api/v1/users/me"
        case .deleteCurrentUser:
            return "/api/v1/users/me"
        case .updateCurrentUser:
            return "/api/v1/users/me"
        case .getUserById(let userId):
            return "/api/v1/users/\(userId)"
        }
    }
    
    var method: HTTPMethod {
        switch self {
        case .getCurrentUser, .getUserById:
            return .get
        case .deleteCurrentUser:
            return .delete
        case .updateCurrentUser:
            return .patch
        }
    }
}
