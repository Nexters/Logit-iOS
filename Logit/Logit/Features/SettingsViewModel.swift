//
//  SettingsViewModel.swift
//  Logit
//
//  Created by 임재현 on 2/24/26.
//

import Foundation

@MainActor
class SettingsViewModel: ObservableObject {
    @Published var userName: String = ""
    @Published var usedTokens: Int = 0
    @Published var totalTokens: Int = 0
    @Published var isLoggingOut: Bool = false
    @Published var isLoggedOut: Bool = false
    @Published var logoutError: String?

    @Published var isWithdrawing: Bool = false
    @Published var isWithdrawn: Bool = false
    @Published var withdrawError: String?

    private let userRepository: UserRepository
    private let authRepository: AuthRepository
    private let tokenRepository: TokenRepository

    init(
        userRepository: UserRepository = DefaultUserRepository(networkClient: DefaultNetworkClient()),
        authRepository: AuthRepository = DefaultAuthRepository(),
        tokenRepository: TokenRepository = DefaultTokenRepository()
    ) {
        self.userRepository = userRepository
        self.authRepository = authRepository
        self.tokenRepository = tokenRepository
    }

    func fetchCurrentUser() async {
        do {
            let user = try await userRepository.getCurrentUser()
            userName = user.fullName ?? ""
            print("유저 정보 조회 성공: \(user.fullName ?? "")")
        } catch {
            print("유저 정보 조회 실패: \(error)")
        }
    }

    func fetchTokenBalance() async {
        do {
            let balance = try await tokenRepository.getBalance()
            usedTokens = balance.monthlyUsed
            totalTokens = balance.balance + balance.monthlyUsed
            if balance.attendanceAmount > 0 {
                NotificationCenter.default.post(
                    name: .attendanceRewardReceived,
                    object: nil,
                    userInfo: ["amount": balance.attendanceAmount]
                )
            }
            print("토큰 잔액 조회 성공: \(balance.monthlyUsed) / \(balance.balance + balance.monthlyUsed)")
        } catch {
            print("토큰 잔액 조회 실패: \(error)")
        }
    }

    func logout() async {
        isLoggingOut = true
        logoutError = nil
        do {
            try await authRepository.logout()
            isLoggedOut = true
            print("로그아웃 성공")
        } catch let error as APIError {
            print("로그아웃 실패: \(error)")
            switch error {
            case .unauthorized:
                // 토큰이 없거나 만료된 경우 → 로컬 토큰 정리 후 로그인으로
                TokenManager.shared.clearTokens()
                isLoggedOut = true
            default:
                logoutError = "로그아웃에 실패했습니다. 다시 시도해주세요."
            }
        } catch {
            print("로그아웃 실패: \(error)")
            logoutError = "로그아웃에 실패했습니다. 다시 시도해주세요."
        }
        isLoggingOut = false
    }

    func withdraw() async {
        isWithdrawing = true
        withdrawError = nil
        do {
            try await userRepository.deleteCurrentUser()
            TokenManager.shared.clearTokens()
            isWithdrawn = true
            print("회원탈퇴 성공")
        } catch let error as APIError {
            print("회원탈퇴 실패: \(error)")
            withdrawError = "회원탈퇴에 실패했습니다. 다시 시도해주세요."
        } catch {
            print("회원탈퇴 실패: \(error)")
            withdrawError = "회원탈퇴에 실패했습니다. 다시 시도해주세요."
        }
        isWithdrawing = false
    }
}
