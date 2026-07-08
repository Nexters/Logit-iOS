//
//  ExperienceFlowViewModel.swift
//  Logit
//
//  Created by 임재현 on 1/29/26.
//

import SwiftUI

enum ExperienceMethod: String, CaseIterable {
    case star = "STAR"
    case psi  = "PSI"
    case free = "FREE"

    var displayName: String {
        switch self {
        case .star: return "STAR"
        case .psi:  return "PSI"
        case .free: return "자유형식"
        }
    }
}

@MainActor
class ExperienceFlowViewModel: ObservableObject {
    @Published var path = NavigationPath()

    // 경험 정리 방법
    @Published var selectedMethod: ExperienceMethod = .star

    // 데이터
    @Published var experienceTitle: String = ""
    @Published var experienceType: String?

    // STAR
    @Published var situation: String = ""
    @Published var task: String = ""
    @Published var action: String = ""
    @Published var result: String = ""

    // PSI
    @Published var problem: String = ""
    @Published var solution: String = ""
    @Published var insight: String = ""

    // FREE
    @Published var content: String = ""

    @Published var selectedCompetency: String?
    
    @Published var startDate: Date?
    @Published var endDate: Date?
    @Published var isOngoing: Bool = false
    
    var onComplete: (() -> Void)?

    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var showError: Bool = false
    @Published var isExampleLoaded: Bool = false

    // 수정 모드
    @Published var isEditMode: Bool = false
    private var editingExperienceId: String? = nil

    private let experienceRepository: ExperienceRepository

    init(experienceRepository: ExperienceRepository, existingExperience: ExperienceResponse? = nil) {
        self.experienceRepository = experienceRepository
        guard let experience = existingExperience else { return }

        isEditMode = true
        editingExperienceId = experience.id
        experienceTitle = experience.title
        experienceType = experience.experienceType
        selectedMethod = ExperienceMethod(rawValue: experience.formatType ?? "STAR") ?? .star
        selectedCompetency = experience.tags.isEmpty ? nil : experience.tags

        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.timeZone = TimeZone(identifier: "Asia/Seoul")
        for format in ["yyyy-MM-dd'T'HH:mm:ss", "yyyy-MM-dd"] {
            formatter.dateFormat = format
            if let date = formatter.date(from: experience.startDate) {
                startDate = date
                break
            }
        }
        if let endDateStr = experience.endDate, !endDateStr.isEmpty {
            for format in ["yyyy-MM-dd'T'HH:mm:ss", "yyyy-MM-dd"] {
                formatter.dateFormat = format
                if let date = formatter.date(from: endDateStr) {
                    endDate = date
                    break
                }
            }
            isOngoing = false
        } else {
            isOngoing = true
        }

        situation = experience.situation ?? ""
        task = experience.task ?? ""
        action = experience.action ?? ""
        result = experience.result ?? ""
        problem = experience.problem ?? ""
        solution = experience.solution ?? ""
        insight = experience.insight ?? ""
        content = experience.content ?? ""

        path.append(ExperienceFlowRoute.starMethod)
    }
    
    // Navigation 함수들
    func navigateToStarMethod() {
        path.append(ExperienceFlowRoute.starMethod)
    }
    
    func navigateBack() {
        if !path.isEmpty {
            path.removeLast()
        }
    }
    
    func saveExperience() async {
        isLoading = true
        errorMessage = nil

        let commonEndDate = isOngoing ? nil : (endDate?.toString() ?? "")
        let commonStartDate = startDate?.toString() ?? ""

        do {
            if isEditMode {
                try await performUpdate(startDate: commonStartDate, endDate: commonEndDate)
            } else {
                try await performCreate(startDate: commonStartDate, endDate: commonEndDate)
            }
            onComplete?()
        } catch let error as APIError {
            handleAPIError(error)
        } catch {
            errorMessage = "알 수 없는 오류가 발생했습니다."
            showError = true
        }

        isLoading = false
    }

