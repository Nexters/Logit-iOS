//
//  ExperienceSelectionSheet.swift
//  Logit
//
//  Created by 임재현 on 1/29/26.
//

import SwiftUI

struct ExperienceSelectionSheet: View {
    @Binding var isPresented: Bool
    @State private var showExperienceAddFlow = false
    @State private var experiences: [MatchingExperience] = []
    @State private var selectedExperienceIds: Set<String> = []  
    @State private var isLoading = false
    @State private var errorMessage: String?
    
    let questionId: String  //  문항 ID
    let initialSelectedIds: [String]  // 기존 선택된 경험 ID
    let onConfirm: ([String]) -> Void  //선택 완료 콜백
    
    private let experienceRepository: ExperienceRepository
    private let maxSelectionCount = 3
    
    init(
        isPresented: Binding<Bool>,
        questionId: String,
        initialSelectedIds: [String] = [],
        onConfirm: @escaping ([String]) -> Void,
        experienceRepository: ExperienceRepository = DefaultExperienceRepository()
    ) {
        self._isPresented = isPresented
        self.questionId = questionId
        self.initialSelectedIds = initialSelectedIds
        self.onConfirm = onConfirm
        self.experienceRepository = experienceRepository
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // 핸들 바
            RoundedRectangle(cornerRadius: 2.5)
                .fill(Color.gray200)
                .frame(width: 40, height: 5)
                .padding(.top, 8)
            
            // 헤더
            HStack {
                HStack(spacing: 10) {
                    Image("folder_selected")
                        .resizable()
                        .renderingMode(.template)
                        .foregroundStyle(.black)
                        .frame(size: 20)
                    
                    Text("경험 선택")
                        .typo(.semibold_17)
                        .foregroundColor(.black)
                }
                
                Spacer()
            }
            .padding(.horizontal, 20)
            .padding(.top, 16)
            .padding(.bottom, 12)
            
            // 설명 텍스트
            HStack {
                Text("반영할 경험카드를 선택해주세요 (최대 3개)")
                    .typo(.regular_15)
                    .foregroundColor(.gray400)
                
                Spacer()
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 16)
            
            // 추가하기 버튼
            Button {
                showExperienceAddFlow = true
            } label: {
                HStack(spacing: 8) {
                    Image("plus_selected")
                        .frame(size: 18)
                    
                    Text("추가하기")
                        .typo(.medium_15)
                        .foregroundColor(.gray300)
                    
                    Spacer()
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 11.5)
                .background(Color.primary50)
                .cornerRadius(8)
                .contentShape(Rectangle())
            }
            .buttonStyle(PlainButtonStyle())
            .padding(.horizontal, 20)
            .padding(.bottom, 16)
            
            // 컨텐츠 영역
            if isLoading {
                //  로딩 상태
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                
            } else if let error = errorMessage {
                //  에러 상태
                VStack(spacing: 12) {
                    Text(error)
                        .typo(.regular_14_160)
                        .foregroundColor(.gray200)
                    
                    Button("다시 시도") {
                        Task {
                            await loadMatchingExperiences()
                        }
                    }
                    .typo(.medium_13)
                    .foregroundColor(.primary100)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                
            } else {
                // 경험 리스트
                ScrollView {
                    VStack(spacing: 12) {
                        ForEach(
                            experiences.sorted(by: { $0.similarityScore > $1.similarityScore }),
                            id: \.experience.id
                        ) { matchingExperience in
                            SelectableExperienceCell(
                                experience: matchingExperience.experience,
                                similarityScore: matchingExperience.similarityScore,
                                
                                isSelected: selectedExperienceIds.contains(matchingExperience.experience.id),
                                onTap: {
                                    toggleSelection(matchingExperience.experience.id)
                                },
                                onMoreTapped: {
                                    // TODO: 수정/삭제 메뉴 표시
                                    print("더보기 버튼 클릭: \(matchingExperience.experience.title)")
                                }
                            )
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 4)
                }
                .padding(.bottom, 20)
            }
            
            // 하단 확인 버튼
            Button {
                onConfirm(Array(selectedExperienceIds))
                isPresented = false
            } label: {
                Text("\(selectedExperienceIds.count)개 경험 선택")
                    .typo(.semibold_16)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(selectedExperienceIds.isEmpty ? Color.gray100 : Color.primary100)
                    .cornerRadius(12)
            }
            .disabled(selectedExperienceIds.isEmpty)
            .padding(.horizontal, 20)
            .padding(.bottom, 10)
        }
        .presentationDetents([.large])
        .presentationDragIndicator(.hidden)
        .fullScreenCover(isPresented: $showExperienceAddFlow) {
            ExperienceFlowCoordinator {
                print(" 경험 등록 완료 - 목록 새로고침")
                Task {
                    await loadMatchingExperiences()
                }
            }
        }
        .task {
            await loadMatchingExperiences()
        }
    }
    
    // 버튼 타이틀 (초안 생성 or 경험 선택)
    private var buttonTitle: String {
        if initialSelectedIds.isEmpty {
            return "초안 생성하기"
        } else {
            return "\(selectedExperienceIds.count)개 경험 선택"
        }
    }
    
    // 매칭 경험 로드
    private func loadMatchingExperiences() async {
        isLoading = true
        errorMessage = nil
        
        do {
            let response = try await experienceRepository.getMatchingExperiences(
                questionId: questionId
            )
            
            experiences = response.experiences
            
            // 초기 선택 설정
            selectedExperienceIds = Set(initialSelectedIds)
            
            print(" 매칭 경험 로드 성공")
            print("  - 총 개수: \(response.total)")
            print("  - 경험 목록: \(experiences.count)개")
            print("  - 초기 선택: \(initialSelectedIds)")
            
            experiences.enumerated().forEach { index, matching in
                print("  \(index + 1). \(matching.experience.title) (점수: \(matching.similarityScore))")
            }
            
        } catch {
            print(" 매칭 경험 로드 실패: \(error)")
            errorMessage = "경험 목록을 불러올 수 없습니다."
            
            if let apiError = error as? APIError {
                print("API Error: \(apiError.localizedDescription)")
            }
        }
        
        isLoading = false
    }
    
    // 선택 토글
    private func toggleSelection(_ experienceId: String) {
        if selectedExperienceIds.contains(experienceId) {
            selectedExperienceIds.remove(experienceId)
        } else {
            if selectedExperienceIds.count < maxSelectionCount {
                selectedExperienceIds.insert(experienceId)
            } else {
                print(" 최대 3개까지만 선택 가능합니다")
                // TODO: 토스트 메시지 표시
            }
        }
    }
}

// 선택 가능한 경험 셀
struct SelectableExperienceCell: View {
    let experience: ExperienceResponse
    let similarityScore: Double
    let isSelected: Bool
    let onTap: () -> Void
    let onMoreTapped: () -> Void
    
