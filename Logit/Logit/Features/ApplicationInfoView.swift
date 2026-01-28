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
    
    @State private var companyName: String = ""
    @State private var position: String = ""
    @State private var department: String = ""
    @State private var experienceLevel: String = ""
    
    var body: some View {
        VStack(spacing: 0) {
            CustomNavigationBar(
                title: "프로젝트 생성",
                showBackButton: true,
                onBackTapped: { dismiss() }
            )
            
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    PageIndicator(currentPage: 1, totalPages: 2)
                        .padding(.top, 16)
                    
                    Text("지원기업 정보 입력")
                        .typo(.bold_18)
                        .padding(.top, 13.25)
                    
                    Text("지원하는 기업의 정보를 알려주세요")
                        .typo(.regular_15)
                        .foregroundColor(.gray300)
                        .padding(.top, 3)
                    
                    VStack(spacing: 20) {
                        InputFieldView(
                            title: "기업명",
                            placeholder: "예) 로짓 컴퍼니",
                            isRequired: true,
                            maxLength: 100,
                            text: $companyName
                        )
                        
                        InputFieldView(
                            title: "직무명",
                            placeholder: "예) 프로덕트 디자이너",
                            isRequired: true,
                            maxLength: 100,
                            text: $position
                        )
                        
                        InputFieldView(
                            title: "채용 공고",
                            placeholder: "주요 업무, 자격요건, 우대사항 등을 입력하세요",
                            isRequired: true,
                            maxLength: 3000,
                            isLarge: true,
                            text: $department
                        )
                        
                        InputFieldView(
                            title: "기업 인재상",
                            placeholder: "기업의 인재상이나 핵심가치를 입력하세요",
                            isRequired: false,
                            maxLength: 1000,
                            text: $experienceLevel
                        )
                    }
                    .padding(.top, 24)
                    
                    Spacer()
                        .frame(minHeight: 46.75)
                    
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
                    
                    .padding(.bottom, 10)
                }
                .padding(.horizontal, 20)
            }
            .scrollToMinDistance(minDisntance: 32)
        }
        .navigationBarHidden(true)
        .dismissKeyboardOnTap()
    }
    
    private var isFormValid: Bool {
        !companyName.isEmpty && !position.isEmpty && !department.isEmpty
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
    let maxLength: Int?
    var isLarge: Bool? = false
    @Binding var text: String
    
    init(
        title: String,
        placeholder: String,
        isRequired: Bool = false,
        maxLength: Int? = nil,
        isLarge: Bool? = false,
        text: Binding<String>
    ) {
        self.title = title
        self.placeholder = placeholder
        self.isRequired = isRequired
        self.maxLength = maxLength
        self.isLarge = isLarge
        self._text = text
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            // 타이틀 + 필수 표시 + 글자수
            HStack(spacing: 2) {
                Text(title)
                    .typo(.medium_16)
                    .foregroundColor(.black)
                
                if isRequired {
                    Text("*")
                        .typo(.medium_16)
                        .foregroundColor(.alert)
                }
                
                Spacer()
                
                if let maxLength = maxLength {
                    HStack(spacing: 0) {
                        Text("\(text.count)")
                            .typo(.regular_15)
                            .foregroundColor(text.count > maxLength ? .alert : .black)
                        
                        Text(" / \(maxLength)")
                            .typo(.regular_15)
                            .foregroundColor(.gray200)
                    }
                }
            }
            
            // 조건부 렌더링
            if isLarge == true {
                // 큰 사이즈 - TextEditor
                ZStack(alignment: .topLeading) {
                    TextEditor(text: $text)
                        .typo(.regular_15)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 8)
                        .frame(height: 90)
                        .scrollContentBackground(.hidden)
                        .background(Color.clear)
                        .onChange(of: text) { oldValue, newValue in
                            if let maxLength = maxLength, newValue.count > maxLength {
                                text = String(newValue.prefix(maxLength))
                            }
                        }
                    
                    // Placeholder
                    if text.isEmpty {
                        Text(placeholder)
                            .typo(.regular_15)
                            .foregroundColor(.gray100)
                            .padding(.horizontal, 18)
                            .padding(.vertical, 8)
                            .allowsHitTesting(false)
                    }
                }
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.gray100, lineWidth: 1)
                )
                
            } else {
                // 기본 사이즈 - TextField
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
                    .onChange(of: text) { oldValue, newValue in
                        if let maxLength = maxLength, newValue.count > maxLength {
                            text = String(newValue.prefix(maxLength))
                        }
                    }
            }
        }
    }
}
