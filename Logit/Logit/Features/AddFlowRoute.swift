//
//  AddFlowRoute.swift
//  Logit
//
//  Created by 임재현 on 1/26/26.
//

import Foundation

enum AddFlowRoute: Hashable {
    case applicationInfo // 지원 정보 입력
    case coverLetterQuestions // 자소서 문항
    case questionDetails(String) // 상세문항 (q1,q2...)
}
