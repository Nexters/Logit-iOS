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
    
    @State private var showToast: Bool = false
    
    private var currentQuestion: QuestionResponse? {
        guard !viewModel.questionList.isEmpty,
              selectedQuestionIndex < viewModel.questionList.count else {
            return nil
        }
        return viewModel.questionList[selectedQuestionIndex]
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
                        selectedIndex: $selectedQuestionIndex
                    )
                    .onChange(of: selectedQuestionIndex) { newIndex in
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
                    }
                } else if viewModel.isLoading {
                    ProgressView()
                        .padding(.vertical, 12)
                } else {
                    QuestionTabBar(
                        questionCount: questions.count,
                        selectedIndex: $selectedQuestionIndex
                    )
                }
                
                // 채팅 / 자기소개서 선택 버튼
                HStack(spacing: 8) {
                    IconTextButton(
                        selectedIconName: "chat_selected",
                        unselectedIconName: "chat_unselected",
                        title: "채팅",
                        isSelected: selectedView == .chat,
                        action: { selectedView = .chat }
                    )
                    
                    IconTextButton(
                        selectedIconName: "coverLetter_selected",
                        unselectedIconName: "coverLetter_unselected",
                        title: "자기소개서",
                        isSelected: selectedView == .coverLetter,
                        action: { selectedView = .coverLetter }
                    )
                    
                    Spacer()
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)
                
                // 채팅 스크롤 영역
                ScrollView {
                    VStack(spacing: 0) {
                        if selectedView == .chat {
                            if let question = currentQuestion {
                                ChatMessagesView(
                                    projectId: projectId,
                                    questionId: question.id,
                                    hasSelectedExperiences: $hasSelectedExperiences,
                                    selectedExperienceIds: $selectedExperienceIds,
                                    viewModelRef: $currentChatViewModel,
                                    onUpdateCoverLetter: {
                                        // 업데이트 성공 처리
                                        Task {
                                            // questionList 다시 fetch
                                            await viewModel.fetchQuestionList()
                                            
                                            //  토스트 표시
                                            withAnimation(.spring()) {
                                                showToast = true
                                            }
                                            
                                            //  3초 후 자동 숨김
                                            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                                                withAnimation {
                                                    showToast = false
                                                }
                                            }
                                        }
                                    },
                                    onShowExperienceSelection: {
                                        showExperienceSelection = true
                                    },
                                    onGenerateDraft: {}
                                )
                            }
                        } else {
                            // 자소서 뷰
                            if let question = currentQuestion {
                                CoverLetterContentView(
                                    question: question.question,
                                    answer: question.answer
                                )
                            }
                        }
                    }
                }
                .scrollToMinDistance(minDisntance: 32)
                
                // 채팅 입력창
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
        .dismissKeyboardOnTap()
        .navigationBarHidden(true)
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
            VStack(spacing: 0) {
                Text("Q\(number)")
                    .typo(.semibold_16)
                    .foregroundColor(isSelected ? .primary100 : .gray400)
                    .padding(.horizontal, 15)
                    .padding(.vertical, 11)
                
                // 선택 인디케이터
                if isSelected {
                    Rectangle()
                        .fill(Color.primary100)
                        .frame(height: 2)
                } else {
                    Rectangle()
                        .fill(Color.clear)
                        .frame(height: 2)
                }
            }
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct IconTextButton: View {
    let selectedIconName: String
    let unselectedIconName: String
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 10) {
                Image(isSelected ? selectedIconName : unselectedIconName)
                    .resizable()
                    .frame(width: 15, height: 15)
                
                Text(title)
                    .typo(.medium_15)
                    .foregroundColor(isSelected ? .white : .gray200)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(isSelected ? Color.gray400 : Color.gray50)
            .cornerRadius(8)
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
                        
                        // 더보기 버튼
                        if viewModel.hasMore {
                            Button {
                                Task {
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
                    }
                    //  메시지 변경 시 자동 스크롤
                    .onChange(of: viewModel.messages.count) { _ in
                        withAnimation {
                            proxy.scrollTo("bottom", anchor: .bottom)
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
    let answer: String?
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                // 제목
                Text(question)
                    .typo(.semibold_18)
                    .foregroundColor(.black)
                    .padding(.top, 20)
                
                // 자기소개서 본문
                if let answer = answer, !answer.isEmpty {
                    VStack(alignment: .leading, spacing: 16) {
                        // answer를 단락별로 나눠서 표시
                        ForEach(answer.components(separatedBy: "\n\n"), id: \.self) { paragraph in
                            if !paragraph.isEmpty {
                                Text(paragraph)
                                    .typo(.regular_14_160)
                                    .foregroundColor(.black)
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 20)
                    .background(Color.gray20)
                    .cornerRadius(12)
                } else {
                    //  answer가 없을 때
                    VStack(spacing: 12) {
                        Text("아직 작성된 자기소개서가 없습니다.")
                            .typo(.regular_14_160)
                            .foregroundColor(.gray200)
                        
                        Text("채팅에서 초안을 생성하고 업데이트해보세요.")
                            .typo(.regular_12)
                            .foregroundColor(.gray300)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 60)
                }
                
                Spacer()
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 40)
        }
        .background(Color.white)
    }
}

struct ToastView: View {
    let message: String
    let actionTitle: String
    let onAction: () -> Void
    
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
            
            // 바로가기 버튼
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
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.primary400)
        )
        .padding(.horizontal, 20)
    }
}

