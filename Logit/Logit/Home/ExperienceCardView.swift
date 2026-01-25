//
//  ExperienceCardView.swift
//  Logit
//
//  Created by 임재현 on 1/25/26.
//

import SwiftUI

struct ExperienceCardView: View {
    let title: String
    let count: Int
    let imageName: String
    let currentPage: Int
    let totalPages: Int
    let backgroundStyle: CardBackgroundStyle
    
    var body: some View {
        ZStack {
            // 이미지 (오른쪽 상단)
            VStack {
                HStack {
                    Spacer()
                    
                    Image(imageName)
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
                Text(title)
                    .typo(.body3_semibold)
                
                Text("관련경험 \(count)개")
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
                    Text("\(currentPage) / \(totalPages)")
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
        .background(backgroundStyle.style)
        .cornerRadius(20)
    }
}


enum CardBackgroundStyle {
    case gradient(GradientStyle)
    case color(Color)
    
    var style: AnyShapeStyle {
        switch self {
        case .gradient(let gradientStyle):
            return AnyShapeStyle(gradientStyle.gradient)
        case .color(let color):
            return AnyShapeStyle(color)
        }
    }
}
