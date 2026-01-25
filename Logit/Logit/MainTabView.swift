//
//  MainTabView.swift
//  Logit
//
//  Created by 임재현 on 1/24/26.
//

import SwiftUI

struct MainTabView: View {
    @State private var selectedTab: Tab = .home
    
    enum Tab {
        case home
        case search
        case add
        case activity
        case profile
    }
    
    var body: some View {
        TabView(selection: $selectedTab) {
            HomeView()
                .tabItem {
                    Image(selectedTab == .home ? "home_selected" : "home")
                    Text("홈")
                }
                .tag(Tab.home)
            
            Text("1")
                .tabItem {
                    Image(selectedTab == .search ? "file_selected" : "file")
                    Text("검색")
                }
                .tag(Tab.search)
            
            Text("2")
                .tabItem {
                    Image(selectedTab == .add ? "plus_selected" : "plus")
                    Text("추가")
                }
                .tag(Tab.add)
            
            Text("3")
                .tabItem {
                    Image(selectedTab == .activity ? "folder_selected" : "folder")
                    Text("경험")
                }
                .tag(Tab.activity)
            
            Text("4")
                .tabItem {
                    Image(selectedTab == .profile ? "report_selected" : "report")
                    Text("리포트")
                }
                .tag(Tab.profile)
        }
        .tint(.secondary100)  // 선택된 탭 색상
    }
}
