//
//  CoverLetterWorkspaceView.swift
//  Logit
//
//  Created by 임재현 on 1/29/26.
//

import SwiftUI

struct CoverLetterWorkspaceView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject private var viewModel: WorkspaceViewModel
    let questions: [QuestionItem]
    let projectId: String
    @State private var selectedQuestionIndex: Int = 0
    @State private var selectedView: ContentType = .chat
    @State private var showExperienceSelection = false
    
    @State private var hasLoadedData = false
    
    @State private var hasSelectedExperiences: Bool = false
    @State private var selectedExperienceIds: [String] = []
    @State private var currentChatViewModel: ChatMessagesViewModel?
    
    @State private var editingAnswer: String = ""
    @State private var originalAnswer: String = ""
    @State private var showToast: Bool = false
    @State private var showEditQuestions: Bool = false
    @State private var showQuestionDetail: Bool = false
    @State private var editingQuestionText: String = ""
    @State private var editingMaxLength: String = ""
    @State private var overlayEditorHeight: CGFloat = 44
    
    private var currentQuestion: QuestionResponse? {
        guard !viewModel.questionList.isEmpty,
              selectedQuestionIndex < viewModel.questionList.count else {
            return nil
        }
        return viewModel.questionList[selectedQuestionIndex]
    }

    private func dismissQuestionDetail() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        withAnimation(.easeInOut(duration: 0.2)) {
            showQuestionDetail = false
        }
        // 애니메이션 완료 후 저장 — 동시에 상태 변경이 일어나면 번쩍임 발생
        DispatchQueue.main.asyncAfter(deadline: .now()) {
            saveQuestionEdits()
        }
    }

    private func saveQuestionEdits() {
        guard let question = currentQuestion, !editingQuestionText.isEmpty else { return }
        Task {
            await viewModel.saveQuestions(
                editedItems: [EditableQuestionItem(
                    questionId: question.id,
                    title: editingQuestionText,
                    characterLimit: editingMaxLength
                )],
                deletedQuestionIds: []
            )
        }
    }

    /// TextEditor 콘텐츠 높이를 텍스트 기준으로 계산
    private func overlayEditorContentHeight(text: String) -> CGFloat {
        // HStack 가용 너비: 화면 너비 - 좌우 패딩(40) - spacing(12) - chevron 이미지(12) - UITextView 내부 패딩(10)
        let contentWidth = max(1, UIScreen.main.bounds.width - 74)
        let font = UIFont.systemFont(ofSize: 16, weight: .bold)
        let rect = (text.isEmpty ? " " : text).boundingRect(
            with: CGSize(width: contentWidth, height: .greatestFiniteMagnitude),
            options: [.usesLineFragmentOrigin, .usesFontLeading],
            attributes: [.font: font],
            context: nil
        )
        // UITextView 내부 상하 패딩 ~8pt씩 = 16pt, 최소 44pt
        return min(max(44, ceil(rect.height) + 16), 220)
    }

    @ViewBuilder
    private var questionDetailOverlay: some View {
        VStack(spacing: 0) {
            // 상단 흰색 영역: 네비게이션 + 탭바 + 질문 편집 + 글자수
            VStack(spacing: 0) {
                CustomNavigationBar(
                    title: viewModel.navigationTitle,
                    showBackButton: true,
                    onBackTapped: { dismiss() }
                )

                if !viewModel.questionList.isEmpty {
                    QuestionTabBar(
                        questionCount: viewModel.questionList.count,
                        selectedIndex: $selectedQuestionIndex,
                        onAddTapped: { showEditQuestions = true }
                    )
                }

                // 질문 편집 행
                HStack(alignment: .top, spacing: 12) {
                    TextEditor(text: $editingQuestionText)
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.gray400)
                        .scrollContentBackground(.hidden)
                        .background(Color.clear)
                        .frame(height: overlayEditorHeight)
                        .onChange(of: editingQuestionText) { _, newValue in
                            let h = overlayEditorContentHeight(text: newValue)
                            if abs(h - overlayEditorHeight) > 1 {
                                overlayEditorHeight = h
                            }
                        }

                    Button {
                        dismissQuestionDetail()
                    } label: {
                        Image(systemName: "chevron.up")
                            .resizable()
                            .frame(width: 12, height: 8)
                            .foregroundColor(.gray400)
                    }
                    .padding(.top, 4)
                }
                .padding(.horizontal, 20)
                .padding(.top, 12)
                .padding(.bottom, 8)

                Divider()
                    .padding(.horizontal, 20)

                // 글자수 편집 행
                HStack(spacing: 4) {
                    TextField("", text: $editingMaxLength)
                        .keyboardType(.numberPad)
                        .font(.system(size: 15))
                        .foregroundColor(.gray400)
                        .fixedSize()

                    Text("자")
                        .font(.system(size: 15))
                        .foregroundColor(.gray400)

                    Spacer()
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 10)
            }
            .background(Color.white)

            // 하단 dimmed 영역 — 탭하면 저장 후 닫기
            Color.black.opacity(0.4)
                .ignoresSafeArea(edges: .bottom)
                .onTapGesture {
                    dismissQuestionDetail()
                }
        }
        .transition(.opacity)
    }
    
    enum ContentType {
        case chat, coverLetter
    }
    
    init(projectId: String, questions: [QuestionItem]) {
        self.projectId = projectId
        self.questions = questions
        _viewModel = StateObject(wrappedValue: WorkspaceViewModel(projectId: projectId))
    }
    
    var body: some View {
        ZStack {
            Color.white.ignoresSafeArea()

            VStack(spacing: 0) {
                CustomNavigationBar(
                    title: viewModel.navigationTitle,
                    showBackButton: true,
                    onBackTapped: { dismiss() }
                )
                
                // 문항 탭 바
                if !viewModel.questionList.isEmpty {
                    QuestionTabBar(
                        questionCount: viewModel.questionList.count,
                        selectedIndex: $selectedQuestionIndex,
                        onAddTapped: { showEditQuestions = true }
                    )
                    .onChange(of: selectedQuestionIndex) { oldIndex, newIndex in
                        print("========== 문항 전환 ==========")
                        print("선택된 Index: \(newIndex)")

                        if newIndex < viewModel.questionList.count {
                            let question = viewModel.questionList[newIndex]
                            print("문항 ID: \(question.id)")
                            print("문항 내용: \(question.question)")
                        } else {
                            print(" Index out of range")
                        }
                        print("==============================")

                        if selectedView == .coverLetter, newIndex < viewModel.questionList.count {
                            let questionId = viewModel.questionList[newIndex].id
                            Task { await viewModel.fetchQuestionDetail(questionId: questionId) }
                        }

                        if showQuestionDetail {
                            // 탭 전환 시 이전 문항 저장
                            if oldIndex < viewModel.questionList.count, !editingQuestionText.isEmpty {
                                let oldQ = viewModel.questionList[oldIndex]
                                Task {
                                    await viewModel.saveQuestions(
                                        editedItems: [EditableQuestionItem(
                                            questionId: oldQ.id,
                                            title: editingQuestionText,
                                            characterLimit: editingMaxLength
                                        )],
                                        deletedQuestionIds: []
                                    )
                                }
                            }
                            // 새 문항 편집 데이터 로드
                            if newIndex < viewModel.questionList.count {
                                let q = viewModel.questionList[newIndex]
                                editingQuestionText = q.question
                                editingMaxLength = q.maxLength.map { String($0) } ?? ""
                            }
                        }
                    }
                } else if viewModel.isLoading {
                    ProgressView()
                        .padding(.vertical, 12)
                } else {
                    QuestionTabBar(
                        questionCount: questions.count,
                        selectedIndex: $selectedQuestionIndex,
                        onAddTapped: { showEditQuestions = true }
                    )
                }
                
                if let question = currentQuestion {
                    Button {
                        editingQuestionText = question.question
                        editingMaxLength = question.maxLength.map { String($0) } ?? ""
                        overlayEditorHeight = overlayEditorContentHeight(text: question.question)
                        withAnimation(.easeInOut(duration: 0.2)) {
                            showQuestionDetail = true
                        }
                    } label: {
                        HStack(spacing: 12) {
                            Text(question.question)
                                .typo(.bold_16)
                                .foregroundColor(.gray400)
                                .lineLimit(1)

                            Spacer()

                            Image(systemName: "chevron.down")
                                .resizable()
                                .frame(width: 12, height: 8)
                                .foregroundColor(.gray400)
                        }
                    }
                    .buttonStyle(PlainButtonStyle())
                    .padding(.horizontal, 20)
                    .padding(.vertical, 12)
                    .background(Color.white)
                }
                
                // 채팅 / 자기소개서 선택 버튼
                HStack(spacing: 8) {
                    IconTextButton(
                        title: "채팅",
                        isSelected: selectedView == .chat,
                        action: { selectedView = .chat }
                    )

                    IconTextButton(
                        title: "자기소개서",
                        isSelected: selectedView == .coverLetter,
                        action: {
                            selectedView = .coverLetter
                            if let question = currentQuestion {
                                Task { await viewModel.fetchQuestionDetail(questionId: question.id) }
                            }
                        }
                    )
                    
                    Spacer()
                }
                .padding(.horizontal, 20)
                .padding(.top, 0)
                
                // 채팅 탭: ScrollView
                if selectedView == .chat {
                    ScrollView {
                        VStack(spacing: 0) {
                            if let question = currentQuestion {
                                ChatMessagesView(
                                    projectId: projectId,
                                    questionId: question.id,
                                    hasSelectedExperiences: $hasSelectedExperiences,
                                    selectedExperienceIds: $selectedExperienceIds,
                                    viewModelRef: $currentChatViewModel,
                                    onUpdateCoverLetter: {
                                        Task {
                                            await viewModel.fetchQuestionList()
                                            if let question = currentQuestion {
                                                await viewModel.fetchQuestionDetail(questionId: question.id)
                                            }
                                            withAnimation(.spring()) { showToast = true }
                                            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                                                withAnimation { showToast = false }
                                            }
                                        }
                                    },
                                    onShowExperienceSelection: {
                                        showExperienceSelection = true
                                    },
                                    onGenerateDraft: {}
                                )
                                .id(question.id)
                            }
                        }
                    }
                    .scrollToMinDistance(minDisntance: 32)
                } else {
                    // 자소서 탭: TextEditor가 남은 공간 전체 차지
                    if let question = currentQuestion {
                        if viewModel.isLoadingDetail {
                            ProgressView()
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                        } else {
                            CoverLetterContentView(
                                question: question.question,
                                editingAnswer: $editingAnswer,
                                maxLength: question.maxLength,
                                isCompleted: viewModel.currentQuestionDetail?.isCompleted ?? false,
                                onComplete: {
                                    Task {
                                        await viewModel.saveAnswer(questionId: question.id, answer: editingAnswer)
                                        await viewModel.markQuestionComplete(questionId: question.id)
                                    }
                                }
                            )
                            .id(question.id)
                        }
                    }
                }
                
                // 하단 입력 영역 (탭에 따라 분기)
                if selectedView == .chat {
                    ChatInputBar(
                        hasSelectedExperiences: hasSelectedExperiences,
                        onSend: { message in
                            print("전송: \(message)")
                            print("프로젝트 ID: \(projectId)")

                            guard let chatViewModel = currentChatViewModel else {
                                print(" ChatViewModel이 아직 초기화되지 않았습니다")
                                return
                            }

                            Task {
                                await chatViewModel.sendMessage(
                                    content: message,
                                    experienceIds: selectedExperienceIds
                                )
                            }
                        },
                        onAttachmentTapped: {
                            showExperienceSelection = true
                        }
                    )
                } else {
                    // 자기소개서 탭 저장하기 버튼
                    let isChanged = editingAnswer != originalAnswer
                    let isOverLimit = currentQuestion.flatMap { $0.maxLength }.map { editingAnswer.count > $0 } ?? false
                    Button {
                        guard let question = currentQuestion else { return }
                        Task {
                            await viewModel.saveAnswer(questionId: question.id, answer: editingAnswer)
                        }
                    } label: {
                        Text("저장하기")
                            .typo(.bold_16)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(isChanged && !isOverLimit ? Color.primary100 : Color.gray100)
                            .cornerRadius(12)
                    }
                    .disabled(!isChanged || isOverLimit)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 10)
                    .background(Color.white)
                }
            }
            
            // 질문 상세/편집 오버레이
            if showQuestionDetail {
                questionDetailOverlay
            }

            //  토스트 오버레이
            if showToast {
                VStack {
                    Spacer()
                    
                    ToastView(
                        message: "자소서가 업데이트 됐어요",
                        actionTitle: "바로가기",
                        onAction: {
                            // 자기소개서 탭으로 전환
                            selectedView = .coverLetter
                            
                            // 토스트 숨김
                            withAnimation {
                                showToast = false
                            }
                        }
                    )
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                    .padding(.bottom, 74)
                }
            }
        }
        .onAppear {
            guard !hasLoadedData else {
                print(" 이미 데이터 로드됨, 스킵")
                return
            }
            
            hasLoadedData = true
            
            Task {
                async let projectDetail: () = viewModel.fetchProjectDetail()
                async let questionList: () = viewModel.fetchQuestionList()
                
                await projectDetail
                await questionList
                
                print("========== 데이터 할당 체크 ==========")
                print("프로젝트 ID: \(projectId)")
                print("문항 목록 개수: \(viewModel.questionList.count)")
                
                if let question = currentQuestion {
                    print("현재 선택된 문항:")
                    print("  - Index: \(selectedQuestionIndex)")
                    print("  - ID: \(question.id)")
                    print("  - 문항: \(question.question)")
                    print("  - max_length: \(question.maxLength ?? 0)")
                } else {
                    print(" currentQuestion이 nil입니다")
                }
                print("====================================")
            }
        }
        .onChange(of: viewModel.currentQuestionDetail) { _, detail in
            let answer = detail?.answer ?? ""
            editingAnswer = answer
            originalAnswer = answer
        }
        .dismissKeyboardOnTap()
        .navigationBarHidden(true)
        .fullScreenCover(isPresented: $showEditQuestions) {
            EditQuestionsView(viewModel: viewModel)
        }
        .sheet(isPresented: $showExperienceSelection) {
            if let question = currentQuestion {
                ExperienceSelectionSheet(
                    isPresented: $showExperienceSelection,
                    questionId: question.id,
                    initialSelectedIds: selectedExperienceIds,
                    onConfirm: { selectedIds in
                        selectedExperienceIds = selectedIds
                        hasSelectedExperiences = !selectedIds.isEmpty
                        
                        print("경험 선택 완료: \(selectedIds)")
                    }
                )
            }
        }
    }
}

