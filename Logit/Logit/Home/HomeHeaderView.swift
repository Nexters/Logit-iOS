//
//  HomeHeaderView.swift
//  Logit
//
//  Created by 임재현 on 1/25/26.
//

import SwiftUI

struct HomeHeaderView: View {
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        HStack {
           Image("app_logo_symbolWord")
                .resizable()
                .scaledToFit()
                .frame(width: 85.35.adjustedWidth, height: 28.adjustedHeight)
            
            Spacer()
            
            Image("app_user")
                .resizable()
                .scaledToFit()
                .frame(size: 35.2.adjustedLayout)
                .onTapGesture {
                    appState.startSettings()
                }
        }
        .padding(.vertical, 8.adjustedLayout)
        .padding(.horizontal, 20.adjustedLayout)
        .padding(.top, 2.adjustedLayout)
        .background(.white)
    }
}
