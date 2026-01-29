//
//  ExperienceListView.swift
//  Logit
//
//  Created by 임재현 on 1/29/26.
//

import SwiftUI

struct ExperienceListView: View {
    @Environment(\.dismiss) var dismiss
    @State private var experienceCount: Int = 0
    @State private var hasData: Bool = false
    
    var body: some View {
        VStack(spacing: 0) {
            ExperienceListHeader(
                onAddTapped: {
                    print("경험 추가 버튼 클릭")
                }
            )
            
            if hasData {
                ExperienceCountLabel(count: experienceCount)
            }
            
            if hasData {
                ScrollView {
                    VStack(spacing: 0) {
                        // TODO: 경험 리스트 아이템들
                        Text("경험 리스트 아이템들")
                    }
                }
            } else {
                EmptyExperienceView {
                    print("경험 추가 버튼 클릭")
                }
            }
        }
        .navigationBarHidden(true)
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
        .background(Color.white)
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
        .background(.white)
        .cornerRadius(16.adjustedLayout)
        .padding(.horizontal, 20.adjustedLayout)
    }
}
