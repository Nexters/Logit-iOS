//
//  ProjectEndpoint.swift
//  Logit
//
//  Created by 임재현 on 1/30/26.
//

import Foundation

enum ProjectEndpoint: Endpoint {
    case createProject              // 프로젝트 생성
    case getProjectList(skip: Int, limit: Int)   // 프로젝트 목록 조회
    case getProjectDetail(projectId: String)       // 프로젝트 상세 조회
    case updateProject(projectId: String)          // 프로젝트 수정
    case deleteProject(projectId: String)          // 프로젝트 삭제
    
    var path: String {
        switch self {
        case .createProject:
            return "/api/v1/projects/"
        case .getProjectList(let skip, let limit):
            let skipValue = max(skip, 0) 
            let limitValue = max(1, min(limit, 200))
            return "/api/v1/projects?skip=\(skipValue)&limit=\(limitValue)"
        case .getProjectDetail(let id):
            return "/api/v1/projects/\(id)"
        case .updateProject(let id):
            return "/api/v1/projects/\(id)"
        case .deleteProject(let id):
            return "/api/v1/projects/\(id)"
        }
    }
    
    var method: HTTPMethod {
        switch self {
        case .createProject:
            return .post
        case .getProjectList, .getProjectDetail:
            return .get
        case .updateProject:
            return .patch
        case .deleteProject:
            return .delete
        }
    }
}
