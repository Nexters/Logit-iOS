//
//  LogoutRequest.swift
//  Logit
//
//  Created by 임재현 on 2/24/26.
//

import Foundation

struct LogoutRequest: Encodable {
    let authorization: String
    let refreshToken: String

    enum CodingKeys: String, CodingKey {
        case authorization
        case refreshToken = "refresh_token"
    }
}
