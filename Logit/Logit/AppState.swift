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
    private var authObserver: NSObjectProtocol?  // 반드시 strong reference 유지

    init(
        tokenManager: TokenManager = .shared,
        authRepository: AuthRepository = DefaultAuthRepository()
    ) {
        self.tokenManager = tokenManager
        self.authRepository = authRepository

        // Refresh token 만료 시 자동으로 로그인 화면으로 이동
        // addObserver(forName:queue:using:)는 반환 토큰을 저장해야 observer가 유지됨
        authObserver = NotificationCenter.default.addObserver(
            forName: .authenticationRequired,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            Task { @MainActor [weak self] in
                self?.forceLogout()
            }
        }
    }

    deinit {
        if let observer = authObserver {
            NotificationCenter.default.removeObserver(observer)
        }
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

    // 정상 로그아웃 (서버 API 호출 후 토큰 삭제)
    func logout() {
        Task {
            try? await authRepository.logout()
            forceLogout()
        }
    }

    // 강제 로그아웃 (refresh 실패 등 인증 완전 만료 시 API 없이 즉시 이동)
    func forceLogout() {
        tokenManager.clearTokens()
        isShowingSettings = false
        isShowingAddFlow = false
        selectedProjectId = nil
        isShowingDeleteAlert = false
        appPhase = .login
    }

    func startAddFlow() {
        isShowingAddFlow = true
    }

    func startSettings() {
        isShowingSettings = true
    }

    var openWorkspaceOnCoverLetterTab: Bool = false

    func openWorkspace(projectId: String, onCoverLetterTab: Bool = false) {
        openWorkspaceOnCoverLetterTab = onCoverLetterTab
        selectedProjectId = projectId
    }
}
