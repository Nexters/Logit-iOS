//
//  ReportViewModel.swift
//  Logit
//
//  Created by 임재현 on 2/21/26.
//

import SwiftUI

@MainActor
class ReportViewModel: ObservableObject {
    @Published var summary: ExperienceSummaryResponse?
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var showError: Bool = false

    private let reportRepository: ReportRepository

    init(reportRepository: ReportRepository = DefaultReportRepository()) {
        self.reportRepository = reportRepository
    }

    func fetchExperienceSummary() async {
        isLoading = true
        errorMessage = nil

        do {
            summary = try await reportRepository.getExperienceSummary()
            print("리포트 요약 조회 성공")
        } catch let error as APIError {
            handleAPIError(error)
        } catch {
            errorMessage = "리포트를 불러오는데 실패했습니다."
            showError = true
        }

        isLoading = false
    }

    private func handleAPIError(_ error: APIError) {
        switch error {
        case .unauthorized(let message):
            errorMessage = message
        case .serverError(let message):
            errorMessage = message
        default:
            errorMessage = "오류가 발생했습니다."
        }
        showError = true
    }

    // MARK: - Chart Colors

    private static let chartColors: [Color] = [
        Color(hex: "A8EDD8"), Color(hex: "A8D4F5"), Color(hex: "B8B8F0"),
        Color(hex: "C8B8E8"), Color(hex: "E8B8E8"), Color(hex: "F5C8D8")
    ]

    private static let donutTextColors: [Color] = [
        Color(hex: "4AB89A"), Color(hex: "4A90C4"), Color(hex: "6B6BC4"),
        Color(hex: "9B6BC4"), Color(hex: "C46BAA"), Color(hex: "C46B8A")
    ]

    private static func chartColor(at index: Int) -> Color {
        chartColors[index % chartColors.count]
    }

    private static func donutTextColor(at index: Int) -> Color {
        donutTextColors[index % donutTextColors.count]
    }

    // MARK: - Chart Data

    private static let chartCount = 6
    private static let defaultLabel = "-"

    /// 세로 바 차트: 역량 카테고리별 (categoryCounts) - 항상 6개 (부족하면 0으로 패딩)
    var barChartData: [BarChartData] {
        guard let summary else { return [] }
        let real = summary.categoryCounts
            .sorted { $0.count > $1.count }
            .prefix(Self.chartCount)
            .enumerated()
            .map { index, item -> BarChartData in
                let color = Self.chartColor(at: index)
                return BarChartData(
                    label: CompetencyMapper.toDisplayTitle(item.category),
                    value: Double(item.count),
                    color: color,
                    textColor: color
                )
            }
        let defaults = (real.count..<Self.chartCount).map { index -> BarChartData in
            let color = Self.chartColor(at: index)
            return BarChartData(label: Self.defaultLabel, value: 0, color: color, textColor: color)
        }
        return real + defaults
    }

    /// 도넛 차트: 해시태그별 (tagCounts) - 항상 6개 (부족하면 0으로 패딩)
    var donutChartData: [DonutChartData] {
        guard let summary else { return [] }
        let real = summary.tagCounts
            .sorted { $0.count > $1.count }
            .prefix(Self.chartCount)
            .enumerated()
            .map { index, item -> DonutChartData in
                DonutChartData(
                    label: item.tag,
                    value: Double(item.count),
                    color: Self.chartColor(at: index),
                    textColor: Self.donutTextColor(at: index)
                )
            }
        let defaults = (real.count..<Self.chartCount).map { index -> DonutChartData in
            DonutChartData(
                label: Self.defaultLabel,
                value: 0,
                color: Self.chartColor(at: index),
                textColor: Self.donutTextColor(at: index)
            )
        }
        return real + defaults
    }

