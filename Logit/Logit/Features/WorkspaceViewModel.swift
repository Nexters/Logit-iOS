//
//  WorkspaceViewModel.swift
//  Logit
//
//  Created by 임재현 on 2/6/26.
//

import Foundation

@MainActor
class WorkspaceViewModel: ObservableObject {
    @Published var projectDetail: ProjectDetailResponse?
    @Published var questionList: [QuestionResponse] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    
    private let projectRepository: ProjectRepository
    private let questionRepository: QuestionRepository
    let projectId: String
    
    init(
        projectId: String,
        projectRepository: ProjectRepository = DefaultProjectRepository(),
        questionRepository: QuestionRepository = DefaultQuestionRepository()
    ) {
        self.projectId = projectId
        self.projectRepository = projectRepository
        self.questionRepository = questionRepository
    }
    

    func fetchProjectDetail() async {
        isLoading = true
        errorMessage = nil
        
        do {
            let detail = try await projectRepository.getProjectDetail(projectId: projectId)
            projectDetail = detail
            print(" 프로젝트 상세 조회 성공: \(detail.company) - \(detail.jobPosition)")
            
        } catch {
            print("프로젝트 상세 조회 실패: \(error)")
            errorMessage = "프로젝트 정보를 불러올 수 없습니다."
            
            if let apiError = error as? APIError {
                print("API Error: \(apiError.localizedDescription)")
            }
        }
        
        isLoading = false
    }
    
    func fetchQuestionList() async {
        do {
            let questions = try await questionRepository.getQuestionList(projectId: projectId)
            questionList = questions
            print("문항 목록 조회 성공: \(questions.count)개")
            questions.enumerated().forEach { index, question in
                print("  Q\(index + 1): \(question.question) (ID: \(question.id))")
            }
            
        } catch {
            print("문항 목록 조회 실패: \(error)")
            errorMessage = "문항 목록을 불러올 수 없습니다."
            
            if let apiError = error as? APIError {
                print("API Error: \(apiError.localizedDescription)")
            }
        }
    }
    
    var navigationTitle: String {
        guard let detail = projectDetail else {
            return "프로젝트"
        }
        return "\(detail.company) - \(detail.jobPosition)"
    }
}
