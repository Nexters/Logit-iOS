//
//  SplashView.swift
//  Logit
//
//  Created by 임재현 on 1/23/26.
//

import SwiftUI

struct SplashView: View {
    var body: some View {
        ZStack {
            Color.white
                .ignoresSafeArea()
            
            Image("app_logo_splash")
                .resizable()
                .scaledToFit()
                .frame(width: 173.53.adjustedWidth, height: 60.adjustedHeight)
        }
    }
}
