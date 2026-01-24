//
//  LogitApp.swift
//  Logit
//
//  Created by 임재현 on 1/17/26.
//

import SwiftUI

@main
struct LogitApp: App {
    @State private var isShowingSplash = true
    
    var body: some Scene {
        WindowGroup {
            if isShowingSplash {
                SplashView()
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                            withAnimation {
                                isShowingSplash = false
                            }
                        }
                    }
            } else {
                LoginView()
            }
            
        }
    }
}
