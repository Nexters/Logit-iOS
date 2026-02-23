//
//  ExperienceDetailView.swift
//  Logit
//

import SwiftUI

struct ExperienceDetailView: View {
    @StateObject private var viewModel: ExperienceDetailViewModel
    @Environment(\.dismiss) var dismiss

    init(experienceId: String) {
        _viewModel = StateObject(
            wrappedValue: ExperienceDetailViewModel(experienceId: experienceId)
        )
    }

    var body: some View {
        VStack(spacing: 0) {
            CustomNavigationBar(
                title: "경험 상세",
                showBackButton: true,
                onBackTapped: { dismiss() }
            )

            if viewModel.isLoading {
                Spacer()
                ProgressView()
                Spacer()
            } else if let e = viewModel.experience {
                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        DetailRow(label: "ID",           value: e.id)
                        DetailRow(label: "제목",          value: e.title)
                        DetailRow(label: "경험 유형",      value: e.experienceType)
                        DetailRow(label: "역량 카테고리",   value: e.category)
                        DetailRow(label: "태그",          value: e.tags)
                        DetailRow(label: "시작일",         value: e.startDate)
                        DetailRow(label: "종료일",         value: e.endDate ?? "진행 중")
                        DetailRow(label: "Situation",    value: e.situation)
                        DetailRow(label: "Task",         value: e.task)
                        DetailRow(label: "Action",       value: e.action)
                        DetailRow(label: "Result",       value: e.result)
                        DetailRow(label: "생성일",         value: e.createdAt)
                        DetailRow(label: "수정일",         value: e.updatedAt)
                        DetailRow(label: "User ID",      value: e.userId)
                    }
                    .padding(20)
                }
            } else if let errorMessage = viewModel.errorMessage {
                Spacer()
                Text(errorMessage)
                    .typo(.regular_15)
                    .foregroundColor(.gray300)
                Spacer()
            }
        }
        .navigationBarHidden(true)
        .onAppear {
            Task {
                await viewModel.fetchDetail()
            }
        }
    }
}

private struct DetailRow: View {
    let label: String
    let value: String

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label)
                .typo(.medium_13)
                .foregroundColor(.gray300)

            Text(value.isEmpty ? "-" : value)
                .typo(.regular_15)
                .foregroundColor(.black)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(12)
        .background(Color.white)
        .cornerRadius(8)
    }
}