struct QuestionTabBar: View {
    let questionCount: Int
    @Binding var selectedIndex: Int
    var onAddTapped: () -> Void = {}
    var showAddButton: Bool = true

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(0..<questionCount, id: \.self) { index in
                    QuestionTabButton(
                        number: index + 1,
                        isSelected: selectedIndex == index,
                        action: { selectedIndex = index }
                    )
                }

                if showAddButton {
                    Button(action: onAddTapped) {
                        Image(systemName: "plus")
                            .font(.system(size: 14))
                            .foregroundColor(.gray300)
                            .frame(width: 34, height: 34)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color.gray100, lineWidth: 1)
                            )
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
        }
    }
}


struct QuestionTabButton: View {
    let number: Int
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text("Q\(number)")
                .typo(isSelected ? .bold_16 : .regular_16_140)
                .foregroundColor(isSelected ? .primary100 : .gray300)
                .padding(.horizontal, 14)
                .padding(.vertical, 6)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(isSelected ? Color.primary100 : Color.gray100, lineWidth: 1)
                )
        }
        .buttonStyle(PlainButtonStyle())
    }
}


struct IconTextButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 0) {
                Text(title)
                    .typo(.medium_15)
                    .foregroundColor(isSelected ? .gray400 : .gray200)
                    .padding(.vertical, 10)
                
