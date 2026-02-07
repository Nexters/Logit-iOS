//
//  CoverLetterViewModel.swift
//  Logit
//
//  Created by 임재현 on 2/7/26.
//

import Foundation

@MainActor
class CoverLetterViewModel: ObservableObject {
    @Published var projects: [ProjectListItemResponse] = []
    @Published var selectedProject: ProjectListItemResponse?
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    
    private let projectRepository: ProjectRepository
    
    init(projectRepository: ProjectRepository = DefaultProjectRepository()) {
        self.projectRepository = projectRepository
    }
    
    func fetchProjects() async {
        isLoading = true
        errorMessage = nil
        
        do {
            let fetchedProjects = try await projectRepository.getProjectList(
                skip: 0,
                limit: 100
            )
            
            projects = fetchedProjects
            
            // 첫 번째 프로젝트 자동 선택
            if selectedProject == nil, let first = fetchedProjects.first {
                selectedProject = first
            }
            
            print("자기소개서 프로젝트 목록 조회 성공: \(fetchedProjects.count)개")
            
        } catch {
            print(" 자기소개서 프로젝트 목록 조회 실패: \(error)")
            errorMessage = "프로젝트 목록을 불러올 수 없습니다."
        }
        
        isLoading = false
    }
    
    func selectProject(_ project: ProjectListItemResponse) {
        selectedProject = project
        print(" 선택된 프로젝트: \(project.company) - \(project.jobPosition)")
        print("   Project ID: \(project.id)")
        print("   Question ID: \(project.questionId)")
    }
}
