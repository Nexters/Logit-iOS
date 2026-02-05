//
//  QuestionEndpoint.swift
//  Logit
//
//  Created by 임재현 on 1/31/26.
//

import Foundation

enum QuestionEndpoint: Endpoint {
    case createQuestion(projectId: String)                              // 문항 생성
    case getQuestionList(projectId: String)                             // 문항 목록 조회
    case getQuestionDetail(projectId: String, questionId: String)       // 문항 상세 조회
    case updateQuestion(projectId: String, questionId: String)          // 문항 수정
    case deleteQuestion(projectId: String, questionId: String)          // 문항 삭제
    
    var path: String {
        switch self {
        case .createQuestion(let projectId):
            return "/api/v1/projects/\(projectId)/questions/"
            
        case .getQuestionList(let projectId):
            return "/api/v1/projects/\(projectId)/questions"
            
        case .getQuestionDetail(let projectId, let questionId):
            return "/api/v1/projects/\(projectId)/questions/\(questionId)"
            
        case .updateQuestion(let projectId, let questionId):
            return "/api/v1/projects/\(projectId)/questions/\(questionId)"
            
        case .deleteQuestion(let projectId, let questionId):
            return "/api/v1/projects/\(projectId)/questions/\(questionId)"
        }
    }
    
    var method: HTTPMethod {
        switch self {
        case .createQuestion:
            return .post
        case .getQuestionList, .getQuestionDetail:
            return .get
        case .updateQuestion:
            return .patch
        case .deleteQuestion:
            return .delete
        }
    }
}
