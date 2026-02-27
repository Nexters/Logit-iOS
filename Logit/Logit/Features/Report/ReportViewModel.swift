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
    @Published var userName: String = "로짓"

    private let reportRepository: ReportRepository
    private let userRepository: UserRepository

    init(
        reportRepository: ReportRepository = DefaultReportRepository(),
        userRepository: UserRepository = DefaultUserRepository(networkClient: DefaultNetworkClient())
    ) {
        self.reportRepository = reportRepository
        self.userRepository = userRepository
    }

    func fetchExperienceSummary() async {
        isLoading = true
        errorMessage = nil

        async let summaryFetch = reportRepository.getExperienceSummary()
        async let userFetch = userRepository.getCurrentUser()

        do {
            summary = try await summaryFetch
            print("리포트 요약 조회 성공")
        } catch let error as APIError {
            handleAPIError(error)
        } catch {
            errorMessage = "리포트를 불러오는데 실패했습니다."
            showError = true
        }

        do {
            let user = try await userFetch
            if let name = user.fullName, !name.isEmpty {
                userName = name
            }
        } catch {
            print("유저 정보 조회 실패: \(error)")
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

    /// 바 차트 기본 카테고리 순서 (빈 슬롯을 채울 때 사용)
    private static let defaultCategoryOrder: [String] = [
        "고객 가치 지향",
        "기술적 전문성",
        "협력적 소통",
        "주도적 실행력",
        "논리적 분석력",
        "창의적 문제해결"
    ]

    /// 세로 바 차트: 역량 카테고리별 (categoryCounts) - 항상 6개
    /// 실제 데이터가 6개 미만이면 defaultCategoryOrder 중 미등장 항목으로 0값 채움
    var barChartData: [BarChartData] {
        guard let summary else { return [] }
        let real = Array(
            summary.categoryCounts
                .sorted { $0.count > $1.count }
                .prefix(Self.chartCount)
        )
        let realItems = real.enumerated().map { index, item -> BarChartData in
            let color = Self.chartColor(at: index)
            return BarChartData(
                label: CompetencyMapper.toDisplayTitle(item.category),
                value: Double(item.count),
                color: color,
                textColor: color
            )
        }
        let realCategories = Set(real.map { $0.category })
        let defaultItems = Self.defaultCategoryOrder
            .filter { !realCategories.contains($0) }
            .prefix(Self.chartCount - real.count)
            .enumerated()
            .map { index, category -> BarChartData in
                let colorIndex = real.count + index
                let color = Self.chartColor(at: colorIndex)
                return BarChartData(
                    label: CompetencyMapper.toDisplayTitle(category),
                    value: 0,
                    color: color,
                    textColor: color
                )
            }
        return realItems + defaultItems
    }

    /// 도넛 차트: 해시태그별 (tagCounts) - 항상 6개
    /// 실제 데이터가 6개 미만이면 defaultCategoryOrder 표시 이름으로 0값 채움
    var donutChartData: [DonutChartData] {
        guard let summary else { return [] }
        let real = Array(
            summary.tagCounts
                .sorted { $0.count > $1.count }
                .prefix(Self.chartCount)
        )
        let realItems = real.enumerated().map { index, item -> DonutChartData in
            DonutChartData(
                label: item.tag,
                value: Double(item.count),
                color: Self.chartColor(at: index),
                textColor: Self.donutTextColor(at: index)
            )
        }
        let defaultLabels = Self.defaultCategoryOrder
            .map { CompetencyMapper.toDisplayTitle($0) }
            .prefix(Self.chartCount - real.count)
        let defaultItems = defaultLabels.enumerated().map { index, label -> DonutChartData in
            let colorIndex = real.count + index
            return DonutChartData(
                label: label,
                value: 0,
                color: Self.chartColor(at: colorIndex),
                textColor: Self.donutTextColor(at: colorIndex)
            )
        }
        return realItems + defaultItems
    }

    /// 가로 바 차트 기본 경험 유형 순서 (빈 슬롯을 채울 때 사용)
    private static let defaultTypeOrder: [String] = [
        "아르바이트", "정규직", "인턴", "계약직", "봉사활동", "동아리활동"
    ]

    /// 가로 바 차트: 경험 유형별 (typeCounts) - 항상 6개
    /// 실제 데이터가 6개 미만이면 defaultTypeOrder 중 미등장 항목으로 0값 채움
    var horizontalBarChartData: [HorizontalBarChartData] {
        guard let summary else { return [] }
        let real = Array(
            summary.typeCounts
                .sorted { $0.count > $1.count }
                .prefix(Self.chartCount)
        )
        let realItems = real.enumerated().map { index, item -> HorizontalBarChartData in
            HorizontalBarChartData(
                rank: index + 1,
                label: item.type,
                value: Double(item.count),
                color: Self.chartColor(at: index)
            )
        }
        let realTypes = Set(real.map { $0.type })
        let defaultItems = Self.defaultTypeOrder
            .filter { !realTypes.contains($0) }
            .prefix(Self.chartCount - real.count)
            .enumerated()
            .map { index, type -> HorizontalBarChartData in
                let colorIndex = real.count + index
                return HorizontalBarChartData(
                    rank: real.count + index + 1,
                    label: type,
                    value: 0,
                    color: Self.chartColor(at: colorIndex)
                )
            }
        return realItems + defaultItems
    }

    // MARK: - Dynamic Text

    /// 도넛 가운데 경험키워드 총 개수 (tagCounts 합계)
    var totalTagCount: Int {
        summary?.tagCounts.reduce(0) { $0 + $1.count } ?? 0
    }

    /// (하위 호환) 기존 이름 유지
    var totalCategoryCount: Int { totalTagCount }

    /// 공동 1등 발생 시 우선순위 결정 순서
    private static let categoryPriorityOrder: [String] = [
        "고객 가치 지향",
        "기술적 전문성",
        "협력적 소통",
        "주도적 실행력",
        "논리적 분석력",
        "창의적 문제해결",
        "유연한 적응력",
        "끈기있는 책임감"
    ]

    /// 가장 많은 역량 카테고리 (API 값) — 공동 1등 시 우선순위로 결정
    var topCategory: String {
        guard let summary, !summary.categoryCounts.isEmpty else { return "기술적 전문성" }
        let maxCount = summary.categoryCounts.map { $0.count }.max() ?? 0
        let topCandidates = summary.categoryCounts
            .filter { $0.count == maxCount }
            .map { $0.category }
        return Self.categoryPriorityOrder.first { topCandidates.contains($0) }
            ?? topCandidates.first
            ?? "기술적 전문성"
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

    private static let typeDescriptions: [String: String] = [
        "아르바이트": "서비스 현장에서 고객과 직접 소통하며 쌓은 실전 감각이 돋보입니다.",
        "정규직": "풍부한 실무 경험을 바탕으로 조직의 성과를 이끌어온 준비된 전문가입니다.",
        "인턴": "실무 현장을 직접 경험하며 조직의 시스템과 업무 흐름을 빠르게 익혔습니다.",
        "계약직": "주어진 기간 내에 목표를 완수하며 실무 역량과 책임감을 입증해왔습니다.",
        "봉사활동": "사회적 가치를 실현하고 타인을 배려하며 쌓은 선한 영향력이 느껴집니다.",
        "동아리활동": "동료들과 공동의 목표를 향해 협력하며 팀워크의 가치를 경험했습니다.",
        "연구활동": "특정 분야를 깊이 있게 탐구하고 분석하여 학술적 전문성을 쌓아왔습니다.",
        "수상경력": "치열한 경쟁 속에서 남다른 성과를 내며 객관적인 역량의 우수성을 증명했습니다.",
        "군복무관련": "엄격한 환경 속에서도 맡은 임무를 성실히 수행하며 강한 책임감을 길렀습니다.",
        "개인활동": "스스로 목표를 설정하고 끝까지 완수해낸 자기주도적 실행력이 훌륭합니다."
    ]

    /// 가로 바 차트 하단 설명 멘트 - 최다 경험 유형에 맞는 문구
    var horizontalBarChartDescription: String {
        guard !topType.isEmpty else { return "" }
        return Self.typeDescriptions[topType] ?? "다양한 경험을 통해 폭넓은 역량을 쌓아온 인재입니다."
    }

    /// 가장 적은 역량 카테고리 (API 값) — 누락 카테고리는 0으로 간주, 동점 시 우선순위로 결정
    var weakestCategory: String {
        guard let summary else { return Self.categoryPriorityOrder.first ?? "" }
        let countMap = Dictionary(uniqueKeysWithValues: summary.categoryCounts.map { ($0.category, $0.count) })
        let minCount = Self.categoryPriorityOrder.map { countMap[$0] ?? 0 }.min() ?? 0
        let minCandidates = Self.categoryPriorityOrder.filter { (countMap[$0] ?? 0) == minCount }
        return Self.categoryPriorityOrder.first { minCandidates.contains($0) } ?? minCandidates.first ?? ""
    }

    /// 가장 적은 역량 카테고리 (표시용)
    var weakestCategoryDisplay: String {
        CompetencyMapper.toDisplayTitle(weakestCategory)
    }
    
    /// 가장 많은 역량 카테고리 (표시용)
    var strongCategoryDisplay: String {
        topCategoryDisplay
    }


    /// 가장 많은 해시태그
    var topTag: String {
        summary?.tagCounts.sorted { $0.count > $1.count }.first?.tag ?? ""
    }

    // MARK: - Tag Group

    private static let tagGroups: [(group: String, keywords: [String])] = [
        ("IT/기술", ["개발", "프로그래밍", "코딩", "swift", "python", "java", "javascript", "react", "ios", "android", "백엔드", "프론트엔드", "데이터", "ai", "ml", "서버", "앱", "웹", "sql", "알고리즘", "기술", "엔지니어링", "devops", "클라우드", "인프라"]),
        ("디자인/예술", ["디자인", "ui", "ux", "figma", "포토샵", "일러스트", "그래픽", "영상", "사진", "드로잉", "시각", "예술", "창작", "편집"]),
        ("기획/비즈니스", ["기획", "pm", "프로젝트", "비즈니스", "전략", "제안", "시장조사", "사업", "서비스기획"]),
        ("마케팅/영업", ["마케팅", "영업", "sns", "광고", "콘텐츠", "브랜딩", "홍보", "세일즈", "pr", "퍼포먼스"]),
        ("운영/지원", ["운영", "cs", "고객", "관리", "지원", "총무", "인사", "재무", "회계", "행정", "cs관리"])
    ]

    private static func tagGroup(for tag: String) -> String {
        let lowercased = tag.lowercased()
        for (group, keywords) in tagGroups {
            if keywords.contains(where: { lowercased.contains($0) }) {
                return group
            }
        }
        return "공통태그"
    }

    /// 도넛 차트 하단 설명 멘트 - 최다 태그의 그룹에 맞는 문구
    var donutChartDescription: String {
        guard !topTag.isEmpty else { return "자주 사용하는 키워드를 확인해보세요" }
        let group = Self.tagGroup(for: topTag)
        switch group {
        case "IT/기술":
            return "\(topTag) 기술을 바탕으로 복잡한 문제를 해결하는 기술 전문가입니다."
        case "디자인/예술":
            return "\(topTag)를 통해 사용자 중심의 가치를 시각적으로 구현하는 디자이너입니다."
        case "기획/비즈니스":
            return "\(topTag) 역량을 발휘하여 비즈니스 모델과 서비스의 방향을 결정하는 기획자입니다."
        case "마케팅/영업":
            return "\(topTag) 지표를 기반으로 고객의 마음을 사로잡고 성과를 만들어내는 마케터입니다."
        case "운영/지원":
            return "\(topTag) 활동을 통해 서비스 안정성을 높이고 조직의 성장을 돕는 조율자입니다."
        default:
            return "업무의 기초가 되는 \(topTag) 역량이 탄탄하게 갖춰져 있습니다."
        }
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

    /// 역량 설명 멘트 - 가장 많이 집계된 카테고리에 맞는 문구
    var categoryDescription: String {
        guard summary != nil else { return "" }
        return Self.categoryDescriptions[topCategory] ?? "다양한 역량을 균형있게 보유한 인재예요."
    }

    /// 바 차트 하단 보완 멘트
    /// - 집계된 카테고리 종류가 3개 이하: 경험 다양화 유도 멘트
    /// - 4개 이상: 최소 카테고리 보완 멘트 (누락 카테고리는 0으로 간주, 동점 시 우선순위 적용)
    var barChartSubDescription: String {
        guard let summary else { return "" }
        let categoryCount = summary.categoryCounts.filter { $0.count > 0 }.count
        if categoryCount <= 3 {
            return "현재 경험 유형이 \(topCategoryDisplay) 중심으로 구성되어 있어요. 경험 유형을 다양화하면 더 입체적인 자소서가 될 거예요!"
        }
        return "현재 \(weakestCategoryDisplay) 관련 경험이 적은 편이에요. 이 부분을 보완하면 더 입체적인 자소서가 될 거예요!"
    }

    private static let categoryDescriptions: [String: String] = [
        "고객 가치 지향": "사용자의 관점에서 깊게 고민하고 불편함을 해결하는 '공감형 기획자'시군요.",
        "기술적 전문성": "자신만의 탄탄한 기술 스택과 전공 지식을 실무에 녹여내는 '스페셜리스트'입니다.",
        "협력적 소통": "팀원들 사이의 갈등을 조율하고 시너지를 만들어내는 '최고의 커뮤니케이터'예요.",
        "주도적 실행력": "직접 문제를 정의하고 움직이는 '행동파 리더'의 면모가 돋보여요.",
        "논리적 분석력": "근거와 데이터를 바탕으로 설득하는 '전략가' 타입의 경험이 많으시네요.",
        "창의적 문제해결": "고정관념을 깨는 새로운 시각으로 남다른 대안을 제시하는 '아이디어 뱅크'의 자질이 충분합니다.",
        "유연한 적응력": "변화하는 환경에 기민하게 대처하며 빠르게 성장하는 '성장형 인재'의 강점이 두드러집니다.",
        "끈기있는 책임감": "어려운 상황에서도 목표를 놓지 않고 끝내 결과를 만들어내는 '책임감 있는 파트너'의 면모가 돋보여요."
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

    /// 경험이 하나도 없는 상태
    var isEmpty: Bool {
        guard let summary else { return false }
        return summary.total == 0
    }

    /// 프로필 강점 태그 목록: 모든 카테고리를 count 내림차순으로 (표시용)
    var allCategoryTags: [String] {
        guard let summary else { return [] }
        return summary.categoryCounts
            .sorted { $0.count > $1.count }
            .map { CompetencyMapper.toDisplayTitle($0.category) }
    }
}
