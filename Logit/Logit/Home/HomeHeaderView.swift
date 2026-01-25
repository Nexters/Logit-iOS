//
//  HomeHeaderView.swift
//  Logit
//
//  Created by 임재현 on 1/25/26.
//

import SwiftUI

struct HomeHeaderView: View {
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
                .frame(size: 35.2)
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 20)
        .padding(.top, 2)
        .background(.white)
    }
}
