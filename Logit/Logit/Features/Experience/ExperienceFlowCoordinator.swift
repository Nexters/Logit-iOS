//
//  ExperienceFlowCoordinator.swift
//  Logit
//
//  Created by 임재현 on 1/29/26.
//

import SwiftUI

struct ExperienceFlowCoordinator: View {
    @Environment(\.dismiss) var dismiss
    @StateObject private var viewModel: ExperienceFlowViewModel
    let onComplete: (() -> Void)?
    
    init(onComplete: (() -> Void)? = nil) {
        self.onComplete = onComplete
        let networkClient = DefaultNetworkClient()
        let repository = DefaultExperienceRepository(networkClient: networkClient)
        _viewModel = StateObject(wrappedValue: ExperienceFlowViewModel(experienceRepository: repository))
    }

    init(experience: ExperienceResponse, onComplete: (() -> Void)? = nil) {
        self.onComplete = onComplete
        let networkClient = DefaultNetworkClient()
        let repository = DefaultExperienceRepository(networkClient: networkClient)
        _viewModel = StateObject(wrappedValue: ExperienceFlowViewModel(
            experienceRepository: repository,
            existingExperience: experience
        ))
    }
    
    var body: some View {
        NavigationStack(path: $viewModel.path) {
            ExperienceInfoInputView()
                .navigationDestination(for: ExperienceFlowRoute.self) { route in
                    viewModel.destination(for: route)
                }
        }
        .navigationBarHidden(true)
        .environmentObject(viewModel)
        .presentationDetents([.large])
        .presentationDragIndicator(.hidden)
        .onAppear {
            viewModel.onComplete = { [dismiss] in
                onComplete?()  // 부모에게 성공 알림 
                dismiss()      // sheet dismiss
            }
        }
    }
}


enum ExperienceFlowRoute: Hashable {
    case starMethod        // 2단계: STAR 기반 경험 정리
}
