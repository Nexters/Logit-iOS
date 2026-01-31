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
    
    var onComplete: ((ExperienceData) -> Void)?
    
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
    
    func saveExperience() {
        print("=== 경험 등록 완료 ===")
        print("경험 제목: \(experienceTitle)")
        print("경험 유형: \(experienceType ?? "미선택")")
        print("\n[STAR 분석]")
        print("Situation: \(situation)")
        print("Task: \(task)")
        print("Action: \(action)")
        print("Result: \(result)")
        print("\n핵심 역량: \(selectedCompetency ?? "미선택")")
        print("==================")
        
        let experienceData = ExperienceData(
            title: experienceTitle,
            type: experienceType ?? "",
            situation: situation,
            task: task,
            action: action,
            result: result,
            competency: selectedCompetency ?? "",
            score: "11"
        )
        
        onComplete?(experienceData)
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
