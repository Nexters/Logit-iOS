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
    @Published var userName: String = ""

    private let projectRepository: ProjectRepository
    private let userRepository: UserRepository
    private let tokenRepository: TokenRepository
    private var projectCreatedObserver: NSObjectProtocol?

    init(
        projectRepository: ProjectRepository = DefaultProjectRepository(),
        userRepository: UserRepository = DefaultUserRepository(networkClient: DefaultNetworkClient()),
        tokenRepository: TokenRepository = DefaultTokenRepository()
    ) {
        self.tokenRepository = tokenRepository
        self.projectRepository = projectRepository
        self.userRepository = userRepository
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

    func fetchTokenBalance() async {
        do {
            let balance = try await tokenRepository.getBalance()
            if balance.attendanceAmount > 0 {
                NotificationCenter.default.post(
                    name: .attendanceRewardReceived,
                    object: nil,
                    userInfo: ["amount": balance.attendanceAmount]
                )
            }
            if balance.signupBonusAmount > 0 {
                NotificationCenter.default.post(
                    name: .signupBonusReceived,
                    object: nil,
                    userInfo: ["amount": balance.signupBonusAmount]
                )
            }
            if balance.referralRewardAmount > 0 {
                NotificationCenter.default.post(
                    name: .referralRewardReceived,
                    object: nil,
                    userInfo: ["amount": balance.referralRewardAmount]
                )
            }
            if balance.monthlyGrantAmount > 0 {
                NotificationCenter.default.post(
                    name: .monthlyGrantReceived,
                    object: nil,
                    userInfo: ["amount": balance.monthlyGrantAmount]
                )
            }
            print("토큰 잔액 조회 성공 (출석 체크): attendance_amount = \(balance.attendanceAmount)")
        } catch {
            print("토큰 잔액 조회 실패: \(error)")
        }
    }

    func fetchCurrentUser() async {
        do {
            let user = try await userRepository.getCurrentUser()
            userName = user.fullName ?? ""
            print("유저 정보 조회 성공: \(user.fullName ?? "")")
        } catch {
            print("유저 정보 조회 실패: \(error)")
        }
    }

    func deleteProject(projectId: String) async {
        do {
            try await projectRepository.deleteProject(projectId: projectId)
            await fetchProjects()
            print("프로젝트 삭제 성공: \(projectId)")
        } catch {
            print("프로젝트 삭제 실패: \(error)")
            errorMessage = "프로젝트를 삭제할 수 없습니다."
        }
    }

    var hasProjects: Bool {
        !projects.isEmpty
    }
}
    