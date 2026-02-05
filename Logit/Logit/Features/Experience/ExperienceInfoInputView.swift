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
                title: "",
                showBackButton: true,
                onBackTapped: { dismiss() }
            )
            
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    PageIndicator(currentPage: 1, totalPages: 3)
                        .padding(.top, 16)
                    
                    HStack(alignment: .center, spacing: 0) {
                        Text("경험 정보 입력")
                            .typo(.bold_18)
                        
                        Spacer()
                        
                        Button {
                            viewModel.loadExampleData()
                        } label: {
                            if viewModel.isExampleLoaded {
                                //  로드 후: 텍스트만
                                Text("작성된 예시로 등록해보세요")
                                    .typo(.regular_12)
                                    .foregroundColor(.primary100)
                                    .padding(.horizontal, 14)
                                    .padding(.vertical, 6)
                            } else {
                                //  로드 전: 버튼 스타일
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
                        .disabled(viewModel.isExampleLoaded)
                    }
                    .padding(.top, 13.25)
                    
                    Text("등록하는 경험의 정보를 알려주세요")
                        .typo(.regular_15)
                        .foregroundColor(.gray300)
                        .padding(.top, 3)
                    
                    VStack(spacing: 36) {
                        InputFieldView(
                            title: "경험 제목",
                            placeholder: "예) 로짓 데이터 분석을 통한 이탈률 개선",
                            isRequired: true,
                            maxLength: 100,
                            text: $viewModel.experienceTitle
                        )
                        
                        DateRangeInputView(
                            title: "경험 날짜",
                            isRequired: true,
                            startDate: $viewModel.startDate,
                            endDate: $viewModel.endDate,
                            isOngoing: $viewModel.isOngoing
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
                        .frame(minHeight: 40)
                    
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
        // 경험 제목과 유형은 필수
        guard !viewModel.experienceTitle.isEmpty,
              viewModel.experienceType != nil else {
            return false
        }
        
        // 진행중인 경우: 시작 날짜만 있으면 됨
        if viewModel.isOngoing {
            return viewModel.startDate != nil
        }
        
        // 진행중이 아닌 경우: 시작 날짜와 종료 날짜 모두 필요
        return viewModel.startDate != nil && viewModel.endDate != nil
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


struct DateRangeInputView: View {
    let title: String
    let isRequired: Bool
    @Binding var startDate: Date?
    @Binding var endDate: Date?
    @Binding var isOngoing: Bool
    
    @State private var startDateText: String = ""
    @State private var endDateText: String = ""
    @State private var isStartDateValid: Bool = true
    @State private var isEndDateValid: Bool = true
    @FocusState private var focusedField: DateField?
    
    enum DateField {
        case start, end
    }
    
    init(
        title: String,
        isRequired: Bool = false,
        startDate: Binding<Date?>,
        endDate: Binding<Date?>,
        isOngoing: Binding<Bool>
    ) {
        self.title = title
        self.isRequired = isRequired
        self._startDate = startDate
        self._endDate = endDate
        self._isOngoing = isOngoing
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            // 타이틀 영역
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
            
            // 날짜 입력 영역
            if isOngoing {
                dateTextField(
                    placeholder: "yyyy.mm.dd",
                    text: $startDateText,
                    isValid: $isStartDateValid,
                    field: .start
                )
            } else {
                HStack(alignment: .top, spacing: 8) {
                    dateTextField(
                        placeholder: "yyyy.mm.dd",
                        text: $startDateText,
                        isValid: $isStartDateValid,
                        field: .start
                    )
                    
                    Text("~")
                        .typo(.regular_15)
                        .foregroundColor(.gray200)
                        .padding(.top, 12)
                    
                    dateTextField(
                        placeholder: "yyyy.mm.dd",
                        text: $endDateText,
                        isValid: $isEndDateValid,
                        field: .end
                    )
                }
            }
            
            // 진행중 체크박스
            Button {
                isOngoing.toggle()
                if isOngoing {
                    endDate = nil
                    endDateText = ""
                    isEndDateValid = true
                }
            } label: {
                HStack(spacing: 8) {
                    Image(isOngoing ? "activated" : "deactivated")
                        .frame(size: 28)
                    
                    Text("진행중")
                        .typo(.regular_14_160)
                        .foregroundColor(.black)
                }
            }
        }
    }
    
    // 공통 텍스트필드 컴포넌트
    @ViewBuilder
    private func dateTextField(placeholder: String, text: Binding<String>, isValid: Binding<Bool>, field: DateField) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            TextField(placeholder, text: text)
                .typo(.regular_15)
                .foregroundColor(.black)
                .keyboardType(.numberPad)
                .multilineTextAlignment(isOngoing ? .leading : .center)
                .padding(.horizontal, 18)
                .frame(height: 44)
                .background(Color.clear)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(
                            !isValid.wrappedValue ? Color.alert :
                            focusedField == field ? Color.primary100 : Color.gray100,
                            lineWidth: 1
                        )
                )
                .focused($focusedField, equals: field)
                .onChange(of: text.wrappedValue) { oldValue, newValue in
                    handleDateInput(
                        oldValue: oldValue,
                        newValue: newValue,
                        text: text,
                        date: field == .start ? $startDate : $endDate,
                        isValid: isValid
                    )
                }
            // 시작 날짜가 변경될 때
                .onChange(of: startDate) { oldValue, newValue in
                    if field == .start, let date = newValue {
                        text.wrappedValue = formatDateToString(date)
                        isValid.wrappedValue = true
                    }
                }
            // 종료 날짜가 변경될 때
                .onChange(of: endDate) { oldValue, newValue in
                    if field == .end, let date = newValue {
                        text.wrappedValue = formatDateToString(date)
                        isValid.wrappedValue = true
                    }
                }
                .onAppear {
                    // 초기 데이터 바인딩
                    if field == .start, let date = startDate {
                        startDateText = formatDateToString(date)
                    } else if field == .end, let date = endDate {
                        endDateText = formatDateToString(date)
                    }
                }
            
            if !isValid.wrappedValue {
                Text("올바른 날짜를 입력해주세요")
                    .typo(.regular_12)
                    .foregroundColor(.alert)
            }
        }
    }
    
    private func handleDateInput(
        oldValue: String,
        newValue: String,
        text: Binding<String>,
        date: Binding<Date?>,
        isValid: Binding<Bool>
    ) {
        // 1. 숫자만 추출
        let digits = newValue.filter { $0.isNumber }
        
        // 2. 8자리 초과 입력 방지
        if digits.count > 8 {
            text.wrappedValue = oldValue
            return
        }
        
        // 3. 삭제 처리 (지우는 중일 때는 포맷팅을 최소화하여 갇히지 않게 함)
        if oldValue.count > newValue.count {
            // 지울 때는 digits 기반으로 새로 그리되,
            // 만약 oldValue가 "2025.12." 였는데 지워서 "2025.12"가 되었다면 그대로 둠
            text.wrappedValue = formatWithDots(digits)
        } else {
            // 입력 중일 때는 포맷팅 적용
            text.wrappedValue = formatWithDots(digits)
        }
        
        // 4. 유효성 검사 및 Date 변환
        if digits.count == 8 {
            if let parsed = parseDate(from: digits) {
                date.wrappedValue = parsed
                isValid.wrappedValue = true
            } else {
                date.wrappedValue = nil
                isValid.wrappedValue = false
            }
        } else {
            // 8자리가 되기 전까지는 에러를 띄우지 않음 (입력 중)
            isValid.wrappedValue = true
            date.wrappedValue = nil
        }
    }
    
    // 점 찍어주는 함수
    private func formatWithDots(_ digits: String) -> String {
        var result = ""
        let chars = Array(digits)
        for i in 0..<chars.count {
            result.append(chars[i])
            if (i == 3 || i == 5) && i != chars.count - 1 {
                result.append(".")
            }
        }
        return result
    }
    
    private func parseDate(from digits: String) -> Date? {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyyMMdd"
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.timeZone = TimeZone(identifier: "Asia/Seoul")
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.isLenient = false
        return formatter.date(from: digits)
    }
    
    private func formatDateToString(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy.MM.dd"
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.timeZone = TimeZone(identifier: "Asia/Seoul")
        return formatter.string(from: date)
    }
}
