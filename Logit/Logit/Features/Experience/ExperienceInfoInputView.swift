//
//  ExperienceInfoInputView.swift
//  Logit
//
//  Created by 임재현 on 1/29/26.
//

import SwiftUI

struct ExperienceInfoInputView: View {
    @EnvironmentObject var viewModel: ExperienceFlowViewModel
    @Environment(\.dismiss) var dismiss

    let experienceTypes = ["아르바이트", "정규직", "인턴", "계약직", "봉사 활동", "동아리 활동", "연구 활동", "군복무","수상경력","개인활동"]
    
    var body: some View {
        VStack(spacing: 0) {
            CustomNavigationBar(
                title: "경험 등록",
                showBackButton: true,
                onBackTapped: { dismiss() }
            )
            
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    PageIndicator(currentPage: 1, totalPages: 3)
                        .padding(.top, 16)
                    
                    Text("경험 정보 입력")
                        .typo(.bold_18)
                        .padding(.top, 13.25)
                    
                    Text("경험에 대한 기본 정보를 입력해주세요")
                        .typo(.regular_15)
                        .foregroundColor(.gray300)
                        .padding(.top, 3)
                    
                    VStack(spacing: 20) {
                        InputFieldView(
                            title: "경험 제목",
                            placeholder: "예) 로짓 데이터 분석을 통한 이탈률 개선",
                            isRequired: true,
                            maxLength: 100,
                            text: $viewModel.experienceTitle
                        )
                        
                        SelectableChipGroup(
                            title: "경험 유형",
                            isRequired: true,
                            options: experienceTypes,
                            selectedOption: $viewModel.experienceType
                        )
                    }
                    .padding(.top, 24)
                    
                    Spacer()
                        .frame(minHeight: 173)
                    
                    Button {
                        viewModel.navigateToStarMethod()
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
                    .padding(.bottom, 34)
                }
                .padding(.horizontal, 20)
            }
            .scrollToMinDistance(minDisntance: 32)
        }
        .navigationBarHidden(true)
        .dismissKeyboardOnTap()
    }
    
    private var isFormValid: Bool {
        return !viewModel.experienceTitle.isEmpty && viewModel.experienceType != nil
    }
}


struct SelectableChipGroup: View {
    let title: String
    let isRequired: Bool
    let options: [String]
    @Binding var selectedOption: String?
    
    init(
        title: String,
        isRequired: Bool = false,
        options: [String],
        selectedOption: Binding<String?>
    ) {
        self.title = title
        self.isRequired = isRequired
        self.options = options
        self._selectedOption = selectedOption
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            // 상단 타이틀 부분
            HStack(spacing: 2) {
                Text(title)
                    .typo(.medium_16)
                    .foregroundColor(.black)
                
                if isRequired {
                    Text("*")
                        .typo(.medium_16)
                        .foregroundColor(.alert)
                }
                
                Spacer()
            }
            
            // FlowLayout
            FlowLayout(spacing: 8) {
                ForEach(options, id: \.self) { option in
                    CategoryChip(
                        text: option,
                        isSelected: selectedOption == option
                    ) {
                        selectedOption = option
                    }
                }
            }
        }
    }
}

// CategoryChip
struct CategoryChip: View {
    let text: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(text)
                .typo(.regular_15)
                .foregroundColor(isSelected ? .primary200 : .gray300)
                .padding(.horizontal, 14)
                .padding(.vertical, 6.5)
                .background(isSelected ? Color.primary50 : Color.gray50)
                .cornerRadius(8)

        }
        .animation(.easeInOut(duration: 0.2), value: isSelected)
    }
}

struct FlowLayout: Layout {
    var spacing: CGFloat = 8
    
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = FlowResult(
            in: proposal.replacingUnspecifiedDimensions().width,
            subviews: subviews,
            spacing: spacing
        )
        return result.size
    }
    
    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = FlowResult(
            in: bounds.width,
            subviews: subviews,
            spacing: spacing
        )
        for (index, subview) in subviews.enumerated() {
            let position = CGPoint(
                x: bounds.minX + result.positions[index].x,
                y: bounds.minY + result.positions[index].y
            )
            subview.place(at: position, proposal: .unspecified)
        }
    }
    
    struct FlowResult {
        var size: CGSize = .zero
        var positions: [CGPoint] = []
        
        init(in maxWidth: CGFloat, subviews: Subviews, spacing: CGFloat) {
            var x: CGFloat = 0
            var y: CGFloat = 0
            var lineHeight: CGFloat = 0
            
            for subview in subviews {
                let size = subview.sizeThatFits(.unspecified)
                
                if x + size.width > maxWidth && x > 0 {
                    // 다음 줄로
                    x = 0
                    y += lineHeight + spacing
                    lineHeight = 0
                }
                
                positions.append(CGPoint(x: x, y: y))
                lineHeight = max(lineHeight, size.height)
                x += size.width + spacing
            }
            
            self.size = CGSize(width: maxWidth, height: y + lineHeight)
        }
    }
}
