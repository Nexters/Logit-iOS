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
    @State private var experiences: [ExperienceData] = [
            ExperienceData(
                title: "로짓 데이터 분석을 통한 이탈률 개선",
                type: "인턴",
                situation: "사용자 이탈률이 높아 개선이 필요했습니다",
                task: "데이터 분석을 통해 이탈 원인 파악",
                action: "로그 데이터 분석 및 A/B 테스트 진행",
                result: "이탈률 15% 감소",
                competency: "문제해결력",
                score: "97"
            ),
            ExperienceData(
                title: "신규 서비스 기획 및 런칭",
                type: "정규직",
                situation: "새로운 시장 진입이 필요했습니다",
                task: "0부터 서비스 기획 및 출시",
                action: "시장 조사 및 MVP 개발 주도",
                result: "출시 3개월 만에 MAU 10만 달성",
                competency: "실행력",
                score: "87"
            ),
            ExperienceData(
                title: "스타트업 창업 및 운영",
                type: "개인활동",
                situation: "문제를 해결할 서비스가 필요했습니다",
                task: "팀 구성 및 서비스 개발",
                action: "팀원 모집, 개발, 마케팅 진행",
                result: "시드 투자 유치 성공",
                competency: "리더십",
                score: "66"
            ),
            ExperienceData(
                title: "고객 응대 및 CS 개선 프로젝트",
                type: "아르바이트",
                situation: "고객 불만이 증가하는 상황",
                task: "CS 프로세스 개선",
                action: "고객 피드백 분석 및 매뉴얼 작성",
                result: "고객 만족도 20% 향상",
                competency: "소통력",
                score: "55"
            ),
            ExperienceData(
                title: "해커톤 대회 참가 및 수상",
                type: "수상경력",
                situation: "48시간 안에 서비스 개발 필요",
                task: "아이디어 구현 및 발표",
                action: "팀원들과 협업하여 프로토타입 완성",
                result: "최우수상 수상",
                competency: "전문성",
                score: "33"
            )
        ]
    
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
            ExperienceFlowCoordinator { experienceData in
                // 경험 추가 후 목록에 추가
                experiences.append(experienceData)
                // 자동으로 선택
                if selectedExperiences.count < maxSelectionCount {
                    selectedExperiences.insert(experienceData.title)
                }
            }
        }
        .onAppear {
            loadExperiences()
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
