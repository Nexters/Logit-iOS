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
            
            // 카드 레이아웃
            ZStack {
                //  이미지 (오른쪽 상단)
                VStack {
                    HStack {
                        Spacer()
                        
                        Image("42 2")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 125, height: 125)
                            .padding(.top, 20)
                            .padding(.bottom, 10)
                            .padding(.trailing, 10.33)
                    }
                    Spacer()
                }
                
                // 텍스트 영역 (왼쪽)
                VStack(alignment: .leading, spacing: 2) {
                    Text("창의적 문제해결")
                        .typo(.body3_semibold)
                    
                    Text("관련경험 7개")
                        .typo(.body5_medium)
                        .foregroundStyle(.gray200)
                    
                    Spacer()
                }
                .padding(.top, 20)
                .padding(.leading, 20)
                .frame(maxWidth: .infinity, alignment: .leading)
                
                // 페이지 인디케이터 (왼쪽 하단)
                VStack {
                    Spacer()
                    HStack {
                        Text("1 / 8")
                            .typo(.body7_semibold)
                            .foregroundStyle(.white)
                            .padding(.horizontal, 17)
                            .padding(.vertical, 3)
                            .background(
                                Capsule()
                                    .fill(Color.black.opacity(0.2))
                            )
                            .padding(.bottom, 18.91)
                            .padding(.leading, 20)
                        
                        Spacer()
                    }
                }
            }
            .frame(height: 155)
            .background(GradientStyle.experienceCard.gradient)
            .cornerRadius(20)
        }
        .padding(.horizontal, 20)
    }
}
