//
//  LoginView.swift
//  Logit
//
//  Created by 임재현 on 1/23/26.
//

import SwiftUI

struct LoginView: View {
    var body: some View {
        ZStack {
            // 중앙 컨텐츠
            VStack(spacing: 8) {
                Image("logo_symbol_3d")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 70.adjustedWidth, height: 70.adjustedHeight)
                
                Image("app_logo_wordmark")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 71.1.adjustedWidth, height: 36.adjustedHeight)
                
                Text("자소서가 쉬워지는곳")
                    .typo(.semibold_18)
                    .foregroundStyle(.gray100)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            
            // 하단 버튼
            VStack(spacing: 12) {
                Button(action: {
                    // 구글 로그인 액션
                }) {
                    HStack(spacing: 0) {
                        Image("google")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 22, height: 22)
                            .padding(.leading, 16)
                        
                        Text("Google로 시작하기")
                            .typo(.regular_19)
                            .frame(maxWidth: .infinity)
                        
                        Spacer()
                            .frame(width: 38)
                    }
                    .frame(height: 49.adjustedHeight)
                    .background(Color.white)
                    .foregroundColor(.black)
                    .cornerRadius(8)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.gray, lineWidth: 1)
                    )
                }
                Button(action: {
                    // 애플 로그인 액션
                }) {
                    Text("Apple로 시작하기")
                        .typo(.regular_19)
                        .frame(maxWidth: .infinity)
                        .frame(height: 49.adjustedHeight)
                        .background(Color.black)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 38)
            .frame(maxHeight: .infinity, alignment: .bottom)
        }
        .background(.white)
    }
}
