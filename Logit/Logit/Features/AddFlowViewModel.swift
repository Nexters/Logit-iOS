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
    
    
    // Step 1: 지원기업 정보
    @Published var companyName: String = ""  // 기업명
    @Published var jobPosition: String = ""  // 직무명
    @Published var recruitNotice: String = ""  // 채용 공고
    @Published var companyTalent: String = ""  // 기업 인재상
    @Published var dueDate: String?
    
    
    @Published var questions: [QuestionItem] = [QuestionItem()]
    
    private let projectRepository: ProjectRepository
    
    init(projectRepository: ProjectRepository = DefaultProjectRepository()) {
        self.projectRepository = projectRepository
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
        print("마감일: \(dueDate)")
        print("문항 개수: \(questions.count)")
        questions.enumerated().forEach { index, question in
            print("  문항 \(index + 1): \(question.title) (\(question.characterLimit)자)")
        }
        
        do {
            let response = try await projectRepository.createProject(request: request)
            print(" 프로젝트 생성 성공!")
            print("응답: \(response)")
            print("프로젝트 ID: \(response.id)")
            
            // TODO: 성공 후 처리 (예: Workspace로 이동)
            path.append(AddFlowRoute.workspace(
                           questions: questions,
                           projectId: response.id
                       ))
            
        } catch {
            print(" 프로젝트 생성 실패: \(error)")
            
            if let apiError = error as? APIError {
                print("API Error: \(apiError.localizedDescription)")
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

