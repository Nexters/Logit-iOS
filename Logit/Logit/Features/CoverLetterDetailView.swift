//
//  CoverLetterDetailView.swift
//  Logit
//

import SwiftUI

struct CoverLetterDetailView: View {
    @EnvironmentObject var appState: AppState
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
            appState.requestDeleteConfirmation(
                message: "프로젝트를 삭제하시겠어요?",
                subMessage: "삭제하면 복구 못해요"
            ) {
                Task {
                    try? await viewModel.deleteProject()
                    dismiss()
                }
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

            if viewModel.isLoadingQuestions {
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if viewModel.questionList.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "doc.text")
                        .font(.system(size: 60))
                        .foregroundStyle(.secondary)

                    Text("문항이 없습니다")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                // 목차 탭 바
                QuestionTabBar(
                    questionCount: viewModel.questionList.count,
                    selectedIndex: $selectedQuestionIndex,
                    showAddButton: false
                )

                // 전체 문항 스크롤 뷰
                ScrollViewReader { proxy in
                    ScrollView {
                        VStack(alignment: .leading, spacing: 0) {
                            ForEach(Array(viewModel.questionList.enumerated()), id: \.element.id) { index, question in
                                questionSection(index: index, question: question)
                                    .id(question.id)
                            }
                        }
                        .padding(.bottom, 40)
                    }
                    .onChange(of: selectedQuestionIndex) { _, newIndex in
                        guard newIndex < viewModel.questionList.count else { return }
                        withAnimation(.easeInOut(duration: 0.3)) {
                            proxy.scrollTo(viewModel.questionList[newIndex].id, anchor: .top)
                        }
                    }
                }
            }
        }
        .background(.white)
        .navigationBarHidden(true)
        .task {
            await viewModel.fetchQuestionList()
        }
        .overlay {
            if showDeleteMenu {
                Color.clear
                    .contentShape(Rectangle())
                    .ignoresSafeArea()
                    .onTapGesture { showDeleteMenu = false }
                    .overlay(alignment: .topTrailing) {
                        deleteMenuPopup
                            .padding(.top, 44)
                            .padding(.trailing, 16)
                    }
            }
        }
    }

    @ViewBuilder
    private func questionSection(index: Int, question: QuestionResponse) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            // 문항 번호 + 질문
            HStack(alignment: .top, spacing: 10) {
                Text("Q\(index + 1)")
                    .typo(.bold_16)
                    .foregroundStyle(.primary100)

                if let detail = viewModel.questionDetails[question.id] {
                    Text(detail.question)
                        .typo(.bold_16)
                        .foregroundStyle(.gray400)
                        .fixedSize(horizontal: false, vertical: true)
                } else {
                    Text(question.question)
                        .typo(.bold_16)
                        .foregroundStyle(.gray400)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }

            // 답변
            if let detail = viewModel.questionDetails[question.id] {
                if let answer = detail.answer, !answer.isEmpty {
                    Text(answer)
                        .typo(.regular_14_160)
                        .foregroundStyle(.black)
                        .fixedSize(horizontal: false, vertical: true)
                } else {
                    Text("아직 작성된 답변이 없습니다.")
                        .typo(.regular_14_160)
                        .foregroundStyle(.gray300)
                }
            } else {
                ProgressView()
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 20)
        .padding(.vertical, 20)

    }
}
