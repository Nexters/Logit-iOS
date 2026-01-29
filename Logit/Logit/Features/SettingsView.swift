//
//  SettingsView.swift
//  Logit
//
//  Created by 임재현 on 1/29/26.
//

import SwiftUI

struct SettingsView: View {
    @Environment(\.dismiss) var dismiss
    @State private var isNotificationEnabled: Bool = false
    
    var body: some View {
        VStack(spacing: 0) {
            CustomNavigationBar(
                title: "설정",
                showBackButton: true,
                onBackTapped: { dismiss() }
            )
            
            // 프로필 영역
            HStack(spacing: 20) {
                // 프로필 이미지
                Circle()
                    .fill(Color.primary50)
                    .frame(width: 48, height: 48)
                
                // 닉네임
                Text("로짓")
                    .typo(.bold_20)
                    .foregroundColor(.gray400)
                
                Spacer()
            }
            .padding(.horizontal, 20)
            .padding(.top, 20)
            
            // 구분선
            Rectangle()
                .fill(Color.gray100)
                .frame(height: 2)
                .padding(.top, 26)
            
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
                    .scaleEffect(0.8)
            }
            .padding(.horizontal, 20)
            .padding(.top, 28)
            
            // 구분선
            Rectangle()
                .fill(Color.gray100)
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
                    print("문의하기 클릭")
                }
                
                SettingsRow(title: "로그아웃") {
                    print("로그아웃 클릭")
                }
                
                SettingsRow(title: "회원탈퇴") {
                    print("회원탈퇴 클릭")
                }
            }
            .padding(.top, 14)
            
            Spacer()
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
