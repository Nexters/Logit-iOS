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


// 3단계: 경험 유형 선택
struct ExperienceTypeSelectionView: View {
    @EnvironmentObject var viewModel: ExperienceFlowViewModel
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        VStack {
            Text("3단계: 경험 유형 선택")
                .font(.largeTitle)
                .padding()
            
            Button("이전") {
                viewModel.navigateBack()
            }
            .padding()
            .background(Color.gray)
            .foregroundColor(.white)
            .cornerRadius(8)
            
            Button("완료") {
                // TODO: 경험 저장 로직
                dismiss() // ExperienceFlowCoordinator 전체 닫기
            }
            .padding()
            .background(Color.green)
            .foregroundColor(.white)
            .cornerRadius(8)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.orange.opacity(0.1))
        .navigationBarHidden(true)
    }
}
