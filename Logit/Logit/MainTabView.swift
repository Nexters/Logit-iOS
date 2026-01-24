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
                    Image(systemName: selectedTab == .home ? "house.fill" : "house")
                    Text("홈")
                }
                .tag(Tab.home)
            
            Text("1")
                .tabItem {
                    Image(systemName: selectedTab == .search ? "magnifyingglass.circle.fill" : "magnifyingglass")
                    Text("검색")
                }
                .tag(Tab.search)
            
            Text("2")
                .tabItem {
                    Image(systemName: selectedTab == .add ? "plus.circle.fill" : "plus.circle")
                    Text("추가")
                }
                .tag(Tab.add)
            
            Text("3")
                .tabItem {
                    Image(systemName: selectedTab == .activity ? "bell.fill" : "bell")
                    Text("알림")
                }
                .tag(Tab.activity)
            
            Text("4")
                .tabItem {
                    Image(systemName: selectedTab == .profile ? "person.fill" : "person")
                    Text("프로필")
                }
                .tag(Tab.profile)
        }
        .tint(.blue)  // 선택된 탭 색상
    }
}
