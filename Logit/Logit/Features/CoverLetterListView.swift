//
//  CoverLetterListView.swift
//  Logit
//
//  Created by 임재현 on 2/7/26.
//

import SwiftUI

struct CoverLetterListView: View {
    @StateObject private var viewModel = CoverLetterViewModel()
    
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
                            viewModel.selectProject(project)
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
            
            // 선택된 프로젝트 내용
            if viewModel.isLoading {
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if let project = viewModel.selectedProject {
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        // 헤더
                        VStack(alignment: .leading, spacing: 8) {
                            Text(project.company)
                                .font(.system(size: 14))
                                .foregroundStyle(.secondary)
                            
                            Text(project.jobPosition)
                                .font(.system(size: 20, weight: .bold))
                            
                            Text(project.updatedAt)
                                .font(.system(size: 13))
                                .foregroundStyle(.secondary)
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 20)
                        
                        Divider()
                        
                        // ID 확인용 본문
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Text("Project ID:")
                                    .font(.system(size: 14, weight: .semibold))
                                Text(project.id)
                                    .font(.system(size: 13))
                                    .foregroundStyle(.secondary)
                            }
                            
                            HStack {
                                Text("Question ID:")
                                    .font(.system(size: 14, weight: .semibold))
                                Text(project.questionId ?? "questionId 없음")
                                    .font(.system(size: 13))
                                    .foregroundStyle(.secondary)
                            }
                        }
                        .padding(.horizontal, 20)
                        
                        Spacer()
                    }
                }
            } else {
                // 빈 상태
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
