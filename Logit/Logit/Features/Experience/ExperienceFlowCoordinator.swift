//
//  ExperienceFlowCoordinator.swift
//  Logit
//
//  Created by 임재현 on 1/29/26.
//

import SwiftUI

struct ExperienceFlowCoordinator: View {
    @Environment(\.dismiss) var dismiss
    @StateObject private var viewModel = ExperienceFlowViewModel()
    
    var body: some View {
        NavigationStack(path: $viewModel.path) {
            ExperienceInfoInputView()  // 1단계: 경험 정보 입력
                .navigationDestination(for: ExperienceFlowRoute.self) { route in
                    viewModel.destination(for: route)
                }
        }
        .navigationBarHidden(true)
        .environmentObject(viewModel)
        .presentationDetents([.large])
        .presentationDragIndicator(.hidden)
    }
}

@MainActor
class ExperienceFlowViewModel: ObservableObject {
    @Published var path = NavigationPath()
    
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
    
    func popToRoot() {
        path.removeLast(path.count)
    }
    
    // View 생성
    @ViewBuilder
    func destination(for route: ExperienceFlowRoute) -> some View {
        switch route {
        case .starMethod:
            ExperienceStarMethodView()  // 2단계
            
        case .experienceType:
            ExperienceTypeSelectionView()  // 3단계
        }
    }
}

enum ExperienceFlowRoute: Hashable {
    case starMethod        // 2단계: STAR 기반 경험 정리
    case experienceType    // 3단계: 경험 유형 선택
}
