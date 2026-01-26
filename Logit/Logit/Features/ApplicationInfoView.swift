//
//  ApplicationInfoView.swift
//  Logit
//
//  Created by 임재현 on 1/26/26.
//

import SwiftUI

struct ApplicationInfoView: View {
    @EnvironmentObject var viewModel: AddFlowViewModel
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        VStack(spacing: 0) {
            // 커스텀 NavigationBar
            CustomNavigationBar(
                title: "프로젝트 생성",
                showBackButton: true,
                onBackTapped: {
                    dismiss()
                }
            )
            
            VStack(alignment: .leading, spacing: 0) {
                // 페이지 인디케이터
                PageIndicator(currentPage: 1, totalPages: 2)
                    .padding(.top, 16)
                
                // 첫 번째 텍스트
                Text("지원기업 정보 입력")
                    .font(.title2)
                    .fontWeight(.bold)
                    .padding(.top, 24)
                
                // 두 번째 텍스트
                Text("지원하는 기업의 정보를 알려주세요")
                    .font(.body)
                    .foregroundColor(.gray)
                    .padding(.top, 3)
                
                // 나머지 컨텐츠
                ScrollView {
                    VStack(spacing: 20) {
                        // TODO: 실제 폼 구현
                        TextField("회사명", text: .constant(""))
                            .textFieldStyle(.roundedBorder)
                        
                        TextField("직무", text: .constant(""))
                            .textFieldStyle(.roundedBorder)
                        
                        Spacer()
                        
                        Button("다음") {
                            viewModel.navigateToCoverLetterQuestions()
                        }
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                    }
                    .padding(.top, 24)
                }
            }
            .padding(.horizontal, 20)
        }
        .navigationBarHidden(true)
    }
}


struct PageIndicator: View {
    let currentPage: Int
    let totalPages: Int
    
    var body: some View {
        HStack(spacing: 0) {
            Text("\(currentPage)")
                .typo(.bold_14)
                .foregroundColor(.black)
            
            Text("/\(totalPages)")
                .typo(.regular_14_140)
                .foregroundColor(.gray)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 4)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(.primary20)
        )
    }
}
