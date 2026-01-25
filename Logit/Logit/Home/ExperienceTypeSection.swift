//
//  ExperienceTypeSection.swift
//  Logit
//
//  Created by 임재현 on 1/25/26.
//

import SwiftUI

struct ExperienceTypeSection: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("로짓님의 경험 유형")
                .typo(.body3_bold)
                .foregroundStyle(.black)
            
            TabView {
                ExperienceCardView(
                    title: "주도적 실행력",
                    count: 7,
                    imageName: "주도적 실행력",
                    currentPage: 1,
                    totalPages: 8,
                    backgroundStyle: .gradient(.experienceCard)
                )
                
                ExperienceCardView(
                    title: "기술적 전문성",
                    count: 5,
                    imageName: "기술적 전문성",
                    currentPage: 2,
                    totalPages: 8,
                    backgroundStyle: .gradient(.experienceCard)
                )
                
                ExperienceCardView(
                    title: "논리적 분석력",
                    count: 3,
                    imageName: "논리적 분석력",
                    currentPage: 3,
                    totalPages: 8,
                    backgroundStyle: .color(.icon7)
                )
                
                ExperienceCardView(
                    title: "창의적 문제해결",
                    count: 3,
                    imageName: "창의적 문제해결",
                    currentPage: 4,
                    totalPages: 8,
                    backgroundStyle: .color(.icon7)
                )
                
                ExperienceCardView(
                    title: "협력적 소통",
                    count: 3,
                    imageName: "협력적 소통",
                    currentPage: 5,
                    totalPages: 8,
                    backgroundStyle: .gradient(.empty100)
                )
                
                ExperienceCardView(
                    title: "끈기 있는 책임감",
                    count: 3,
                    imageName: "끈기 있는 책임감",
                    currentPage: 6,
                    totalPages: 8,
                    backgroundStyle: .gradient(.empty200)
                )
                
                ExperienceCardView(
                    title: "유연한 적응력",
                    count: 3,
                    imageName: "유연한 적응력",
                    currentPage: 7,
                    totalPages: 8,
                    backgroundStyle: .gradient(.empty100)
                )
                
                ExperienceCardView(
                    title: "고객 가치 지향",
                    count: 3,
                    imageName: "고객 가치 지향",
                    currentPage: 8,
                    totalPages: 8,
                    backgroundStyle: .gradient(.empty100)
                )
                
                
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .frame(height: 155)
        }
        .padding(.horizontal, 20)
    }
}
