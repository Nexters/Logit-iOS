//
//  CoverLetterListView.swift
//  Logit
//
//  Created by 임재현 on 2/7/26.
//

import SwiftUI

struct CoverLetterListView: View {
    @State private var coverLetters: [CoverLetter] = CoverLetter.mockData
    @State private var selectedLetter: CoverLetter?
    
    var body: some View {
        VStack(spacing: 0) {
            // 상단 헤더
            HStack {
                Text("자기소개서")
                    .typo(.semibold_17)
                
                Spacer()
                
                Menu {
                    // 자소서 목록
                    ForEach(coverLetters) { letter in
                        Button {
                            selectedLetter = letter
                            // 실제로는 여기서 API 호출
                            print("선택된 자소서: \(letter.title)")
                        } label: {
                            HStack {
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(letter.title)
                                        .font(.system(size: 15, weight: .medium))
                                    Text(letter.company)
                                        .font(.system(size: 13))
                                        .foregroundStyle(.secondary)
                                }
                                
                                Spacer()
                                
                                if selectedLetter?.id == letter.id {
                                    Image(systemName: "checkmark")
                                }
                            }
                        }
                    }
                    
                } label: {
                    Image("app_btn_menubar")
                        .frame(width: 20, height: 20)
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
            
            // 선택된 자소서 내용
            if let letter = selectedLetter {
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        // 헤더
                        VStack(alignment: .leading, spacing: 8) {
                            Text(letter.company)
                                .font(.system(size: 14))
                                .foregroundStyle(.secondary)
                            
                            Text(letter.title)
                                .font(.system(size: 20, weight: .bold))
                            
                            Text(letter.date)
                                .font(.system(size: 13))
                                .foregroundStyle(.secondary)
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 20)
                        
                        Divider()
                        
                        // 본문
                        Text(letter.content)
                            .font(.system(size: 15))
                            .lineSpacing(6)
                            .padding(.horizontal, 20)
                        
                        Spacer()
                    }
                }
            } else {
                // 빈 상태
                VStack(spacing: 12) {
                    Image(systemName: "doc.text")
                        .font(.system(size: 60))
                        .foregroundStyle(.secondary)
                    
                    Text("자기소개서를 선택해주세요")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .onAppear {
            // 첫 번째 자소서 자동 선택
            if selectedLetter == nil, let first = coverLetters.first {
                selectedLetter = first
            }
        }
    }
}

// MARK: - Model
struct CoverLetter: Identifiable {
    let id: String
    let title: String
    let company: String
    let date: String
    let content: String
    
    static let mockData: [CoverLetter] = [
        CoverLetter(id: "1", title: "iOS 개발자", company: "카카오", date: "2024.02.01", content: "SwiftUI와 TCA 경험"),
        CoverLetter(id: "2", title: "신입 개발자", company: "네이버", date: "2024.01.28", content: "정보처리기사 자격증 보유"),
        CoverLetter(id: "3", title: "주니어 개발자", company: "토스", date: "2024.01.25", content: "사용자 경험 중심 개발"),
        CoverLetter(id: "4", title: "앱 개발자", company: "당근마켓", date: "2024.01.20", content: "커뮤니티 서비스 관심"),
        CoverLetter(id: "5", title: "iOS Developer", company: "라인", date: "2024.01.15", content: "글로벌 서비스 도전"),
        CoverLetter(id: "6", title: "모바일 개발자", company: "쿠팡", date: "2024.01.14", content: "대규모 서비스 경험"),
        CoverLetter(id: "7", title: "Swift 개발자", company: "배달의민족", date: "2024.01.13", content: "음식 배달 앱 관심"),
        CoverLetter(id: "8", title: "주니어 iOS", company: "야놀자", date: "2024.01.12", content: "여행 서비스 개발"),
        CoverLetter(id: "9", title: "신입 iOS", company: "직방", date: "2024.01.11", content: "부동산 앱 개발"),
        CoverLetter(id: "10", title: "개발자", company: "뱅크샐러드", date: "2024.01.10", content: "핀테크 서비스"),
        CoverLetter(id: "11", title: "iOS 엔지니어", company: "29CM", date: "2024.01.09", content: "커머스 플랫폼"),
        CoverLetter(id: "12", title: "주니어", company: "무신사", date: "2024.01.08", content: "패션 앱 개발"),
        CoverLetter(id: "13", title: "신입", company: "컬리", date: "2024.01.07", content: "새벽배송 서비스"),
        CoverLetter(id: "14", title: "개발자", company: "번개장터", date: "2024.01.06", content: "중고거래 플랫폼"),
        CoverLetter(id: "15", title: "iOS", company: "왓챠", date: "2024.01.05", content: "영상 스트리밍"),
        CoverLetter(id: "16", title: "모바일", company: "지그재그", date: "2024.01.04", content: "쇼핑 앱 개발"),
        CoverLetter(id: "17", title: "앱 개발", company: "당근페이", date: "2024.01.03", content: "간편결제 서비스"),
        CoverLetter(id: "18", title: "신입 개발", company: "토스뱅크", date: "2024.01.02", content: "금융 서비스"),
        CoverLetter(id: "19", title: "주니어 앱", company: "카카오뱅크", date: "2024.01.01", content: "뱅킹 앱 개발"),
        CoverLetter(id: "20", title: "iOS 개발", company: "카카오페이", date: "2023.12.31", content: "결제 시스템"),
        CoverLetter(id: "21", title: "개발자", company: "네이버페이", date: "2023.12.30", content: "페이먼트 서비스"),
        CoverLetter(id: "22", title: "신입", company: "NC소프트", date: "2023.12.29", content: "게임 개발"),
        CoverLetter(id: "23", title: "주니어", company: "넥슨", date: "2023.12.28", content: "모바일 게임"),
        CoverLetter(id: "24", title: "iOS", company: "크래프톤", date: "2023.12.27", content: "게임 플랫폼"),
        CoverLetter(id: "25", title: "개발", company: "넷마블", date: "2023.12.26", content: "게임 서비스"),
        CoverLetter(id: "26", title: "신입 iOS", company: "스마일게이트", date: "2023.12.25", content: "게임 앱 개발"),
        CoverLetter(id: "27", title: "모바일 개발", company: "카카오게임즈", date: "2023.12.24", content: "게임 퍼블리싱"),
        CoverLetter(id: "28", title: "앱 개발자", company: "컴투스", date: "2023.12.23", content: "모바일 게임"),
        CoverLetter(id: "29", title: "주니어 개발", company: "네오위즈", date: "2023.12.22", content: "게임 개발"),
        CoverLetter(id: "30", title: "iOS 엔지니어", company: "펄어비스", date: "2023.12.21", content: "게임 엔진"),
        CoverLetter(id: "31", title: "개발자", company: "하이퍼커넥트", date: "2023.12.20", content: "영상통화 앱"),
        CoverLetter(id: "32", title: "신입", company: "센드버드", date: "2023.12.19", content: "메시징 SDK"),
        CoverLetter(id: "33", title: "주니어", company: "리디", date: "2023.12.18", content: "전자책 앱"),
        CoverLetter(id: "34", title: "iOS", company: "밀리의서재", date: "2023.12.17", content: "독서 플랫폼"),
        CoverLetter(id: "35", title: "개발", company: "플로", date: "2023.12.16", content: "음악 스트리밍"),
        CoverLetter(id: "36", title: "신입 iOS", company: "멜론", date: "2023.12.15", content: "음원 서비스"),
        CoverLetter(id: "37", title: "모바일 개발", company: "지니뮤직", date: "2023.12.14", content: "음악 앱"),
        CoverLetter(id: "38", title: "앱 개발자", company: "벅스", date: "2023.12.13", content: "음악 플랫폼"),
        CoverLetter(id: "39", title: "주니어 개발", company: "유튜브뮤직", date: "2023.12.12", content: "음원 스트리밍"),
        CoverLetter(id: "40", title: "iOS 엔지니어", company: "스포티파이", date: "2023.12.11", content: "글로벌 음악"),
        CoverLetter(id: "41", title: "개발자", company: "당근알바", date: "2023.12.10", content: "구인구직 서비스"),
        CoverLetter(id: "42", title: "신입", company: "사람인", date: "2023.12.09", content: "채용 플랫폼"),
        CoverLetter(id: "43", title: "주니어", company: "잡코리아", date: "2023.12.08", content: "취업 정보"),
        CoverLetter(id: "44", title: "iOS", company: "링크드인", date: "2023.12.07", content: "비즈니스 네트워킹"),
        CoverLetter(id: "45", title: "개발", company: "원티드", date: "2023.12.06", content: "채용 매칭"),
        CoverLetter(id: "46", title: "신입 iOS", company: "리멤버", date: "2023.12.05", content: "명함 관리"),
        CoverLetter(id: "47", title: "모바일 개발", company: "블라인드", date: "2023.12.04", content: "직장인 커뮤니티"),
        CoverLetter(id: "48", title: "앱 개발자", company: "점핏", date: "2023.12.03", content: "헬스케어 앱"),
        CoverLetter(id: "49", title: "주니어 개발", company: "캐시워크", date: "2023.12.02", content: "만보기 리워드"),
        CoverLetter(id: "50", title: "iOS 엔지니어", company: "토스피드", date: "2023.12.01", content: "커뮤니티 서비스"),
        CoverLetter(id: "51", title: "개발자", company: "소카", date: "2023.11.30", content: "카셰어링 앱"),
        CoverLetter(id: "52", title: "신입", company: "타다", date: "2023.11.29", content: "모빌리티 서비스"),
        CoverLetter(id: "53", title: "주니어", company: "카카오T", date: "2023.11.28", content: "택시 호출"),
        CoverLetter(id: "54", title: "iOS", company: "우버", date: "2023.11.27", content: "승차공유"),
        CoverLetter(id: "55", title: "개발", company: "그랩", date: "2023.11.26", content: "동남아 모빌리티"),
        CoverLetter(id: "56", title: "신입 iOS", company: "카카오모빌리티", date: "2023.11.25", content: "종합 모빌리티"),
        CoverLetter(id: "57", title: "모바일 개발", company: "쏘카", date: "2023.11.24", content: "차량공유"),
        CoverLetter(id: "58", title: "앱 개발자", company: "위메프", date: "2023.11.23", content: "소셜커머스"),
        CoverLetter(id: "59", title: "주니어 개발", company: "티몬", date: "2023.11.22", content: "이커머스"),
        CoverLetter(id: "60", title: "iOS 엔지니어", company: "11번가", date: "2023.11.21", content: "오픈마켓")
    ]
}

// MARK: - Preview
#Preview {
    CoverLetterListView()
}
