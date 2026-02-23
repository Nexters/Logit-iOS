//
//  CoverLetterListView.swift
//  Logit
//
//  Created by 임재현 on 2/7/26.
//

import SwiftUI

struct CoverLetterListView: View {
    @StateObject private var viewModel = CoverLetterListViewModel()
    @State private var selectedQuestionIndex: Int = 0
    
    var body: some View {
        VStack(spacing: 0) {
            // 상단 헤더
            HStack {
                Text("자기소개서")
                    .typo(.semibold_17)
                    .foregroundStyle(.black)
                
                Spacer()
                
                Menu {
                    // 프로젝트 목록
                    ForEach(viewModel.projects) { project in
                        Button {
                            Task {
                                await viewModel.selectProject(project)
                                // 프로젝트 선택 시 첫 번째 문항으로 리셋
                                selectedQuestionIndex = 0
                            }
                        } label: {
                            HStack {
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(project.jobPosition)
                                        .font(.system(size: 15, weight: .medium))
                                    Text(project.company)
                                        .font(.system(size: 13))
                                        .foregroundStyle(.secondary)
                                }
                                
                                Spacer()
                                
                                if viewModel.selectedProject?.id == project.id {
                                    Image(systemName: "checkmark")
                                }
                            }
                        }
                    }
                    
                } label: {
                    Image("app_btn_menubar")
                        .frame(width: 20, height: 20)
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
            
            // 문항 탭 바
            if !viewModel.questionList.isEmpty {
                QuestionTabBar(
                    questionCount: viewModel.questionList.count,
                    selectedIndex: $selectedQuestionIndex
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
            
            // 선택된 문항 내용
            if viewModel.isLoadingQuestionDetail {
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if let question = viewModel.currentQuestionDetail {
                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        // 문항
                        Text(question.question)
                            .typo(.bold_16)
                            .foregroundStyle(.gray400)
                        
                        // 답변
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
            } else if viewModel.selectedProject != nil {
                // 프로젝트는 선택됐는데 문항이 없는 경우
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
                // 프로젝트 미선택
                VStack(spacing: 12) {
                    Image(systemName: "doc.text")
                        .font(.system(size: 60))
                        .foregroundStyle(.secondary)
                    
                    Text("프로젝트를 선택해주세요")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .background(.white)
        .onAppear {
            Task {
                await viewModel.fetchProjects()
            }
        }
        .refreshable {
            await viewModel.fetchProjects()
        }
    }
}
