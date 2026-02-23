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
            // Navigation Bar
            HStack {
                Button { dismiss() } label: {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(.black)
                        .frame(width: 44, height: 44)
                }
                Spacer()
                Button { } label: {
                    Image(systemName: "ellipsis")
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

                        // STAR 섹션들
                        if !e.situation.isEmpty {
                            ExperienceSTARSection(label: "Situation (상황)", content: e.situation)
                                .padding(.top, 32)
                        }
                        if !e.task.isEmpty {
                            ExperienceSTARSection(label: "Task (과제/목표)", content: e.task)
                                .padding(.top, 24)
                        }
                        if !e.action.isEmpty {
                            ExperienceSTARSection(label: "Action (행동)", content: e.action)
                                .padding(.top, 24)
                        }
                        if !e.result.isEmpty {
                            ExperienceSTARSection(label: "Result (결과)", content: e.result)
                                .padding(.top, 24)
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

// MARK: - 태그 Flow 레이아웃

private struct ExperienceFlowTagsView: View {
    let competencyTag: String
    let tags: [String]

    private var allTags: [(text: String, isCompetency: Bool)] {
        [(competencyTag, true)] + tags.map { ($0, false) }
    }

    var body: some View {
        let rows = makeRows()
        VStack(alignment: .leading, spacing: 8) {
            ForEach(rows.indices, id: \.self) { i in
                HStack(spacing: 8) {
                    ForEach(rows[i].indices, id: \.self) { j in
                        let item = rows[i][j]
                        ExperienceTag(
                            text: item.text,
                            icon: item.isCompetency ? item.text : nil,
                            isCompetency: item.isCompetency
                        )
                    }
                    Spacer()
                }
            }
        }
    }

    private func makeRows() -> [[(text: String, isCompetency: Bool)]] {
        let maxWidth = UIScreen.main.bounds.width - 40
        var rows: [[(text: String, isCompetency: Bool)]] = [[]]
        var currentWidth: CGFloat = 0

        for tag in allTags {
            let charWidth: CGFloat = tag.text.unicodeScalars.first.map {
                $0.value > 127 ? 14 : 8
            } ?? 8
            let tagWidth = CGFloat(tag.text.count) * charWidth + 28 + (tag.isCompetency ? 24 : 0)

            if currentWidth + tagWidth + 8 > maxWidth, !rows.last!.isEmpty {
                rows.append([tag])
                currentWidth = tagWidth
            } else {
                rows[rows.count - 1].append(tag)
                currentWidth += tagWidth + 8
            }
        }
        return rows.filter { !$0.isEmpty }
    }
}
