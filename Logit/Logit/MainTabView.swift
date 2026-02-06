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
    
    enum Tab {
        case home, search, add, activity, profile
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
                        Text("검색")
                    case .add:
                        EmptyView()
                    case .activity:
                        ExperienceListView()
                    case .profile:
                        Text("리포트")
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
        .fullScreenCover(isPresented: $appState.isShowingAddFlow) {
            AddFlowCoordinator()
        }
        .fullScreenCover(item: $appState.selectedProjectId) { projectId in
            CoverLetterWorkspaceView(
                projectId: projectId, questions: []
            )
        }
        .fullScreenCover(isPresented: $appState.isShowingSettings) {
            SettingsView()
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
                title: "검색",
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
                icon: selectedTab == .profile ? "report_selected" : "report",
                title: "리포트",
                isSelected: selectedTab == .profile
            ) {
                selectedTab = .profile
            }
        }
        .frame(height: 49)
        .background(
            .white
        )
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
                    .font(.system(size: 10)) // TODO: - medium 10으로 교체 해야함
                    .foregroundStyle(isSelected ? .black : .primary400)
            }
            .frame(maxWidth: .infinity)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}
