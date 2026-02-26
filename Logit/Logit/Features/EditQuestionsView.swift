//
//  EditQuestionsView.swift
//  Logit
//

import SwiftUI

struct AddQuestionSheet: View {
    @ObservedObject var viewModel: WorkspaceViewModel
    @Environment(\.dismiss) var dismiss

    @State private var questionText: String = ""
    @State private var characterLimit: String = ""

    private var isFormValid: Bool {
        !questionText.isEmpty && !characterLimit.isEmpty
    }

    @FocusState private var focusedField: AddQuestionField?

    enum AddQuestionField { case question, limit }

    var body: some View {
        VStack(spacing: 0) {
            CustomNavigationBar(
                title: "",
                showBackButton: true,
                onBackTapped: { dismiss() }
            )

            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    Text("추가 문항 입력")
                        .typo(.bold_18)
                        .padding(.top, 16)

                    Text("추가할 문항을 입력하세요")
                        .typo(.regular_15)
                        .foregroundColor(.gray300)
                        .padding(.top, 3)

                    VStack(alignment: .leading, spacing: 20) {
                        // 문항 입력 필드
                        VStack(alignment: .leading, spacing: 10) {
                            Text("문항")
                                .typo(.medium_16)
                                .foregroundColor(.black)

                            TextField("예) 지원동기를 입력해주세요", text: $questionText)
                                .typo(.regular_15)
                                .padding(.horizontal, 18)
                                .frame(height: 44)
                                .focused($focusedField, equals: .question)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(focusedField == .question ? Color.primary100 : Color.gray100, lineWidth: 1)
                                )
                        }

                        // 글자수 입력 필드
                        VStack(alignment: .leading, spacing: 10) {
                            Text("글자수")
                                .typo(.medium_16)
                                .foregroundColor(.black)

                            HStack(spacing: 0) {
                                TextField("글자수", text: $characterLimit)
                                    .typo(.regular_15)
                                    .keyboardType(.numberPad)
                                    .padding(.leading, 18)
                                    .focused($focusedField, equals: .limit)
                                    .onChange(of: characterLimit) { _, newValue in
                                        characterLimit = newValue.filter { $0.isNumber }
                                    }

                                Text("자")
                                    .typo(.regular_15)
                                    .foregroundColor(.gray400)
                                    .padding(.trailing, 18)
                            }
                            .frame(height: 44)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(focusedField == .limit ? Color.primary100 : Color.gray100, lineWidth: 1)
                            )
                        }
                    }
                    .padding(.top, 24)

                    Spacer()
                        .frame(minHeight: 40)
                }
                .padding(.horizontal, 20)
            }
            .scrollToMinDistance(minDisntance: 32)
            .safeAreaInset(edge: .bottom) {
                Button {
                    Task {
                        await viewModel.saveQuestions(
                            editedItems: [EditableQuestionItem(
                                questionId: nil,
                                title: questionText,
                                characterLimit: characterLimit
                            )],
                            deletedQuestionIds: []
                        )
                        dismiss()
                    }
                } label: {
                    Group {
                        if viewModel.isSavingQuestions {
                            ProgressView().tint(.white)
                        } else {
                            Text("문항 추가")
                                .typo(.bold_18)
                                .foregroundColor(.white)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(isFormValid ? Color.primary100 : Color.gray100)
                    .cornerRadius(12)
                }
                .disabled(!isFormValid || viewModel.isSavingQuestions)
                .padding(.horizontal, 20)
                .padding(.bottom, 10)
                .padding(.top, 8)
                .background(Color.white)
            }
        }
        .navigationBarHidden(true)
        .dismissKeyboardOnTap()
    }
}

struct EditableQuestionItem: Identifiable, Hashable {
    let id = UUID()
    var questionId: String?   // nil이면 새로 추가하는 문항
    var title: String
    var characterLimit: String
}

struct EditQuestionsView: View {
    @ObservedObject var viewModel: WorkspaceViewModel
    @Environment(\.dismiss) var dismiss

    @State private var editableQuestions: [EditableQuestionItem] = []
    @State private var deletedQuestionIds: [String] = []

    private let maxQuestionsCount = 5

    private var isFormValid: Bool {
        editableQuestions.allSatisfy { !$0.title.isEmpty && !$0.characterLimit.isEmpty }
    }

    var body: some View {
        VStack(spacing: 0) {
            CustomNavigationBar(
                title: "문항 수정",
                showBackButton: true,
                onBackTapped: { dismiss() }
            )

            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    Text("자기소개서 문항 수정")
                        .typo(.bold_18)
                        .padding(.top, 24)

                    Text("문항을 수정하거나 새 문항을 추가하세요")
                        .typo(.regular_15)
                        .foregroundColor(.gray300)
                        .padding(.top, 3)

                    VStack(spacing: 20) {
                        ForEach(editableQuestions) { item in
                            let index = editableQuestions.firstIndex(where: { $0.id == item.id }) ?? 0
                            QuestionInputRow(
                                questionNumber: index + 1,
                                questionTitle: Binding(
                                    get: {
                                        editableQuestions.first(where: { $0.id == item.id })?.title ?? ""
                                    },
                                    set: {
                                        if let i = editableQuestions.firstIndex(where: { $0.id == item.id }) {
                                            editableQuestions[i].title = $0
                                        }
                                    }
                                ),
                                characterLimit: Binding(
                                    get: {
                                        editableQuestions.first(where: { $0.id == item.id })?.characterLimit ?? ""
                                    },
                                    set: {
                                        if let i = editableQuestions.firstIndex(where: { $0.id == item.id }) {
                                            editableQuestions[i].characterLimit = $0
                                        }
                                    }
                                ),
                                showDelete: editableQuestions.count > 1,
                                onDelete: {
                                    if let questionId = item.questionId {
                                        deletedQuestionIds.append(questionId)
                                    }
                                    editableQuestions.removeAll { $0.id == item.id }
                                }
                            )
                        }

                        if editableQuestions.count < maxQuestionsCount {
                            Button {
                                editableQuestions.append(EditableQuestionItem(
                                    questionId: nil,
                                    title: "",
                                    characterLimit: ""
                                ))
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
                        Task {
                            await viewModel.saveQuestions(
                                editedItems: editableQuestions,
                                deletedQuestionIds: deletedQuestionIds
                            )
                            dismiss()
                        }
                    } label: {
                        Group {
                            if viewModel.isSavingQuestions {
                                ProgressView()
                                    .tint(.white)
                            } else {
                                Text("문항 수정")
                                    .typo(.bold_18)
                                    .foregroundColor(.white)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(isFormValid ? Color.primary100 : Color.gray100)
                        .cornerRadius(12)
                    }
                    .disabled(!isFormValid || viewModel.isSavingQuestions)
                    .padding(.bottom, 10)
                }
                .padding(.horizontal, 20)
            }
            .scrollToMinDistance(minDisntance: 32)
        }
        .navigationBarHidden(true)
        .dismissKeyboardOnTap()
        .onAppear {
            editableQuestions = viewModel.questionList.map { q in
                EditableQuestionItem(
                    questionId: q.id,
                    title: q.question,
                    characterLimit: q.maxLength.map { String($0) } ?? ""
                )
            }
        }
    }
}
