//
//  AppState.swift
//  Logit
//
//  Created by 임재현 on 1/24/26.
//

import SwiftUI

@MainActor
class AppState: ObservableObject {
    @Published var appPhase: AppPhase = .splash
    @Published var isShowingAddFlow: Bool = false
    @Published var isShowingSettings = false
    @Published var selectedProjectId: String?
    @Published var isShowingDeleteAlert: Bool = false
    var onDeleteConfirm: (() -> Void)?

    func requestDeleteConfirmation(onConfirm: @escaping () -> Void) {
        onDeleteConfirm = onConfirm
        isShowingDeleteAlert = true
    }

    func dismissDeleteAlert() {
        isShowingDeleteAlert = false
        onDeleteConfirm = nil
    }

    enum AppPhase {
        case splash
        case login
        case onboarding
        case main
    }

    // Mock용 상태
    private var mockAccessToken: String?
    private var mockIsRegistrationComplete: Bool = false

    // 테스트용 초기화
    init(mockScenario: MockScenario = .noToken) {
        switch mockScenario {
        case .noToken:
            mockAccessToken = nil
            mockIsRegistrationComplete = false

        case .existingUser:
            mockAccessToken = "mock_token_existing"
            mockIsRegistrationComplete = true

        case .newUser:
            mockAccessToken = "mock_token_new"
            mockIsRegistrationComplete = false
        }
    }

    enum MockScenario {
        case noToken  // 로그인 필요
        case existingUser  // 바로 메인으로
        case newUser  // 약관동의로
    }

    func checkAuthenticationStatus() {
        // Splash 후 자동 로그인 체크
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            if let _ = self.mockAccessToken {
                if self.mockIsRegistrationComplete {
                    self.appPhase = .main
                } else {
                    // 신규 유저는 온보딩으로
                    self.appPhase = .onboarding
                }
            } else {
                // 토큰이 없으면 로그인 화면
                self.appPhase = .login
            }
        }
    }

    // Mock 로그인 (기존 유저)
    func mockLoginExistingUser() {
        mockAccessToken = "mock_token_existing"
        mockIsRegistrationComplete = true
        appPhase = .main
    }
    
    // Mock 로그인 (신규 유저)
    func mockLoginNewUser() {
        mockAccessToken = "mock_token_new"
        mockIsRegistrationComplete = false
        appPhase = .onboarding
    }

    // 온보딩 완료
    func completeOnboarding() {
        mockIsRegistrationComplete = true
        appPhase = .main
    }

    // 로그아웃
    func logout() {
        mockAccessToken = nil
        mockIsRegistrationComplete = false
        isShowingSettings = false
        isShowingAddFlow = false
        selectedProjectId = nil
        appPhase = .login
    }

    func startAddFlow() {
        isShowingAddFlow = true
    }

    func startSettings() {
        isShowingSettings = true
    }

    func openWorkspace(projectId: String) {
        selectedProjectId = projectId
    }
}
