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
                        .frame(width: 125.adjustedLayout, height: 125.adjustedLayout)
                        .padding(.top, 20.adjustedLayout)
                        .padding(.bottom, 10.adjustedLayout)
                        .padding(.trailing, 10.33.adjustedLayout)
                }
                Spacer()
            }
            
            // 텍스트 영역 (왼쪽)
            VStack(alignment: .leading, spacing: 2.adjustedLayout) {
                Text(title)
                    .typo(.semibold_18)
                
                Text("관련경험 \(count)개")
                    .typo(.medium_16)
                    .foregroundStyle(.gray200)
                
                Spacer()
            }
            .padding(.top, 20.adjustedLayout)
            .padding(.leading, 20.adjustedLayout)
            .frame(maxWidth: .infinity, alignment: .leading)
            
            // 페이지 인디케이터 (왼쪽 하단)
            VStack {
                Spacer()
                HStack {
                    Text("\(currentPage) / \(totalPages)")
                        .typo(.semibold_14)
                        .foregroundStyle(.white)
                        .padding(.horizontal, 17.adjustedLayout)
                        .padding(.vertical, 3.adjustedLayout)
                        .background(
                            Capsule()
                                .fill(Color.black.opacity(0.2))
                        )
                        .padding(.bottom, 18.91.adjustedLayout)
                        .padding(.leading, 20.adjustedLayout)
                    
                    Spacer()
                }
            }
        }
        .frame(height: 155.adjustedHeight)
        .background(backgroundStyle.style)
        .cornerRadius(20.adjustedLayout)
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
