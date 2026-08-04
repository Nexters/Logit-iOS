//
//  MainTabView.swift
//  Logit
//
//  Created by 임재현 on 1/24/26.
//

import SwiftUI

struct MainTabView: View {
    @EnvironmentObject var appState: AppState
    @State private var selectedTab: Tab = .home
    @State private var rewardToastMessage: String? = nil
    @State private var rewardToastQueue: [String] = []
    @State private var isShowingRewardToast: Bool = false
    
    enum Tab {
        case home, search, add, activity, report
    }
    
    var body: some View {
        ZStack {
            // 컨텐츠
            VStack(spacing: 0) {
                // 선택된 탭에 따른 뷰
                Group {
                    switch selectedTab {
                    case .home:
                        HomeView()
                    case .search:
                        CoverLetterListView()
                    case .add:
                        EmptyView()
                    case .activity:
                        ExperienceListView()
                    case .report:
                        ReportView()
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            
            // Custom TabBar
            VStack {
                Spacer()
                CustomTabBar(selectedTab: $selectedTab) {
                    appState.startAddFlow()
                }
            }
        }
        .ignoresSafeArea(.keyboard)
        .overlay(alignment: .bottom) {
            if isShowingRewardToast, let message = rewardToastMessage {
                ToastView(message: message)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                    .padding(.bottom, 16)
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .attendanceRewardReceived)) { notification in
            guard let amount = notification.userInfo?["amount"] as? Int else { return }
            enqueueRewardToast("출석체크로 +\(amount)토큰이 지급되었어요")
        }
        .onReceive(NotificationCenter.default.publisher(for: .signupBonusReceived)) { notification in
            guard let amount = notification.userInfo?["amount"] as? Int else { return }
            enqueueRewardToast("신규 가입 보너스로 +\(amount)토큰이 지급되었어요")
        }
        .onReceive(NotificationCenter.default.publisher(for: .referralRewardReceived)) { notification in
            guard let amount = notification.userInfo?["amount"] as? Int else { return }
            enqueueRewardToast("친구 초대 보상으로 +\(amount)토큰이 지급되었어요")
        }
        .onReceive(NotificationCenter.default.publisher(for: .monthlyGrantReceived)) { notification in
            guard let amount = notification.userInfo?["amount"] as? Int else { return }
            enqueueRewardToast("월간 토큰 +\(amount)토큰이 지급되었어요")
        }
        .overlay {
            if appState.isShowingDeleteAlert {
                LogitAlertView(
                    message: appState.deleteAlertMessage,
                    subMessage: appState.deleteAlertSubMessage,
                    cancelTitle: "취소하기",
                    confirmTitle: "삭제하기",
                    onCancel: { appState.dismissDeleteAlert() },
                    onConfirm: {
                        appState.onDeleteConfirm?()
                        appState.dismissDeleteAlert()
                    }
                )
            }
        }
        .fullScreenCover(isPresented: $appState.isShowingAddFlow) {
            AddFlowCoordinator()
        }
        .fullScreenCover(item: $appState.selectedProjectId) { projectId in
            CoverLetterWorkspaceView(
                projectId: projectId,
                questions: [],
                initialTab: appState.openWorkspaceOnCoverLetterTab ? .coverLetter : .chat
            )
        }
        .fullScreenCover(isPresented: $appState.isShowingSettings) {
            SettingsView()
        }
    }

    private func enqueueRewardToast(_ message: String) {
        rewardToastQueue.append(message)
        guard !isShowingRewardToast else { return }
        showNextRewardToast()
    }

    private func showNextRewardToast() {
        guard !rewardToastQueue.isEmpty else { return }
        rewardToastMessage = rewardToastQueue.removeFirst()
        withAnimation(.spring()) { isShowingRewardToast = true }
        Task {
            try? await Task.sleep(for: .seconds(3))
            withAnimation { isShowingRewardToast = false }
            try? await Task.sleep(for: .seconds(0.4))
            showNextRewardToast()
        }
    }
}

struct CustomTabBar: View {
    @Binding var selectedTab: MainTabView.Tab
    let onAddTapped: () -> Void
    
    var body: some View {
        HStack(spacing: 0) {
            TabBarItem(
                icon: selectedTab == .home ? "home_selected" : "home",
                title: "홈",
                isSelected: selectedTab == .home
            ) {
                selectedTab = .home
            }
            
            TabBarItem(
                icon: selectedTab == .search ? "file_selected" : "file",
                title: "자소서",
                isSelected: selectedTab == .search
            ) {
                selectedTab = .search
            }
            
            TabBarItem(
                icon: selectedTab == .add ? "plus_selected" : "plus",
                title: "추가",
                isSelected: selectedTab == .add
            ) {
                onAddTapped()
            }
            
            TabBarItem(
                icon: selectedTab == .activity ? "folder_selected" : "folder",
                title: "경험",
                isSelected: selectedTab == .activity
            ) {
                selectedTab = .activity
            }
            
            TabBarItem(
                icon: selectedTab == .report ? "report_selected" : "report",
                title: "리포트",
                isSelected: selectedTab == .report
            ) {
                selectedTab = .report
            }
        }
        .frame(height: 63)
        .background(.white)
    }
}

struct TabBarItem: View {
    let icon: String
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 2) {
                Image(icon)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 25, height: 25)
                
                Text(title)
                    .typo(.medium_10)
                    .foregroundStyle(isSelected ? .black : .primary400)
            }
            .padding(.top, 12)
            .padding(.bottom, 12)
            .frame(maxWidth: .infinity)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}