    private func performCreate(startDate: String, endDate: String?) async throws {
        let request: CreateExperienceRequest
        switch selectedMethod {
        case .star:
            request = CreateExperienceRequest(
                endDate: endDate, experienceType: experienceType ?? "",
                formatType: "STAR", startDate: startDate,
                tags: selectedCompetency ?? "", title: experienceTitle,
                situation: situation, task: task, action: action, result: result,
                problem: nil, solution: nil, insight: nil, content: nil
            )
        case .psi:
            request = CreateExperienceRequest(
                endDate: endDate, experienceType: experienceType ?? "",
                formatType: "PSI", startDate: startDate,
                tags: selectedCompetency ?? "", title: experienceTitle,
                situation: nil, task: nil, action: nil, result: nil,
                problem: problem, solution: solution, insight: insight, content: nil
            )
        case .free:
            request = CreateExperienceRequest(
                endDate: endDate, experienceType: experienceType ?? "",
                formatType: "FREE", startDate: startDate,
                tags: selectedCompetency ?? "", title: experienceTitle,
                situation: nil, task: nil, action: nil, result: nil,
                problem: nil, solution: nil, insight: nil, content: content
            )
        }
        let response = try await experienceRepository.createExperience(request)
        print("경험 등록 성공: \(response)")
    }

    private func performUpdate(startDate: String, endDate: String?) async throws {
        guard let experienceId = editingExperienceId else { return }
        let request: UpdateExperienceRequest
        switch selectedMethod {
        case .star:
            request = UpdateExperienceRequest(
                endDate: endDate, experienceType: experienceType,
                formatType: "STAR", startDate: startDate,
                tags: selectedCompetency, title: experienceTitle,
                situation: situation, task: task, action: action, result: result,
                problem: nil, solution: nil, insight: nil, content: nil
            )
        case .psi:
            request = UpdateExperienceRequest(
                endDate: endDate, experienceType: experienceType,
                formatType: "PSI", startDate: startDate,
                tags: selectedCompetency, title: experienceTitle,
                situation: nil, task: nil, action: nil, result: nil,
                problem: problem, solution: solution, insight: insight, content: nil
            )
        case .free:
            request = UpdateExperienceRequest(
                endDate: endDate, experienceType: experienceType,
                formatType: "FREE", startDate: startDate,
                tags: selectedCompetency, title: experienceTitle,
                situation: nil, task: nil, action: nil, result: nil,
                problem: nil, solution: nil, insight: nil, content: content
            )
        }
        let response = try await experienceRepository.updateExperience(experienceId: experienceId, request: request)
        print("경험 수정 성공: \(response)")
    }
    
    private func handleAPIError(_ error: APIError) {
        switch error {
        case .unauthorized(let message):
            errorMessage = message ?? "로그인이 필요합니다."
        case .validationError(let errors):
            errorMessage = errors.first?.message ?? "입력값을 확인해주세요."
        case .serverError(let message):
            errorMessage = message
        default:
            errorMessage = "네트워크 오류가 발생했습니다."
        }
        showError = true
    }
    
    func loadExampleData() {
        experienceTitle = "iOS 앱 개발 인턴"
        experienceType = "인턴"
        
        // 날짜 예시 (2024년 1월 1일 ~ 2024년 6월 30일)
        let calendar = Calendar.current
        startDate = calendar.date(from: DateComponents(year: 2024, month: 1, day: 1))
        endDate = calendar.date(from: DateComponents(year: 2024, month: 6, day: 30))
        isOngoing = false
        isExampleLoaded = true
    }
    
    func loadExampleData(for method: ExperienceMethod) {
        switch method {
        case .star:
            situation = "앱 사용자 이탈률이 지속적으로 증가하여 월 평균 20%의 사용자가 앱을 삭제하는 문제가 발생했습니다. 데이터 분석 결과, 첫 로그인 후 3일 이내 이탈이 가장 높았습니다."
            task = "사용자 이탈률을 분석하고, 3개월 내 이탈률을 10% 이하로 낮추는 것이 목표였습니다. 특히 신규 사용자의 온보딩 경험을 개선해야 했습니다."
            action = "Firebase Analytics와 Mixpanel을 활용해 사용자 행동 패턴을 분석했습니다. 온보딩 프로세스를 3단계에서 5단계로 세분화하고, 각 단계마다 핵심 기능을 직접 체험할 수 있도록 인터랙티브 튜토리얼을 구현했습니다."
            result = "3개월 후 신규 사용자 이탈률이 20%에서 8%로 감소했습니다. 온보딩 완료율이 45%에서 78%로 증가했고, 데이터 기반 의사결정의 중요성을 직접 체감했습니다."

        case .psi:
            problem = "신규 기능 출시 후 서버 응답 속도가 평균 3초를 초과하며 사용자 불만이 급증했습니다. 특히 피크 타임에 타임아웃 오류가 빈번하게 발생해 서비스 신뢰도가 하락하는 상황이었습니다."
            solution = "프로파일링 도구로 병목 구간을 특정하고, 불필요한 API 중복 호출을 제거했습니다. 캐싱 레이어를 도입하고 데이터베이스 쿼리를 최적화해 응답 속도를 개선했습니다."
            insight = "성능 문제는 코드 품질만의 문제가 아니라 아키텍처 설계 단계에서 결정된다는 것을 배웠습니다. 기능 개발 전 부하 테스트를 선행하는 것이 훨씬 효율적임을 깨달았습니다."

        case .free:
            content = "스타트업 인턴십 기간 동안 처음으로 실제 서비스에 기여하는 경험을 했습니다. 초반에는 낯선 코드베이스와 빠른 개발 속도에 적응하기 힘들었지만, 팀원들과 적극적으로 소통하며 온보딩 기간을 단축했습니다. 맡은 기능을 기한 내에 완성하면서 협업과 자기주도적 학습의 중요성을 실감했고, 이 경험이 이후 프로젝트에서 큰 자산이 됐습니다."
        }
    }
    
    
    @ViewBuilder
    func destination(for route: ExperienceFlowRoute) -> some View {
        switch route {
        case .starMethod:
            ExperienceStarMethodView()
        }
    }
}

