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
    @State private var selectedExperiences: Set<String> = []
    @State private var experiences: [ExperienceData] = []
    
    let onSelectExperiences: ([ExperienceData]) -> Void
    private let maxSelectionCount = 3
    
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
            ScrollView {
                VStack(spacing: 12) {
                    ForEach(experiences.sorted(by: { Int($0.score) ?? 0 > Int($1.score) ?? 0 }), id: \.title) { experience in
                        SelectableExperienceCell(
                            experience: experience,
                            isSelected: selectedExperiences.contains(experience.title),
                            onTap: {
                                toggleSelection(experience)
                            }
                        )
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 4)
            }
            .padding(.bottom, 20)
            
            // 하단 적용 버튼
            Button {
                let selected = experiences.filter { selectedExperiences.contains($0.title) }
                onSelectExperiences(selected)
                isPresented = false
            } label: {
                Text("\(selectedExperiences.count)개 경험선택")
                    .typo(.semibold_16)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(selectedExperiences.isEmpty ? Color.gray100 : Color.primary100)
                    .cornerRadius(12)
            }
            .disabled(selectedExperiences.isEmpty)
            .padding(.horizontal, 20)
            .padding(.bottom, 10)
        }
        .presentationDetents([.large])
        .presentationDragIndicator(.hidden)
        .fullScreenCover(isPresented: $showExperienceAddFlow) {
            ExperienceFlowCoordinator {
                print("경험 등록 완료!")
            }
        }
        .onAppear {
           // loadExperiences()
        }
    }
    
    private func toggleSelection(_ experience: ExperienceData) {
        if selectedExperiences.contains(experience.title) {
            // 이미 선택됨 → 선택 해제
            selectedExperiences.remove(experience.title)
        } else {
            // 선택 안 됨 → 선택
            if selectedExperiences.count < maxSelectionCount {
                selectedExperiences.insert(experience.title)
            } else {
                // TODO: 최대 개수 초과 알림 (옵션)
                print("최대 3개까지만 선택 가능합니다")
            }
        }
    }
    
    private func loadExperiences() {
        // TODO: 실제 경험 목록 로드
        experiences = ExperienceDataStore.shared.experiences
    }
}

// 선택 가능한 경험 셀
struct SelectableExperienceCell: View {
    let experience: ExperienceData
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // 상단: 제목과 점수
            HStack {
                Text(experience.title)
                    .typo(.semibold_16)
                    .foregroundColor(.black)
                    .lineLimit(1)
                
                Spacer()
                
                Text("\(experience.score)점")
                    .typo(.medium_15)
                    .foregroundColor(.primary200)
            }
            
            // 하단: 태그들
            HStack(spacing: 8) {
                ExperienceTag(
                    text: experience.competency,
                    icon: experience.competency,
                    isCompetency: true
                )
                ExperienceTag(text: experience.type)
                Spacer()
            }
        }
        .padding(16)
        .background(isSelected ? Color.primary20 : Color.white)
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(isSelected ? Color.primary100 : Color.gray100, lineWidth: isSelected ? 2 : 1)
        )
        .onTapGesture {
            onTap()
        }
        .animation(.easeInOut(duration: 0.2), value: isSelected)
    }
}
