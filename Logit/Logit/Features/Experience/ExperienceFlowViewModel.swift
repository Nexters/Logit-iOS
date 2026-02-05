//
//  ExperienceFlowViewModel.swift
//  Logit
//
//  Created by 임재현 on 1/29/26.
//

import SwiftUI

@MainActor
class ExperienceFlowViewModel: ObservableObject {
    @Published var path = NavigationPath()
    
    // 데이터
    @Published var experienceTitle: String = ""
    @Published var experienceType: String?
    @Published var situation: String = ""
    @Published var task: String = ""
    @Published var action: String = ""
    @Published var result: String = ""
    @Published var selectedCompetency: String?
    
    @Published var startDate: Date?
    @Published var endDate: Date?
    @Published var isOngoing: Bool = false
    
    var onComplete: (() -> Void)?
    
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var showError: Bool = false
    
    private let experienceRepository: ExperienceRepository
    
    init(experienceRepository: ExperienceRepository) {
        self.experienceRepository = experienceRepository
    }
    
    // Navigation 함수들
    func navigateToStarMethod() {
        path.append(ExperienceFlowRoute.starMethod)
    }
    
    func navigateToExperienceType() {
        path.append(ExperienceFlowRoute.experienceType)
    }
    
    func navigateBack() {
        if !path.isEmpty {
            path.removeLast()
        }
    }
    
    func saveExperience() async {
         isLoading = true
         errorMessage = nil
         
         do {
             // Request 생성
             let request = CreateExperienceRequest(
                 action: action,
                 category: selectedCompetency ?? "",
                 endDate: isOngoing ? "" : (endDate?.toString() ?? ""),
                 experienceType: experienceType ?? "",
                 result: result,
                 situation: situation,
                 startDate: startDate?.toString() ?? "",
                 task: task,
                 title: experienceTitle
             )
             
             // API 호출
             let response: ExperienceResponse = try await experienceRepository.createExperience(request)
             
             print("경험 등록 성공: \(response)")
             
             // 성공하면 그냥 dismiss
             onComplete?()
             
         } catch let error as APIError {
             handleAPIError(error)
         } catch {
             errorMessage = "알 수 없는 오류가 발생했습니다."
             showError = true
         }
         
         isLoading = false
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
    }
    
    // STAR 기반 경험 정리 예시 데이터 불러오기
        func loadStarExampleData() {
            situation = "앱 사용자 이탈률이 지속적으로 증가하여 월 평균 20%의 사용자가 앱을 삭제하는 문제가 발생했습니다. 데이터 분석 결과, 첫 로그인 후 3일 이내 이탈이 가장 높았습니다."
            
            task = "사용자 이탈률을 분석하고, 3개월 내 이탈률을 10% 이하로 낮추는 것이 목표였습니다. 특히 신규 사용자의 온보딩 경험을 개선해야 했습니다."
            
            action = "Firebase Analytics와 Mixpanel을 활용해 사용자 행동 패턴을 분석했습니다. 온보딩 프로세스를 3단계에서 5단계로 세분화하고, 각 단계마다 핵심 기능을 직접 체험할 수 있도록 인터랙티브 튜토리얼을 구현했습니다. SwiftUI를 활용해 부드러운 애니메이션과 직관적인 UI를 제공했습니다."
            
            result = "3개월 후 신규 사용자 이탈률이 20%에서 8%로 감소했습니다. 특히 온보딩 완료율이 45%에서 78%로 증가했고, 첫 3일 내 핵심 기능 사용률이 2배 향상되었습니다. 이 경험을 통해 데이터 기반 의사결정의 중요성과 사용자 경험 개선이 비즈니스 성과에 직접적인 영향을 미친다는 것을 배웠습니다."
        }
    
    
    @ViewBuilder
    func destination(for route: ExperienceFlowRoute) -> some View {
        switch route {
        case .starMethod:
            ExperienceStarMethodView()
        case .experienceType:
            ExperienceTypeSelectionView()
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
