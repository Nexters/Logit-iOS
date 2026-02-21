//
//  AppleLoginRequest.swift
//  Logit
//
//  Created by 임재현 on 2/22/26.
//

import Foundation

struct AppleLoginRequest: Encodable {
    let idToken: String
    let fullName: String?

    enum CodingKeys: String, CodingKey {
        case idToken = "id_token"
        case fullName = "full_name"
    }
}
