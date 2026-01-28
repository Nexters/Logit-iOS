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
    
    func navigateToCoverLetterWorkspace(questions: [QuestionItem]) {
        path.append(AddFlowRoute.workspace(questions))
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
            CoverLetterQuestionsView()
            
        case .workspace(let questions):
            CoverLetterWorkspaceView(questions: questions)
            

        }
    }
}

