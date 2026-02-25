//
//  LogitAlertView.swift
//  Logit
//

import SwiftUI

struct LogitAlertView: View {
    let message: String
    var subMessage: String? = nil
    let cancelTitle: String
    let confirmTitle: String
    let onCancel: () -> Void
    let onConfirm: () -> Void

    var body: some View {
        ZStack {
            // 딤 배경
            Color.black.opacity(0.4)
                .ignoresSafeArea()
                .onTapGesture { onCancel() }
                .frame(maxWidth: .infinity, maxHeight: .infinity)

            // 카드
            VStack(spacing: 0) {
                // 느낌표 아이콘
                ZStack {
                    Circle()
                        .fill(Color.alert.opacity(0.12))
                        .frame(width: 52, height: 52)

                    Image(systemName: "exclamationmark")
                        .font(.system(size: 22, weight: .bold))
                        .foregroundColor(.alert)
                }
                .padding(.top, 28)

                // 메시지
                Text(message)
                    .typo(.semibold_16)
                    .foregroundColor(.black)
                    .multilineTextAlignment(.center)
                    .padding(.top, 16)
                    .padding(.horizontal, 20)

                // 서브 메시지
                if let subMessage {
                    Text(subMessage)
                        .typo(.regular_13)
                        .foregroundColor(.gray300)
                        .multilineTextAlignment(.center)
                        .padding(.top, 6)
                        .padding(.horizontal, 20)
                }

                // 버튼
                HStack(spacing: 10) {
                    // 계속하기
                    Button(action: onCancel) {
                        Text(cancelTitle)
                            .typo(.medium_15)
                            .foregroundColor(.gray300)
                            .frame(maxWidth: .infinity)
                            .frame(height: 44)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color.gray100, lineWidth: 1)
                            )
                    }

                    // 그만하기
                    Button(action: onConfirm) {
                        Text(confirmTitle)
                            .typo(.medium_15)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 44)
                            .background(Color.primary100)
                            .cornerRadius(8)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
                .padding(.bottom, 24)
            }
            .background(Color.white)
            .cornerRadius(16)
            .padding(.horizontal, 40)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .ignoresSafeArea()
    }
}
