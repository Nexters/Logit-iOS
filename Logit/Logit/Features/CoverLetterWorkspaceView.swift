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
    let questions: [QuestionItem]  // AddFlow에서 전달받은 임시 데이터
    let projectId: String
    @State private var selectedQuestionIndex: Int = 0
    @State private var selectedView: ContentType = .chat
    @State private var showExperienceSelection = false
    
    @State private var hasLoadedData = false
    
    @State private var hasSelectedExperiences: Bool = false
    
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
        VStack(spacing: 0) {
            CustomNavigationBar(
                title: viewModel.navigationTitle,  //  동적 타이틀
                showBackButton: true,
                onBackTapped: { dismiss() }
            )
            
            // 문항 탭 바 (API에서 가져온 데이터)
            if !viewModel.questionList.isEmpty {
                QuestionTabBar(
                    questionCount: viewModel.questionList.count,
                    selectedIndex: $selectedQuestionIndex
                )
                .onChange(of: selectedQuestionIndex) { newIndex in
                    // 탭 전환 시 체크
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
                // 로딩 중
                ProgressView()
                    .padding(.vertical, 12)
            } else {
                // 임시: AddFlow에서 전달받은 questions 사용
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
                                onUpdateCoverLetter: {
                                    selectedView = .coverLetter
                                },
                                onShowExperienceSelection: {
                                    showExperienceSelection = true
                                }
                            )
                        }
                    } else {
                        // 자소서 뷰
                        CoverLetterContentView()
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
                    
                    // 현재 선택된 문항 정보
                    if !viewModel.questionList.isEmpty {
                        let currentQuestion = viewModel.questionList[selectedQuestionIndex]
                        print("문항 ID: \(currentQuestion.id)")
                    }
                },
                onAttachmentTapped: {
                    showExperienceSelection = true
                }
            )
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
                
                // 디버깅
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
            ExperienceSelectionSheet(
                isPresented: $showExperienceSelection,
                onSelectExperiences: { selectedExperiences in
                    print("선택된 경험들: \(selectedExperiences.map { $0.title })")
                    // TODO: 경험 선택 후 메시지 전송
                }
            )
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
    let onSelectExperience: () -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            Image("app_status_empty2")
                .resizable()
                .scaledToFit()
                .frame(width: 80.adjustedLayout, height: 80.adjustedLayout)
            
            Text("경험을 선택하면 초안이 생성돼요")
                .typo(.medium_15)
                .foregroundStyle(.gray100)
                .padding(.top, 16.adjustedLayout)
            
            Button {
                onSelectExperience()
            } label: {
                Text("자기소개서 작성")
                    .typo(.medium_15)
                    .foregroundStyle(.primary200)
                    .padding(.horizontal, 24.adjustedLayout)
                    .padding(.vertical, 7.5.adjustedLayout)
                    .background(.primary50)
                    .cornerRadius(8.adjustedLayout)
            }
            .padding(.top, 17.adjustedLayout)
        }
        .offset(y: -10.adjustedLayout)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(.vertical, 60.adjustedLayout)
        .background(.white)
        .cornerRadius(16.adjustedLayout)
        .padding(.horizontal, 20.adjustedLayout)
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
    let onUpdateCoverLetter: () -> Void
    let onShowExperienceSelection: () -> Void
    
    @StateObject private var viewModel: ChatMessagesViewModel
    
    init(
        projectId: String,
        questionId: String,
        hasSelectedExperiences: Binding<Bool>,
        onUpdateCoverLetter: @escaping () -> Void,
        onShowExperienceSelection: @escaping () -> Void
    ) {
        self.projectId = projectId
        self.questionId = questionId
        self._hasSelectedExperiences = hasSelectedExperiences
        self.onUpdateCoverLetter = onUpdateCoverLetter
        self.onShowExperienceSelection = onShowExperienceSelection
        _viewModel = StateObject(wrappedValue: ChatMessagesViewModel(
            projectId: projectId,
            questionId: questionId
        ))
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            if viewModel.isLoading && viewModel.messages.isEmpty {
                // 초기 로딩
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                
            } else if let error = viewModel.errorMessage {
                // 에러 상태
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
                // 채팅 히스토리가 비어있음 → EmptyView
                EmptyWorkspaceView {
                    print("========== 경험 선택 버튼 클릭 ==========")
                    print("프로젝트 ID: \(projectId)")
                    print("문항 ID: \(questionId)")
                    print("======================================")
                    
                    onShowExperienceSelection()
                }
                
            } else {
                //  채팅 메시지 표시
                ForEach(viewModel.messages) { message in
                    ChatBubble(
                        message: message.content,
                        isUser: message.role == .user,
                        showUpdateButton: message.role == .assistant && message.id == viewModel.messages.last?.id,
                        onUpdateCoverLetter: onUpdateCoverLetter
                    )
                }
                
                // 더 불러오기
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
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .task {
            await viewModel.fetchChatHistory()
        }
        .onChange(of: viewModel.experienceIds) { newValue in
            // ✅ experienceIds 변경 시 바인딩 자동 업데이트
            hasSelectedExperiences = !newValue.isEmpty
            print("🔍 experienceIds 변경: \(newValue)")
            print("🔍 hasSelectedExperiences → \(hasSelectedExperiences)")
        }
    }
}

