//
//  ReportView.swift
//  Logit
//
//  Created by 임재현 on 2/20/26.
//

import SwiftUI

struct ReportView: View {
    var body: some View {
        VStack {
            Text("로짓님의 프로파일")
                .typo(.bold_20)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.vertical, 10)
                .padding(.leading, 20)
            
            VStack(spacing: 0) {
                Image("Frame 2087332000")
                    .resizable()
                    .frame(width: 100, height: 36)
                    .padding(.top, 16)
                
                Image("기술적 전문성")
                    .resizable()
                    .frame(width: 154, height: 154)
                    .padding(.top, 17.98)
                
                Text("도구와 기술 스택을 능숙하게\n활용하는 기술적 전문가")
                    .typo(.bold_20)
                    .foregroundStyle(.gradient(.reportCardTextColor))
                    .multilineTextAlignment(.center)
                    .padding(.top, 13.02)
                
            }
            .frame(maxWidth: .infinity)
            .frame(height: 320)
            .background(.gradient(.reportCard))
            .cornerRadius(20)
            .padding(.horizontal, 20)
            .padding(.top, 11)
            
            Spacer()
        }
    }
}

