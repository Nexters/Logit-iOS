//
//  ChatMessagesViewModel.swift
//  Logit
//
//  Created by 임재현 on 2/6/26.
//

import Foundation

private let draftTokenCost = 10
private let chatTokenCost = 3

@MainActor
class ChatMessagesViewModel: ObservableObject {
    @Published var messages: [ChatMessage] = []
    @Published var streamingMessage: String = ""
    @Published var isStreaming: Bool = false
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var hasMore: Bool = false
    @Published var answer: String = ""
    @Published var experienceIds: [String] = []
    @Published var draftTokensUsed: Int? = nil
    @Published var tokenBalance: Int? = nil
    @Published var showInsufficientBalanceAlert: Bool = false

    private var nextCursor: String?
    private let projectId: String
    private let questionId: String
    private let chatRepository: ChatRepository
    private let questionRepository: QuestionRepository
    private let tokenRepository: TokenRepository

    var hasSelectedExperiences: Bool {
        !experienceIds.isEmpty
    }

    init(
        projectId: String,
        questionId: String,
        chatRepository: ChatRepository = DefaultChatRepository(
            sseClient: DefaultSSEClient(),
            networkClient: DefaultNetworkClient()
        ),
        questionRepository: QuestionRepository = DefaultQuestionRepository(),
        tokenRepository: TokenRepository = DefaultTokenRepository()
    ) {
        self.projectId = projectId
        self.questionId = questionId
        self.chatRepository = chatRepository
        self.questionRepository = questionRepository
        self.tokenRepository = tokenRepository
    }

    /// 초기 채팅 히스토리 로드
    func fetchChatHistory() async {
        guard !isLoading else { return }

        isLoading = true
        errorMessage = nil

        async let historyTask: () = loadChatHistory()
        async let balanceTask: () = loadTokenBalance()
        _ = await (historyTask, balanceTask)

        isLoading = false
    }

    private func loadChatHistory() async {
        do {
            let response = try await chatRepository.getChatHistory(
                projectId: projectId,
                questionId: questionId,
                cursor: nil,
                size: 20
            )

            print(" 채팅 히스토리 조회 성공")
            print("  - 프로젝트: \(response.projectName)")
            print("  - 문항: \(response.question)")
            print("  - 메시지 개수: \(response.chats.count)")
            print("  - 현재 답변: \(response.answer)")
            print("  - 더 있는지: \(response.hasMore)")
            print("  - 경험 ID 개수: \(response.experienceIds.count)")
            print("  - 경험 IDs: \(response.experienceIds)")

            messages = response.chats
            answer = response.answer ?? ""
            experienceIds = response.experienceIds
            nextCursor = response.nextCursor
            hasMore = response.hasMore

        } catch {
            print(" 채팅 히스토리 조회 실패: \(error)")
            errorMessage = "채팅 내역을 불러올 수 없습니다."
        }
    }

    private func loadTokenBalance() async {
        do {
            let response = try await tokenRepository.getBalance()
            tokenBalance = response.balance
            if response.attendanceAmount > 0 {
                NotificationCenter.default.post(
                    name: .attendanceRewardReceived,
                    object: nil,
                    userInfo: ["amount": response.attendanceAmount]
                )
            }
        } catch {
            print(" 토큰 잔액 조회 실패: \(error)")
        }
    }

    /// 추가 메시지 로드 (페이지네이션)
    func loadMoreMessages() async {
        guard !isLoading, hasMore, let cursor = nextCursor else {
            return
        }

        isLoading = true

        do {
            let response = try await chatRepository.getChatHistory(
                projectId: projectId,
                questionId: questionId,
                cursor: cursor,
                size: 20
            )

            print("추가 메시지 로드 성공: \(response.chats.count)개")

            // 오래된 메시지는 앞에 붙여야 함
            messages.insert(contentsOf: response.chats, at: 0)
            nextCursor = response.nextCursor
            hasMore = response.hasMore

        } catch {
            print(" 추가 메시지 로드 실패: \(error)")
            errorMessage = "메시지를 더 불러올 수 없습니다."
        }

        isLoading = false
    }

