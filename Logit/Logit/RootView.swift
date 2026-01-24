//
//  RootView.swift
//  Logit
//
//  Created by 임재현 on 1/24/26.
//

import SwiftUI

struct RootView: View {
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        Group {
            switch appState.appPhase {
            case .splash:
                SplashView()
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                            appState.checkAuthenticationStatus()
                        }
                    }
                
            case .login:
                LoginView()
                
            case .termsAgreement:
                Rectangle()
                     .background(.black)
               // TermsAgreementView()
                
            case .main:
               Rectangle()
                    .background(.red)
               // MainTabView()
            }
        }
    }
}
