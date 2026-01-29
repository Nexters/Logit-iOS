//
//  ExperienceSelectionSheet.swift
//  Logit
//
//  Created by 임재현 on 1/29/26.
//

import SwiftUI

struct ExperienceSelectionSheet: View {
    @Binding var isPresented: Bool
    @State private var showExperienceAddFlow = false
    let onSelectExperience: (ExperienceData) -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            // 핸들 바
            RoundedRectangle(cornerRadius: 2.5)
                .fill(Color.gray200)
                .frame(width: 40, height: 5)
                .padding(.top, 8)
            
            // 헤더
            HStack {
                Text("경험 선택")
                    .typo(.semibold_17)
                    .foregroundColor(.black)
                
                Spacer()
                
                Button {
                    isPresented = false
                } label: {
                    Image(systemName: "xmark")
                        .foregroundColor(.gray200)
                        .frame(width: 24, height: 24)
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 16)
            .padding(.bottom, 12)
            
            Divider()
            
            // 컨텐츠 영역
            ScrollView {
                VStack(spacing: 16) {
                    Text("여기에 등록된 경험 목록이 표시됩니다")
                        .typo(.regular_15)
                        .foregroundColor(.gray400)
                        .padding(.top, 40)
                    
                    // TODO: 경험 목록 표시
                }
                .padding(.horizontal, 20)
            }
            
            // 하단 버튼
            Button {
                showExperienceAddFlow = true
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "plus")
                        .font(.system(size: 16, weight: .semibold))
                    
                    Text("새 경험 추가")
                        .typo(.semibold_16)
                }
                .foregroundColor(.primary100)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(Color.primary20)
                .cornerRadius(12)
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 10)
        }
        .presentationDetents([.large])
        .presentationDragIndicator(.hidden)
        .fullScreenCover(isPresented: $showExperienceAddFlow) {
            ExperienceFlowCoordinator { experienceData in
                // 경험 추가 후 바로 선택
                onSelectExperience(experienceData)
                isPresented = false
            }
        }
    }
}
