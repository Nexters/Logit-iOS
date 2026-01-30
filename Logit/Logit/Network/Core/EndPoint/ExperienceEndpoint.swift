//
//  ExperienceEndpoint.swift
//  Logit
//
//  Created by 임재현 on 1/30/26.
//

import Foundation

enum ExperienceEndpoint: Endpoint {
    case createExperience           // 경험 등록
    case getExperienceList(limit:Int, offset:Int)          // 경험 목록 조회
    case searchExperiences(query: String, limit: Int)         // 경험 검색
    case getExperienceDetail(experienceId: String)  // 경험 상세 조회
    case updateExperience(experienceId:String)     // 경험 수정
    case deleteExperience(experienceId:String)     // 경험 삭제
    case getMatchingExperiences(questionId:String)     // 문항과 매칭되는 경험 조회
    
    var path: String {
        switch self {
        case .createExperience:
            return "/api/v1/experiences"
        case .getExperienceList(let limit, let offset):
            let limitValue = min(limit, 1000)
           return "/api/v1/experiences?limit=\(limitValue)&offset=\(offset)"
        case .searchExperiences(let query, let limit):
               let encodedQuery = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? query
               let limitValue = min(limit, 100)  
               return "/api/v1/experiences/search?q=\(encodedQuery)&limit=\(limitValue)"
        case .getExperienceDetail(let id):
            return "/api/v1/experiences/\(id)"
        case .updateExperience(let id):
            return "/api/v1/experiences/\(id)"
        case .deleteExperience(let id):
            return "/api/v1/experiences/\(id)"
        case .getMatchingExperiences(let id):
            return "/api/v1/experiences/match-question/\(id)"
        }
    }
    
    var method: HTTPMethod {
        switch self {
        case .createExperience:
            return .post
        case .getExperienceList, .searchExperiences, .getExperienceDetail, .getMatchingExperiences:
            return .get
        case .updateExperience:
            return .patch
        case .deleteExperience:
            return .delete
        }
    }
}
