//
//  EditQuestionsView.swift
//  Logit
//

import SwiftUI

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
                        ForEach(Array(editableQuestions.enumerated()), id: \.element.id) { index, _ in
                            QuestionInputRow(
                                questionNumber: index + 1,
                                questionTitle: Binding(
                                    get: { editableQuestions[index].title },
                                    set: { editableQuestions[index].title = $0 }
                                ),
                                characterLimit: Binding(
                                    get: { editableQuestions[index].characterLimit },
                                    set: { editableQuestions[index].characterLimit = $0 }
                                )
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
                            await viewModel.saveQuestions(editedItems: editableQuestions)
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
