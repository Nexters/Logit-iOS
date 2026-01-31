//
//  UpdateUserRequest.swift
//  Logit
//
//  Created by 임재현 on 1/31/26.
//

import Foundation

struct UpdateUserRequest: Encodable {
    let email: String?
    let fullName: String?
    
    enum CodingKeys: String, CodingKey {
        case email
        case fullName = "full_name"
    }
    
    init(email: String? = nil, fullName: String? = nil) {
        self.email = email
        self.fullName = fullName
    }
}
