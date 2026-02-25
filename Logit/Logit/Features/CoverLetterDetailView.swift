//
//  CoverLetterDetailView.swift
//  Logit
//
//  Created by 임재현 on 2/7/26.
//

import SwiftUI

struct CoverLetterDetailView: View {
    @StateObject private var viewModel: CoverLetterDetailViewModel
    @Environment(\.dismiss) var dismiss
    @State private var selectedQuestionIndex: Int = 0
    @State private var showDeleteMenu = false

    init(project: ProjectListItemResponse) {
        _viewModel = StateObject(wrappedValue: CoverLetterDetailViewModel(project: project))
    }

    private var deleteMenuPopup: some View {
        Button {
            showDeleteMenu = false
            Task {
                try? await viewModel.deleteProject()
                dismiss()
            }
        } label: {
            HStack(spacing: 8) {
                Image(systemName: "trash")
                    .font(.system(size: 14))
                    .foregroundStyle(.black)

                Text("삭제")
                    .typo(.regular_14_140)
                    .foregroundStyle(.black)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.white)
                    .shadow(color: .black.opacity(0.12), radius: 8, x: 0, y: 4)
            )
        }
    }

    var body: some View {
        ZStack(alignment: .topTrailing) {
        VStack(spacing: 0) {
            CustomNavigationBar(
                title: viewModel.project.company,
                showBackButton: true,
                onBackTapped: { dismiss() }
            ) {
                Button {
                    showDeleteMenu.toggle()
                } label: {
                    Image(systemName: "ellipsis")
                        .rotationEffect(.degrees(90))
                        .foregroundStyle(.gray300)
                        .frame(width: 24, height: 24)
                }
            }

            // 문항 탭 바
            if !viewModel.questionList.isEmpty {
                QuestionTabBar(
                    questionCount: viewModel.questionList.count,
                    selectedIndex: $selectedQuestionIndex,
                    showAddButton: false
                )
                .onChange(of: selectedQuestionIndex) { _, newIndex in
                    Task {
                        await viewModel.selectQuestion(at: newIndex)
                    }
                }
            } else if viewModel.isLoadingQuestions {
                ProgressView()
                    .padding(.vertical, 12)
            }

            // 문항 내용
            if viewModel.isLoadingQuestionDetail {
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if let question = viewModel.currentQuestionDetail {
                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        Text(question.question)
                            .typo(.bold_16)
                            .foregroundStyle(.gray400)

                        if let answer = question.answer, !answer.isEmpty {
                            Text(answer)
                                .typo(.regular_14_160)
                                .foregroundStyle(.black)
                        } else {
                            Text("아직 작성된 답변이 없습니다.")
                                .typo(.regular_14_160)
                                .foregroundStyle(.gray300)
                        }

                        Spacer()
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                    .padding(.bottom, 69)
                }
            } else if !viewModel.isLoadingQuestions {
                VStack(spacing: 12) {
                    Image(systemName: "doc.text")
                        .font(.system(size: 60))
                        .foregroundStyle(.secondary)

                    Text("문항이 없습니다")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .background(.white)
        .navigationBarHidden(true)
        .task {
            await viewModel.fetchQuestionList()
        }
        .contentShape(Rectangle())
        .onTapGesture {
            if showDeleteMenu { showDeleteMenu = false }
        }
        }

        // 삭제 팝업
        if showDeleteMenu {
            deleteMenuPopup
                .padding(.top, 44)
                .padding(.trailing, 16)
                .zIndex(1)
        }
        }
    }
}
