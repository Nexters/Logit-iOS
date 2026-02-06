//
//  HomeView.swift
//  Logit
//
//  Created by 임재현 on 1/24/26.
//

import SwiftUI

struct HomeView: View {
    @EnvironmentObject var appState: AppState
    @StateObject private var viewModel = HomeViewModel()
    
    var body: some View {
        VStack(spacing: 0) {
            HomeHeaderView()
            
            ExperienceTypeSection()
                .padding(.top, 22.adjustedLayout)
            
            ProjectListSection(
                hasProjects: viewModel.hasProjects,
                projects: viewModel.projects,
                isLoading: viewModel.isLoading
            )
            .padding(.top, 43.adjustedLayout)
            
            Spacer()
        }
        .task {
            // 화면이 나타날 때 프로젝트 목록 조회
            await viewModel.fetchProjects()
        }
        .refreshable {
            // Pull to refresh
            await viewModel.fetchProjects()
        }
    }
}
