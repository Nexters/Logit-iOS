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
    @Published var questionDetails: [String: QuestionDetailResponse] = [:]

    @Published var isLoadingQuestions: Bool = false
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

            await fetchAllQuestionDetails(questions: questions)
        } catch {
            print("문항 목록 조회 실패: \(error)")
            errorMessage = "문항 목록을 불러올 수 없습니다."
        }

        isLoadingQuestions = false
    }

    func deleteProject() async throws {
        try await projectRepository.deleteProject(projectId: project.id)
    }

    private func fetchAllQuestionDetails(questions: [QuestionResponse]) async {
        await withTaskGroup(of: (String, QuestionDetailResponse?).self) { group in
            for question in questions {
                group.addTask {
                    do {
                        let detail = try await self.questionRepository.getQuestionDetail(
                            projectId: self.project.id,
                            questionId: question.id
                        )
                        return (question.id, detail)
                    } catch {
                        print("문항 상세 조회 실패 (\(question.id)): \(error)")
                        return (question.id, nil)
                    }
                }
            }

            for await (questionId, detail) in group {
                if let detail {
                    questionDetails[questionId] = detail
                }
            }
        }
    }
}