// 채팅 버블 컴포넌트
struct ChatBubble: View {
    let message: String
    let isUser: Bool
    let showUpdateButton: Bool
    @State private var displayedText: String = ""
    @State private var isTypingComplete: Bool = false
    let onUpdateCoverLetter: (() -> Void)?
    
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
                    
                    VStack(alignment: .leading, spacing: 12) {
                        // 봇 메시지
                        Text(displayedText)
                            .typo(.regular_14_160)
                            .foregroundColor(.black)
                            .padding(.vertical, 10)
                            .background(Color.clear)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        // 자기소개서 업데이트 버튼 (타이핑 완료 후 표시)
                        if showUpdateButton && isTypingComplete {
                            Button {
                                print("자기소개서 업데이트 버튼 클릭 (시연용)")
                                onUpdateCoverLetter?()
                            } label: {
                                HStack(spacing: 6) {
                                    Image("autorenew")
                                        .frame(size: 16)
                                    
                                    Text("자기소개서 업데이트")
                                        .typo(.medium_13)
                                        .foregroundStyle(.primary600)
                    
                                }
//                                .foregroundColor(.clear)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 8)
                                .background(Color.clear)
                                .cornerRadius(8)
                            }
                            .transition(.opacity.combined(with: .scale))  //  부드러운 등장 효과
                        }
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .onAppear {
            if !isUser {
                startTypingAnimation()
            } else {
                // 사용자 메시지는 즉시 표시
                displayedText = message
                isTypingComplete = true
            }
        }
    }
    
    private func startTypingAnimation() {
        displayedText = ""
        isTypingComplete = false  // ← 타이핑 시작 시 false
        
        let characters = Array(message)
        
        for (index, character) in characters.enumerated() {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(index) * 0.03) {
                displayedText.append(character)
                
                if index == characters.count - 1 {
                    // 타이핑 완료
                    withAnimation(.easeIn(duration: 0.3)) {
                        isTypingComplete = true  //  완료 후 true
                    }
                }
            }
        }
    }
}

struct CoverLetterContentView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                // 제목
                Text("Q1. 지원 동기 및 포부")
                    .typo(.semibold_18)
                    .foregroundColor(.black)
                    .padding(.top, 20)
                
                // 자기소개서 본문
                VStack(alignment: .leading, spacing: 16) {
                    Text("저는 비전공자로 iOS 개발을 시작했지만, 사용자 중심의 문제 해결에 집중하며 성장해왔습니다. 특히 로그 데이터 분석을 통한 이탈률 개선 프로젝트에서, Firebase Analytics와 Mixpanel을 활용해 사용자 행동 패턴을 분석하고 특정 화면에서의 높은 이탈률 원인을 파악했습니다.")
                        .typo(.regular_14_160)
                        .foregroundColor(.black)
                    
                    Text("이를 해결하기 위해 이미지 캐싱과 lazy loading을 적용하여 로딩 시간을 개선했고, 불필요한 네트워크 요청을 최적화한 결과 이탈률을 15% 감소시켰습니다. 이 과정에서 단순히 코드를 작성하는 것을 넘어, 데이터 기반으로 문제를 정의하고 기술적 해결책을 찾는 능력을 키웠습니다.")
                        .typo(.regular_14_160)
                        .foregroundColor(.black)
                    
                    Text("또한 신규 서비스 런칭 경험에서는 SwiftUI와 MVVM 아키텍처를 활용해 빠른 프로토타이핑과 확장 가능한 구조를 동시에 구현했으며, 출시 3개월 만에 MAU 10만을 달성하는 성과를 이뤘습니다.")
                        .typo(.regular_14_160)
                        .foregroundColor(.black)
                    
                    Text("앞으로도 사용자에게 진정한 가치를 전달하는 iOS 개발자로 성장하고 싶습니다. 귀사에서 저의 기술적 역량과 문제 해결 능력을 발휘하여, 더 나은 사용자 경험을 만드는 데 기여하고 싶습니다.")
                        .typo(.regular_14_160)
                        .foregroundColor(.black)
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 20)
                .background(Color.gray20)
                .cornerRadius(12)
                
                Spacer()
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 40)
        }
        .background(Color.white)
    }
}
