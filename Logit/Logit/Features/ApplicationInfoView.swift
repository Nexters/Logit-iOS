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
    
    // 입력 필드 상태
    @State private var companyName: String = ""
    @State private var position: String = ""
    @State private var department: String = ""
    @State private var experienceLevel: String = ""
    
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
                
                // 타이틀
                Text("지원기업 정보 입력")
                    .typo(.bold_18)
                    .padding(.top, 13.25)
                
                // 서브타이틀
                Text("지원하는 기업의 정보를 알려주세요")
                    .typo(.regular_15)
                    .foregroundColor(.gray300)
                    .padding(.top, 3)
                
                // 스크롤 컨텐츠
                ScrollView {
                    VStack(spacing: 20) {
                        // 기업명 (필수)
                        InputFieldView(
                            title: "기업명",
                            placeholder: "회사명을 입력해주세요",
                            isRequired: true,
                            text: $companyName
                        )
                        
                        // 직무명 (필수)
                        InputFieldView(
                            title: "직무명",
                            placeholder: "직무를 입력해주세요",
                            isRequired: true,
                            text: $position
                        )
                        
                        // 채용 공고 (필수)
                        InputFieldView(
                            title: "채용 공고",
                            placeholder: "부서를 입력해주세요",
                            isRequired: true,
                            text: $department
                        )
                        
                        // 기업 인재상 (선택)
                        InputFieldView(
                            title: "기업 인재상",
                            placeholder: "경력을 입력해주세요",
                            isRequired: false,
                            text: $experienceLevel
                        )
                    }
                    .padding(.top, 24)
                }
                
                // 다음 버튼
                Button {
                    viewModel.navigateToCoverLetterQuestions()
                } label: {
                    Text("다음으로")
                        .typo(.bold_18)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(isFormValid ? Color.primary100 : Color.gray100)
                        .cornerRadius(12)
                }
                .disabled(!isFormValid)
                .padding(.top, 24)
            }
            .padding(.horizontal, 20)
        }
        .navigationBarHidden(true)
    }
    
    // 폼 유효성 검사
    private var isFormValid: Bool {
        !companyName.isEmpty && !position.isEmpty
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

struct InputFieldView: View {
    let title: String
    let placeholder: String
    let isRequired: Bool
    @Binding var text: String
    
    init(
        title: String,
        placeholder: String,
        isRequired: Bool = false,
        text: Binding<String>
    ) {
        self.title = title
        self.placeholder = placeholder
        self.isRequired = isRequired
        self._text = text
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            // 타이틀 + 필수 표시
            HStack(spacing: 2) {
                Text(title)
                    .typo(.medium_16)
                    .foregroundColor(.black)
                
                if isRequired {
                    Text("*")
                        .typo(.medium_16)
                        .foregroundColor(.alert)
                }
            }
            
            // TextField
            TextField(placeholder, text: $text)
                .typo(.regular_15)
                .padding(.horizontal, 18)
                .frame(height: 44)
                .background(Color.clear)
                .cornerRadius(8)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.gray100, lineWidth: 1)
                )
        }
    }
}
