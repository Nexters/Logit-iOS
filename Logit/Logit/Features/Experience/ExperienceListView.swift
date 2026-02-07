//
//  ExperienceListView.swift
//  Logit
//
//  Created by 임재현 on 1/29/26.
//

import SwiftUI

struct ExperienceListView: View {
    @StateObject private var viewModel: ExperienceListViewModel
    @State private var showExperienceAddFlow = false
    
    init() {
        let networkClient = DefaultNetworkClient()
        let repository = DefaultExperienceRepository(networkClient: networkClient)
        _viewModel = StateObject(wrappedValue: ExperienceListViewModel(experienceRepository: repository))
    }
    
    var body: some View {
        VStack(spacing: 0) {
            ExperienceListHeader(
                onAddTapped: {
                    showExperienceAddFlow = true
                }
            )
            
            if !viewModel.experiences.isEmpty {
                ExperienceCountLabel(count: viewModel.experiences.count)
            }
            
            if viewModel.isLoading {
                Spacer()
                ProgressView()
                Spacer()
            } else if viewModel.experiences.isEmpty {
                EmptyExperienceView {
                    showExperienceAddFlow = true
                }
            } else {
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(viewModel.experiences, id: \.id) { experience in
                            ExperienceListCell(experience: experience)
                                .onTapGesture {
                                    print("선택된 경험: \(experience.title)")
                                }
                                .onAppear {
                                    // 마지막에서 3개 전에 미리 로드
                                    if let lastIndex = viewModel.experiences.firstIndex(where: { $0.id == experience.id }),
                                       lastIndex >= viewModel.experiences.count - 3 {
                                        Task {
                                            await viewModel.loadMore()
                                        }
                                    }
                                }
                        }
                        
                        // 로딩 인디케이터
                        if viewModel.isLoadingMore {
                            ProgressView()
                                .padding(.vertical, 20)
                        } else if viewModel.showError && !viewModel.experiences.isEmpty {
                            Button("재시도") {
                                Task {
                                    await viewModel.loadMore()
                                }
                            }
                            .padding(.vertical, 20)
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 8)
                    .padding(.bottom, 49 + 20)
                }
                .refreshable {
                    // Pull to Refresh
                    await viewModel.fetchExperiences()
                }
            }
        }
        .background(.gray20)
        .navigationBarHidden(true)
        .fullScreenCover(isPresented: $showExperienceAddFlow) {
            ExperienceFlowCoordinator {
                Task {
                    await viewModel.fetchExperiences()
                }
            }
        }
        .alert("오류", isPresented: $viewModel.showError) {
            Button("확인", role: .cancel) { }
        } message: {
            Text(viewModel.errorMessage ?? "")
        }
        .task {
            // 첫 로드
            await viewModel.fetchExperiences()
        }
    }
}

struct ExperienceListHeader: View {
    let onAddTapped: () -> Void
    
    var body: some View {
        HStack(spacing: 12) {
            // 타이틀
            Text("경험 목록")
                .typo(.bold_20)
                .foregroundColor(.black)
            
            Spacer()
            
            // 추가 버튼
            Button {
                onAddTapped()
            } label: {
                Image(systemName: "plus")
                    .frame(size: 24)
                    .foregroundColor(.black)
                    .contentShape(Rectangle())
            }
        }
        .frame(height: 44)
        .padding(.horizontal, 20)
        .background(Color.gray20)
    }
}

struct ExperienceCountLabel: View {
    let count: Int
    
    var body: some View {
        HStack {
            Text("\(count)개")
                .typo(.medium_13)
                .foregroundColor(.gray200)
            
            Spacer()
        }
        .padding(.horizontal, 20)
        .padding(.top, 12)
        .padding(.bottom, 8)
    }
}

struct EmptyExperienceView: View {
    let onSelectExperience: () -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            Image("app_status_empty2")
                .resizable()
                .scaledToFit()
                .frame(width: 80.adjustedLayout, height: 80.adjustedLayout)
            
            Text("등록된 경험이 없어요")
                .typo(.medium_15)
                .foregroundStyle(.gray100)
                .padding(.top, 16.adjustedLayout)
            
            Button {
                onSelectExperience()
            } label: {
                Text("경험 등록하기")
                    .typo(.medium_15)
                    .foregroundStyle(.white)
                    .padding(.horizontal, 39.adjustedLayout)
                    .padding(.vertical, 7.5.adjustedLayout)
                    .background(.primary100)
                    .cornerRadius(8.adjustedLayout)
            }
            .padding(.top, 17.adjustedLayout)
        }
        .offset(y: -10.adjustedLayout)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(.vertical, 60.adjustedLayout)
        .background(.gray20)
        .cornerRadius(16.adjustedLayout)
        .padding(.horizontal, 20.adjustedLayout)
    }
}

struct ExperienceListCell: View {
    let experience: ExperienceResponse
    
    // 태그 파싱 (쉼표로 분리)
    private var parsedTags: [String] {
        experience.tags
            .split(separator: ",")
            .map { $0.trimmingCharacters(in: .whitespaces) }
            .filter { !$0.isEmpty }
    }
    
    // Category를 짧은 이름으로 변환
    private var displayCategory: String {
        CompetencyMapper.toDisplayTitle(experience.category)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // 상단: 제목
            Text(experience.title)
                .typo(.medium_15)
                .foregroundColor(.primary500)
                .lineLimit(1)
            
            // 하단: 태그들 (가변 레이아웃)
            AdaptiveTagsView(
                competencyTag: displayCategory,
                tags: parsedTags
            )
        }
        .padding(16)
        .background(Color.white)
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.gray70, lineWidth: 1)
        )
    }
}

struct AdaptiveTagsView: View {
    let competencyTag: String
    let tags: [String]
    
    var body: some View {
        ViewThatFits(in: .horizontal) {
            // 1순위: 모든 태그 표시
            allTagsView
            
            // 2순위: 태그 개수에 따라 단계적으로 줄이기
            ForEach((0..<tags.count).reversed(), id: \.self) { count in
                limitedTagsView(count: count)
            }
        }
    }
    
    // 모든 태그 표시
    private var allTagsView: some View {
        HStack(spacing: 8) {
            ExperienceTag(
                text: competencyTag,
                icon: competencyTag,
                isCompetency: true
            )
            
            ForEach(tags, id: \.self) { tag in
                ExperienceTag(text: tag)
            }
            
            Spacer()
        }
    }
    
    // 제한된 개수만 표시
    private func limitedTagsView(count: Int) -> some View {
        HStack(spacing: 8) {
            ExperienceTag(
                text: competencyTag,
                icon: competencyTag,
                isCompetency: true
            )
            
            ForEach(tags.prefix(count), id: \.self) { tag in
                ExperienceTag(text: tag)
            }
            
            if tags.count > count {
                Text("+\(tags.count - count)")
                    .typo(.regular_12)
                    .foregroundColor(.gray400)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 6)
                    .background(Color.gray50)
                    .cornerRadius(6)
            }
            
            Spacer()
        }
    }
}

// 태그
struct ExperienceTag: View {
    let text: String
    var icon: String? = nil
    var isCompetency: Bool = false
    
    var body: some View {
        HStack(spacing: 6) {
            if let icon = icon {
                Image(icon)
                    .resizable()
                    .frame(width: 16, height: 16)
            }
            
            Text(text)
                .typo(.regular_12)
                .foregroundColor(.primary600)
                .lineLimit(1)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 6)
        .background(isCompetency ? Color(hex: "E3F5FF") : Color.gray50)
        .cornerRadius(6)
        .fixedSize(horizontal: true, vertical: false)
    }
}
