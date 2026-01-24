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
    @Published var isShowingSignUpSheet: Bool = false
    
    enum AppPhase {
        case splash
        case login
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
        case noToken          // 로그인 필요
        case existingUser     // 바로 메인으로
        case newUser          // 약관동의로
    }
    
    func checkAuthenticationStatus() {
           // Splash 후 자동 로그인 체크
           DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
               if let token = self.mockAccessToken {
                   // 토큰이 있으면 회원가입 완료 여부 확인
                   if self.mockIsRegistrationComplete {
                       self.appPhase = .main
                   } else {
                       // 신규 유저는 로그인 화면에서 시트 표시
                       self.appPhase = .login
                       self.isShowingSignUpSheet = true 
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
        isShowingSignUpSheet = true
    }
    
    // 회원가입 완료
    func completeRegistration() {
        mockIsRegistrationComplete = true
        isShowingSignUpSheet = false
        appPhase = .main
    }
    
    // 로그아웃
    func logout() {
        mockAccessToken = nil
        mockIsRegistrationComplete = false
        appPhase = .login
    }
}
