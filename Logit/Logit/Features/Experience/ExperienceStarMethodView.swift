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
    
    var body: some View {
        VStack(spacing: 0) {
            CustomNavigationBar(
                title: "",
                showBackButton: true,
                onBackTapped: { viewModel.navigateBack() }
            )
            
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    PageIndicator(currentPage: 2, totalPages: 3)
                        .padding(.top, 16)
                    
                    HStack(alignment: .center, spacing: 0) {
                        Text("STAR 기반 경험 정리")
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
                    
                    Text("상세할수록 답변의 품질이 올라가요")
                        .typo(.regular_15)
                        .foregroundColor(.gray300)
                        .padding(.top, 3)
                    
                    VStack(spacing: 20) {
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
                            isRequired: false,
                            maxLength: 1000,
                            largeHeight: 74,
                            text: $viewModel.result
                        )
                    }
                    .padding(.top, 24)
                    
                    Spacer()
                        .frame(minHeight: 46.75)
                    
                    Button {
                        viewModel.navigateToExperienceType()
                    } label: {
                        Text("다음으로")
                            .typo(.bold_18)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(isFormValid ? Color.primary100 : Color.gray100)
                            .cornerRadius(12)
                    }
                    .disabled(!isFormValid)
                    
                    .padding(.bottom, 10)
                }
                .padding(.horizontal, 20)
            }
            .scrollToMinDistance(minDisntance: 32)
        }
        .navigationBarHidden(true)
        .dismissKeyboardOnTap()
    }
    
    private var isFormValid: Bool {
        !viewModel.situation.isEmpty &&
        !viewModel.task.isEmpty &&
        !viewModel.action.isEmpty &&
        !viewModel.result.isEmpty
    }
}

