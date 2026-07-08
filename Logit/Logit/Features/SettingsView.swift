//
//  SettingsView.swift
//  Logit
//
//  Created by 임재현 on 1/29/26.
//

import SwiftUI

struct SettingsView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var appState: AppState
    @State private var isNotificationEnabled: Bool = false
    @State private var showLogoutAlert: Bool = false
    @State private var showWithdrawAlert: Bool = false
    @State private var showFeatureToast: Bool = false
    @State private var showInquiryPage: Bool = false
    @StateObject private var viewModel = SettingsViewModel()

    private var tokenUsageRow: some View {
        HStack {
            Text("토큰 사용량")
                .typo(.semibold_16)
                .foregroundColor(.black)
            Spacer()
            HStack(spacing: 0) {
                Text("\(viewModel.usedTokens)")
                    .typo(.bold_14)
                    .foregroundColor(.gray400)
                Text(" / \(viewModel.totalTokens)")
                    .typo(.medium_13)
                    .foregroundColor(.gray400)
            }
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            CustomNavigationBar(
                title: "",
                showBackButton: true,
                onBackTapped: { dismiss() }
            )

            // 프로필 영역
            HStack(spacing: 20) {
                // 프로필 이미지
                Image("app_user")
                    .resizable()
                    .scaledToFit()
                    .frame(size: 48.adjustedLayout)
                // 닉네임
                Text(viewModel.userName)
                    .typo(.bold_20)
                    .foregroundColor(.gray400)

                Spacer()
            }
            .padding(.horizontal, 20)
            .padding(.top, 20)

            // 구분선
            Rectangle()
                .fill(Color.gray50)
                .frame(height: 2)
                .padding(.top, 26)

            // 토큰 사용량
            tokenUsageRow
                .padding(.horizontal, 20)
                .padding(.top, 30)

            // 알림 설정
            HStack {
                Text("알림 설정")
                    .typo(.semibold_16)
                    .foregroundColor(.black)

                Spacer()
            }
            .padding(.horizontal, 20)
            .padding(.top, 30)

            HStack {
                Text("커리어 리포트 업데이트 알림")
                    .typo(.regular_14_140)
                    .foregroundColor(.gray400)

                Spacer()

                Toggle("", isOn: $isNotificationEnabled)
                    .labelsHidden()
                    .tint(Color.gray100)
                    .scaleEffect(0.8)
                    .onChange(of: isNotificationEnabled) { _, newValue in
                        if newValue {
                            isNotificationEnabled = false
                            withAnimation(.spring()) { showFeatureToast = true }
                            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                withAnimation { showFeatureToast = false }
                            }
                        }
                    }
            }
            .padding(.horizontal, 20)
            .padding(.top, 28)

            // 구분선
            Rectangle()
                .fill(Color.gray50)
                .frame(height: 2)
                .padding(.top, 34)

            // 다음 섹션 타이틀
            HStack {
                Text("고객 지원 및 정보")
                    .typo(.semibold_16)
                    .foregroundColor(.black)

                Spacer()
            }
            .padding(.horizontal, 20)
            .padding(.top, 30)

            VStack(spacing: 0) {
                SettingsRow(title: "문의하기") {
                    showInquiryPage = true
                }

                SettingsRow(title: "로그아웃") {
                    showLogoutAlert = true
                }

                SettingsRow(title: "회원탈퇴") {
                    showWithdrawAlert = true
                }
            }
            .padding(.top, 14)

            Spacer()
        }
        .overlay(alignment: .bottom) {
            if showFeatureToast {
                ToastView(message: "준비중인 기능입니다")
                    .padding(.horizontal, 20)
                    .padding(.bottom, 40)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .overlay {
            if showLogoutAlert {
                LogitAlertView(
                    message: "로그아웃 하시겠어요?",
                    cancelTitle: "취소하기",
                    confirmTitle: "로그아웃",
                    onCancel: { showLogoutAlert = false },
                    onConfirm: {
                        showLogoutAlert = false
                        Task { await viewModel.logout() }
                    }
                )
            }
        }
        .overlay {
            if showWithdrawAlert {
                LogitAlertView(
                    message: "정말 탈퇴하시겠어요?",
                    subMessage: "탈퇴 시 데이터는 복구할 수 없어요",
                    cancelTitle: "취소하기",
                    confirmTitle: "탈퇴하기",
                    onCancel: { showWithdrawAlert = false },
                    onConfirm: {
                        showWithdrawAlert = false
                        Task { await viewModel.withdraw() }
                    }
                )
            }
        }
        .task {
            await viewModel.fetchCurrentUser()
        }
        .alert("오류", isPresented: Binding(
            get: { viewModel.logoutError != nil },
            set: { if !$0 { viewModel.logoutError = nil } }
        )) {
            Button("확인", role: .cancel) { }
        } message: {
            Text(viewModel.logoutError ?? "")
        }
        .onChange(of: viewModel.isLoggedOut) { loggedOut in
            if loggedOut {
                appState.logout()
            }
        }
        .onChange(of: viewModel.isWithdrawn) { withdrawn in
            if withdrawn {
                appState.logout()
            }
        }
        .alert("오류", isPresented: Binding(
            get: { viewModel.withdrawError != nil },
            set: { if !$0 { viewModel.withdrawError = nil } }
        )) {
            Button("확인", role: .cancel) { }
        } message: {
            Text(viewModel.withdrawError ?? "")
        }
        .disabled(viewModel.isLoggingOut || viewModel.isWithdrawing)
        .sheet(isPresented: $showInquiryPage) {
            if let url = URL(string: "https://bouncy-file-a93.notion.site/326ebdc3fb638030b247f247b9294bae") {
                SafariView(url: url)
                    .ignoresSafeArea()
            }
        }
    }
}



struct SettingsRow: View {
    let title: String
    let action: () -> Void
    
    var body: some View {
        Button {
            action()
        } label: {
            HStack {
                Text(title)
                    .typo(.regular_14_140)
                    .foregroundColor(.gray400)
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 14))
                    .foregroundColor(.gray300)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 14)
            .contentShape(Rectangle())
        }
        .buttonStyle(PlainButtonStyle())
    }
}
