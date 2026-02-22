//
//  LoginViewModel.swift
//  Logit
//
//  Created by 임재현 on 2/22/26.
//

import Foundation
import AuthenticationServices
import GoogleSignIn
import UIKit

@MainActor
class LoginViewModel: ObservableObject {
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var loginResult: AppleLoginResponse?

    private let authRepository: AuthRepository

    init(authRepository: AuthRepository = DefaultAuthRepository()) {
        self.authRepository = authRepository
    }

    func handleAppleLogin(_ authorization: ASAuthorization) {
        guard let credential = authorization.credential as? ASAuthorizationAppleIDCredential else {
            return
        }

        guard let idTokenData = credential.identityToken,
              let idToken = String(data: idTokenData, encoding: .utf8) else {
            errorMessage = "Apple 인증 토큰을 가져오지 못했습니다."
            return
        }

        let authorizationCode = credential.authorizationCode.flatMap { String(data: $0, encoding: .utf8) }
        let fullName = formatFullName(credential.fullName)

        print("===== Apple Sign In Credential =====")
        print("userID: \(credential.user)")
        print("idToken: \(idToken)")
        print("authorizationCode(accessToken 교환용): \(authorizationCode ?? "nil")")
        print("fullName: \(fullName ?? "nil")")
        print("email: \(credential.email ?? "nil")")
        print("====================================")

        Task {
            await loginWithApple(idToken: idToken, fullName: fullName)
        }
    }

    private func loginWithApple(idToken: String, fullName: String?) async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            let request = AppleLoginRequest(idToken: idToken, fullName: fullName)
            let response = try await authRepository.appleLogin(request: request)

            TokenManager.shared.saveTokens(
                access: response.accessToken,
                refresh: response.refreshToken
            )

            print("로그인 성공 - isNewUser: \(response.isNewUser)")
            loginResult = response
        } catch {
            errorMessage = error.localizedDescription
            print("로그인 실패: \(error)")
        }
    }

    private func formatFullName(_ nameComponents: PersonNameComponents?) -> String? {
        guard let nameComponents else { return nil }
        let parts = [nameComponents.familyName, nameComponents.givenName].compactMap { $0 }
        return parts.isEmpty ? nil : parts.joined(separator: " ")
    }

    // MARK: - Google Login

    func handleGoogleLogin() {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let rootVC = windowScene.windows.first?.rootViewController else {
            errorMessage = "화면 정보를 가져오지 못했습니다."
            return
        }

        GIDSignIn.sharedInstance.signIn(withPresenting: rootVC) { [weak self] signInResult, error in
            if let error {
                Task { @MainActor in
                    self?.errorMessage = error.localizedDescription
                }
                return
            }

            guard let idToken = signInResult?.user.idToken?.tokenString else {
                Task { @MainActor in
                    self?.errorMessage = "Google 인증 토큰을 가져오지 못했습니다."
                }
                return
            }

            Task {
                await self?.loginWithGoogle(idToken: idToken)
            }
        }
    }

    private func loginWithGoogle(idToken: String) async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            let request = GoogleLoginRequest(idToken: idToken)
            let response = try await authRepository.googleLogin(request: request)

            TokenManager.shared.saveTokens(
                access: response.accessToken,
                refresh: response.refreshToken
            )

            print("구글 로그인 성공 - isNewUser: \(response.isNewUser)")
            loginResult = response
        } catch {
            errorMessage = error.localizedDescription
            print("구글 로그인 실패: \(error)")
        }
    }
}
