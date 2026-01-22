//
//  ContentView.swift
//  Logit
//
//  Created by 임재현 on 1/17/26.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Headline
                Group {
                    Text("Headline")
                        .font(.system(size: 12))
                        .foregroundColor(.gray)
                    
                    Text("헤드라인 텍스트 Headline Text 123")
                        .typo(.headLine1_bold)
                }
                
                Divider()
                
                // Title
                Group {
                    Text("Title")
                        .font(.system(size: 12))
                        .foregroundColor(.gray)
                    
                    Text("타이틀1 볼드 Title1 Bold")
                        .typo(.title1_bold)
                    
                    Text("타이틀2 볼드 Title2 Bold")
                        .typo(.title2_bold)
                    
                    Text("타이틀2 세미볼드 Title2 SemiBold")
                        .typo(.title2_semibold)
                    
                    Text("타이틀3 세미볼드 Title3 SemiBold")
                        .typo(.title3_semibold)
                }
                
                Divider()
                
                // Body
                Group {
                    Text("Body")
                        .font(.system(size: 12))
                        .foregroundColor(.gray)
                    
                    Text("바디1 볼드 Body1 Bold")
                        .typo(.body1_bold)
                    
                    Text("바디2 레귤러 Body2 Regular")
                        .typo(.body2_regular)
                    
                    Text("바디3 볼드 Body3 Bold")
                        .typo(.body3_bold)
                    
                    Text("바디3 세미볼드 Body3 SemiBold")
                        .typo(.body3_semibold)
                    
                    Text("바디3 레귤러 Body3 Regular")
                        .typo(.body3_regular)
                    
                    Text("바디5 볼드 Body5 Bold")
                        .typo(.body5_bold)
                    
                    Text("바디5 레귤러 150% Body5 Regular 150%")
                        .typo(.body5_regular_150)
                    
                    Text("바디5 레귤러 140% Body5 Regular 140%")
                        .typo(.body5_regular_140)
                    
                    Text("바디7 볼드 Body7 Bold")
                        .typo(.body7_bold)
                    
                    Text("바디9 레귤러 Body9 Regular")
                        .typo(.body9_regular)
                }
                
                Divider()
                
                // Label
                Group {
                    Text("Label")
                        .font(.system(size: 12))
                        .foregroundColor(.gray)
                    
                    Text("라벨1 미디엄 Label1 Medium")
                        .typo(.label1_medium)
                }
                
                Divider()
                
                // Multi-line Test
                Group {
                    Text("Multi-line Text")
                        .font(.system(size: 12))
                        .foregroundColor(.gray)
                    
                    Text("여러 줄로 된 긴 텍스트입니다. Line Height가 제대로 적용되는지 확인하기 위한 텍스트입니다. This is a long text to test multi-line rendering with proper line height.")
                        .typo(.body5_regular_150)
                        .multilineTextAlignment(.leading)
                }
            }
            .padding(20)
        }
    }
}

