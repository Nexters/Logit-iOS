//
//  ExperienceListResponse.swift
//  Logit
//
//  Created by 임재현 on 1/30/26.
//

import Foundation

// 경험목록 조회
struct ExperienceListResponse: Decodable {
    let experiences: [ExperienceResponse]
    let limit: Int
    let offset: Int
    let total: Int
}
