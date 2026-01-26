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
            
            HStack {
                PageIndicator(currentPage: 1, totalPages: 2)
                    .padding(.leading, 20)
                Spacer()
            }
            .padding(.top, 12)
            
            // 컨텐츠
            ScrollView {
                VStack(spacing: 20) {
                    Text("지원 정보를 입력해주세요")
                        .font(.title2)
                        .fontWeight(.bold)
                        .padding(.top, 24)
                    
                    // TODO: 실제 폼 구현
                    TextField("회사명", text: .constant(""))
                        .textFieldStyle(.roundedBorder)
                        .padding(.horizontal)
                    
                    TextField("직무", text: .constant(""))
                        .textFieldStyle(.roundedBorder)
                        .padding(.horizontal)
                    
                    Spacer()
                    
                    Button("다음") {
                        viewModel.navigateToCoverLetterQuestions()
                    }
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(12)
                }
            }
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
                .typo(.body7_bold)
                .foregroundColor(.black)
            
            Text("/\(totalPages)")
                .typo(.body7_regular_140)
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
