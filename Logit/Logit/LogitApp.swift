//
//  LogitApp.swift
//  Logit
//
//  Created by 임재현 on 1/17/26.
//

import SwiftUI

@main
struct LogitApp: App {
    @StateObject private var appState = AppState()
    
    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(appState)
            
        }
    }
}
