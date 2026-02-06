//
//  ProjectListSection.swift
//  Logit
//
//  Created by 임재현 on 1/25/26.
//

import SwiftUI

struct ProjectListSection: View {
    @EnvironmentObject var appState: AppState
    let hasProjects: Bool
    let projects: [ProjectListItemResponse]
    let isLoading: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8.adjustedLayout) {
            // 헤더
            HStack {
                Text("프로젝트 목록")
                    .typo(.bold_18)
                    .foregroundStyle(.black)
                
                Spacer()
            }
            .padding(.horizontal, 20.adjustedLayout)
            
            // 컨텐츠
            if isLoading {
                // 로딩 중
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .padding(.vertical, 60.adjustedLayout)
            } else if hasProjects {
                ProjectListView(projects: projects)
                    .padding(.top, 8.adjustedLayout)
            } else {
                ProjectEmptyView()
            }
        }
    }
}

struct ProjectEmptyView: View {
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        VStack(spacing: 0) {
            Image("app_status_empty2")
                .resizable()
                .scaledToFit()
                .frame(width: 80.adjustedLayout, height: 80.adjustedLayout)
            
            Text("자기소개서를 생성해보세요")
                .typo(.medium_15)
                .foregroundStyle(.gray100)
                .padding(.top, 16.adjustedLayout)
            
            Button {
                appState.startAddFlow()
            } label: {
                Text("자기소개서 작성")
                    .typo(.medium_15)
                    .foregroundStyle(.white)
                    .padding(.horizontal, 24.adjustedLayout)
                    .padding(.vertical, 7.5.adjustedLayout)
                    .background(.primary100)
                    .cornerRadius(8.adjustedLayout)
            }
            .padding(.top, 17.adjustedLayout)
        }
        .offset(y: -10.adjustedLayout)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(.vertical, 60.adjustedLayout)
        .background(.white)
        .cornerRadius(16.adjustedLayout)
        .padding(.horizontal, 20.adjustedLayout)
    }
}

struct ProjectListView: View {
    let projects: [ProjectListItemResponse]
    
    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                ForEach(projects.indices, id: \.self) { index in
                    ProjectCardCell(
                        project: projects[index]
                    )
                    
                    if index < projects.count - 1 {
                        Divider()
                            .background(Color.gray100)
                            .padding(.horizontal, 20.adjustedLayout)
                    }
                }
            }
            .padding(.bottom, (49 + 20).adjustedLayout)
        }
    }
}

struct ProjectCardCell: View {
    @EnvironmentObject var appState: AppState
    let project: ProjectListItemResponse
    
    var body: some View {
        HStack(spacing: 12.adjustedLayout) {
            // 세로 막대기
            RoundedRectangle(cornerRadius: 2.adjustedLayout)
                .fill(.primary70)
                .frame(width: 3.adjustedWidth, height: 24.adjustedHeight)
            
            // 타이틀
            Text(project.company)
                .typo(.medium_15)
                .foregroundStyle(.black)
                .lineLimit(1)
            
            Spacer()
            
            // 날짜
            Text(project.updatedAt.toDateString(format: "yyyy.MM.dd"))
                .typo(.regular_14_140)
                .foregroundStyle(.gray100)
        }
        .padding(.horizontal, 20.adjustedLayout)
        .padding(.vertical, 17.5.adjustedLayout)
        .background(Color.white)
        .contentShape(Rectangle())
        .onTapGesture {
            appState.openWorkspace(projectId: project.id)
        }
    }
}
