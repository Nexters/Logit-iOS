//
//  HomeView.swift
//  Logit
//
//  Created by 임재현 on 1/24/26.
//

import SwiftUI

struct HomeView: View {
    var body: some View {
        VStack(spacing: 0) {
            
            HomeHeaderView()
            ExperienceTypeSection()
                .padding(.top, 22)
            
            Spacer()
            
        }
    }
}

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
        .background(.red)
    }
}

struct ExperienceTypeSection: View {
    var body: some View {
        
        VStack(alignment: .leading, spacing: 12) {
            Text("로짓님의 경험 유형")
                .typo(.body3_bold)
                .foregroundStyle(.black)
            
            RoundedRectangle(cornerRadius: 20)
                .fill(GradientStyle.experienceCard.gradient)
                .frame(height: 155)
               
        }
        .padding(.horizontal, 20)
    }
}
