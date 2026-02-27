//
//  ExperienceDetailView.swift
//  Logit
//

import SwiftUI

struct ExperienceDetailView: View {
    @StateObject private var viewModel: ExperienceDetailViewModel
    @Environment(\.dismiss) var dismiss

    @State private var showMenu = false
    @State private var showDeleteAlert = false
    @State private var showEditFlow = false

    var onDeleted: (() -> Void)? = nil

    init(experienceId: String, onDeleted: (() -> Void)? = nil) {
        _viewModel = StateObject(
            wrappedValue: ExperienceDetailViewModel(experienceId: experienceId)
        )
        self.onDeleted = onDeleted
    }

    private var ellipsisMenuPopup: some View {
        VStack(spacing: 0) {
            Button {
                showMenu = false
                showEditFlow = true
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "pencil")
                        .font(.system(size: 14))
                        .foregroundStyle(.black)
                    Text("수정")
                        .typo(.regular_14_140)
                        .foregroundStyle(.black)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
            }

            Divider()

            Button {
                showMenu = false
                showDeleteAlert = true
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
            }
        }
        .fixedSize()
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.white)
                .shadow(color: .black.opacity(0.12), radius: 8, x: 0, y: 4)
        )
    }

    var body: some View {
        VStack(spacing: 0) {
            // Navigation Bar
            HStack {
                Button { dismiss() } label: {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(.black)
                        .frame(width: 44, height: 44)
                }
                Spacer()
                Button { showMenu.toggle() } label: {
                    Image(systemName: "ellipsis")
                        .rotationEffect(.degrees(90))
                        .font(.system(size: 18))
                        .foregroundColor(.black)
                        .frame(width: 44, height: 44)
                }
            }
            .padding(.horizontal, 8)

            if viewModel.isLoading {
                Spacer()
                ProgressView()
                Spacer()
            } else if let e = viewModel.experience {
                ScrollView {
                    VStack(alignment: .leading, spacing: 0) {

                        // 제목
                        Text(e.title)
                            .typo(.bold_18)
                            .foregroundColor(.black)
                            .padding(.top, 24)

                        // 경험 종류
                        ExperienceInfoSection(label: "경험 종류", value: e.experienceType)
                            .padding(.top, 28)

                        // 경험 날짜
                        ExperienceInfoSection(
                            label: "경험 날짜",
                            value: formattedDateRange(start: e.startDate, end: e.endDate)
                        )
                        .padding(.top, 24)

                        // 경험 키워드
                        VStack(alignment: .leading, spacing: 10) {
                            Text("경험 키워드")
                                .typo(.regular_13)
                                .foregroundColor(.gray300)

                            ExperienceFlowTagsView(
                                competencyTag: CompetencyMapper.toDisplayTitle(e.category),
                                tags: parsedTags(from: e.tags)
                            )
                        }
                        .padding(.top, 24)

                        // STAR 섹션
                        if let situation = e.situation, !situation.isEmpty {
                            ExperienceSTARSection(label: "Situation (상황)", content: situation)
                                .padding(.top, 32)
                        }
                        if let task = e.task, !task.isEmpty {
                            ExperienceSTARSection(label: "Task (과제/목표)", content: task)
                                .padding(.top, 24)
                        }
                        if let action = e.action, !action.isEmpty {
                            ExperienceSTARSection(label: "Action (행동)", content: action)
                                .padding(.top, 24)
                        }
                        if let result = e.result, !result.isEmpty {
                            ExperienceSTARSection(label: "Result (결과)", content: result)
                                .padding(.top, 24)
                        }

                        // PSI 섹션
                        if let problem = e.problem, !problem.isEmpty {
                            ExperienceSTARSection(label: "Problem (문제)", content: problem)
                                .padding(.top, 32)
                        }
                        if let solution = e.solution, !solution.isEmpty {
                            ExperienceSTARSection(label: "Solution (해결책)", content: solution)
                                .padding(.top, 24)
                        }
                        if let insight = e.insight, !insight.isEmpty {
                            ExperienceSTARSection(label: "Insight (인사이트)", content: insight)
                                .padding(.top, 24)
                        }

                        // FREE 섹션
                        if let content = e.content, !content.isEmpty {
                            ExperienceSTARSection(label: "경험 내용", content: content)
                                .padding(.top, 32)
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 60)
                }
            } else if let msg = viewModel.errorMessage {
                Spacer()
                Text(msg)
                    .typo(.regular_15)
                    .foregroundColor(.gray300)
                Spacer()
            }
            }
            .background(Color.white)
            .navigationBarHidden(true)
            .onAppear {
                Task { await viewModel.fetchDetail() }
            }
            .fullScreenCover(isPresented: $showEditFlow) {
                if let experience = viewModel.experience {
                    ExperienceFlowCoordinator(experience: experience) {
                        Task { await viewModel.fetchDetail() }
                    }
                }
            }

        .overlay {
            if showMenu {
                Color.clear
                    .contentShape(Rectangle())
                    .ignoresSafeArea()
                    .onTapGesture { showMenu = false }
                    .overlay(alignment: .topTrailing) {
                        ellipsisMenuPopup
                            .padding(.top, 52)
                            .padding(.trailing, 20)
                    }
            }
        }
        .overlay {
            if showDeleteAlert {
                LogitAlertView(
                    message: "경험을 삭제하시겠어요?",
                    subMessage: "삭제하면 복구 못해요",
                    cancelTitle: "취소하기",
                    confirmTitle: "삭제하기",
                    onCancel: { showDeleteAlert = false },
                    onConfirm: {
                        showDeleteAlert = false
                        Task {
                            try? await viewModel.deleteExperience()
                            onDeleted?()
                            dismiss()
                        }
                    }
                )
            }
        }
    }

    // MARK: - Helpers

    private func parsedTags(from tags: String) -> [String] {
        tags.split(separator: ",")
            .map { $0.trimmingCharacters(in: .whitespaces) }
            .filter { !$0.isEmpty }
    }

    private func formattedDateRange(start: String, end: String?) -> String {
        let s = formatDate(start)
        guard let end, !end.isEmpty else { return "\(s)  ~  진행 중" }
        return "\(s)  ~  \(formatDate(end))"
    }

    private func formatDate(_ raw: String) -> String {
        String(raw.prefix(10)).replacingOccurrences(of: "-", with: ".")
    }
}

