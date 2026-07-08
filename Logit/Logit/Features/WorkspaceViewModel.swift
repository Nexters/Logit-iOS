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
    @Published var currentQuestionDetail: QuestionDetailResponse?
    @Published var isLoading: Bool = false
    @Published var isLoadingDetail: Bool = false
    @Published var isSavingQuestions: Bool = false
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
    
    func saveAnswer(questionId: String, answer: String) async {
        do {
            let req = UpdateQuestionRequest(answer: answer)
            _ = try await questionRepository.updateQuestion(
                projectId: projectId,
                questionId: questionId,
                request: req
            )
            await fetchQuestionDetail(questionId: questionId)
            print("자기소개서 저장 성공: \(questionId)")
        } catch {
            print("자기소개서 저장 실패: \(error)")
        }
    }

    func markQuestionComplete(questionId: String) async {
        do {
            _ = try await questionRepository.completeQuestion(
                projectId: projectId,
                questionId: questionId
            )
            await fetchQuestionList()
            await fetchQuestionDetail(questionId: questionId)
            print("문항 작성완료 처리 성공: \(questionId)")
        } catch {
            print("문항 작성완료 처리 실패: \(error)")
        }
    }

    func fetchQuestionDetail(questionId: String) async {
        isLoadingDetail = true
        do {
            let detail = try await questionRepository.getQuestionDetail(
                projectId: projectId,
                questionId: questionId
            )
            currentQuestionDetail = detail
            print("문항 상세 조회 성공: \(detail.question)")
        } catch {
            print("문항 상세 조회 실패: \(error)")
        }
        isLoadingDetail = false
    }

    func saveQuestions(editedItems: [EditableQuestionItem], deletedQuestionIds: [String] = []) async {
        isSavingQuestions = true
        defer { isSavingQuestions = false }

        do {
            try await withThrowingTaskGroup(of: Void.self) { group in
                // 삭제
                for questionId in deletedQuestionIds {
                    group.addTask {
                        try await self.questionRepository.deleteQuestion(
                            projectId: self.projectId,
                            questionId: questionId
                        )
                    }
                }
                // 수정 / 생성
                for item in editedItems {
                    if let questionId = item.questionId {
                        // 기존 문항 수정
                        group.addTask {
                            let req = UpdateQuestionRequest(
                                answer: nil,
                                maxLength: Int(item.characterLimit),
                                question: item.title
                            )
                            _ = try await self.questionRepository.updateQuestion(
                                projectId: self.projectId,
                                questionId: questionId,
                                request: req
                            )
                        }
                    } else {
                        // 새 문항 생성
                        group.addTask {
                            let req = CreateQuestionRequest(
                                maxLength: Int(item.characterLimit) ?? 0,
                                question: item.title
                            )
                            _ = try await self.questionRepository.createQuestion(
                                projectId: self.projectId,
                                request: req
                            )
                        }
                    }
                }
                for try await _ in group {}
            }
            await fetchQuestionList()
            print("문항 저장 완료")
        } catch {
            print("문항 저장 실패: \(error)")
            if let apiError = error as? APIError {
                print("API Error: \(apiError.localizedDescription)")
            }
        }
    }

    var navigationTitle: String {
        guard let detail = projectDetail else {
            return "프로젝트"
        }
        return "\(detail.company) \(detail.jobPosition)"
    }
}
