//
//  GoogleLoginRequest.swift
//  Logit
//
//  Created by 임재현 on 2/22/26.
//

import Foundation

struct GoogleLoginRequest: Encodable {
    let idToken: String

    enum CodingKeys: String, CodingKey {
        case idToken = "id_token"
    }
}