                Rectangle()
                    .fill(isSelected ? Color.gray400 : Color.clear)
                    .frame(height: 2)
            }
            .fixedSize(horizontal: true, vertical: false)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct EmptyWorkspaceView: View {
    let hasSelectedExperiences: Bool  //  경험 선택 여부
    let onSelectExperience: () -> Void  // 경험 선택 버튼
    let onGenerateDraft: () -> Void  // 초안 생성 버튼
    
    var body: some View {
        VStack(spacing: 0) {
            
            Image("app_status_empty2")
                .resizable()
                .scaledToFit()
                .frame(width: 80.adjustedLayout, height: 80.adjustedLayout)
            
            Text(descriptionText)
                .typo(.medium_15)
                .foregroundStyle(.gray100)
                .padding(.top, 16.adjustedLayout)
            
            Button {
                if hasSelectedExperiences {
                    onGenerateDraft()  //  초안 생성
                } else {
                    onSelectExperience()  // 경험 선택
                }
            } label: {
                Text(buttonTitle)
                    .typo(.medium_15)
                    .foregroundStyle(hasSelectedExperiences ? .white: .primary200)
                    .padding(.horizontal, 24.adjustedLayout)
                    .padding(.vertical, 7.5.adjustedLayout)
                    .background(hasSelectedExperiences ? .primary100 : .primary50)
                    .cornerRadius(8.adjustedLayout)
            }
            .padding(.top, 17.adjustedLayout)
            
        }
        .offset(y: -10.adjustedLayout)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(.vertical, 105.adjustedLayout)
        .background(.white)
        .cornerRadius(16.adjustedLayout)
        .padding(.horizontal, 20.adjustedLayout)
    }
    
    //  버튼 타이틀
    private var buttonTitle: String {
        hasSelectedExperiences ? "초안 생성하기" : "경험을 선택해주세요"
    }
    
    // 설명 텍스트 (옵션)
    private var descriptionText: String {
        hasSelectedExperiences
            ? "선택한 경험으로 초안을 생성할게요"
            : "경험을 선택하면 초안이 생성돼요"
    }
}

