//
//  ReportEndpoint.swift
//  Logit
//
//  Created by 임재현 on 2/21/26.
//

import Foundation

enum ReportEndpoint: Endpoint {
    case getExperienceSummary
    
    var path: String {
        switch self {
        case .getExperienceSummary:
            return "/api/v1/report/experience-summary"
        }
    }
    
    var method: HTTPMethod {
        switch self {
        case .getExperienceSummary:
            return .get
        }
    }
}
