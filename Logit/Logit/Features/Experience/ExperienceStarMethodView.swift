//
//  ExperienceStarMethodView.swift
//  Logit
//
//  Created by 임재현 on 1/29/26.
//

import SwiftUI

struct ExperienceStarMethodView: View {
    @EnvironmentObject var viewModel: ExperienceFlowViewModel
    @Environment(\.dismiss) var dismiss
    @State private var isMethodDropdownOpen: Bool = false
    
    var body: some View {
        VStack(spacing: 0) {
            CustomNavigationBar(
                title: "",
                showBackButton: true,
                onBackTapped: { viewModel.navigateBack() }
            )
            
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    PageIndicator(currentPage: 2, totalPages: 2)
                        .padding(.top, 16)
                    
                    HStack(alignment: .center, spacing: 0) {
                        Text("경험 정리")
                            .typo(.bold_18)
                        
                        Spacer()
                        
                        Button {
                            viewModel.loadStarExampleData()
                        } label: {
                            if viewModel.isStarExampleLoaded {
                                Text("작성된 예시로 등록해보세요")
                                    .typo(.regular_12)
                                    .foregroundColor(.primary100)
                                    .padding(.horizontal, 14)
                                    .padding(.vertical, 6)
                            } else {
                                Text("예시 불러오기")
                                    .typo(.regular_12)
                                    .foregroundColor(.primary400)
                                    .padding(.horizontal, 14)
                                    .padding(.vertical, 6)
                                    .background(
                                        RoundedRectangle(cornerRadius: 8)
                                            .stroke(.gray70, lineWidth: 1)
                                            .background(.gray20)
                                    )
                            }
                        }
                        .disabled(viewModel.isStarExampleLoaded)
                    }
                    .padding(.top, 13.25)
                    
                    Text("최소 50자 이상 입력해 주세요.")
                        .typo(.regular_15)
                        .foregroundColor(.gray300)
                        .padding(.top, 3)

                    // 경험 정리법 드롭다운
                    VStack(alignment: .leading, spacing: 8) {
                        Text("경험 정리법")
                            .typo(.medium_15)
                            .foregroundColor(.black)

                        // 선택 버튼
                        Button {
                            withAnimation(.easeInOut(duration: 0.2)) {
                                isMethodDropdownOpen.toggle()
                            }
                        } label: {
                            HStack {
                                Text(viewModel.selectedMethod.displayName)
                                    .typo(.medium_15)
                                    .foregroundColor(.black)
                                Spacer()
                                Image(systemName: isMethodDropdownOpen ? "chevron.up" : "chevron.down")
                                    .font(.system(size: 12))
                                    .foregroundColor(.gray300)
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 13)
                            .contentShape(Rectangle())
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(
                                        isMethodDropdownOpen ? Color.primary100 : Color.gray100,
                                        lineWidth: 1
                                    )
                            )
                        }
                        .buttonStyle(PlainButtonStyle())

                        // 드롭다운 목록
                        if isMethodDropdownOpen {
                            VStack(spacing: 0) {
                                ForEach(ExperienceMethod.allCases, id: \.self) { method in
                                    Button {
                                        withAnimation(.easeInOut(duration: 0.2)) {
                                            viewModel.selectedMethod = method
                                            isMethodDropdownOpen = false
                                        }
                                    } label: {
                                        HStack {
                                            Text(method.displayName)
                                                .typo(.regular_15)
                                                .foregroundColor(
                                                    viewModel.selectedMethod == method ? .primary100 : .black
                                                )
                                            Spacer()
                                            if viewModel.selectedMethod == method {
                                                Image(systemName: "checkmark")
                                                    .font(.system(size: 13))
                                                    .foregroundColor(.primary100)
                                            }
                                        }
                                        .padding(.horizontal, 16)
                                        .padding(.vertical, 13)
                                        .contentShape(Rectangle())
                                    }
                                    .buttonStyle(PlainButtonStyle())

                                    if method != ExperienceMethod.allCases.last {
                                        Divider()
                                            .padding(.horizontal, 16)
                                    }
                                }
                            }
                            .background(Color.white)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color.gray100, lineWidth: 1)
                            )
                            .transition(.opacity.combined(with: .move(edge: .top)))
                        }
                    }
                    .padding(.top, 16)

                    VStack(spacing: 20) {
                        switch viewModel.selectedMethod {
                        case .star:
                            InputFieldView(
                                title: "Situation (상황)",
                                placeholder: "어떤 일이 일어났는지 배경을 기술합니다.",
                                isRequired: true,
                                maxLength: 1000,
                                largeHeight: 74,
                                text: $viewModel.situation
                            )
                            InputFieldView(
                                title: "Task (과제/목표)",
                                placeholder: "해결해야 했던 과제를 기술합니다.",
                                isRequired: true,
                                maxLength: 1000,
                                largeHeight: 74,
                                text: $viewModel.task
                            )
                            InputFieldView(
                                title: "Action (행동)",
                                placeholder: "문제를 해결하기 위해 한 행동을 기술합니다.",
                                isRequired: true,
                                maxLength: 1000,
                                largeHeight: 74,
                                text: $viewModel.action
                            )
                            InputFieldView(
                                title: "Result (결과)",
                                placeholder: "행동으로 얻은 성과와 배운 점을 서술합니다.",
                                isRequired: true,
                                maxLength: 1000,
                                largeHeight: 74,
                                text: $viewModel.result
                            )

                        case .psi:
                            InputFieldView(
                                title: "Problem (문제)",
                                placeholder: "직면했던 문제나 상황을 기술합니다.",
                                isRequired: true,
                                maxLength: 1000,
                                largeHeight: 74,
                                text: $viewModel.problem
                            )
                            InputFieldView(
                                title: "Solution (해결책)",
                                placeholder: "문제를 해결하기 위해 취한 행동을 기술합니다.",
                                isRequired: true,
                                maxLength: 1000,
                                largeHeight: 74,
                                text: $viewModel.solution
                            )
                            InputFieldView(
                                title: "Insight (인사이트)",
                                placeholder: "경험을 통해 얻은 인사이트와 배운 점을 서술합니다.",
                                isRequired: true,
                                maxLength: 1000,
                                largeHeight: 74,
                                text: $viewModel.insight
                            )

                        case .free:
                            InputFieldView(
                                title: "경험 내용",
                                placeholder: "경험을 자유롭게 서술합니다.",
                                isRequired: true,
                                maxLength: 3000,
                                largeHeight: 200,
                                text: $viewModel.content
                            )
                        }
                    }
                    .padding(.top, 24)
                    
                    Spacer()
                        .frame(minHeight: 46.75)
                    
                    Button {
                        Task {
                            await viewModel.saveExperience()
                        }
                    } label: {
                        if viewModel.isLoading {
                            ProgressView()
                                .tint(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 14)
                        } else {
                            Text("경험등록")
                                .typo(.bold_18)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 14)
                        }
                    }
                    .background(isFormValid && !viewModel.isLoading ? Color.primary100 : Color.gray100)
                    .cornerRadius(12)
                    .disabled(!isFormValid || viewModel.isLoading)
                    .padding(.bottom, 10)
                }
                .padding(.horizontal, 20)
            }
            .scrollToMinDistance(minDisntance: 32)
        }
        .alert("오류", isPresented: $viewModel.showError) {
            Button("확인", role: .cancel) { }
        } message: {
            Text(viewModel.errorMessage ?? "")
        }
        .navigationBarHidden(true)
        .dismissKeyboardOnTap()
    }
    
    private var isFormValid: Bool {
        switch viewModel.selectedMethod {
        case .star:
            return !viewModel.situation.isEmpty &&
                   !viewModel.task.isEmpty &&
                   !viewModel.action.isEmpty &&
                   !viewModel.result.isEmpty
        case .psi:
            return !viewModel.problem.isEmpty &&
                   !viewModel.solution.isEmpty &&
                   !viewModel.insight.isEmpty
        case .free:
            return !viewModel.content.isEmpty
        }
    }
}

