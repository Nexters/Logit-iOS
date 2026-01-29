//
//  ExperienceListView.swift
//  Logit
//
//  Created by 임재현 on 1/29/26.
//

import SwiftUI

struct ExperienceListView: View {
    @State private var experiences: [ExperienceData] = []
    @State private var experienceCount: Int = 0
    @State private var hasData: Bool = false
    @State private var showExperienceAddFlow = false
    
    var body: some View {
        VStack(spacing: 0) {
            ExperienceListHeader(
                onAddTapped: {
                    showExperienceAddFlow = true
                }
            )
            
            if hasData {
                ExperienceCountLabel(count: experienceCount)
            }
            
            if hasData {
                // 경험 리스트
                ScrollView {
                    VStack(spacing: 12) {
                        ForEach(experiences, id: \.title) { experience in
                            ExperienceListCell(experience: experience)
                                .onTapGesture {
                                    // TODO: 경험 상세보기
                                    print("선택된 경험: \(experience.title)")
                                }
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 8)
                }
            } else {
                EmptyExperienceView {
                    showExperienceAddFlow = true
                }
            }
        }
        .background(.gray20)
        .navigationBarHidden(true)
        .fullScreenCover(isPresented: $showExperienceAddFlow) {
            ExperienceFlowCoordinator { experienceData in
                experiences.append(experienceData)
                hasData = true
                experienceCount = experiences.count
            }
        }
    }
}

struct ExperienceListHeader: View {
    let onAddTapped: () -> Void
    
    var body: some View {
        HStack(spacing: 12) {
            // 타이틀
            Text("경험 목록")
                .typo(.bold_20)
                .foregroundColor(.black)
            
            Spacer()
            
            // 추가 버튼
            Button {
                onAddTapped()
            } label: {
                Image(systemName: "plus")
                    .frame(size: 24)
                    .foregroundColor(.black)
                    .contentShape(Rectangle())
            }
        }
        .frame(height: 44)
        .padding(.horizontal, 20)
        .background(Color.gray20)
    }
}

struct ExperienceCountLabel: View {
    let count: Int
    
    var body: some View {
        HStack {
            Text("\(count)개")
                .typo(.medium_13)
                .foregroundColor(.gray200)
            
            Spacer()
        }
        .padding(.horizontal, 20)
        .padding(.top, 12)
        .padding(.bottom, 8)
    }
}

struct EmptyExperienceView: View {
    let onSelectExperience: () -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            Image("app_status_empty2")
                .resizable()
                .scaledToFit()
                .frame(width: 80.adjustedLayout, height: 80.adjustedLayout)
            
            Text("등록된 경험이 없어요")
                .typo(.medium_15)
                .foregroundStyle(.gray100)
                .padding(.top, 16.adjustedLayout)
            
            Button {
                onSelectExperience()
            } label: {
                Text("경험 등록하기")
                    .typo(.medium_15)
                    .foregroundStyle(.white)
                    .padding(.horizontal, 39.adjustedLayout)
                    .padding(.vertical, 7.5.adjustedLayout)
                    .background(.primary100)
                    .cornerRadius(8.adjustedLayout)
            }
            .padding(.top, 17.adjustedLayout)
        }
        .offset(y: -10.adjustedLayout)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(.vertical, 60.adjustedLayout)
        .background(.gray20)
        .cornerRadius(16.adjustedLayout)
        .padding(.horizontal, 20.adjustedLayout)
    }
}

struct ExperienceListCell: View {
    let experience: ExperienceData
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // 상단: 제목과 점수
            HStack {
                Text(experience.title)
                    .typo(.medium_15)
                    .foregroundColor(.primary500)
                    .lineLimit(1)
                
                Spacer()
                
                Text("00점")
                    .typo(.medium_13)
                    .foregroundColor(.primary200)
            }
            
            // 하단: 태그들
            HStack(spacing: 8) {
                // 핵심 역량 태그
                ExperienceTag(
                    text: experience.competency,
                    icon: experience.competency,
                    isCompetency: true  // 역량 태그 표시
                )
                
                // 경험 유형 태그
                ExperienceTag(text: experience.type)
                
                Spacer()
            }
        }
        .padding(16)
        .background(Color.white)
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.gray70, lineWidth: 1)
        )
    }
}

// 태그
struct ExperienceTag: View {
    let text: String
    var icon: String? = nil
    var isCompetency: Bool = false
    
    var body: some View {
        HStack(spacing: 6) {
            if let icon = icon {
                Image(icon)
                    .resizable()
                    .frame(width: 16, height: 16)
            }
            
            Text(text)
                .typo(.regular_12)
                .foregroundColor(.primary600)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(isCompetency ? Color(hex: "E3F5FF") : Color.gray50)
        .cornerRadius(6)
    }
}
