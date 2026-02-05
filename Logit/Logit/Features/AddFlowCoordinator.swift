//
//  AddFlowCoordinator.swift
//  Logit
//
//  Created by 임재현 on 1/26/26.
//

import SwiftUI

struct AddFlowCoordinator: View {
    @Environment(\.dismiss) var dismiss
    @StateObject private var viewModel = AddFlowViewModel()
    
    var body: some View {
        NavigationStack(path: $viewModel.path) {
            Group {
                switch viewModel.rootScreen {
                case .applicationInfo:
                    ApplicationInfoView()
                    
                case .workspace(let projectId, let questions):
                    CoverLetterWorkspaceView(
                        questions: questions, projectId: projectId
                    )
                }
            }
            .navigationDestination(for: AddFlowRoute.self) { route in
                viewModel.destination(for: route)
            }
        }
        .navigationBarHidden(true)
        .environmentObject(viewModel)
        .presentationDetents([.large])
        .presentationDragIndicator(.hidden)
    }
}