// MARK: - 상단 정보 섹션 (경험 종류 / 날짜)

private struct ExperienceInfoSection: View {
    let label: String
    let value: String

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(label)
                .typo(.regular_13)
                .foregroundColor(.gray300)
            Text(value.isEmpty ? "-" : value)
                .typo(.regular_15)
                .foregroundColor(.black)
        }
    }
}

// MARK: - STAR 섹션

private struct ExperienceSTARSection: View {
    let label: String
    let content: String

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(label)
                .typo(.medium_15)
                .foregroundColor(.gray300)

            Text(content)
                .typo(.regular_15)
                .foregroundColor(.black)
                .lineSpacing(5)
                .fixedSize(horizontal: false, vertical: true)

            Spacer().frame(height: 4)
        }
    }
}

// MARK: - Flow Layout

private struct TagFlowLayout: Layout {
    var spacing: CGFloat = 8

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let maxWidth = proposal.width ?? .infinity
        var currentX: CGFloat = 0
        var currentY: CGFloat = 0
        var rowHeight: CGFloat = 0

        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if currentX + size.width > maxWidth, currentX > 0 {
                currentY += rowHeight + spacing
                currentX = 0
                rowHeight = 0
            }
            currentX += size.width + spacing
            rowHeight = max(rowHeight, size.height)
        }
        return CGSize(width: maxWidth, height: currentY + rowHeight)
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        var currentX = bounds.minX
        var currentY = bounds.minY
        var rowHeight: CGFloat = 0

        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if currentX + size.width > bounds.maxX, currentX > bounds.minX {
                currentY += rowHeight + spacing
                currentX = bounds.minX
                rowHeight = 0
            }
            subview.place(at: CGPoint(x: currentX, y: currentY), proposal: .unspecified)
            currentX += size.width + spacing
            rowHeight = max(rowHeight, size.height)
        }
    }
}

// MARK: - 태그 Flow 레이아웃

private struct ExperienceFlowTagsView: View {
    let competencyTag: String
    let tags: [String]

    private var allTags: [(text: String, isCompetency: Bool)] {
        [(competencyTag, true)] + tags.map { ($0, false) }
    }

    var body: some View {
        TagFlowLayout(spacing: 8) {
            ForEach(allTags.indices, id: \.self) { i in
                let item = allTags[i]
                ExperienceTag(
                    text: item.text,
                    icon: item.isCompetency ? item.text : nil,
                    isCompetency: item.isCompetency
                )
            }
        }
    }
}
