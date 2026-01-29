//
//  CoverLetterWorkspaceView.swift
//  Logit
//
//  Created by 임재현 on 1/29/26.
//

import SwiftUI

struct CoverLetterWorkspaceView: View {
    @Environment(\.dismiss) var dismiss
    let questions: [QuestionItem]
    @State private var selectedQuestionIndex: Int = 0
    @State private var selectedView: ContentType = .chat
    @State private var hasData: Bool = false
    
    enum ContentType {
        case chat, coverLetter
    }
    
    var body: some View {
        VStack(spacing: 0) {
            CustomNavigationBar(
                title: "프로젝트 생성",
                showBackButton: true,
                onBackTapped: { dismiss() }
            )
            
            // 문항 탭 바
            QuestionTabBar(
                questionCount: questions.count,
                selectedIndex: $selectedQuestionIndex
            )
            
            // 채팅 / 자기소개서 선택 버튼
            HStack(spacing: 8) {
                IconTextButton(
                    selectedIconName: "chat_selected",
                    unselectedIconName: "chat_unselected",
                    title: "채팅",
                    isSelected: selectedView == .chat,
                    action: { selectedView = .chat }
                )
                
                IconTextButton(
                    selectedIconName: "coverLetter_selected",
                    unselectedIconName: "coverLetter_unselected",
                    title: "자기소개서",
                    isSelected: selectedView == .coverLetter,
                    action: { selectedView = .coverLetter }
                )
                
                Spacer()
            }
            .padding(.horizontal, 20)
            .padding(.top, 16)
            
            // TODO: 컨텐츠 영역
            
            if hasData {
                Text("데이터 있음")  
                    .padding()
            } else {
                EmptyWorkspaceView {
                    print("경험 선택 버튼 클릭")
                }
            }

            
            Spacer()
        }
        .navigationBarHidden(true)
    }
}

struct QuestionTabBar: View {
    let questionCount: Int
    @Binding var selectedIndex: Int
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(0..<questionCount, id: \.self) { index in
                    QuestionTabButton(
                        number: index + 1,
                        isSelected: selectedIndex == index,
                        action: { selectedIndex = index }
                    )
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
        }
    }
}



struct QuestionTabButton: View {
    let number: Int
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 0) {
                Text("Q\(number)")
                    .typo(.semibold_16)
                    .foregroundColor(isSelected ? .primary100 : .gray400)
                    .padding(.horizontal, 15)
                    .padding(.vertical, 11)
                
                // 선택 인디케이터
                if isSelected {
                    Rectangle()
                        .fill(Color.primary100)
                        .frame(height: 2)
                } else {
                    Rectangle()
                        .fill(Color.clear)
                        .frame(height: 2)
                }
            }
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct IconTextButton: View {
    let selectedIconName: String
    let unselectedIconName: String
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 10) {
                Image(isSelected ? selectedIconName : unselectedIconName)
                    .resizable()
                    .frame(width: 15, height: 15)
                
                Text(title)
                    .typo(.medium_15)
                    .foregroundColor(isSelected ? .white : .gray200)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(isSelected ? Color.gray400 : Color.gray50)
            .cornerRadius(8)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct EmptyWorkspaceView: View {
    let onSelectExperience: () -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            Image("app_status_empty2")
                .resizable()
                .scaledToFit()
                .frame(width: 80.adjustedLayout, height: 80.adjustedLayout)
            
            Text("경험을 선택하면 초안이 생성돼요")
                .typo(.medium_15)
                .foregroundStyle(.gray100)
                .padding(.top, 16.adjustedLayout)
            
            Button {
                onSelectExperience()
            } label: {
                Text("자기소개서 작성")
                    .typo(.medium_15)
                    .foregroundStyle(.primary200)
                    .padding(.horizontal, 24.adjustedLayout)
                    .padding(.vertical, 7.5.adjustedLayout)
                    .background(.primary50)
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
