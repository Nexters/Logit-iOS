//
//  ReportView.swift
//  Logit
//
//  Created by 임재현 on 2/20/26.
//

import SwiftUI
import Charts

struct ReportView: View {
    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                // 흰색 영역
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
                        
                        FlowTagsView(
                            competencyTag: "전문성",
                            tags: ["고객이해력", "소통력", "실행력", "문제해결력", "고객이해력"],
                            allCompetency: true
                        )
                        .padding(.top, 28)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 20)
                    .padding(.top, 34)
                    .padding(.bottom, 30)
                }
                .background(.white)
                
                // 하단 그래프 영역
                VStack(spacing: 0) {
                    // 그래프 카드들 추가 예정
                    
                    // 흰색 카드
                    VStack(alignment: .leading, spacing: 5) {
                        Text("{최다 경험 유형}이 두드러져요")
                            .typo(.bold_18)
                            .foregroundStyle(.black)
                        
                        Text("{최소 경험 유형}을 보완하면 더 균형 잡힌 역량의 인재로 보일 수 있어요!")
                            .typo(.regular_15)
                            .foregroundStyle(.gray)
                        
                        ReportBarChartView()
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(20)
                    .background(.white)
                    .cornerRadius(16)
                    .padding(.horizontal, 20)
                    .padding(.top, 21)
                }
                .frame(maxWidth: .infinity)
                .padding(.bottom, 24)
                .background(Color.gray20)
            }
        }
        .scrollIndicators(.hidden)
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
            ForEach(Array(allTags.enumerated()), id: \.offset) { _, tag in
                ReportTag(
                    text: tag.0,
                    icon: tag.1 ? tag.0 : nil
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

struct BarChartData: Identifiable {
    let id = UUID()
    let label: String
    let value: Double
    let color: Color
}

struct ReportBarChartView: View {
    let data: [BarChartData] = [
        BarChartData(label: "고객 중심", value: 62, color: Color(hex: "A8EDD8")),
        BarChartData(label: "분석력",   value: 80, color: Color(hex: "A8D4F5")),
        BarChartData(label: "분석력",   value: 62, color: Color(hex: "B8B8F0")),
        BarChartData(label: "책임감",   value: 24, color: Color(hex: "C8B8E8")),
        BarChartData(label: "문제해결력", value: 2, color: Color(hex: "E8B8E8")),
        BarChartData(label: "분석력",   value: 4,  color: Color(hex: "F5C8D8")),
    ]
    
    var body: some View {
        VStack(spacing: 0) {
            // 차트 영역
            Chart(data) { item in
                BarMark(
                    x: .value("label", item.id.uuidString),
                    y: .value("value", item.value),
                    width: .fixed(20)
                )
                .foregroundStyle(item.color)
                .clipShape(UnevenRoundedRectangle(topLeadingRadius: 8, bottomLeadingRadius: 8, bottomTrailingRadius: 8, topTrailingRadius: 8))
                .annotation(position: .top) {
                    Text("\(Int(item.value))")
                        .typo(.bold_14)
                        .foregroundStyle(item.color)
                }
            }
            .chartXAxis(.hidden)
            .chartYAxis(.hidden)
            .frame(width: 210, height: 160)
            .padding(.horizontal, 16)
            .padding(.top, 16)
            .padding(.bottom, 40)
            

            // 범례 영역
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 4), count: 3), spacing: 12) {
                ForEach(data) { (item: BarChartData) in
                    HStack(spacing: 6) {
                        Rectangle()
                            .fill(item.color)
                            .frame(width: 10, height: 10)
                        Text(item.label)
                            .typo(.regular_13)
                            .foregroundStyle(.black)
                            .lineLimit(1)
                            .minimumScaleFactor(0.8)
                        Spacer()
                    }
                }
            }
            .padding(16)
        }
        .background(.white)
        .cornerRadius(16)
    }
}
