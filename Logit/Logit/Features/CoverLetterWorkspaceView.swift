//
//  CoverLetterWorkspaceView.swift
//  Logit
//
//  Created by 임재현 on 1/29/26.
//

import SwiftUI

struct CoverLetterWorkspaceView: View {
    @Environment(\.dismiss) var dismiss
    let questions: [QuestionItem]
    @State private var selectedQuestionIndex: Int = 0
    @State private var selectedView: ContentType = .chat
    @State private var hasData: Bool = true
    @State private var showExperienceSelection = false
    
    enum ContentType {
        case chat, coverLetter
    }
    
    var body: some View {
        VStack(spacing: 0) {
            CustomNavigationBar(
                title: "프로젝트 생성",
                showBackButton: true,
                onBackTapped: { dismiss() }
            )
            
            // 문항 탭 바
            QuestionTabBar(
                questionCount: questions.count,
                selectedIndex: $selectedQuestionIndex
            )
            
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
                    if hasData {
                        // 채팅 메시지 리스트
                        ChatMessagesView()
                    } else {
                        // 빈 화면
                        EmptyWorkspaceView {
                            print("경험 선택 버튼 클릭")
                            showExperienceSelection = true
                        }
                    }
                }
            }
            .scrollToMinDistance(minDisntance: 32)
            
            // 채팅 입력창 (항상 하단 고정)
            ChatInputBar(
                onSend: { message in
                    print("전송: \(message)")
                },
                onAttachmentTapped: {
                    showExperienceSelection = true 
                }
            )
        }
        .dismissKeyboardOnTap()
        .navigationBarHidden(true)
        .sheet(isPresented: $showExperienceSelection) {
            ExperienceSelectionSheet(
                isPresented: $showExperienceSelection,
                onSelectExperiences: { selectedExperiences in
                    print("선택된 경험들: \(selectedExperiences.map { $0.title })")
                    // TODO: 선택된 경험들로 채팅 시작
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
                    
                    Image("Union")
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
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // TODO: 실제 채팅 메시지들
            ChatBubble(message: "안녕하세요!", isUser: false)
            ChatBubble(message: "네 안녕하세요네 안녕하세요네 안녕하세요네 안녕하세요네 안녕하세요네 안녕하세요네 안녕하세요네 안녕하세요", isUser: true)
            ChatBubble(message: "자기소개서 작성 도와드릴게요자기소개서 작성 도와드릴게요자기소개서 작성 도와드릴게요자기소개서 작성 도와드릴게요", isUser: false)
            ChatBubble(message: "자기소개서 작성 도와드릴게요", isUser: false)
            ChatBubble(message: "자기소개서 작성 도와드릴게요", isUser: false)
            ChatBubble(message: "자기소개서 작성 도와드릴게요", isUser: false)
            ChatBubble(message: "자기소개서 작성 도와드릴게요", isUser: true)
            ChatBubble(message: "자기소개서 작성 도와드릴게요", isUser: false)
            ChatBubble(message: "자기소개서 작성 도와드릴게요", isUser: false)
            ChatBubble(message: "자기소개서 작성 도와드릴게요", isUser: false)
            ChatBubble(message: "자기소개서 작성 도와드릴게요", isUser: true)
            ChatBubble(message: "자기소개서 작성 도와드릴게요", isUser: false)
            ChatBubble(message: "자기소개서 작성 도와드릴게요", isUser: false)
            ChatBubble(message: "자기소개서 작성 도와드릴게요", isUser: false)
            ChatBubble(message: "자기소개서 작성 도와드릴게요", isUser: true)
            ChatBubble(message: "자기소개서 작성 도와드릴게요", isUser: false)
            ChatBubble(message: "자기소개서 작성 도와드릴게요", isUser: true)
            ChatBubble(message: "자기소개서 작성 도와드릴게요", isUser: false)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
    }
}

// 채팅 버블 컴포넌트
struct ChatBubble: View {
    let message: String
    let isUser: Bool
    
    var body: some View {
        HStack(alignment: .top, spacing: 0) {
            if isUser {
                Spacer()
                
                // 사용자 메시지
                Text(message)
                    .typo(.regular_14_160)
                    .foregroundColor(.black )
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .background(Color.primary20)
                    .cornerRadius(16)
            } else {
                VStack(alignment: .leading, spacing: 8) {
                    Image("chatting_logo")
                        .resizable()
                        .frame(size: 24)
                    
                    // 봇 메시지
                    Text(message)
                        .typo(.regular_14_160)
                        .foregroundColor(.black)
                        .padding(.vertical, 10)
                        .background(Color.clear)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
    }
}