struct ChatInputBar: View {
    @State private var messageText: String = ""
    let hasSelectedExperiences: Bool
    let onSend: (String) -> Void
    let onAttachmentTapped: () -> Void
    
    var body: some View {
        HStack(spacing: 6) {
            // 동그란 버튼
            Button {
                // TODO: 추가 기능 (사진, 파일 등)
                onAttachmentTapped()

            } label: {
                ZStack {
                    Circle()
                        .fill(Color.gray50)
                        .frame(size: 44)
                    
                    Image(hasSelectedExperiences ? "Union_selected" : "Union")
                        .resizable()
                        .frame(width: 18.12, height: 15)
                        .foregroundColor(.primary400)
                }
            }
            
            // 캡슐 모양 채팅 입력창
            HStack(spacing: 8) {
                TextField("메시지를 입력하세요", text: $messageText)
                    .font(.system(size: 15))
                    .padding(.leading, 16)
                
                Button {
                    onSend(messageText)
                    messageText = ""
                    UIApplication.shared.sendAction(
                            #selector(UIResponder.resignFirstResponder),
                            to: nil,
                            from: nil,
                            for: nil
                        )
                } label: {
                    ZStack {
                        Circle()
                            .fill(messageText.isEmpty ? Color.gray50 : Color.primary20)
                            .frame(width: 32, height: 32)
                        
                        Image(systemName: "paperplane.fill")
                            .resizable()
                            .frame(width: 16, height: 16)
                            .foregroundColor(messageText.isEmpty ? .gray200 : .primary100)
                    }
                    .padding(.trailing, 8)
                }
                .disabled(messageText.isEmpty)
            }
            .frame(height: 44)
            .background(Color.white)
            .overlay(
                Capsule()
                    .stroke(Color.gray100, lineWidth: 1)
            )
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 10)
        .background(Color.white)
    }
}