    /// 메시지 전송 (SSE 스트리밍)
    func sendMessage(
        content: String,
        experienceIds: [String],
        isDraftRequest: Bool = false
    ) async {
        guard !isStreaming else {
            print("이미 전송 중입니다")
            return
        }

        // 잔액 검증
        let requiredTokens = isDraftRequest ? draftTokenCost : chatTokenCost
        if let balance = tokenBalance, balance < requiredTokens {
            showInsufficientBalanceAlert = true
            return
        }

        isStreaming = true
        streamingMessage = ""
        errorMessage = nil

        let request = SendMessageRequest(
            content: content,
            experienceIds: experienceIds,
            questionId: questionId
        )

        print(" SSE 메시지 전송")
        print("  - questionId: \(questionId)")
        print("  - content: \(content)")
        print("  - experienceIds: \(experienceIds)")
        print("  - isDraftRequest: \(isDraftRequest)")

        //  1. 사용자 메시지 즉시 추가 (낙관적 업데이트)
        let userMessage = ChatMessage(
            id: UUID().uuidString,  // 임시 ID
            role: .user,
            content: content,
            isDraft: false,
            createdAt: ISO8601DateFormatter().string(from: Date())
        )
        messages.append(userMessage)

        do {
            let stream = chatRepository.sendMessage(
                projectId: projectId,
                request: request
            )

            //  2. SSE 스트리밍 수신
            var chatId: String = ""

            for try await event in stream {
                switch event {
                case .content(let text):
                    streamingMessage += text
                    print(" 스트리밍: \(text)")

                case .done(let completedChatId, let isDraft, let draftLimitExceeded, let newTokenBalance, let tokensUsed):
                    print("스트리밍 완료")
                    print("  - chatId: \(completedChatId)")
                    print("  - isDraft: \(isDraft)")
                    print("  - draftLimitExceeded: \(draftLimitExceeded)")
                    print("  - tokenBalance: \(newTokenBalance)")
                    print("  - tokensUsed: \(tokensUsed)")

                    chatId = completedChatId

                    // 3. 완성된 어시스턴트 메시지 추가
                    let assistantMessage = ChatMessage(
                        id: completedChatId,
                        role: .assistant,
                        content: streamingMessage,
                        isDraft: isDraft,
                        createdAt: ISO8601DateFormatter().string(from: Date())
                    )
                    messages.append(assistantMessage)

                    //  4. experienceIds 업데이트
                    self.experienceIds = experienceIds

                    // 5. 토큰 잔액 업데이트
                    self.tokenBalance = newTokenBalance

                    // 6. 초안 생성 시 토큰 사용량 알림
                    if isDraft {
                        draftTokensUsed = tokensUsed
                    }

                    streamingMessage = ""
                    isStreaming = false

                case .error(let message):
                    print(" SSE 에러: \(message)")
                    errorMessage = message
                    messages.removeAll { $0.id == userMessage.id }
                    isStreaming = false
                }
            }

        } catch {
            print(" 메시지 전송 실패: \(error)")
            errorMessage = "메시지 전송에 실패했습니다."

            if let apiError = error as? APIError {
                errorMessage = apiError.localizedDescription
            }

            messages.removeAll { $0.id == userMessage.id }
            isStreaming = false
        }
    }

    /// 자기소개서 업데이트
    func updateAnswer(chatId: String) async {
        guard !isLoading else {
            print(" 이미 처리 중입니다")
            return
        }

        guard let message = messages.first(where: { $0.id == chatId }) else {
            print(" chatId에 해당하는 메시지를 찾을 수 없습니다: \(chatId)")
            return
        }

        isLoading = true
        errorMessage = nil

        do {
            let req = UpdateQuestionRequest(answer: message.content)
            _ = try await questionRepository.updateQuestion(
                projectId: projectId,
                questionId: questionId,
                request: req
            )

            print("자기소개서 업데이트 성공")
            print("  - chatId: \(chatId)")
            print("  - 저장된 답변: \(message.content)")

            answer = message.content

            if let index = messages.firstIndex(where: { $0.id == chatId }) {
                messages[index] = ChatMessage(
                    id: messages[index].id,
                    role: messages[index].role,
                    content: messages[index].content,
                    isDraft: false,
                    createdAt: messages[index].createdAt
                )
            }

        } catch {
            print(" 자기소개서 업데이트 실패: \(error)")
            errorMessage = "자기소개서 업데이트에 실패했습니다."

            if let apiError = error as? APIError {
                errorMessage = apiError.localizedDescription
            }
        }

        isLoading = false
    }
}
