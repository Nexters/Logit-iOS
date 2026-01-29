//
//  ExperienceFlowViewModel.swift
//  Logit
//
//  Created by 임재현 on 1/29/26.
//

import SwiftUI

@MainActor
class ExperienceFlowViewModel: ObservableObject {
    @Published var path = NavigationPath()
    
    // 데이터
    @Published var experienceTitle: String = ""
    @Published var experienceType: String?
    @Published var situation: String = ""
    @Published var task: String = ""
    @Published var action: String = ""
    @Published var result: String = ""
    @Published var selectedCompetency: String?
    
    var onComplete: ((ExperienceData) -> Void)?
    
    // Navigation 함수들
    func navigateToStarMethod() {
        path.append(ExperienceFlowRoute.starMethod)
    }
    
    func navigateToExperienceType() {
        path.append(ExperienceFlowRoute.experienceType)
    }
    
    func navigateBack() {
        if !path.isEmpty {
            path.removeLast()
        }
    }
    
    func saveExperience() {
        print("=== 경험 등록 완료 ===")
        print("경험 제목: \(experienceTitle)")
        print("경험 유형: \(experienceType ?? "미선택")")
        print("\n[STAR 분석]")
        print("Situation: \(situation)")
        print("Task: \(task)")
        print("Action: \(action)")
        print("Result: \(result)")
        print("\n핵심 역량: \(selectedCompetency ?? "미선택")")
        print("==================")
        
        let experienceData = ExperienceData(
            title: experienceTitle,
            type: experienceType ?? "",
            situation: situation,
            task: task,
            action: action,
            result: result,
            competency: selectedCompetency ?? ""
        )
        
        onComplete?(experienceData)
    }
    
    @ViewBuilder
    func destination(for route: ExperienceFlowRoute) -> some View {
        switch route {
        case .starMethod:
            ExperienceStarMethodView()
        case .experienceType:
            ExperienceTypeSelectionView()
        }
    }
}