// 채팅 메시지 리스트 뷰
struct ChatMessagesView: View {
    let projectId: String
    let questionId: String
    @Binding var hasSelectedExperiences: Bool
    @Binding var selectedExperienceIds: [String]
    let onUpdateCoverLetter: () -> Void
    let onShowExperienceSelection: () -> Void
    let onGenerateDraft: () -> Void
    
    @StateObject private var viewModel: ChatMessagesViewModel
    @Binding var viewModelRef: ChatMessagesViewModel?
    @State private var anchorMessageId: String? = nil
    
    init(
        projectId: String,
        questionId: String,
        hasSelectedExperiences: Binding<Bool>,
        selectedExperienceIds: Binding<[String]>,
        viewModelRef: Binding<ChatMessagesViewModel?>,
        onUpdateCoverLetter: @escaping () -> Void,
        onShowExperienceSelection: @escaping () -> Void,
        onGenerateDraft: @escaping () -> Void
    ) {
        self.projectId = projectId
        self.questionId = questionId
        self._hasSelectedExperiences = hasSelectedExperiences
        self._selectedExperienceIds = selectedExperienceIds
        self._viewModelRef = viewModelRef
        self.onUpdateCoverLetter = onUpdateCoverLetter
        self.onShowExperienceSelection = onShowExperienceSelection
        self.onGenerateDraft = onGenerateDraft
        _viewModel = StateObject(wrappedValue: ChatMessagesViewModel(
            projectId: projectId,
            questionId: questionId
        ))
    }
    
