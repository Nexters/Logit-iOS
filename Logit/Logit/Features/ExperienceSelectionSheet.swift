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
                HStack(spacing: 10) {
                    Image("file_selected")
                        .resizable()
                        .renderingMode(.template)
                        .foregroundStyle(.black)
                        .frame(size: 20)
                    
                    Text("경험 선택")
                        .typo(.semibold_17)
                        .foregroundColor(.black)
                }
                
                Spacer()
                
            }
            .padding(.horizontal, 20)
            .padding(.top, 16)
            .padding(.bottom, 12)
            
            // 설명 텍스트
            HStack {
                Text("반영할 경험카드를 선택해주세요 (최대 3개)")
                    .typo(.regular_15)
                    .foregroundColor(.gray400)
                
                Spacer()
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 16)
            
            // 추가하기 버튼
            Button {
                showExperienceAddFlow = true
            } label: {
                HStack(spacing: 8) {
                    Image("plus_selected")
                        .frame(size: 18)
                    
                    Text("추가하기")
                        .typo(.medium_15)
                        .foregroundColor(.gray300)
                    
                    Spacer()
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 11.5)
                .background(Color.primary50)
                .cornerRadius(8)
                .contentShape(Rectangle())
            }
            .buttonStyle(PlainButtonStyle())
            .padding(.horizontal, 20)
            .padding(.bottom, 16)
            
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
            
            // 하단 적용 버튼
            Button {
                // TODO: 선택된 경험들 적용
                isPresented = false
            } label: {
                Text("적용하기")
                    .typo(.semibold_16)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(Color.primary100)
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
