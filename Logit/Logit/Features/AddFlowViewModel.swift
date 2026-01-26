//
//  AddFlowViewModel.swift
//  Logit
//
//  Created by 임재현 on 1/26/26.
//

import SwiftUI

@MainActor
class AddFlowViewModel: ObservableObject {
    @Published var path = NavigationPath()
    
    // Navigation 함수들
    
    func navigateToCoverLetterQuestions() {
        path.append(AddFlowRoute.coverLetterQuestions)
    }
    
    func navigateToApplicationInfo() {
        path.append(AddFlowRoute.applicationInfo)
    }
    
    func navigateToQuestions() {
        path.append(AddFlowRoute.coverLetterQuestions)
    }
    
    func navigateBack() {
        if !path.isEmpty {
            path.removeLast()
        }
    }
    
    // View 생성
    @ViewBuilder
    func destination(for route: AddFlowRoute) -> some View {
        switch route {
        case .applicationInfo:
            // TODO: 실제 View로 교체
            EmptyView()
            
        case .coverLetterQuestions:
            Text("자기소개서 문항 화면")
                .navigationTitle("자기소개서 문항")
            
        case .questionDetails(let id):
            Text("문항 상세: \(id)")
                .navigationTitle("문항 작성")
            

        }
    }
}

