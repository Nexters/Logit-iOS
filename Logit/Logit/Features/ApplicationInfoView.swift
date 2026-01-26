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