class ExperienceDataStore {
    static var shared = ExperienceDataStore()
    
    var experiences: [ExperienceData] = [
        ExperienceData(
            title: "SwiftUI 기반 앱 성능 최적화",
            type: "정규직",
            situation: "앱 실행 시 초기 로딩 시간이 3초 이상 걸려 사용자 이탈이 발생했습니다",
            task: "로딩 시간을 1초 이내로 단축하여 사용자 경험 개선",
            action: "LazyVStack과 이미지 캐싱을 적용하고, 비동기 처리를 통해 메인 스레드 부담 감소",
            result: "초기 로딩 시간 70% 감소, 앱스토어 평점 3.8에서 4.5로 상승",
            competency: "문제해결력",
            score: "95"
        ),
        ExperienceData(
            title: "TCA 아키텍처 도입 및 리팩토링",
            type: "정규직",
            situation: "레거시 코드베이스가 복잡해져 버그 수정과 기능 추가가 어려워짐",
            task: "유지보수 가능한 아키텍처로 전환하여 개발 생산성 향상",
            action: "The Composable Architecture를 도입하고 단위 테스트 커버리지 80% 달성",
            result: "버그 발생률 40% 감소, 신규 기능 개발 속도 2배 향상",
            competency: "전문성",
            score: "92"
        ),
        ExperienceData(
            title: "실시간 채팅 기능 구현",
            type: "인턴",
            situation: "사용자 간 실시간 소통 기능이 필요한 상황",
            task: "WebSocket 기반 실시간 채팅 시스템 구축",
            action: "Starscream 라이브러리 활용, 메시지 큐잉 및 재연결 로직 구현",
            result: "동시접속 5000명 환경에서 안정적 동작, 메시지 전송 성공률 99.8%",
            competency: "실행력",
            score: "88"
        ),
        ExperienceData(
            title: "CoreData 마이그레이션 성공",
            type: "프리랜서",
            situation: "앱 업데이트 시 사용자 데이터 유실 문제 발생",
            task: "안전한 데이터 마이그레이션 프로세스 구축",
            action: "Lightweight Migration과 Heavyweight Migration 전략 수립 및 테스트",
            result: "10만 사용자 데이터 무손실 마이그레이션 완료, 앱 업데이트율 95% 달성",
            competency: "책임감",
            score: "85"
        ),
        ExperienceData(
            title: "App Clip 기능 개발 및 출시",
            type: "개인 프로젝트",
            situation: "앱 설치 없이 빠른 서비스 경험 제공 필요",
            task: "10MB 이하 경량화된 App Clip 개발",
            action: "핵심 기능만 추출하여 모듈화, 코드 사이즈 최적화 진행",
            result: "App Clip을 통한 신규 유입 30% 증가, 전환율 18% 향상",
            competency: "고객이해력",
            score: "82"
        ),
        ExperienceData(
            title: "Accessibility 개선 프로젝트",
            type: "아르바이트",
            situation: "시각 장애인 사용자의 앱 접근성이 낮은 문제",
            task: "VoiceOver 지원 및 Dynamic Type 적용",
            action: "모든 UI 요소에 적절한 accessibility label 추가, 색상 대비 개선",
            result: "접근성 점수 WCAG 2.1 AA 등급 달성, 장애인 사용자 만족도 4.7/5.0",
            competency: "소통력",
            score: "78"
        )
    ]
}
