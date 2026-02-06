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
    @Published var streamingMessage: String = ""
    @Published var isStreaming: Bool = false
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
    
    /// 메시지 전송 (SSE 스트리밍)
      func sendMessage(
          content: String,
          experienceIds: [String]
      ) async {
          guard !isStreaming else {
              print("이미 전송 중입니다")
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
                      // 실시간으로 텍스트 추가
                      streamingMessage += text
                      print(" 스트리밍: \(text)")
                      
                  case .done(let completedChatId, let isDraft, let remainingChats):
                      print("스트리밍 완료")
                      print("  - chatId: \(completedChatId)")
                      print("  - isDraft: \(isDraft)")
                      print("  - remainingChats: \(remainingChats)")
                      
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
                      
                      //  4. experienceIds 업데이트 (서버에 저장된 상태)
                      self.experienceIds = experienceIds
                      
                      // 초기화
                      streamingMessage = ""
                      isStreaming = false
                      
                  case .error(let message):
                      print(" SSE 에러: \(message)")
                      errorMessage = message
                      
                      // 실패 시 사용자 메시지 제거
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
              
              // 실패 시 사용자 메시지 제거
              messages.removeAll { $0.id == userMessage.id }
              
              isStreaming = false
          }
      }
}
