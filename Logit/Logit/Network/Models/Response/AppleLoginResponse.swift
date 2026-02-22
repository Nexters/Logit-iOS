//
//  AppleLoginResponse.swift
//  Logit
//
//  Created by 임재현 on 2/22/26.
//

import Foundation

struct AppleLoginResponse: Decodable, Equatable {
    let accessToken: String
    let refreshToken: String
    let isNewUser: Bool

    enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
        case refreshToken = "refresh_token"
        case isNewUser = "is_new_user"
    }
}