    /// 가로 바 차트: 경험 유형별 (typeCounts) - 항상 6개 (부족하면 0으로 패딩)
    var horizontalBarChartData: [HorizontalBarChartData] {
        guard let summary else { return [] }
        let real = summary.typeCounts
            .sorted { $0.count > $1.count }
            .prefix(Self.chartCount)
            .enumerated()
            .map { index, item -> HorizontalBarChartData in
                HorizontalBarChartData(
                    rank: index + 1,
                    label: item.type,
                    value: Double(item.count),
                    color: Self.chartColor(at: index)
                )
            }
        let defaults = (real.count..<Self.chartCount).map { index -> HorizontalBarChartData in
            HorizontalBarChartData(
                rank: index + 1,
                label: Self.defaultLabel,
                value: 0,
                color: Self.chartColor(at: index)
            )
        }
        return real + defaults
    }

    // MARK: - Dynamic Text

    /// 도넛 가운데 경험키워드 총 개수 (tagCounts 합계)
    var totalTagCount: Int {
        summary?.tagCounts.reduce(0) { $0 + $1.count } ?? 0
    }

    /// (하위 호환) 기존 이름 유지
    var totalCategoryCount: Int { totalTagCount }

    /// 가장 많은 역량 카테고리 (API 값)
    var topCategory: String {
        summary?.categoryCounts.sorted { $0.count > $1.count }.first?.category ?? "기술적 전문성"
    }

    /// 가장 많은 역량 카테고리 (표시용)
    var topCategoryDisplay: String {
        CompetencyMapper.toDisplayTitle(topCategory)
    }

    /// 가장 많은 경험 유형
    var topType: String {
        summary?.typeCounts.sorted { $0.count > $1.count }.first?.type ?? ""
    }

    /// 가장 적은 경험 유형
    var weakestType: String {
        summary?.typeCounts.sorted { $0.count < $1.count }.first?.type ?? ""
    }

    /// 가장 적은 역량 카테고리 (표시용)
    var weakestCategoryDisplay: String {
        let weakest = summary?.categoryCounts.sorted { $0.count < $1.count }.first?.category ?? ""
        return CompetencyMapper.toDisplayTitle(weakest)
    }

    /// 가장 많은 해시태그
    var topTag: String {
        summary?.tagCounts.sorted { $0.count > $1.count }.first?.tag ?? ""
    }

    /// 프로필 카드 태그 목록: 상위 카테고리 제외한 나머지 최대 5개 (competencyTag 포함 총 6개)
    var profileTags: [String] {
        guard let summary else { return [] }
        return summary.categoryCounts
            .sorted { $0.count > $1.count }
            .dropFirst()
            .prefix(5)
            .map { CompetencyMapper.toDisplayTitle($0.category) }
    }

    /// 역량 카테고리별 설명 멘트
    var categoryDescription: String {
        Self.categoryDescriptions[topCategory] ?? "다양한 역량을 균형있게 보유한 인재예요"
    }

    private static let categoryDescriptions: [String: String] = [
        "기술적 전문성": "도구와 기술 스택을 능숙하게 활용하는 기술적 전문가",
        "고객 가치 지향": "고객의 입장에서 생각하고 가치를 만들어가는 인재",
        "협력적 소통": "팀원과 협력하며 함께 성장하는 소통의 달인",
        "주도적 실행력": "목표를 설정하고 직접 이끌어가는 실행력의 인재",
        "논리적 분석력": "데이터와 논리로 문제를 분석하는 분석력의 인재",
        "창의적 문제해결": "새로운 시각으로 문제를 해결하는 창의적 인재",
        "유연한 적응력": "변화에 유연하게 적응하며 성장하는 인재",
        "끈기있는 책임감": "맡은 일을 끝까지 해내는 책임감 있는 인재"
    ]

    private static let categoryImageNames: [String: String] = [
        "고객 가치 지향": "property_1_01",
        "기술적 전문성": "property_1_02",
        "협력적 소통": "property_1_03",
        "주도적 실행력": "property_1_04",
        "논리적 분석력": "property_1_05",
        "창의적 문제해결": "property_1_06",
        "유연한 적응력": "property_1_07",
        "끈기있는 책임감": "property_1_08"
    ]

    /// 현재 topCategory에 해당하는 WebP 이미지 이름
    var topCategoryImageName: String {
        Self.categoryImageNames[topCategory] ?? "property_1_01"
    }
}
