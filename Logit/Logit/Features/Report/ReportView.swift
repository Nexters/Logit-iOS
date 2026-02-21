//
//  ReportView.swift
//  Logit
//
//  Created by 임재현 on 2/20/26.
//

import SwiftUI

struct ReportView: View {
    var body: some View {
        VStack {
            Text("로짓님의 프로파일")
                .typo(.bold_20)
                .foregroundStyle(.black)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.vertical, 10)
                .padding(.leading, 20)
            
            VStack(spacing: 0) {
                Image("Frame 2087332000")
                    .resizable()
                    .frame(width: 100, height: 36)
                    .padding(.top, 16)
                
                Image("기술적 전문성")
                    .resizable()
                    .frame(width: 154, height: 154)
                    .padding(.top, 17.98)
                
                Text("도구와 기술 스택을 능숙하게\n활용하는 기술적 전문가")
                    .typo(.bold_20)
                    .foregroundStyle(.gradient(.reportCardTextColor))
                    .multilineTextAlignment(.center)
                    .padding(.top, 13.02)
                
            }
            .frame(maxWidth: .infinity)
            .frame(height: 320)
            .background(.gradient(.reportCard))
            .cornerRadius(20)
            .padding(.horizontal, 20)
            .padding(.top, 11)
            
            VStack(alignment: .leading, spacing: 5) {
                Text("기술적 전문성이 가장 두드러져요")
                    .typo(.bold_18)
                    .foregroundStyle(.black)
                
                Text("{각 해쉬태그 별 전문성을 강조하는 지정 멘트}")
                    .typo(.regular_15)
                    .foregroundStyle(.gray)
                
                // 서버에서 받아온 태그 영역
                FlowTagsView(
                    competencyTag: "전문성",
                    tags: ["고객이해력", "소통력", "실행력", "문제해결력","고객이해력"],
                    allCompetency: true
                )
                .padding(.top, 28)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 20)
            .padding(.top, 34)
            
            Spacer()
        }
        .background(.white)
    }
}


struct FlowTagsView: View {
    let competencyTag: String
    let tags: [String]
    var allCompetency: Bool = false
    let spacing: CGFloat = 8
    
    private var allTags: [(String, Bool)] {
        [(competencyTag, true)] + tags.map { ($0, allCompetency) }
    }
    
    var body: some View {
        FlowLayout(spacing: spacing) {
            ForEach(allTags, id: \.0) { tag, isCompetency in
                ReportTag(
                    text: tag,
                    icon: isCompetency ? tag : nil
                )
            }
        }
    }
}


struct ReportTag: View {
    let text: String
    var icon: String? = nil
    
    var body: some View {
        HStack(spacing: 6) {
            if let icon = icon {
                Image(icon)
                    .resizable()
                    .frame(width: 16, height: 16)
            }
            
            Text(text)
                .typo(.regular_15)
                .foregroundColor(.primary600)
                .lineLimit(1)
        }
        .padding(.horizontal, 8.31) 
        .padding(.vertical, 6.5)
        .background(Color(hex: "E3F5FF"))
        .cornerRadius(11.08)
        .fixedSize(horizontal: true, vertical: false)
    }
}
