//
//  ExperienceDetailViewModel.swift
//  Logit
//

import Foundation

@MainActor
class ExperienceDetailViewModel: ObservableObject {
    @Published var experience: ExperienceResponse?
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?

    private let experienceRepository: ExperienceRepository
    let experienceId: String

    init(
        experienceId: String,
        experienceRepository: ExperienceRepository = DefaultExperienceRepository()
    ) {
        self.experienceId = experienceId
        self.experienceRepository = experienceRepository
    }

    func deleteExperience() async throws {
        try await experienceRepository.deleteExperience(experienceId: experienceId)
    }

    func fetchDetail() async {
        isLoading = true
        errorMessage = nil
        do {
            experience = try await experienceRepository.getExperienceDetail(experienceId: experienceId)
            print("경험 상세 조회 성공: \(experience?.title ?? "")")
        } catch {
            errorMessage = "경험 정보를 불러올 수 없습니다."
            print("경험 상세 조회 실패: \(error)")
        }
        isLoading = false
    }
}
