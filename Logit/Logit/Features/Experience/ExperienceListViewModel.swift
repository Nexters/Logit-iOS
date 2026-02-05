//
//  ExperienceListViewModel.swift
//  Logit
//
//  Created by 임재현 on 2/5/26.
//

import Foundation

@MainActor
class ExperienceListViewModel: ObservableObject {
    @Published var experiences: [ExperienceResponse] = []
    @Published var isLoading: Bool = false
    @Published var isLoadingMore: Bool = false  // 추가 로딩 상태
    @Published var errorMessage: String?
    @Published var showError: Bool = false
    
    private let experienceRepository: ExperienceRepository
    
    //  Pagination 상태
    private var currentOffset: Int = 0
    private let pageSize: Int = 20
    private var totalCount: Int = 0
    private var canLoadMore: Bool = true
    
    init(experienceRepository: ExperienceRepository) {
        self.experienceRepository = experienceRepository
    }
    
    // 첫 페이지 로드 (새로고침)
    func fetchExperiences() async {
        isLoading = true
        currentOffset = 0
        canLoadMore = true
        errorMessage = nil
        
        do {
            let response: ExperienceListResponse = try await experienceRepository.getExperienceList(
                limit: pageSize,
                offset: 0
            )
            
            experiences = response.experiences
            totalCount = response.total
            currentOffset = response.experiences.count
            canLoadMore = currentOffset < totalCount
            
            print(" 경험 목록 조회 성공: \(experiences.count)/\(totalCount)개")
            
        } catch let error as APIError {
            handleAPIError(error)
        } catch {
            errorMessage = "경험 목록을 불러오는데 실패했습니다."
            showError = true
        }
        
        isLoading = false
    }
    
    //  다음 페이지 로드
    func loadMore() async {
        guard !isLoading && !isLoadingMore && canLoadMore else {
            print(" Load more skipped - loading: \(isLoading), loadingMore: \(isLoadingMore), canLoadMore: \(canLoadMore)")
            return
        }
        
        isLoadingMore = true
        
        do {
            let response: ExperienceListResponse = try await experienceRepository.getExperienceList(
                limit: pageSize,
                offset: currentOffset
            )
            
            //  기존 리스트에 추가
            experiences.append(contentsOf: response.experiences)
            currentOffset += response.experiences.count
            canLoadMore = currentOffset < response.total
            
            print(" 추가 로드 성공: \(experiences.count)/\(response.total)개")
            
        } catch let error as APIError {
            handleAPIError(error)
        } catch {
            errorMessage = "추가 데이터를 불러오는데 실패했습니다."
            showError = true
        }
        
        isLoadingMore = false
    }
    
    // 경험 삭제
    func deleteExperience(experienceId: String) async {
        do {
            try await experienceRepository.deleteExperience(experienceId: experienceId)
            
            experiences.removeAll { $0.id == experienceId }
            totalCount -= 1
            currentOffset -= 1
            
            print(" 경험 삭제 성공")
            
        } catch let error as APIError {
            handleAPIError(error)
        } catch {
            errorMessage = "경험 삭제에 실패했습니다."
            showError = true
        }
    }
    
    private func handleAPIError(_ error: APIError) {
        switch error {
        case .unauthorized(let message):
            errorMessage = message ?? "로그인이 필요합니다."
        case .serverError(let message):
            errorMessage = message
        default:
            errorMessage = "오류가 발생했습니다."
        }
        showError = true
    }
}
