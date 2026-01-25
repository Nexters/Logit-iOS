//
//  HomeView.swift
//  Logit
//
//  Created by 임재현 on 1/24/26.
//

import SwiftUI

struct HomeView: View {
    @State private var hasProjects: Bool = false
    
    var body: some View {
        VStack(spacing: 0) {
            
            HomeHeaderView()
            ExperienceTypeSection()
                .padding(.top, 22)
            
            ProjectListSection(hasProjects: hasProjects)
                .padding(.top, 43)
            
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
        .background(.white)
    }
}

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

struct ProjectListSection: View {
    let hasProjects: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // 헤더
            HStack {
                Text("프로젝트 목록")
                    .typo(.body3_bold)
                    .foregroundStyle(.black)
                
                Spacer()
//                
//                if hasProjects {
//                    Button {
//                        // 전체보기 액션
//                    } label: {
//                        HStack(spacing: 4) {
//                            Text("전체보기")
//                                .typo(.body5_medium)
//                                .foregroundStyle(.gray200)
//                            
//                            Image(systemName: "chevron.right")
//                                .font(.system(size: 12))
//                                .foregroundStyle(.gray200)
//                        }
//                    }
//                }
            }
            .padding(.horizontal, 20)
            
            // 컨텐츠
            if hasProjects {
                ProjectListView()
            } else {
                ProjectEmptyView()
            }
        }
    }
}

struct ProjectEmptyView: View {
    var body: some View {
        VStack {
            Image("app_status_empty")
                .resizable()
                .scaledToFit()
                .frame(width: 150,height: 117)
        }
        .frame(maxWidth: .infinity,maxHeight: .infinity)
        .padding(.vertical, 60)
        .background(.white)
        .cornerRadius(16)
        .padding(.horizontal, 20)
    }
}


struct ProjectListView: View {
    // 나중에 실제 데이터로 교체
    let mockProjects = [
        ("프로젝트 1", "2024.01.15"),
        ("프로젝트 2", "2023.12.20"),
        ("프로젝트 3", "2023.11.05"),
        ("프로젝트 4", "2023.11.05"),
        ("프로젝트 5", "2023.11.05")
    ]
    
    var body: some View {
        VStack(spacing: 0) {
            ForEach(mockProjects.indices, id: \.self) { index in
                ProjectCardCell(
                    title: mockProjects[index].0,
                    date: mockProjects[index].1
                )
                
                // Divider (마지막 셀 제외)
                if index < mockProjects.count - 1 {
                    Divider()
                        .background(Color.gray100)
                        .padding(.horizontal, 20)
                }
            }
        }
    }
}

struct ProjectCardCell: View {
    let title: String
    let date: String
    
    var body: some View {
        HStack(spacing: 12) {
            // 세로 막대기 (태그)
            RoundedRectangle(cornerRadius: 2)
                .fill(Color.blue)
                .frame(width: 3, height: 24)
            
            // 타이틀
            Text(title)
                .typo(.body6_medium)
                .foregroundStyle(.black)
                .lineLimit(1)
            
            Spacer()
            
            // 날짜
            Text(date)
                .typo(.body7_regular_140)
                .foregroundStyle(.gray100)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 17.5)
        .background(Color.white)
    }
}
