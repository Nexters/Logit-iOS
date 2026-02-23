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
    
    private let maxQuestionsCount = 5 // 최대 문항 개수
    
    private var isFormValid: Bool {
        viewModel.questions.allSatisfy { question in
            !question.title.isEmpty && !question.characterLimit.isEmpty
        }
    }
    
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
                    
                    VStack(spacing: 20) {
                        ForEach(viewModel.questions) { question in
                            let index = viewModel.questions.firstIndex(where: { $0.id == question.id }) ?? 0
                            QuestionInputRow(
                                questionNumber: index + 1,
                                questionTitle: Binding(
                                    get: {
                                        viewModel.questions.first(where: { $0.id == question.id })?.title ?? ""
                                    },
                                    set: {
                                        if let i = viewModel.questions.firstIndex(where: { $0.id == question.id }) {
                                            viewModel.questions[i].title = $0
                                        }
                                    }
                                ),
                                characterLimit: Binding(
                                    get: {
                                        viewModel.questions.first(where: { $0.id == question.id })?.characterLimit ?? ""
                                    },
                                    set: {
                                        if let i = viewModel.questions.firstIndex(where: { $0.id == question.id }) {
                                            viewModel.questions[i].characterLimit = $0
                                        }
                                    }
                                ),
                                showDelete: viewModel.questions.count > 1,
                                onDelete: { viewModel.questions.removeAll { $0.id == question.id } }
                            )
                        }
                        
                        // 추가하기 버튼 (최대 개수 미만일 때만 표시)
                        if viewModel.questions.count < maxQuestionsCount {
                            Button {
                                viewModel.questions.append(QuestionItem())
                            } label: {
                                HStack(spacing: 8) {
                                    Image("plus_selected")
                                        .frame(size: 18)
                                    
                                    Text("추가하기")
                                        .typo(.medium_15)
                                        .foregroundColor(.gray300)
                                    
                                    Spacer()
                                }
                                .padding(.horizontal, 20)
                                .padding(.vertical, 11.5)
                                .background(Color.primary50)
                                .cornerRadius(8)
                                .contentShape(Rectangle())
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                    .padding(.top, 24)
                    
                    Spacer()
                        .frame(minHeight: 46.75)
                    
                    Button {
                        // TODO: 완료 액션
                        Task {
                            await viewModel.createProject()
                        }
                    } label: {
                        Text("프로젝트 생성")
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
}

struct QuestionInputRow: View {
    let questionNumber: Int
    @Binding var questionTitle: String
    @Binding var characterLimit: String
    var showDelete: Bool = false
    var onDelete: () -> Void = {}
    @FocusState private var focusedField: Field?

    enum Field {
        case title, limit
    }

    var body: some View {
        HStack(spacing: 8) {
            // 문항 제목 입력
            TextField("\(questionNumber)번 문항", text: $questionTitle)
                .font(.system(size: 15))
                .padding(.horizontal, 18)
                .frame(height: 44)
                .background(Color.clear)
                .focused($focusedField, equals: .title)
                .cornerRadius(8)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(
                            focusedField == .title ? Color.primary100 : Color.gray100,
                            lineWidth: 1
                        )
                )

            // 글자 수 제한 입력
            HStack(spacing: 4) {
                TextField("글자수", text: $characterLimit)
                    .font(.system(size: 15))
                    .keyboardType(.numberPad)
                    .multilineTextAlignment(.trailing)
                    .padding(.leading, 18)
                    .frame(height: 44)
                    .background(Color.clear)
                    .focused($focusedField, equals: .limit)
                    .onChange(of: characterLimit) { oldValue, newValue in
                        // 숫자만 입력 가능하도록
                        let filtered = newValue.filter { $0.isNumber }
                        if filtered != newValue {
                            characterLimit = filtered
                        }
                    }

                Text("자")
                    .font(.system(size: 15))
                    .foregroundColor(.black)
                    .padding(.trailing, 18)
            }
            .frame(width: 100)
            .cornerRadius(8)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(
                        focusedField == .limit ? Color.primary100 : Color.gray100,
                        lineWidth: 1
                    )
            )

            // 삭제 버튼 (2개 이상일 때만)
            if showDelete {
                Button(action: onDelete) {
                    Image(systemName: "trash")
                        .font(.system(size: 16))
                        .foregroundColor(.gray300)
                        .frame(width: 34, height: 44)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.gray100, lineWidth: 1)
                        )
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
    }
}

struct QuestionItem: Identifiable,Hashable {
    let id = UUID()
    var title: String = ""
    var characterLimit: String = ""
}
