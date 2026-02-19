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
                    VStack(alignment: .leading, spacing: 20) {
                        // 문항 제목
                        VStack(alignment: .leading, spacing: 8) {
                            Text("문항 \(selectedQuestionIndex + 1)")
                                .font(.system(size: 14))
                                .foregroundStyle(.secondary)
                            
                            Text(question.question)
                                .font(.system(size: 20, weight: .bold))
                            
                            Text("최대 \(question.maxLength)자")
                                .font(.system(size: 13))
                                .foregroundStyle(.secondary)
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 20)
                        
                        Divider()
                        
                        // 답변 내용
                        VStack(alignment: .leading, spacing: 12) {
                            Text("답변")
                                .font(.system(size: 16, weight: .semibold))
                            
                            if let answer = question.answer, !answer.isEmpty {
                                Text(answer)
                                    .font(.system(size: 15))
                                    .lineSpacing(6)
                            } else {
                                Text("아직 작성된 답변이 없습니다.")
                                    .font(.system(size: 15))
                                    .foregroundStyle(.secondary)
                            }
                        }
                        .padding(.horizontal, 20)
                        
                        // ID 확인용 (개발용)
//                        VStack(alignment: .leading, spacing: 8) {
//                            Divider()
//                            
//                            Text("디버그 정보")
//                                .font(.system(size: 14, weight: .semibold))
//                                .foregroundStyle(.secondary)
//                            
//                            Text("Project ID: \(question.projectId)")
//                                .font(.system(size: 12))
//                                .foregroundStyle(.secondary)
//                            
//                            Text("Question ID: \(question.id)")
//                                .font(.system(size: 12))
//                                .foregroundStyle(.secondary)
//                            
//                            Text("User ID: \(question.userId)")
//                                .font(.system(size: 12))
//                                .foregroundStyle(.secondary)
//                            
//                            Text("Created At: \(question.createdAt)")
//                                .font(.system(size: 12))
//                                .foregroundStyle(.secondary)
//                            
//                            Text("Updated At: \(question.updatedAt)")
//                                .font(.system(size: 12))
//                                .foregroundStyle(.secondary)
//                        }
//                        .padding(.horizontal, 20)
//                        .padding(.top, 20)
////                        
                        Spacer()
                    }
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
        .task {
            await viewModel.fetchProjects()
        }
        .refreshable {
            await viewModel.fetchProjects()
        }
    }
}
