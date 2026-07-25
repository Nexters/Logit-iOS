//
//  TokenEndpoint.swift
//  Logit
//

import Foundation

enum TokenEndpoint: Endpoint {
    case getBalance

    var path: String {
        switch self {
        case .getBalance:
            return "/api/v1/tokens/balance"
        }
    }

    var method: HTTPMethod {
        switch self {
        case .getBalance:
            return .get
        }
    }
}
