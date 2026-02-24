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
        .background(.white)
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

struct ProjectCardCell: View {
    @EnvironmentObject var appState: AppState
    let project: ProjectListItemResponse

    private var isCompleted: Bool {
        project.totalQuestions > 0 && project.completedQuestions == project.totalQuestions
    }

    private var dDayText: String {
        guard let dueDateStr = project.dueDate else { return "상시" }

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let date = dateFormatter.date(from: dueDateStr) ?? dueDateStr.toDate()

        guard let targetDate = date else { return "상시" }

        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let target = calendar.startOfDay(for: targetDate)
        let days = calendar.dateComponents([.day], from: today, to: target).day ?? 0

        if days > 0 { return "D-\(days)" }
        else if days == 0 { return "D-Day" }
        else { return "마감" }
    }

    var body: some View {
        HStack(alignment: .center, spacing: 12.adjustedLayout) {
            // 세로 막대기
            RoundedRectangle(cornerRadius: 2.adjustedLayout)
                .fill(.primary70)
                .frame(width: 3.adjustedWidth, height: 40.adjustedHeight)

            // 왼쪽 정보 (D-day + 날짜 / 회사명)
            VStack(alignment: .leading, spacing: 4.adjustedLayout) {
                HStack(spacing: 6.adjustedLayout) {
                    Text(dDayText)
                        .typo(.semibold_12)
                        .foregroundStyle(dDayText == "마감" ? .gray200 : .primary500)
                        .padding(.horizontal, 6.adjustedLayout)
                        .padding(.vertical, 2.adjustedLayout)
                        .background(
                            RoundedRectangle(cornerRadius: 4.adjustedLayout)
                                .fill(dDayText == "마감" ? Color.gray70 : Color.primary50)
                        )

                    Text(project.updatedAt.toDateString(format: "yyyy.MM.dd"))
                        .typo(.regular_14_140)
                        .foregroundStyle(.gray100)
                }

                Text(project.company)
                    .typo(.medium_15)
                    .foregroundStyle(.black)
                    .lineLimit(1)
            }

            Spacer()

            // 오른쪽: 완료 상태 아이콘 + 세로 말줄임 버튼
            HStack(spacing: 8.adjustedLayout) {
                Image(isCompleted ? "checkmark_selected" : "checkmark_unselected")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 20.adjustedLayout, height: 20.adjustedLayout)

                Button {
                    // TODO: 메뉴 액션
                } label: {
                    Image(systemName: "ellipsis")
                        .rotationEffect(.degrees(90))
                        .foregroundStyle(.gray300)
                        .frame(width: 20.adjustedLayout, height: 20.adjustedLayout)
                }
            }
        }
        .padding(.horizontal, 20.adjustedLayout)
        .padding(.vertical, 14.adjustedLayout)
        .background(Color.white)
        .contentShape(Rectangle())
        .onTapGesture {
            appState.openWorkspace(projectId: project.id)
        }
    }
}
