//
//  AddFlowViewModel.swift
//  Logit
//
//  Created by 임재현 on 1/26/26.
//

import SwiftUI

extension Notification.Name {
    static let projectCreated = Notification.Name("projectCreated")
}

@MainActor
class AddFlowViewModel: ObservableObject {
    @Published var path = NavigationPath()
    @Published var rootScreen: RootScreen = .applicationInfo
    @Published var shouldDismissFlow = false
    
    enum RootScreen {
        case applicationInfo
        case workspace(projectId: String, questions: [QuestionItem])
    }
    
    
    // Step 1: 지원기업 정보
    @Published var companyName: String = ""  // 기업명
    @Published var jobPosition: String = ""  // 직무명
    @Published var recruitNotice: String = ""  // 채용 공고
    @Published var companyTalent: String = ""  // 기업 인재상
    @Published var dueDateValue: Date?        // 마감 날짜
    @Published var isAlwaysOpen: Bool = false // 상시 여부
    @Published var isExampleLoaded: Bool = false
    
    
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
       
    
    
    func loadExampleQuestions() {
        questions = [
            QuestionItem(
                title: "본인의 성장 과정과 해당 직무에 지원하게 된 동기를 기술하세요.",
                characterLimit: "1000"
            ),
            QuestionItem(
                title: "직무와 관련된 경험 또는 프로젝트를 통해 발휘한 역량을 설명하세요.",
                characterLimit: "1000"
            ),
            QuestionItem(
                title: "입사 후 이루고 싶은 목표와 포부를 작성하세요.",
                characterLimit: "500"
            )
        ]
    }

    func loadExampleData() {
        companyName = "카카오"
        jobPosition = "iOS 개발자"
        recruitNotice = "• 주요 업무: iOS 앱 신규 기능 개발 및 유지보수, 코드 리뷰 및 기술 개선\n• 자격요건: Swift 및 SwiftUI 개발 경험 2년 이상, iOS 앱 배포 경험\n• 우대사항: 대규모 트래픽 서비스 개발 경험, 오픈소스 기여 경험"
        dueDateValue = Date()
        companyTalent = "도전과 창의를 즐기며, 함께 성장하는 인재를 추구합니다."
        isExampleLoaded = true
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
        let request = CreateProjectRequest(
            company: companyName,
            companyTalent: companyTalent,
            dueDate: isAlwaysOpen ? nil : dueDateValue?.toString(),
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
        
        do {
            let response = try await projectRepository.createProject(request: request)
            print("프로젝트 생성 성공!")
            print("프로젝트 ID: \(response.project.id)")
            print("생성된 문항 개수: \(response.questions.count)")
            
            // Workspace로 이동 (project.id 사용)
            rootScreen = .workspace(
                projectId: response.project.id,
                questions: questions
            )

            // 스택 초기화
            path = NavigationPath()

            // 프로젝트 목록 갱신 노티
            NotificationCenter.default.post(name: .projectCreated, object: nil)
            
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
            
//        case .workspace(let questions, let projectId):
//               CoverLetterWorkspaceView(
//                projectId: projectId, questions: questions
//               )
        }
    }
}

