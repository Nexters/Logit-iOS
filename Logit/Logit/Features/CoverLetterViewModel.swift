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
    @Published var isLoadingProjects: Bool = false
    @Published var errorMessage: String?

    private let projectRepository: ProjectRepository
    private var projectCreatedObserver: NSObjectProtocol?

    init(projectRepository: ProjectRepository = DefaultProjectRepository()) {
        self.projectRepository = projectRepository
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

    func fetchProjects() async {
        isLoadingProjects = true
        errorMessage = nil

        do {
            projects = try await projectRepository.getProjectList(skip: 0, limit: 100)
            print("프로젝트 목록 조회 성공: \(projects.count)개")
        } catch {
            print("프로젝트 목록 조회 실패: \(error)")
            errorMessage = "프로젝트 목록을 불러올 수 없습니다."
        }

        isLoadingProjects = false
    }
}

@MainActor
class CoverLetterDetailViewModel: ObservableObject {
    let project: ProjectListItemResponse

    @Published var questionList: [QuestionResponse] = []
    @Published var currentQuestionDetail: QuestionDetailResponse?

    @Published var isLoadingQuestions: Bool = false
    @Published var isLoadingQuestionDetail: Bool = false
    @Published var errorMessage: String?

    private let questionRepository: QuestionRepository
    private let projectRepository: ProjectRepository

    init(
        project: ProjectListItemResponse,
        questionRepository: QuestionRepository = DefaultQuestionRepository(),
        projectRepository: ProjectRepository = DefaultProjectRepository()
    ) {
        self.project = project
        self.questionRepository = questionRepository
        self.projectRepository = projectRepository
    }

    func fetchQuestionList() async {
        isLoadingQuestions = true

        do {
            let questions = try await questionRepository.getQuestionList(projectId: project.id)
            questionList = questions
            print("문항 목록 조회 성공: \(questions.count)개")

            if !questions.isEmpty {
                await selectQuestion(at: 0)
            }
        } catch {
            print("문항 목록 조회 실패: \(error)")
            errorMessage = "문항 목록을 불러올 수 없습니다."
        }

        isLoadingQuestions = false
    }

    func selectQuestion(at index: Int) async {
        guard index < questionList.count else { return }
        await fetchQuestionDetail(questionId: questionList[index].id)
    }

    func deleteProject() async throws {
        try await projectRepository.deleteProject(projectId: project.id)
    }

    private func fetchQuestionDetail(questionId: String) async {
        isLoadingQuestionDetail = true

        do {
            let detail = try await questionRepository.getQuestionDetail(
                projectId: project.id,
                questionId: questionId
            )
            currentQuestionDetail = detail
            print("문항 상세 조회 성공: \(detail.question)")
        } catch {
            print("문항 상세 조회 실패: \(error)")
            errorMessage = "문항 상세를 불러올 수 없습니다."
        }

        isLoadingQuestionDetail = false
    }
}
