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
    @State private var showAttendanceToast: Bool = false
    @State private var attendanceTokens: Int = 0

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
        .overlay(alignment: .bottom) {
            if showAttendanceToast {
                ToastView(message: "출석체크로 +\(attendanceTokens)토큰이 지급되었어요")
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                    .padding(.bottom, 16)
            }
        }
        .onChange(of: viewModel.attendanceAmount) { amount in
            guard amount > 0 else { return }
            attendanceTokens = amount
            withAnimation(.spring()) { showAttendanceToast = true }
            Task {
                try? await Task.sleep(for: .seconds(3))
                withAnimation { showAttendanceToast = false }
            }
        }
        .onAppear {
            Task {
                async let projects: () = viewModel.fetchProjects()
                async let user: () = viewModel.fetchCurrentUser()
                async let tokenBalance: () = viewModel.fetchTokenBalance()
                _ = await (projects, user, tokenBalance)
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
