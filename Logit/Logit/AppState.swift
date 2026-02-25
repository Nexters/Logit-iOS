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
    var deleteAlertMessage: String = "삭제하시겠어요?"
    var deleteAlertSubMessage: String? = "삭제하면 복구 못해요"

    private let tokenManager: TokenManager
    private let authRepository: AuthRepository

    init(
        tokenManager: TokenManager = .shared,
        authRepository: AuthRepository = DefaultAuthRepository()
    ) {
        self.tokenManager = tokenManager
        self.authRepository = authRepository
    }

    enum AppPhase {
        case splash
        case login
        case onboarding
        case main
    }

    func requestDeleteConfirmation(
        message: String = "삭제하시겠어요?",
        subMessage: String? = "삭제하면 복구 못해요",
        onConfirm: @escaping () -> Void
    ) {
        deleteAlertMessage = message
        deleteAlertSubMessage = subMessage
        onDeleteConfirm = onConfirm
        isShowingDeleteAlert = true
    }

    func dismissDeleteAlert() {
        isShowingDeleteAlert = false
        onDeleteConfirm = nil
    }

    // Splash 후 Keychain 토큰 여부로 분기
    func checkAuthenticationStatus() {
        if tokenManager.isLoggedIn {
            appPhase = .main
        } else {
            appPhase = .login
        }
    }

    // 온보딩 완료
    func completeOnboarding() {
        appPhase = .main
    }

    // 로그아웃 (API 호출 후 토큰 삭제)
    func logout() {
        Task {
            try? await authRepository.logout()
            isShowingSettings = false
            isShowingAddFlow = false
            selectedProjectId = nil
            appPhase = .login
        }
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
