//
//  ExperienceTypeSelectionView.swift
//  Logit
//
//  Created by 임재현 on 1/29/26.
//

import SwiftUI

struct ExperienceTypeSelectionView: View {
    @EnvironmentObject var viewModel: ExperienceFlowViewModel
//    @Environment(\.dismiss) var dismiss
    
    let competencies = [
           CompetencyOption(icon: "고객이해력", displayTitle: "고객이해력", apiValue: "고객 가치 지향"),
           CompetencyOption(icon: "전문성", displayTitle: "전문성", apiValue: "기술적 전문성"),
           CompetencyOption(icon: "소통력", displayTitle: "소통력", apiValue: "협력적 소통"),
           CompetencyOption(icon: "실행력", displayTitle: "실행력", apiValue: "주도적 실행력"),
           CompetencyOption(icon: "분석력", displayTitle: "분석력", apiValue: "논리적 분석력"),
           CompetencyOption(icon: "문제해결력", displayTitle: "문제해결력", apiValue: "창의적 문제해결"),
           CompetencyOption(icon: "적응력", displayTitle: "적응력", apiValue: "유연한 적응력"),
           CompetencyOption(icon: "책임감", displayTitle: "책임감", apiValue: "끈기있는 책임감")
       ]
    
    var body: some View {
        VStack(spacing: 0) {
            CustomNavigationBar(
                title: "경험 등록",
                showBackButton: true,
                onBackTapped: { viewModel.navigateBack() }
            )
            
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    PageIndicator(currentPage: 3, totalPages: 3)
                        .padding(.top, 16)
                    
                    Text("경험 유형 선택")
                        .typo(.bold_18)
                        .padding(.top, 13.25)
                    
                    Text("활용될 핵심 역량을 선택하세요")
                        .typo(.regular_15)
                        .foregroundColor(.gray300)
                        .padding(.top, 3)
                    
                    FlowLayout(spacing: 8) {
                        ForEach(competencies, id: \.displayTitle) { competency in
                            CompetencyChip(
                                icon: competency.icon,
                                title: competency.displayTitle,
                                isSelected: viewModel.selectedCompetency == competency.apiValue
                            ) {
                                viewModel.selectedCompetency = competency.apiValue
                            }
                        }
                    }
                    .padding(.top, 84.87)
                }
                .padding(.horizontal, 20)
            }
        
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
            .background(isButtonEnabled ? Color.primary100 : Color.gray100)
            .cornerRadius(12)
            .disabled(!isButtonEnabled)
            .padding(.horizontal, 20)
            .padding(.bottom, 10)
        }
        .alert("오류", isPresented: $viewModel.showError) {
            Button("확인", role: .cancel) { }
        } message: {
            Text(viewModel.errorMessage ?? "")
        }
        .navigationBarHidden(true)
    }
    
    private var isButtonEnabled: Bool {
        viewModel.selectedCompetency != nil && !viewModel.isLoading
    }
}

// 역량 옵션 모델
struct CompetencyOption {
    let icon: String
    let displayTitle: String  // UI에 표시될 이름
    let apiValue: String      // 서버에 보낼 값
}

// 아이콘이 포함된 칩 버튼
struct CompetencyChip: View {
    let icon: String
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(icon)
                    .resizable()
                    .renderingMode(.template)
                    .foregroundStyle(isSelected ? .icon1 : .gray100)
                    .frame(size: 16)
                
                Text(title)
                    .typo(.regular_15)
                    .foregroundStyle(.primary600)
            }
            .padding(.horizontal, 8.31)
            .padding(.vertical, 6.5)
            .background(isSelected ? Color(hex: "#EBF7F7") : .gray50)
            .cornerRadius(11.08)
        }
        .animation(.easeInOut(duration: 0.2), value: isSelected)
    }
}


extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
