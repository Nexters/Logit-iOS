//
//  ProjectListSection.swift
//  Logit
//
//  Created by 임재현 on 1/25/26.
//

import SwiftUI

struct ProjectListSection: View {
    let hasProjects: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8.adjustedLayout) {
            // 헤더
            HStack {
                Text("프로젝트 목록")
                    .typo(.body3_bold)
                    .foregroundStyle(.black)
                
                Spacer()
            }
            .padding(.horizontal, 20.adjustedLayout)
            
            // 컨텐츠
            if hasProjects {
                ProjectListView()
                    .padding(.top, 8.adjustedLayout)
            } else {
                ProjectEmptyView()
            }
        }
    }
}

struct ProjectEmptyView: View {
    var body: some View {
        VStack(spacing: 0) {
            Image("app_status_empty2")
                .resizable()
                .scaledToFit()
                .frame(width: 80.adjustedLayout, height: 80.adjustedLayout)
            
            Text("자기소개서를 생성해보세요")
                .typo(.body6_medium)
                .foregroundStyle(.gray100)
                .padding(.top, 16.adjustedLayout)
            
            Button {
                // 버튼 액션
            } label: {
                Text("자기소개서 작성")
                    .typo(.body6_medium)
                    .foregroundStyle(.white)
                    .padding(.horizontal, 24.adjustedLayout)
                    .padding(.vertical, 7.5.adjustedLayout)
                    .background(.primary100)
                    .cornerRadius(8.adjustedLayout)
            }
            .padding(.top, 17.adjustedLayout)
        }
        .offset(y: -10.adjustedLayout)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(.vertical, 60.adjustedLayout)
        .background(.white)
        .cornerRadius(16.adjustedLayout)
        .padding(.horizontal, 20.adjustedLayout)
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
                        .padding(.horizontal, 20.adjustedLayout)
                }
            }
        }
    }
}

struct ProjectCardCell: View {
    let title: String
    let date: String
    
    var body: some View {
        HStack(spacing: 12.adjustedLayout) {
            // 세로 막대기 (태그)
            RoundedRectangle(cornerRadius: 2.adjustedLayout)
                .fill(.primary70)
                .frame(width: 3.adjustedWidth, height: 24.adjustedHeight)
            
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
        .padding(.horizontal, 20.adjustedLayout)
        .padding(.vertical, 17.5.adjustedLayout)
        .background(Color.white)
    }
}
