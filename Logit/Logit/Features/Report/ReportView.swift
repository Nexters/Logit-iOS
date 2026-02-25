//
//  ReportView.swift
//  Logit
//
//  Created by 임재현 on 2/20/26.
//

import SwiftUI
import Charts

struct ReportView: View {
    @StateObject private var viewModel = ReportViewModel()
    @State private var showExperienceAddFlow = false

    var body: some View {
        Group {
            if viewModel.isLoading {
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if viewModel.showError {
                VStack(spacing: 12) {
                    Text(viewModel.errorMessage ?? "오류가 발생했습니다.")
                        .typo(.regular_15)
                        .foregroundStyle(.gray)
                        .multilineTextAlignment(.center)

                    Button("다시 시도") {
                        Task { await viewModel.fetchExperienceSummary() }
                    }
                    .typo(.medium_15)
                    .foregroundStyle(Color.primary100)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if viewModel.isEmpty {
                VStack(spacing: 0) {
                    Text("\(viewModel.userName)님의 프로파일")
                        .typo(.bold_20)
                        .foregroundStyle(.black)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.vertical, 10)
                        .padding(.leading, 20)

                    EmptyExperienceView {
                        showExperienceAddFlow = true
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color.white)
            } else {
                contentView
            }
        }
        .background(Color.white.ignoresSafeArea())
        .task {
            await viewModel.fetchExperienceSummary()
        }
        .fullScreenCover(isPresented: $showExperienceAddFlow) {
            ExperienceFlowCoordinator {
                Task { await viewModel.fetchExperienceSummary() }
            }
        }
    }

    // MARK: - Main Content

    private var contentView: some View {
        ScrollView {
            VStack(spacing: 0) {
                // 프로필 카드 영역
                profileSection

                // 그래프 카드 영역
                graphSection
            }
        }
        .scrollIndicators(.hidden)
    }

    // MARK: - Profile Section

    private var profileSection: some View {
        VStack {
            Text("\(viewModel.userName)님의 프로파일")
                .typo(.bold_20)
                .foregroundStyle(.black)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.vertical, 10)
                .padding(.leading, 20)

            if let asset = NSDataAsset(name: viewModel.topCategoryImageName),
               let uiImage = UIImage(data: asset.data) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
                    .frame(maxWidth: .infinity)
                    .frame(height: 320)
                    .clipped()
                    .cornerRadius(20)
                    .padding(.horizontal, 20)
                    .padding(.top, 11)
            }

            VStack(alignment: .leading, spacing: 8) {
                Text("\(viewModel.userName)님의 강점들을 모아봤어요")
                    .typo(.bold_18)
                    .foregroundStyle(.black)

                Text(viewModel.categoryDescription)
                    .typo(.regular_15)
                    .foregroundStyle(.gray)

                if !viewModel.allCategoryTags.isEmpty {
                    FlowLayout(spacing: 8) {
                        ForEach(viewModel.allCategoryTags, id: \.self) { tag in
                            ExperienceTag(text: tag, icon: tag, isCompetency: true)
                        }
                    }
                    .padding(.top, 4)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 20)
            .padding(.top, 16)
            .padding(.bottom, 20)
        }
        .background(.white)
    }

    // MARK: - Graph Section

    private var graphSection: some View {
        VStack(spacing: 0) {
            // 카드 1: 세로 바 차트 (역량 카테고리)
            VStack(alignment: .leading, spacing: 5) {
                Text("\(viewModel.topCategoryDisplay)이 두드러져요")
                    .typo(.bold_18)
                    .foregroundStyle(.black)

                Text(viewModel.barChartSubDescription)
                    .typo(.regular_15)
                    .foregroundStyle(.gray)

                ReportBarChartView(data: viewModel.barChartData)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(20)
            .background(.white)
            .cornerRadius(16)
            .padding(.horizontal, 20)
            .padding(.top, 21)

            // 카드 2: 도넛 차트 (해시태그)
            VStack(alignment: .leading, spacing: 5) {
                Text("\(viewModel.topTag)에 강점이 있어요")
                    .typo(.bold_18)
                    .foregroundStyle(.black)

                Text(viewModel.donutChartDescription)
                    .typo(.regular_15)
                    .foregroundStyle(.gray)

                ReportDonutChartView(
                    data: viewModel.donutChartData,
                    total: viewModel.totalCategoryCount
                )
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(20)
            .background(.white)
            .cornerRadius(16)
            .padding(.horizontal, 20)
            .padding(.top, 16)

            // 카드 3: 가로 바 차트 (경험 유형)
            VStack(alignment: .leading, spacing: 5) {
                Text("\(viewModel.topType) 경험이 가장 많아요")
                    .typo(.bold_18)
                    .foregroundStyle(.black)

                Text(viewModel.horizontalBarChartDescription)
                    .typo(.regular_15)
                    .foregroundStyle(.gray)

                ReportHorizontalBarChartView(data: viewModel.horizontalBarChartData)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(20)
            .background(.white)
            .cornerRadius(16)
            .padding(.horizontal, 20)
            .padding(.top, 16)
        }
        .frame(maxWidth: .infinity)
        .padding(.bottom, (49 + 40).adjustedLayout)
        .background(Color.gray20)
    }
}


// MARK: - Flow Tags View

struct FlowTagsView: View {
    let competencyTag: String
    let tags: [String]
    var allCompetency: Bool = false
    let spacing: CGFloat = 8

    private var allTags: [(String, Bool)] {
        [(competencyTag, true)] + tags.map { ($0, allCompetency) }
    }

    var body: some View {
        FlowLayout(spacing: spacing) {
            ForEach(Array(allTags.enumerated()), id: \.offset) { _, tag in
                ReportTag(
                    text: tag.0,
                    icon: tag.1 ? tag.0 : nil
                )
            }
        }
    }
}


// MARK: - Report Tag

struct ReportTag: View {
    let text: String
    var icon: String? = nil

    var body: some View {
        HStack(spacing: 6) {
            if let icon = icon {
                Image(icon)
                    .resizable()
                    .frame(width: 16, height: 16)
            }

            Text(text)
                .typo(.regular_15)
                .foregroundColor(.primary600)
                .lineLimit(1)
        }
        .padding(.horizontal, 8.31)
        .padding(.vertical, 6.5)
        .background(Color(hex: "E3F5FF"))
        .cornerRadius(11.08)
        .fixedSize(horizontal: true, vertical: false)
    }
}


// MARK: - Bar Chart (세로)

struct BarChartData: Identifiable {
    let id = UUID()
    let label: String
    let value: Double
    let color: Color
    let textColor: Color
}

struct ReportBarChartView: View {
    let data: [BarChartData]

    private var maxValue: Double { data.map { $0.value }.max() ?? 0 }
    private var minRenderValue: Double { max(maxValue * 0.08, 0.3) }

    var body: some View {
        VStack(spacing: 0) {
            Chart(data) { item in
                BarMark(
                    x: .value("label", item.id.uuidString),
                    y: .value("value", max(item.value, minRenderValue)),
                    width: .fixed(20)
                )
                .foregroundStyle(item.color)
                .clipShape(UnevenRoundedRectangle(
                    topLeadingRadius: 8,
                    bottomLeadingRadius: 8,
                    bottomTrailingRadius: 8,
                    topTrailingRadius: 8
                ))
                .annotation(position: .top) {
                    if item.value > 0 {
                        Text("\(Int(item.value))")
                            .typo(.bold_14)
                            .foregroundStyle(item.color)
                    }
                }
            }
            .chartXAxis(.hidden)
            .chartYAxis(.hidden)
            .frame(width: 210, height: 160)
            .padding(.horizontal, 16)
            .padding(.top, 16)
            .padding(.bottom, 40)

            LazyVGrid(
                columns: Array(repeating: GridItem(.flexible(), spacing: 4), count: 3),
                spacing: 12
            ) {
                ForEach(data) { item in
                    HStack(spacing: 6) {
                        Circle()
                            .fill(item.color)
                            .frame(width: 10, height: 10)
                        Text(item.label)
                            .typo(.regular_13)
                            .foregroundStyle(.black)
                            .lineLimit(1)
                            .minimumScaleFactor(0.8)
                        Spacer()
                    }
                }
            }
            .padding(16)
        }
        .background(.white)
        .cornerRadius(16)
    }
}


// MARK: - Donut Chart (도넛)

struct DonutChartData: Identifiable {
    let id = UUID()
    let label: String
    let value: Double
    let color: Color
    let textColor: Color
}

struct ReportDonutChartView: View {
    let data: [DonutChartData]
    let total: Int

    private var adjustedData: [DonutChartData] {
        let sum = data.reduce(0) { $0 + $1.value }
        // 모든 값이 0이면 균등 분할로 도넛 형태 유지
        if sum == 0 {
            return data.map { item in
                DonutChartData(label: item.label, value: 1, color: item.color, textColor: item.textColor)
            }
        }
        let minValue = sum * 0.07
        return data.map { item in
            DonutChartData(
                label: item.label,
                value: max(item.value, minValue),
                color: item.color,
                textColor: item.textColor
            )
        }
    }

    private func originalValue(at index: Int) -> Double {
        data[index].value
    }

    private struct LabelInfo {
        let point: CGPoint
        let value: Int
        let color: Color
    }

    private func computeLabelPositions(size: CGSize) -> [LabelInfo] {
        let totalValue = adjustedData.reduce(0) { $0 + $1.value }
        guard totalValue > 0 else { return [] }

        let center = CGPoint(x: size.width / 2, y: size.height / 2)
        let outerRadius = min(size.width, size.height) / 2
        let innerRadius = outerRadius * 0.68
        let labelRadius = (outerRadius + innerRadius) / 2

        var infos: [LabelInfo] = []
        var startAngle = -Double.pi / 2  // 12시 방향부터 시작

        for (index, item) in adjustedData.enumerated() {
            let sweepAngle = (item.value / totalValue) * 2 * Double.pi
            let midAngle = startAngle + sweepAngle / 2

            let x = center.x + CGFloat(cos(midAngle)) * labelRadius
            let y = center.y + CGFloat(sin(midAngle)) * labelRadius

            infos.append(LabelInfo(
                point: CGPoint(x: x, y: y),
                value: Int(originalValue(at: index)),
                color: data[index].textColor
            ))
            startAngle += sweepAngle
        }
        return infos
    }

    var body: some View {
        VStack(spacing: 0) {
            ZStack {
                Chart(Array(adjustedData.enumerated()), id: \.offset) { index, item in
                    SectorMark(
                        angle: .value("value", item.value),
                        innerRadius: .ratio(0.68),
                        angularInset: 4
                    )
                    .foregroundStyle(item.color)
                    .cornerRadius(8)
                }
                .frame(size: 185)
                .overlay {
                    GeometryReader { geo in
                        ForEach(Array(computeLabelPositions(size: geo.size).enumerated()), id: \.offset) { _, info in
                            Text("\(info.value)")
                                .typo(.bold_14)
                                .foregroundStyle(info.color)
                                .position(x: info.point.x, y: info.point.y)
                        }
                    }
                }

                VStack(spacing: 4) {
                    Text("경험키워드")
                        .typo(.bold_18)
                        .foregroundStyle(.black)
                    Text("\(total)개 집계")
                        .typo(.regular_13)
                        .foregroundStyle(.gray)
                }
            }
            .padding(.top, 16)
            .padding(.bottom, 40)

            LazyVGrid(
                columns: Array(repeating: GridItem(.flexible(), spacing: 4), count: 3),
                spacing: 12
            ) {
                ForEach(Array(data.enumerated()), id: \.offset) { _, item in
                    HStack(spacing: 6) {
                        Circle()
                            .fill(item.color)
                            .frame(width: 10, height: 10)
                        Text(item.label)
                            .typo(.regular_13)
                            .foregroundStyle(.black)
                            .lineLimit(1)
                            .minimumScaleFactor(0.8)
                        Spacer()
                    }
                }
            }
            .padding(16)
        }
        .background(.white)
        .cornerRadius(16)
    }
}


// MARK: - Horizontal Bar Chart (가로)

struct HorizontalBarChartData: Identifiable {
    let id = UUID()
    let rank: Int
    let label: String
    let value: Double
    let color: Color
}

struct ReportHorizontalBarChartView: View {
    let data: [HorizontalBarChartData]

    private var maxValue: Double { data.map { $0.value }.max() ?? 1 }

    var body: some View {
        VStack(spacing: 0) {
            VStack(spacing: 15) {
                ForEach(data) { item in
                    HStack(spacing: 8) {
                        Text("\(Int(item.value))")
                            .typo(.bold_12)
                            .foregroundStyle(item.color)
                            .frame(width: 20, alignment: .center)

                        GeometryReader { geo in
                            ZStack(alignment: .leading) {
                                RoundedRectangle(cornerRadius: 6)
                                    .fill(Color.gray20)
                                    .frame(maxWidth: .infinity)

                                RoundedRectangle(cornerRadius: 6)
                                    .fill(item.color)
                                    .frame(width: geo.size.width * 0.7 * (item.value / maxValue))
                            }
                        }
                        .frame(height: 14.17)
                    }
                }
            }
            .padding(.top, 16)
            .padding(.horizontal, 20)
            .padding(.bottom, 40)

            LazyVGrid(
                columns: Array(repeating: GridItem(.flexible(), spacing: 4), count: 3),
                spacing: 12
            ) {
                ForEach(Array(data.enumerated()), id: \.offset) { _, item in
                    HStack(spacing: 6) {
                        Circle()
                            .fill(item.color)
                            .frame(width: 10, height: 10)
                        Text(item.label)
                            .typo(.regular_13)
                            .foregroundStyle(.black)
                            .lineLimit(1)
                            .minimumScaleFactor(0.8)
                        Spacer()
                    }
                }
            }
            .padding(16)
        }
    }
}
