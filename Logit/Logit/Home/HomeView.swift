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
    @State private var openMenuProjectId: String? = nil

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
                        isLoading: viewModel.isLoading,
                        onDelete: { projectId in
                            appState.requestDeleteConfirmation {
                                Task { await viewModel.deleteProject(projectId: projectId) }
                            }
                        },
                        openMenuProjectId: $openMenuProjectId
                    )
                    .padding(.top, 43.adjustedLayout)
                }
            }
            .refreshable {
                await viewModel.fetchProjects()
            }
            .simultaneousGesture(
                TapGesture().onEnded { openMenuProjectId = nil }
            )
        }
        .background(.white)
        .onAppear {
            Task {
                async let projects: () = viewModel.fetchProjects()
                async let user: () = viewModel.fetchCurrentUser()
                _ = await (projects, user)
            }
        }
        .onChange(of: appState.selectedProjectId) { _, newValue in
            if newValue == nil {
                Task {
                    await viewModel.fetchProjects()
                }
            }
        }
        .onChange(of: appState.isShowingAddFlow) { _, newValue in
            if !newValue {
                Task {
                    await viewModel.fetchProjects()
                }
            }
        }
    }
}