    // 태그 파싱
    private var parsedTags: [String] {
        experience.tags
            .split(separator: ",")
            .map { $0.trimmingCharacters(in: .whitespaces) }
            .filter { !$0.isEmpty }
    }
    
    // Category 변환
    private var displayCategory: String {
        CompetencyMapper.toDisplayTitle(experience.category)
    }
    
    // 점수 계산
    private var displayScore: Int {
        Int((similarityScore * 100).rounded())
    }
    
    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 12) {
                //  상단: 점수 + 더보기 버튼
                HStack {
                    Text("\(displayScore)점")
                        .typo(.medium_13)
                        .foregroundColor(.primary100)
                    
                    Spacer()
                    
                    Button {
                        onMoreTapped()
                    } label: {
                        Image(systemName: "ellipsis")
                            .resizable()
                            .frame(width: 16, height: 4)
                            .foregroundColor(.gray300)
                            .rotationEffect(.degrees(90))  // 세로로 회전
                    }
                    .buttonStyle(PlainButtonStyle())
                }
                
                //  중단: 제목
                Text(experience.title)
                    .typo(.medium_15)
                    .foregroundColor(.primary500)
                    .lineLimit(1)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                //  하단: 태그들 + 체크 아이콘
                HStack(alignment: .bottom) {
                    AdaptiveTagsView(
                        competencyTag: displayCategory,
                        tags: parsedTags
                    )
                    
                    Spacer()
                    
                    Image(isSelected ? "checkmark_selected" : "checkmark_unselected")
                        .resizable()
                        .frame(width: 32, height: 32)
                }
            }
            .padding(16)
            .background(Color.white)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? Color.primary100 : Color.gray70, lineWidth: 1)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}
