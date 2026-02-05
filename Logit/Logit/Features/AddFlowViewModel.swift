//
//  AddFlowViewModel.swift
//  Logit
//
//  Created by 임재현 on 1/26/26.
//

import SwiftUI

@MainActor
class AddFlowViewModel: ObservableObject {
    @Published var path = NavigationPath()
    @Published var rootScreen: RootScreen = .applicationInfo
    
    enum RootScreen {
        case applicationInfo
        case workspace(projectId: String, questions: [QuestionItem])
    }
    
    
    // Step 1: 지원기업 정보
    @Published var companyName: String = ""  // 기업명
    @Published var jobPosition: String = ""  // 직무명
    @Published var recruitNotice: String = ""  // 채용 공고
    @Published var companyTalent: String = ""  // 기업 인재상
    @Published var dueDate: String?
    
    
    @Published var questions: [QuestionItem] = [QuestionItem()]
    
    private let projectRepository: ProjectRepository
    private let questionRepository: QuestionRepository
    
    init(
        projectRepository: ProjectRepository = DefaultProjectRepository(),
        questionRepository: QuestionRepository = DefaultQuestionRepository() 
    ) {
        self.projectRepository = projectRepository
        self.questionRepository = questionRepository
    }
       
    
    
    // Navigation 함수들
    
    func navigateToCoverLetterQuestions() {
        path.append(AddFlowRoute.coverLetterQuestions)
    }
    
    func navigateToApplicationInfo() {
        path.append(AddFlowRoute.applicationInfo)
    }
    func navigateBack() {
        if !path.isEmpty {
            path.removeLast()
        }
    }
    
    func createProject() async {
        // CreateProjectRequest 생성
        let request = CreateProjectRequest(
            company: companyName,
            companyTalent: companyTalent,
            dueDate: nil,
            jobPosition: jobPosition,
            questions: questions.map { question in
                QuestionRequest(
                    maxLength: Int(question.characterLimit) ?? 0,
                    question: question.title
                )
            },
            recruitNotice: recruitNotice
        )
        
        print("프로젝트 생성 요청")
        print("기업명: \(companyName)")
        print("직무명: \(jobPosition)")
        print("채용 공고: \(recruitNotice)")
        print("기업 인재상: \(companyTalent)")
        print("문항 개수: \(questions.count)")
        
        do {
            let response = try await projectRepository.createProject(request: request)
            print(" 프로젝트 생성 성공!")
            print("응답: \(response)")
            print("프로젝트 ID: \(response.id)")
            
            print("문항 등록 시작")
            try await createQuestionsInParallel(projectId: response.id)
            print("모든 문항 등록 완료!")
            
            // TODO: 성공 후 처리 (예: Workspace로 이동)
            rootScreen = .workspace(projectId: response.id, questions: questions)
                       
            //  스택 초기화
            path = NavigationPath()
            
        } catch {
            print(" 프로젝트 생성 실패: \(error)")
            
            if let apiError = error as? APIError {
                print("API Error: \(apiError.localizedDescription)")
            }
        }
    }
    
    private func createQuestionsInParallel(projectId: String) async throws {
         try await withThrowingTaskGroup(of: QuestionResponse.self) { group in
             // 각 문항을 병렬로 등록
             for (index, question) in questions.enumerated() {
                 group.addTask {
                     let request = CreateQuestionRequest(
                        maxLength: Int(question.characterLimit) ?? 0,
                         question: question.title
                        
                     )
                     
                     print("  문항 \(index + 1) 등록 중: \(question.title)")
                     
                     let response = try await self.questionRepository.createQuestion(
                         projectId: projectId,
                         request: request
                     )
                     
                     print("   문항 \(index + 1) 등록 완료 (ID: \(response.id))")
                     return response
                 }
             }
             
             // 모든 작업이 완료될 때까지 대기
             // 하나라도 실패하면 throw
             for try await response in group {
                 // 성공한 응답들 (필요시 저장 가능)
                 _ = response
             }
         }
     }
    
    
    // View 생성
    @ViewBuilder
    func destination(for route: AddFlowRoute) -> some View {
        switch route {
        case .applicationInfo:
            // TODO: 실제 View로 교체
            EmptyView()
            
        case .coverLetterQuestions:
            CoverLetterQuestionsView()
            
        case .workspace(let questions, let projectId):
               CoverLetterWorkspaceView(
                   questions: questions,
                   projectId: projectId
               )
        }
    }
}

