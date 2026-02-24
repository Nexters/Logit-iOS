//
//  CoverLetterListView.swift
//  Logit
//
//  Created by 임재현 on 2/7/26.
//

import SwiftUI

struct CoverLetterListView: View {
    @StateObject private var viewModel = CoverLetterListViewModel()

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // 상단 헤더
                HStack {
                    Text("자기소개서")
                        .typo(.semibold_17)
                        .foregroundStyle(.black)
                    Spacer()
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 16)

                // 프로젝트 리스트
                if viewModel.isLoadingProjects {
                    ProgressView()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if viewModel.projects.isEmpty {
                    VStack(spacing: 12) {
                        Image(systemName: "doc.text")
                            .font(.system(size: 60))
                            .foregroundStyle(.secondary)
                        Text("등록된 자기소개서가 없습니다")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundStyle(.secondary)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    ScrollView {
                        LazyVStack(spacing: 0) {
                            ForEach(viewModel.projects) { project in
                                NavigationLink(destination: CoverLetterDetailView(project: project)) {
                                    CoverLetterProjectCell(project: project)
                                }
                                .buttonStyle(.plain)

                                Divider()
                                    .padding(.horizontal, 20)
                            }
                        }
                        .padding(.bottom, 69)
                    }
                    .refreshable {
                        await viewModel.fetchProjects()
                    }
                }
            }
            .background(.white)
            .task {
                await viewModel.fetchProjects()
            }
        }
    }
}

// MARK: - 프로젝트 셀

private struct CoverLetterProjectCell: View {
    let project: ProjectListItemResponse

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

    private var isExpired: Bool { dDayText == "마감" }

    var body: some View {
        HStack(alignment: .center, spacing: 12) {
            RoundedRectangle(cornerRadius: 2)
                .fill(Color.primary70)
                .frame(width: 3, height: 24)

            VStack(alignment: .leading, spacing: 4) {
                Text("\(project.company) · \(project.jobPosition)")
                    .typo(.medium_15)
                    .foregroundStyle(.black)
                    .lineLimit(1)
            }

            Spacer()

            Text(dDayText)
                .typo(.semibold_12)
                .foregroundStyle(isExpired ? .gray200 : .primary500)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(
                    RoundedRectangle(cornerRadius: 4)
                        .fill(isExpired ? Color.gray70 : Color.primary50)
                )
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
    }
}
