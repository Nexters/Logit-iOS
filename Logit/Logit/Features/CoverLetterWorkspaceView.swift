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
            
            // TODO: 컨텐츠 영역
            Text("Q\(selectedQuestionIndex + 1) 컨텐츠")
            
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