    //  마지막 draft 메시지 ID
    private var lastDraftId: String? {
        viewModel.messages
            .filter { $0.role == .assistant && $0.isDraft }
            .last?.id
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            if viewModel.isLoading && viewModel.messages.isEmpty {
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                
            } else if let error = viewModel.errorMessage {
                // 에러 표시
                VStack(spacing: 12) {
                    Text(error)
                        .typo(.regular_14_160)
                        .foregroundColor(.gray200)
                    
                    Button("다시 시도") {
                        Task {
                            await viewModel.fetchChatHistory()
                        }
                    }
                    .typo(.medium_13)
                    .foregroundColor(.primary100)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                
            } else if viewModel.messages.isEmpty {
                // 빈 화면 (경험 선택 여부에 따라 버튼 변경)
                EmptyWorkspaceView(
                    hasSelectedExperiences: hasSelectedExperiences,
                    onSelectExperience: {
                        onShowExperienceSelection()
                    },
                    onGenerateDraft: {
                        Task {
                            await viewModel.sendMessage(
                                content: "선택한 경험을 바탕으로 자기소개서 초안을 작성해줘",
                                experienceIds: selectedExperienceIds
                            )
                        }
                    }
                )
                
            } else {
                // ScrollViewReader로 자동 스크롤
                ScrollViewReader { proxy in
                    VStack(alignment: .leading, spacing: 16) {
                        // 더보기 버튼 (상단 - 오래된 메시지 불러오기)
                        if viewModel.hasMore {
                            Button {
                                Task {
                                    anchorMessageId = viewModel.messages.first?.id
                                    await viewModel.loadMoreMessages()
                                }
                            } label: {
                                if viewModel.isLoading {
                                    ProgressView()
                                } else {
                                    Text("이전 메시지 보기")
                                        .typo(.regular_14_160)
                                        .foregroundColor(.gray200)
                                }
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                        }

                        // 메시지 리스트
                        ForEach(viewModel.messages) { message in
                            ChatBubble(
                                message: message.content,
                                isUser: message.role == .user,
                                isDraft: message.isDraft,
                                showUpdateButton: message.role == .assistant
                                    && message.isDraft
                                    && message.id == lastDraftId,  //  마지막 draft만
                                isAnimated: false,
                                chatId: message.id,
                                onUpdateCoverLetter: {  chatId in
                                    Task {
                                        await viewModel.updateAnswer(chatId: chatId)

                                        // 성공 후 자기소개서 탭으로 전환
                                        onUpdateCoverLetter()
                                    }
                                }
                            )
                            .id(message.id)  //  스크롤용 ID
                        }

                        // 스트리밍 중일 때 실시간 ChatBubble
                        if viewModel.isStreaming {
                            ChatBubble(
                                message: viewModel.streamingMessage,
                                isUser: false,
                                isDraft: true,  // 의미상: 아직 완성 안 된 초안
                                showUpdateButton: false,  // 스트리밍 중에는 버튼 안 보임
                                isAnimated: true,
                                chatId: nil,
                                onUpdateCoverLetter: nil
                            )
                            .id("streaming")  //  스트리밍용 고정 ID
                        }

                        // 스크롤 앵커 (투명한 뷰)
                        Color.clear
                            .frame(height: 1)
                            .id("bottom")
                    }
                    //  메시지 변경 시 자동 스크롤
                    .onChange(of: viewModel.messages.count) { _ in
                        if let anchor = anchorMessageId {
                            // 이전 메시지 로드 후 → 기존 첫 메시지 위치 유지
                            proxy.scrollTo(anchor, anchor: .top)
                            anchorMessageId = nil
                        } else {
                            withAnimation {
                                proxy.scrollTo("bottom", anchor: .bottom)
                            }
                        }
                    }
                    // 스트리밍 중 실시간 스크롤
                    .onChange(of: viewModel.streamingMessage) { newValue in
                        if !newValue.isEmpty {
                            withAnimation {
                                proxy.scrollTo("bottom", anchor: .bottom)
                            }
                        }
                    }
                    //  스트리밍 시작 시 스크롤
                    .onChange(of: viewModel.isStreaming) { isStreaming in
                        if isStreaming {
                            withAnimation {
                                proxy.scrollTo("bottom", anchor: .bottom)
                            }
                        }
                    }
                }
            }
        }
        .frame(maxHeight: .infinity)
        .padding(.horizontal, viewModel.messages.isEmpty ? 0 : 20)
        .padding(.vertical, viewModel.messages.isEmpty ? 0 : 16)
        .task {
            await viewModel.fetchChatHistory()
        }
        .onChange(of: viewModel.experienceIds) { newValue in
            hasSelectedExperiences = !newValue.isEmpty
            selectedExperienceIds = newValue
        }
        .onAppear {
            viewModelRef = viewModel
        }
    }
}

// 채팅 버블 컴포넌트
struct ChatBubble: View {
    let message: String
    let isUser: Bool
    let isDraft: Bool
    let showUpdateButton: Bool
    let isAnimated: Bool
    let chatId: String?
    @State private var displayedText: String = ""
    @State private var isTypingComplete: Bool = false
    @State private var rotationAngle: Double = 0
    let onUpdateCoverLetter: ((String) -> Void)?
    
