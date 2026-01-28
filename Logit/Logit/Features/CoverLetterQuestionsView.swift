//
//  CoverLetterQuestionsView.swift
//  Logit
//
//  Created by 임재현 on 1/28/26.
//

import SwiftUI

struct CoverLetterQuestionsView: View {
    @EnvironmentObject var viewModel: AddFlowViewModel
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        VStack(spacing: 0) {
            CustomNavigationBar(
                title: "프로젝트 생성",
                showBackButton: true,
                onBackTapped: { dismiss() }
            )
            
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    PageIndicator(currentPage: 2, totalPages: 2)
                        .padding(.top, 16)
                    
                    Text("자기소개서 문항 입력")
                        .typo(.bold_18)
                        .padding(.top, 13.25)
                    
                    Text("작성할 자기소개서 문항을 알려주세요")
                        .typo(.regular_15)
                        .foregroundColor(.gray300)
                        .padding(.top, 3)
                    
                    // 임시 컨텐츠
                    VStack(spacing: 20) {
                        Rectangle()
                            .fill(Color.gray100)
                            .frame(height: 100)
                        
                        Rectangle()
                            .fill(Color.gray100)
                            .frame(height: 100)
                        
                        Rectangle()
                            .fill(Color.gray100)
                            .frame(height: 100)
                    }
                    .padding(.top, 24)
                    
                    Spacer()
                        .frame(minHeight: 46.75)
                    
                    Button {
                        // TODO: 다음 액션
                    } label: {
                        Text("완료")
                            .typo(.bold_18)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(Color.primary100)
                            .cornerRadius(12)
                    }
                    .padding(.bottom, 10)
                }
                .padding(.horizontal, 20)
            }
            .scrollToMinDistance(minDisntance: 32)
        }
        .navigationBarHidden(true)
        .dismissKeyboardOnTap()
    }
}
