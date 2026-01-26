//
//  ApplicationInfoView.swift
//  Logit
//
//  Created by 임재현 on 1/26/26.
//

import SwiftUI

struct ApplicationInfoView: View {
    @EnvironmentObject var viewModel: AddFlowViewModel
    
    var body: some View {
        VStack(spacing: 20) {
            Text("지원 정보 입력")
                .font(.title)
            
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
        .padding()
        .navigationTitle("지원 정보")
    }
}
