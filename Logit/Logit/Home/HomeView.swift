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

            ScrollView {
                VStack(spacing: 0) {
                    ExperienceTypeSection()
                        .padding(.top, 22.adjustedLayout)

                    ProjectListSection(
                        hasProjects: viewModel.hasProjects,
                        projects: viewModel.projects,
                        isLoading: viewModel.isLoading
                    )
                    .padding(.top, 43.adjustedLayout)
                }
            }
            .refreshable {
                await viewModel.fetchProjects()
            }
        }
        .background(.white)
        .task {
            await viewModel.fetchProjects()
        }
    }
}
