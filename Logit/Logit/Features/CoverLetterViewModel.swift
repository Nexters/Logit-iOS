//
//  CoverLetterViewModel.swift
//  Logit
//
//  Created by 임재현 on 2/7/26.
//

import Foundation

@MainActor
class CoverLetterListViewModel: ObservableObject {
    @Published var projects: [ProjectListItemResponse] = []
    @Published var selectedProject: ProjectListItemResponse?
    @Published var questionList: [QuestionResponse] = []
    @Published var currentQuestionDetail: QuestionDetailResponse?
    
    @Published var isLoadingProjects: Bool = false
    @Published var isLoadingQuestions: Bool = false
    @Published var isLoadingQuestionDetail: Bool = false
    @Published var errorMessage: String?
    
    private let projectRepository: ProjectRepository
    private let questionRepository: QuestionRepository
    private var projectCreatedObserver: NSObjectProtocol?

    init(
        projectRepository: ProjectRepository = DefaultProjectRepository(),
        questionRepository: QuestionRepository = DefaultQuestionRepository()
    ) {
        self.projectRepository = projectRepository
        self.questionRepository = questionRepository
        projectCreatedObserver = NotificationCenter.default.addObserver(
            forName: .projectCreated,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            Task { @MainActor [weak self] in
                await self?.fetchProjects()
            }
        }
    }

    deinit {
        if let observer = projectCreatedObserver {
            NotificationCenter.default.removeObserver(observer)
        }
    }
    
    // 1. 프로젝트 목록 조회
    func fetchProjects() async {
        isLoadingProjects = true
        errorMessage = nil
        
        do {
            let fetchedProjects = try await projectRepository.getProjectList(
                skip: 0,
                limit: 100
            )
            
            projects = fetchedProjects
            
            // 첫 번째 프로젝트 자동 선택
            if selectedProject == nil, let first = fetchedProjects.first {
                await selectProject(first)
            }
            
            print("프로젝트 목록 조회 성공: \(fetchedProjects.count)개")
            
        } catch {
            print("프로젝트 목록 조회 실패: \(error)")
            errorMessage = "프로젝트 목록을 불러올 수 없습니다."
        }
        
        isLoadingProjects = false
    }
    
    // 2. 프로젝트 선택 → 문항 목록 조회
    func selectProject(_ project: ProjectListItemResponse) async {
        selectedProject = project
        questionList = []
        currentQuestionDetail = nil
        
        print(" 선택된 프로젝트: \(project.company) - \(project.jobPosition)")
        print("   Project ID: \(project.id)")
        
        await fetchQuestionList(projectId: project.id)
    }
    
    // 3. 문항 목록 조회
    func fetchQuestionList(projectId: String) async {
        isLoadingQuestions = true
        
        do {
            let questions = try await questionRepository.getQuestionList(projectId: projectId)
            questionList = questions
            
            print("문항 목록 조회 성공: \(questions.count)개")
            questions.enumerated().forEach { index, question in
                print("  Q\(index + 1): \(question.question) (ID: \(question.id))")
            }
            
            // 첫 번째 문항 자동 선택
            if !questions.isEmpty {
                await selectQuestion(at: 0)
            }
            
        } catch {
            print(" 문항 목록 조회 실패: \(error)")
            errorMessage = "문항 목록을 불러올 수 없습니다."
        }
        
        isLoadingQuestions = false
    }
    
    // 4. 문항 선택 → 문항 상세 조회
    func selectQuestion(at index: Int) async {
        guard index < questionList.count else {
            print("Index out of range: \(index)")
            return
        }
        
        let question = questionList[index]
        
        print("========== 문항 선택 ==========")
        print("Index: \(index)")
        print("Question ID: \(question.id)")
        print("Question: \(question.question)")
        print("==============================")
        
        await fetchQuestionDetail(questionId: question.id)
    }
    
    // 5. 문항 상세 조회
    func fetchQuestionDetail(questionId: String) async {
        guard let projectId = selectedProject?.id else {
            print(" 선택된 프로젝트가 없습니다")
            return
        }
        
        isLoadingQuestionDetail = true
        
        do {
            let detail = try await questionRepository.getQuestionDetail(
                projectId: projectId,
                questionId: questionId
            )
            currentQuestionDetail = detail
            
            print("문항 상세 조회 성공")
            print("  Project ID: \(projectId)")
            print("  Question ID: \(detail.id)")
            print("  Question: \(detail.question)")
            print("  Max Length: \(detail.maxLength ?? 0)")
            print("  Answer: \(detail.answer ?? "없음")")
            
        } catch {
            print("문항 상세 조회 실패: \(error)")
            errorMessage = "문항 상세를 불러올 수 없습니다."
        }
        
        isLoadingQuestionDetail = false
    }
}
