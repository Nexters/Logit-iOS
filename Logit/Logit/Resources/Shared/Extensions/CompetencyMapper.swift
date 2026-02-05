//
//  CompetencyMapper.swift
//  Logit
//
//  Created by 임재현 on 2/5/26.
//

import Foundation

enum CompetencyMapper {
    private static let mapping: [String: String] = [
        "고객 가치 지향": "고객이해력",
        "기술적 전문성": "전문성",
        "협력적 소통": "소통력",
        "주도적 실행력": "실행력",
        "논리적 분석력": "분석력",
        "창의적 문제해결": "문제해결력",
        "유연한 적응력": "적응력",
        "끈기있는 책임감": "책임감"
    ]
    
    // UI 표시용 (등록 시 사용)
    static func toApiValue(_ displayTitle: String) -> String {
        return mapping.first(where: { $0.value == displayTitle })?.key ?? displayTitle
    }
    
    // API → Display (리스트에서 사용)
    static func toDisplayTitle(_ apiValue: String) -> String {
        return mapping[apiValue] ?? apiValue
    }
}
