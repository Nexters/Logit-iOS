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
    var onDelete: ((String) -> Void)? = nil
    @Binding var openMenuProjectId: String?

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
                ProjectListView(projects: projects, openMenuProjectId: $openMenuProjectId, onDelete: onDelete)
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
    @Binding var openMenuProjectId: String?
    var onDelete: ((String) -> Void)? = nil

    var body: some View {
        VStack(spacing: 0) {
            ForEach(projects.indices, id: \.self) { index in
                ProjectCardCell(
                    project: projects[index],
                    isMenuOpen: openMenuProjectId == projects[index].id,
                    onMenuToggle: {
                        openMenuProjectId = openMenuProjectId == projects[index].id ? nil : projects[index].id
                    },
                    onMenuClose: { openMenuProjectId = nil },
                    onDelete: { onDelete?(projects[index].id) }
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
    var isMenuOpen: Bool = false
    var onMenuToggle: (() -> Void)? = nil
    var onMenuClose: (() -> Void)? = nil
    var onDelete: (() -> Void)? = nil

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

    private var deleteMenuPopup: some View {
        Button {
            onMenuClose?()
            onDelete?()
        } label: {
            HStack(spacing: 8) {
                Image(systemName: "trash")
                    .font(.system(size: 14))
                    .foregroundStyle(.black)

                Text("삭제")
                    .typo(.regular_14_140)
                    .foregroundStyle(.black)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.white)
                    .shadow(color: .black.opacity(0.12), radius: 8, x: 0, y: 4)
            )
        }
    }

    var body: some View {
        ZStack {
            // 팝업 외부 탭 시 닫기
            if isMenuOpen {
                Color.clear
                    .contentShape(Rectangle())
                    .onTapGesture { onMenuClose?() }
            }

            HStack(alignment: .center, spacing: 12.adjustedLayout) {
                // 세로 막대기
                RoundedRectangle(cornerRadius: 2.adjustedLayout)
                    .fill(.primary70)
                    .frame(width: 3.adjustedWidth, height: 60.adjustedHeight)

                // 왼쪽 정보 (D-day + 날짜 / 회사명)
                VStack(alignment: .leading, spacing: 12.adjustedLayout) {
                    HStack(spacing: 10.adjustedLayout) {
                        Text(dDayText)
                            .typo(.semibold_16)
                            .foregroundStyle(dDayText == "마감" ? .gray200 : .primary200)
                            .padding(.horizontal, 11.5.adjustedLayout)
                            .padding(.vertical, 3.adjustedLayout)
                            .background(
                                RoundedRectangle(cornerRadius: 8.adjustedLayout)
                                    .fill(dDayText == "마감" ? Color.gray70 : Color.primary50)
                            )

                        Text(project.updatedAt.toDateString(format: "yyyy.MM.dd"))
                            .typo(.regular_14_140)
                            .foregroundStyle(.gray100)
                    }

                    Text("\(project.company) \(project.jobPosition)")
                        .typo(.medium_15)
                        .foregroundStyle(.black)
                        .lineLimit(1)
                }

                Spacer()

                // 오른쪽: 완료 상태 아이콘 + 세로 말줄임 버튼
                HStack(spacing: 8.adjustedLayout) {
                    Image(isCompleted ? "writeDone" : "writeComplete")
                        .resizable()
                        .scaledToFit()
                        .frame(size: 34.adjustedLayout)
                        .padding(.trailing, 8.adjustedLayout)

                    Button {
                        onMenuToggle?()
                    } label: {
                        Image(systemName: "ellipsis")
                            .rotationEffect(.degrees(90))
                            .foregroundStyle(.gray300)
                            .frame(width: 20.adjustedLayout, height: 20.adjustedLayout)
                    }
                }
                .padding(.trailing, 16.adjustedLayout)
            }
            .padding(.horizontal, 20.adjustedLayout)
            .padding(.vertical, 14.adjustedLayout)
            .background(Color.white)
            .contentShape(Rectangle())
            .onTapGesture {
                if isMenuOpen {
                    onMenuClose?()
                } else {
                    appState.openWorkspace(projectId: project.id)
                }
            }

            // 삭제 팝업
            if isMenuOpen {
                deleteMenuPopup
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
                    .padding(.top, 44)
                    .padding(.trailing, 20)
                    .zIndex(1)
            }
        }
    }
}
