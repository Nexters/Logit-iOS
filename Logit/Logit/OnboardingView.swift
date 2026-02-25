//
//  OnboardingView.swift
//  Logit
//

import SwiftUI

struct OnboardingView: View {
    @EnvironmentObject var appState: AppState
    @State private var currentStep: Int = 1

    private let totalSteps = 3

    private var ctaButton: some View {
        Button {
            if currentStep < totalSteps {
                withAnimation(.easeInOut(duration: 0.25)) {
                    currentStep += 1
                }
            } else {
                appState.completeOnboarding()
            }
        } label: {
            Text(currentStep < totalSteps ? "다음으로" : "시작하기")
                .typo(.semibold_16)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 52.adjustedHeight)
                .background(Color.primary100)
                .cornerRadius(8)
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 10)
    }

    var body: some View {
        VStack(spacing: 0) {
            // 상단 네비게이션
            HStack {
                (Text("\(currentStep)")
                    .font(LogitFont.bold_14.font)
                + Text("/\(totalSteps)")
                    .font(LogitFont.regular_14_140.font))
                    .foregroundColor(.gray300)
                    .padding(.vertical, 4)
                    .padding(.horizontal, 10)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.primary20)
                    )

                Spacer()

                if currentStep < totalSteps {
                    Button("건너뛰기") {
                        appState.completeOnboarding()
                    }
                    .typo(.regular_18)
                    .foregroundColor(.gray200)
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 17)

            // step 콘텐츠
            stepContent
                .transition(.opacity.combined(with: .move(edge: .trailing)))
                .padding(.bottom, 52.adjustedHeight + 10)
        }
        .fillScreen()
        .background(.white)
        .overlay(alignment: .bottom) {
            ctaButton
        }
    }

    @ViewBuilder
    private var stepContent: some View {
        switch currentStep {
        case 1:
            onboardingStep(iconName: "onboarding_icon1", mainImageName: "onboarding1") {
                (Text("예시 불러오기")
                    .font(LogitFont.bold_18.font)
                    .foregroundColor(.primary100)
                + Text("로 빠르게 성능을\n테스트 해보세요")
                    .font(LogitFont.regular_18.font)
                    .foregroundColor(.black))
                .multilineTextAlignment(.center)
            }
        case 2:
            onboardingStep(iconName: "onboarding_icon2", mainImageName: "onboarding2") {
                (Text("등록한 경험과 작성하는\n")
                    .font(LogitFont.regular_18.font)
                    .foregroundColor(.black)
                + Text("공고간의 매칭 점수")
                    .font(LogitFont.bold_18.font)
                    .foregroundColor(.primary100)
                + Text("를 확인해보세요")
                    .font(LogitFont.regular_18.font)
                    .foregroundColor(.black))
                .multilineTextAlignment(.center)
            }
        case 3:
            onboardingStep(iconName: "onboarding_icon3", mainImageName: "onboarding3") {
                (Text("리포트")
                    .font(LogitFont.bold_18.font)
                    .foregroundColor(.primary100)
                + Text("로 나의 강점을 파악해보세요")
                    .font(LogitFont.regular_18.font)
                    .foregroundColor(.black))
                .multilineTextAlignment(.center)
            }
        default:
            EmptyView()
        }
    }

    private func onboardingStep<Content: View>(
        iconName: String,
        mainImageName: String,
        @ViewBuilder textContent: () -> Content
    ) -> some View {
        VStack(spacing: 0) {
            // 40x40 아이콘
            Image(iconName)
                .resizable()
                .scaledToFit()
                .frame(width: 40, height: 40)
                .padding(.top, 28.adjustedHeight)

            // 혼합 스타일 텍스트
            textContent()
                .padding(.top, 13)
                .padding(.horizontal, 20)

            // 전체 이미지 (텍스트 아래~버튼 위 공간 채움)
            Image(mainImageName)
                .resizable()
                .scaledToFit()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview {
    OnboardingView()
        .environmentObject(AppState(mockScenario: .newUser))
}
