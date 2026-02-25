//
//  EndPoint.swift
//  Logit
//
//  Created by 임재현 on 1/30/26.
//

import Foundation

protocol Endpoint {
    var path: String { get }
    var method: HTTPMethod { get }
    /// 인증 토큰이 필요한 엔드포인트 여부 (기본값 true)
    var requiresAuth: Bool { get }
}

extension Endpoint {
    var requiresAuth: Bool { true }
}
