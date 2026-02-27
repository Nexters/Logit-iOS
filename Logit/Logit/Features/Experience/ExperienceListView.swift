//
//  ExperienceListView.swift
//  Logit
//
//  Created by 임재현 on 1/29/26.
//

import SwiftUI

struct ExperienceListView: View {
    @EnvironmentObject var appState: AppState
    @StateObject private var viewModel: ExperienceListViewModel
    @State private var showExperienceAddFlow = false
    @State private var selectedExperienceId: String? = nil
    @State private var experienceToEdit: ExperienceResponse? = nil
    @State private var openMenuExperienceId: String? = nil

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

            if !viewModel.isLoading {
                ExperienceCountLabel(count: viewModel.experiences.count)
            }

            if viewModel.isLoading {
                Spacer()
                ProgressView()
                Spacer()
            } else if viewModel.experiences.isEmpty {
                EmptyExperienceView(backgroundColor: .gray20) {
                    showExperienceAddFlow = true
                }
            } else {
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(viewModel.experiences, id: \.id) { experience in
                            ExperienceListCell(
                                experience: experience,
                                isMenuOpen: openMenuExperienceId == experience.id,
                                onMenuToggle: {
                                    openMenuExperienceId = openMenuExperienceId == experience.id ? nil : experience.id
                                },
                                onMenuClose: { openMenuExperienceId = nil },
                                onTap: { selectedExperienceId = experience.id },
                                onEdit: { experienceToEdit = experience },
                                onDelete: {
                                    appState.requestDeleteConfirmation(
                                        message: "경험을 삭제하시겠어요?",
                                        subMessage: "삭제하면 복구 못해요"
                                    ) {
                                        Task { await viewModel.deleteExperience(experienceId: experience.id) }
                                    }
                                }
                            )
                            .onAppear {
                                if let lastIndex = viewModel.experiences.firstIndex(where: { $0.id == experience.id }),
                                   lastIndex >= viewModel.experiences.count - 3 {
                                    Task { await viewModel.loadMore() }
                                }
                            }
                        }

                        if viewModel.isLoadingMore {
                            ProgressView()
                                .padding(.vertical, 20)
                        } else if viewModel.showError && !viewModel.experiences.isEmpty {
                            Button("재시도") {
                                Task { await viewModel.loadMore() }
                            }
                            .padding(.vertical, 20)
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 8)
                    .padding(.bottom, 49 + 20)
                }
                .refreshable {
                    await viewModel.fetchExperiences()
                }
                .simultaneousGesture(
                    TapGesture().onEnded { openMenuExperienceId = nil }
                )
            }
        }
        .background(.gray20)
        .navigationBarHidden(true)
        .fullScreenCover(isPresented: $showExperienceAddFlow) {
            ExperienceFlowCoordinator {
                Task { await viewModel.fetchExperiences() }
            }
        }
        .fullScreenCover(item: $experienceToEdit) { experience in
            ExperienceFlowCoordinator(experience: experience) {
                Task { await viewModel.fetchExperiences() }
            }
        }
        .fullScreenCover(item: Binding(
            get: { selectedExperienceId.map { SelectedExperienceID(id: $0) } },
            set: { selectedExperienceId = $0?.id }
        ), onDismiss: {
            Task { await viewModel.fetchExperiences() }
        }) { target in
            ExperienceDetailView(experienceId: target.id) {
                Task { await viewModel.fetchExperiences() }
            }
        }
        .alert("오류", isPresented: $viewModel.showError) {
            Button("확인", role: .cancel) { }
        } message: {
            Text(viewModel.errorMessage ?? "")
        }
        .task {
            await viewModel.fetchExperiences()
        }
    }
}

private struct SelectedExperienceID: Identifiable {
    let id: String
}

extension ExperienceResponse: Identifiable {}

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
    var backgroundColor: Color = .white

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
                    .padding(.horizontal, 24.adjustedLayout)
                    .padding(.vertical, 7.5.adjustedLayout)
                    .background(.primary100)
                    .cornerRadius(8.adjustedLayout)
            }
            .padding(.top, 17.adjustedLayout)
        }
        .offset(y: -50.adjustedLayout)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(.vertical, 60.adjustedLayout)
        .background(backgroundColor)
        .cornerRadius(16.adjustedLayout)
        .padding(.horizontal, 20.adjustedLayout)
    }
}

struct ExperienceListCell: View {
    let experience: ExperienceResponse
    var isMenuOpen: Bool = false
    var onMenuToggle: (() -> Void)? = nil
    var onMenuClose: (() -> Void)? = nil
    var onTap: (() -> Void)? = nil
    var onEdit: (() -> Void)? = nil
    var onDelete: (() -> Void)? = nil

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

    private var cellMenuPopup: some View {
        VStack(spacing: 0) {
            Button {
                onMenuClose?()
                onEdit?()
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "pencil")
                        .font(.system(size: 14))
                        .foregroundStyle(.black)
                    Text("수정")
                        .typo(.regular_14_140)
                        .foregroundStyle(.black)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
            }

            Divider()

            Button {
                onMenuClose?()
                onDelete?()
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "trash")
                        .font(.system(size: 14))
                        .foregroundStyle(.black)
                    Text("삭제")
                        .typo(.regular_14_140)
                        .foregroundStyle(.black)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
            }
        }
        .fixedSize()
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.white)
                .shadow(color: .black.opacity(0.12), radius: 8, x: 0, y: 4)
        )
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // 상단: 제목 + 메뉴 버튼
            HStack(alignment: .top) {
                Text(experience.title)
                    .typo(.medium_15)
                    .foregroundColor(.primary500)
                    .lineLimit(1)

                Spacer()

                Button {
                    onMenuToggle?()
                } label: {
                    Image(systemName: "ellipsis")
                        .rotationEffect(.degrees(90))
                        .foregroundStyle(.gray300)
                        .frame(width: 20, height: 20)
                }
            }

            // 하단: 태그들 (competency 1개 + 일반 태그 1개)
            HStack(spacing: 8) {
                ExperienceTag(
                    text: displayCategory,
                    icon: displayCategory,
                    isCompetency: true
                )
                if let firstTag = parsedTags.first {
                    ExperienceTag(text: firstTag)
                }
                Spacer()
            }
        }
        .padding(16)
        .background(Color.white)
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.gray70, lineWidth: 1)
        )
        .contentShape(Rectangle())
        .onTapGesture {
            if isMenuOpen { onMenuClose?() } else { onTap?() }
        }
        .overlay(alignment: .topTrailing) {
            if isMenuOpen {
                cellMenuPopup
                    .alignmentGuide(.top) { d in d[.bottom] - 44 }
                    .padding(.trailing, 16)
            }
        }
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
