//
//  ChatMessagesViewModel.swift
//  Logit
//
//  Created by 임재현 on 2/6/26.
//

import Foundation

@MainActor
class ChatMessagesViewModel: ObservableObject {
    @Published var messages: [ChatMessage] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var hasMore: Bool = false
    @Published var answer: String = ""
    @Published var experienceIds: [String] = []
    
    private var nextCursor: String?
    private let projectId: String
    private let questionId: String
    private let chatRepository: ChatRepository
    
    var hasSelectedExperiences: Bool {
        !experienceIds.isEmpty
    }
    
    init(
        projectId: String,
        questionId: String,
        chatRepository: ChatRepository = DefaultChatRepository(
            sseClient: DefaultSSEClient(),
            networkClient: DefaultNetworkClient()
        )
    ) {
        self.projectId = projectId
        self.questionId = questionId
        self.chatRepository = chatRepository
    }
    
    /// 초기 채팅 히스토리 로드
    func fetchChatHistory() async {
        guard !isLoading else { return }
        
        isLoading = true
        errorMessage = nil
        
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
            // 데이터 업데이트
            messages = response.chats
            answer = response.answer ?? ""
            experienceIds = response.experienceIds
            nextCursor = response.nextCursor
            hasMore = response.hasMore
            
        } catch {
            print(" 채팅 히스토리 조회 실패: \(error)")
            errorMessage = "채팅 내역을 불러올 수 없습니다."
            
            if let apiError = error as? APIError {
                print("API Error: \(apiError.localizedDescription)")
            }
        }
        
        isLoading = false
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
            
            // 기존 메시지에 추가
            messages.append(contentsOf: response.chats)
            nextCursor = response.nextCursor
            hasMore = response.hasMore
            
        } catch {
            print(" 추가 메시지 로드 실패: \(error)")
            errorMessage = "메시지를 더 불러올 수 없습니다."
        }
        
        isLoading = false
    }
}
