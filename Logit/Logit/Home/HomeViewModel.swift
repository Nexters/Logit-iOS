//
//  HomeViewModel.swift
//  Logit
//
//  Created by 임재현 on 2/5/26.
//

import Foundation

@MainActor
class HomeViewModel: ObservableObject {
    @Published var projects: [ProjectListItemResponse] = []
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
            // 전체 프로젝트 가져오기 (skip: 0, limit: 100)
            let fetchedProjects = try await projectRepository.getProjectList(
                skip: 0,
                limit: 100
            )
            
            projects = fetchedProjects
            print(" 프로젝트 목록 조회 성공: \(fetchedProjects.count)개")
            
        } catch {
            print(" 프로젝트 목록 조회 실패: \(error)")
            errorMessage = "프로젝트 목록을 불러올 수 없습니다."
            
            if let apiError = error as? APIError {
                print("API Error: \(apiError.localizedDescription)")
            }
        }
        
        isLoading = false
    }
    
    var hasProjects: Bool {
        !projects.isEmpty
    }
}
