//
//  LoginView.swift
//  Logit
//
//  Created by 임재현 on 1/23/26.
//

import SwiftUI
import AuthenticationServices

struct LoginView: View {
    @EnvironmentObject var appState: AppState
    @StateObject private var viewModel = LoginViewModel()

    // TODO: 실제 URL로 교체
    private let termsOfServiceURL = URL(string: "https://docs.logit.ai.kr/policys/tos")!
    private let privacyPolicyURL = URL(string: "https://docs.logit.ai.kr/policys/privacy-policy")!

    private var termsAndPrivacyText: some View {
        var baseText = AttributedString("계속하면 ")
        baseText.foregroundColor = Color.gray300

        var termsText = AttributedString("이용약관")
        termsText.link = termsOfServiceURL
        termsText.foregroundColor = .blue
        termsText.underlineStyle = Text.LineStyle(pattern: .solid, color: .blue)

        var dotText = AttributedString(" · ")
        dotText.foregroundColor = Color.gray300

        var privacyText = AttributedString("개인정보 처리방침")
        privacyText.link = privacyPolicyURL
        privacyText.foregroundColor = .blue
        privacyText.underlineStyle = Text.LineStyle(pattern: .solid, color: .blue)

        var endText = AttributedString("에 동의합니다.")
        endText.foregroundColor = Color.gray300

        return Text(baseText + termsText + dotText + privacyText + endText)
            .typo(.regular_12)
            .multilineTextAlignment(.center)
    }

    var body: some View {
        ZStack {
            // 중앙 컨텐츠
            VStack(spacing: 8) {
                Image("logo_symbol_3d")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 70.adjustedWidth, height: 70.adjustedHeight)
                
                Image("app_logo_wordmark")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 71.1.adjustedWidth, height: 36.adjustedHeight)
                
                Text("자소서가 쉬워지는곳")
                    .typo(.semibold_18)
                    .foregroundStyle(.gray100)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .ignoresSafeArea()
            
            // 하단 버튼
            VStack(spacing: 12) {
                Button(action: {
                    viewModel.handleGoogleLogin()
                }) {
                    HStack(spacing: 0) {
                        Image("google")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 22, height: 22)
                            .padding(.leading, 16)
                        
                        Text("Google로 시작하기")
                            .typo(.regular_18)
                            .frame(maxWidth: .infinity)
                        
                        Spacer()
                            .frame(width: 38)
                    }
                    .frame(height: 52.adjustedHeight)
                    .background(Color.white)
                    .foregroundColor(.black)
                    .cornerRadius(8)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.gray100, lineWidth: 1)
                    )
                }

                Text("Apple로 시작하기")
                    .typo(.regular_19)
                    .frame(maxWidth: .infinity)
                    .frame(height: 52.adjustedHeight)
                    .background(Color.black)
                    .foregroundColor(.white)
                    .cornerRadius(8)
                    .overlay(
                        SignInWithAppleButton(.signIn) { request in
                            request.requestedScopes = [.fullName, .email]
                        } onCompletion: { result in
                            switch result {
                            case .success(let authorization):
                                viewModel.handleAppleLogin(authorization)
                            case .failure(let error):
                                print("Apple 로그인 실패: \(error.localizedDescription)")
                            }
                        }
                        .signInWithAppleButtonStyle(.black)
                        .cornerRadius(8)
                        .environment(\.colorScheme, .dark)
                    )

                termsAndPrivacyText
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 63)
            .frame(maxHeight: .infinity, alignment: .bottom)

            // 로딩 오버레이
            if viewModel.isLoading {
                Color.black.opacity(0.3)
                    .ignoresSafeArea()
                ProgressView()
                    .tint(.white)
                    .scaleEffect(1.5)
            }
        }
        .background(.white)
        .onChange(of: viewModel.loginResult) { _, result in
            guard let result else { return }
            if result.isNewUser {
                appState.isShowingSignUpSheet = true
            } else {
                appState.appPhase = .main
            }
        }
        .alert("로그인 실패", isPresented: .constant(viewModel.errorMessage != nil)) {
            Button("확인") { viewModel.errorMessage = nil }
        } message: {
            Text(viewModel.errorMessage ?? "")
        }
    }
}
