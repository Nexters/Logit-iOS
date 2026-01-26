//
//  CustomNavigationBar.swift
//  Logit
//
//  Created by 임재현 on 1/26/26.
//

import SwiftUI

struct CustomNavigationBar: View {
    let title: String
    let showBackButton: Bool
    let onBackTapped: () -> Void
    
    init(
        title: String,
        showBackButton: Bool = true,
        onBackTapped: @escaping () -> Void = {}
    ) {
        self.title = title
        self.showBackButton = showBackButton
        self.onBackTapped = onBackTapped
    }
    
    var body: some View {
        HStack(spacing: 12) {
            // 뒤로가기 버튼
            if showBackButton {
                Button {
                    onBackTapped()
                } label: {
                    Image("icNavigateLeft")
                        .frame(size: 24)
                        .foregroundColor(.black)
                        .contentShape(Rectangle())
                }
            } else {
                Spacer()
                    .frame(width: 44)
            }
            
            // 타이틀
            Text(title)
                .font(.system(size: 17, weight: .semibold))
                .foregroundColor(.black)
            
            Spacer()
        }
        .frame(height: 44)
        .padding(.horizontal, 16)
        .background(Color.white)
    }
}
