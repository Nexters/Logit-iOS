//
//  LogitApp.swift
//  Logit
//
//  Created by 임재현 on 1/17/26.
//

import SwiftUI
import GoogleSignIn

@main
struct LogitApp: App {
    @StateObject private var appState = AppState(mockScenario: .existingUser)

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(appState)
                .onOpenURL { url in
                    GIDSignIn.sharedInstance.handle(url)
                }
        }
    }
}