    var body: some View {
        HStack(alignment: .top, spacing: 0) {
            if isUser {
                Spacer()
                
                // 사용자 메시지
                Text(message)
                    .typo(.regular_14_160)
                    .foregroundColor(.black)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .background(Color.primary20)
                    .cornerRadius(16)
            } else {
                VStack(alignment: .leading, spacing: 8) {
                    Image("chatting_logo")
                        .resizable()
                        .frame(size: 24)
                        .rotationEffect(.degrees(isAnimated && displayedText.isEmpty ? rotationAngle : 0))
                    
                    VStack(alignment: .leading, spacing: 12) {
                        // 로딩 상태 분기
                        if isAnimated && displayedText.isEmpty {
                            // 스트리밍 대기 중
                            Text("응답 기다리는 중...")
                                .typo(.regular_14_160)
                                .foregroundColor(.gray200)
                                .padding(.vertical, 10)
                        } else {
                            // 봇 메시지
                            Text(displayedText)
                                .typo(.regular_14_160)
                                .foregroundColor(.black)
                                .padding(.vertical, 10)
                                .background(Color.clear)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        
                        // 자기소개서 업데이트 버튼
                        if showUpdateButton && isTypingComplete && isDraft {
                            Button {
                                if let chatId = chatId {
                                    print("자기소개서 업데이트 버튼 클릭")
                                    print("  - chatId: \(chatId)")
                                    onUpdateCoverLetter?(chatId)
                                }
                            } label: {
                                HStack(spacing: 6) {
                                    Image("autorenew")
                                        .frame(size: 16)
                                    
                                    Text("자기소개서 업데이트")
                                        .typo(.medium_13)
                                        .foregroundStyle(.primary600)
                                }
                                .padding(.horizontal, 12)
                                .padding(.vertical, 8)
                                .background(Color.clear)
                                .cornerRadius(8)
                            }
                            .transition(.opacity.combined(with: .scale))
                        }
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .onAppear {
            if !isUser {
                if isAnimated {
                    //  실시간 스트리밍 → 회전 애니메이션 시작
                    startRotation()
                } else {
                    // 히스토리는 바로 표시
                    displayedText = message
                    isTypingComplete = true
                }
            } else {
                displayedText = message
                isTypingComplete = true
            }
        }
        .onChange(of: message) { newValue in
            if isAnimated && !isUser {
                //  스트리밍 시작되면 텍스트 업데이트 + 회전 중지
                displayedText = newValue
                
                // 첫 글자 들어오면 타이핑 애니메이션 시작
                if !newValue.isEmpty && displayedText.count == newValue.count {
                    isTypingComplete = true  // 회전 애니메이션 중지
                }
            }
        }
    }
    
    // 로고 회전 애니메이션
    private func startRotation() {
        withAnimation(.linear(duration: 1.0).repeatForever(autoreverses: false)) {
            rotationAngle = 360
        }
    }
}

struct CoverLetterContentView: View {
    let question: String
    @Binding var editingAnswer: String
    let maxLength: Int?
    let isCompleted: Bool
    let onComplete: () -> Void

    @State private var showLimitToast = false

    private var isOverLimit: Bool {
        guard let max = maxLength else { return false }
        return editingAnswer.count > max
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // 상단: 글자수 + 작성완료 버튼
            HStack(alignment: .center) {
                Text("\(String(editingAnswer.count)) / \(String(maxLength ?? 0))")
                    .typo(.regular_14_160)
                    .foregroundColor(isOverLimit ? .red : .gray300)

                Spacer()

                Button(action: onComplete) {
                    HStack(spacing: 6) {
                        Image(systemName: "checkmark.circle.fill")
                            .frame(size: 10)
                            .foregroundColor(isCompleted && !isOverLimit ? .primary100 : .gray200)
                        Text("작성완료")
                            .typo(.bold_12)
                            .foregroundColor(isCompleted && !isOverLimit ? .primary100 : .gray200)
                    }
                    .padding(.horizontal, 14)
                    .padding(.vertical, 5)
                    .background(Color.clear)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(isCompleted && !isOverLimit ? Color.primary100 : Color.gray100, lineWidth: 1)
                    )
                }
                .disabled(isOverLimit)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 12)

            Divider()
                .padding(.horizontal, 20)

            // 본문 편집 영역
            ZStack(alignment: .topLeading) {
                TextEditor(text: $editingAnswer)
                    .typo(.regular_14_160)
                    .foregroundColor(.black)
                    .scrollContentBackground(.hidden)
                    .background(Color.clear)
                    .padding(.horizontal, 16)
                    .padding(.top, 8)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)

                if editingAnswer.isEmpty {
                    Text("아직 작성된 자기소개서가 없어요.\n경험을 선택하고 초안을 생성해보세요.")
                        .typo(.regular_14_160)
                        .foregroundColor(.gray200)
                        .padding(.horizontal, 20)
                        .padding(.top, 16)
                        .allowsHitTesting(false)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.white)
        .overlay(alignment: .bottom) {
            if showLimitToast {
                ToastView(message: "글자수 제한에 도달했어요")
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                    .padding(.bottom, 20)
            }
        }
        .onChange(of: editingAnswer) { _, newValue in
            guard let max = maxLength else { return }
            if newValue.count > max && !showLimitToast {
                withAnimation(.spring()) { showLimitToast = true }
                Task {
                    try? await Task.sleep(for: .seconds(2))
                    withAnimation { showLimitToast = false }
                }
            }
        }
    }
}

struct ToastView: View {
    let message: String
    var actionTitle: String? = nil
    var onAction: (() -> Void)? = nil

    var body: some View {
        HStack(spacing: 12) {
            // 체크 아이콘
            ZStack {
                Circle()
                    .fill(Color.primary100)
                    .frame(width: 24, height: 24)

                Image(systemName: "checkmark")
                    .resizable()
                    .frame(width: 12, height: 12)
                    .foregroundColor(.white)
                    .fontWeight(.semibold)
            }

            // 메시지
            Text(message)
                .typo(.regular_16_150)
                .foregroundColor(.white)
                .lineLimit(1)
                .minimumScaleFactor(0.8)

            Spacer(minLength: 8)

            // 바로가기 버튼 (optional)
            if let actionTitle, let onAction {
                Button {
                    onAction()
                } label: {
                    Text(actionTitle)
                        .typo(.regular_14_160)
                        .foregroundColor(.white)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(Color.primary500)
                        .clipShape(Capsule())
                }
                .fixedSize()
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.primary400)
        )
        .padding(.horizontal, 20)
    }
}

