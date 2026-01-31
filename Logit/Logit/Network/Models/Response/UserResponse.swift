//
//  UserResponse.swift
//  Logit
//
//  Created by 임재현 on 1/31/26.
//

import Foundation

struct UserResponse: Decodable {
    let email: String
    let fullName: String
    let id: String
    let oauthProvider: String
    let profileImageUrl: String?
    let createdAt: String
    let isActive: Bool
    
    enum CodingKeys: String, CodingKey {
        case email
        case fullName = "full_name"
        case id
        case oauthProvider = "oauth_provider"
        case profileImageUrl = "profile_image_url"
        case createdAt = "created_at"
        case isActive = "is_active"
    }
}
