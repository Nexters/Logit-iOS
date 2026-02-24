//
//  ApplicationInfoView.swift
//  Logit
//
//  Created by 임재현 on 1/26/26.
//

import SwiftUI

struct ApplicationInfoView: View {
    @EnvironmentObject var viewModel: AddFlowViewModel
    @Environment(\.dismiss) var dismiss
    
    @State private var companyName: String = ""
    @State private var position: String = ""
    @State private var department: String = ""
    @State private var experienceLevel: String = ""
    
    var body: some View {
        VStack(spacing: 0) {
            CustomNavigationBar(
                title: "프로젝트 생성",
                showBackButton: true,
                onBackTapped: { dismiss() }
            )
            
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    PageIndicator(currentPage: 1, totalPages: 2)
                        .padding(.top, 16)
                    
                    HStack(alignment: .center, spacing: 0) {
                        Text("자기소개서 작성")
                            .typo(.bold_18)

                        Spacer()

                        Button {
                            viewModel.loadExampleData()
                        } label: {
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
                    .padding(.top, 13.25)

                    Text("지원하는 기업의 정보를 알려주세요")
                        .typo(.regular_15)
                        .foregroundColor(.gray300)
                        .padding(.top, 3)
                    
                    VStack(spacing: 20) {
                        InputFieldView(
                            title: "기업명",
                            placeholder: "예) 로짓 컴퍼니",
                            isRequired: true,
                            maxLength: 100,
                            text: $viewModel.companyName
                        )
                        
                        InputFieldView(
                            title: "직무명",
                            placeholder: "예) 프로덕트 디자이너",
                            isRequired: true,
                            maxLength: 100,
                            text: $viewModel.jobPosition
                        )
                        
                        InputFieldView(
                            title: "채용 공고",
                            placeholder: "주요 업무, 자격요건, 우대사항 등을 입력하세요",
                            isRequired: true,
                            maxLength: 3000,
                            largeHeight: 90,
                            text: $viewModel.recruitNotice
                        )

                        DueDateInputView(
                            title: "마감 날짜",
                            isRequired: false,
                            date: $viewModel.dueDateValue,
                            isAlwaysOpen: $viewModel.isAlwaysOpen
                        )

                        InputFieldView(
                            title: "기업 인재상",
                            placeholder: "기업의 인재상이나 핵심가치를 입력하세요",
                            isRequired: false,
                            maxLength: 1000,
                            text: $viewModel.companyTalent
                        )
                    }
                    .padding(.top, 24)
                    
                    Spacer()
                        .frame(minHeight: 46.75)
                    
                    Button {
                        viewModel.navigateToCoverLetterQuestions()
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
        !viewModel.companyName.isEmpty &&
        !viewModel.jobPosition.isEmpty &&
        !viewModel.recruitNotice.isEmpty
    }
}


struct PageIndicator: View {
    let currentPage: Int
    let totalPages: Int
    
    var body: some View {
        HStack(spacing: 0) {
            Text("\(currentPage)")
                .typo(.bold_14)
                .foregroundColor(.black)
            
            Text("/\(totalPages)")
                .typo(.regular_14_140)
                .foregroundColor(.gray)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 4)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(.primary20)
        )
    }
}

struct DueDateInputView: View {
    let title: String
    let isRequired: Bool
    @Binding var date: Date?
    @Binding var isAlwaysOpen: Bool

    @State private var dateText: String = ""
    @State private var isDateValid: Bool = true
    @FocusState private var isFocused: Bool

    init(
        title: String,
        isRequired: Bool = false,
        date: Binding<Date?>,
        isAlwaysOpen: Binding<Bool>
    ) {
        self.title = title
        self.isRequired = isRequired
        self._date = date
        self._isAlwaysOpen = isAlwaysOpen
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            // 타이틀
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

            // 날짜 입력 필드
            VStack(alignment: .leading, spacing: 4) {
                TextField("yyyy.mm.dd", text: $dateText)
                    .typo(.regular_15)
                    .foregroundColor(isAlwaysOpen ? .gray200 : .black)
                    .keyboardType(.numberPad)
                    .padding(.horizontal, 18)
                    .frame(height: 44)
                    .background(isAlwaysOpen ? Color.gray50 : Color.clear)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(
                                isAlwaysOpen ? Color.gray70 :
                                !isDateValid ? Color.alert :
                                isFocused ? Color.primary100 : Color.gray100,
                                lineWidth: 1
                            )
                    )
                    .cornerRadius(8)
                    .focused($isFocused)
                    .disabled(isAlwaysOpen)
                    .onChange(of: dateText) { oldValue, newValue in
                        handleDateInput(oldValue: oldValue, newValue: newValue)
                    }
                    .onChange(of: date) { _, newValue in
                        if let d = newValue {
                            dateText = formatDateToString(d)
                            isDateValid = true
                        }
                    }
                    .onAppear {
                        if let d = date {
                            dateText = formatDateToString(d)
                        }
                    }

                if !isDateValid {
                    Text("올바른 날짜를 입력해주세요")
                        .typo(.regular_12)
                        .foregroundColor(.alert)
                }
            }

            // 상시 토글
            Button {
                isAlwaysOpen.toggle()
                if isAlwaysOpen {
                    date = nil
                    dateText = ""
                    isDateValid = true
                }
            } label: {
                HStack(spacing: 8) {
                    Image(isAlwaysOpen ? "activated" : "deactivated")
                        .frame(size: 28)

                    Text("상시")
                        .typo(.regular_14_160)
                        .foregroundColor(.black)
                }
            }
        }
    }

    private func handleDateInput(oldValue: String, newValue: String) {
        let digits = newValue.filter { $0.isNumber }

        if digits.count > 8 {
            dateText = oldValue
            return
        }

        dateText = formatWithDots(digits)

        if digits.count == 8 {
            if let parsed = parseDate(from: digits) {
                date = parsed
                isDateValid = true
            } else {
                date = nil
                isDateValid = false
            }
        } else {
            isDateValid = true
            date = nil
        }
    }

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


struct InputFieldView: View {
    let title: String
    let placeholder: String
    let isRequired: Bool
    let maxLength: Int?
    var largeHeight: CGFloat? = nil
    var isDynamic: Bool = false
    @Binding var text: String
    @FocusState private var isFocused: Bool
    @State private var dynamicHeight: CGFloat

    init(
        title: String,
        placeholder: String,
        isRequired: Bool = false,
        maxLength: Int? = nil,
        largeHeight: CGFloat? = nil,
        isDynamic: Bool = false,
        text: Binding<String>
    ) {
        self.title = title
        self.placeholder = placeholder
        self.isRequired = isRequired
        self.maxLength = maxLength
        self.largeHeight = largeHeight
        self.isDynamic = isDynamic
        self._text = text
        self._dynamicHeight = State(initialValue: largeHeight ?? 74)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
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

                if let maxLength = maxLength {
                    HStack(spacing: 0) {
                        Text("\(text.count)")
                            .typo(.regular_15)
                            .foregroundColor(text.count > maxLength ? .alert : .black)

                        Text(" / \(maxLength)")
                            .typo(.regular_15)
                            .foregroundColor(.gray200)
                    }
                }
            }

            if let height = largeHeight {
                if isDynamic {
                    GeometryReader { geo in
                        ZStack(alignment: .topLeading) {
                            TextEditor(text: $text)
                                .font(.system(size: 15))
                                .padding(.horizontal, 14)
                                .padding(.vertical, 8)
                                .frame(height: dynamicHeight)
                                .scrollContentBackground(.hidden)
                                .background(Color.clear)
                                .focused($isFocused)
                                .onChange(of: text) { _, newValue in
                                    if let maxLength = maxLength, newValue.count > maxLength {
                                        text = String(newValue.prefix(maxLength))
                                    }
                                    let calculated = textContentHeight(text: newValue, width: geo.size.width)
                                    if calculated > 0 { dynamicHeight = max(height, calculated) }
                                }

                            if text.isEmpty {
                                Text(placeholder)
                                    .font(.system(size: 15))
                                    .foregroundColor(.gray100)
                                    .padding(.leading, 19)
                                    .padding(.top, 16)
                                    .allowsHitTesting(false)
                            }
                        }
                        .onChange(of: geo.size, initial: true) { _, size in
                            guard size.width > 0 else { return }
                            let calculated = textContentHeight(text: text, width: size.width)
                            if calculated > 0 { dynamicHeight = max(height, calculated) }
                        }
                    }
                    .frame(height: dynamicHeight)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(isFocused ? Color.primary100 : Color.gray100, lineWidth: 1)
                    )
                } else {
                    ZStack(alignment: .topLeading) {
                        TextEditor(text: $text)
                            .font(.system(size: 15))
                            .padding(.horizontal, 14)
                            .padding(.vertical, 8)
                            .frame(height: height)
                            .scrollContentBackground(.hidden)
                            .background(Color.clear)
                            .focused($isFocused)
                            .onChange(of: text) { oldValue, newValue in
                                if let maxLength = maxLength, newValue.count > maxLength {
                                    text = String(newValue.prefix(maxLength))
                                }
                            }

                        if text.isEmpty {
                            Text(placeholder)
                                .font(.system(size: 15))
                                .foregroundColor(.gray100)
                                .padding(.leading, 19)
                                .padding(.top, 16)
                                .allowsHitTesting(false)
                        }
                    }
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(
                                isFocused ? Color.primary100 : Color.gray100,
                                lineWidth: 1
                            )
                    )
                }
            } else {
                TextField(placeholder, text: $text)
                    .font(.system(size: 15))
                    .padding(.horizontal, 18)
                    .frame(height: 44)
                    .background(Color.clear)
                    .focused($isFocused)
                    .cornerRadius(8)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(
                                isFocused ? Color.primary100 : Color.gray100,
                                lineWidth: 1
                            )
                    )
                    .onChange(of: text) { oldValue, newValue in
                        if let maxLength = maxLength, newValue.count > maxLength {
                            text = String(newValue.prefix(maxLength))
                        }
                    }
            }
        }
    }

    private func textContentHeight(text: String, width: CGFloat) -> CGFloat {
        guard width > 0 else { return 0 }
        // 14px custom padding + ~5px UITextView internal padding = 19px per side
        let textWidth = max(1, width - 38)
        let font = UIFont.systemFont(ofSize: 15)
        let boundingRect = (text.isEmpty ? " " : text).boundingRect(
            with: CGSize(width: textWidth, height: .greatestFiniteMagnitude),
            options: [.usesLineFragmentOrigin, .usesFontLeading],
            attributes: [.font: font],
            context: nil
        )
        // 8px custom top/bottom + ~8px UITextView top/bottom inset = 32px total vertical
        return ceil(boundingRect.height) + 32
    }
}
