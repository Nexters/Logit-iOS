//
//  UpdateProjectRequest.swift
//  Logit
//
//  Created by 임재현 on 1/30/26.
//

import Foundation

struct UpdateProjectRequest: Encodable {
    let company: String?
    let companyTalent: String?
    let dueDate: String?
    let jobPosition: String?
    
    enum CodingKeys: String, CodingKey {
        case company
        case companyTalent = "company_talent"
        case dueDate = "due_date"
        case jobPosition = "job_position"
    }
}
