//
//  HomeView.swift
//  Logit
//
//  Created by 임재현 on 1/24/26.
//

import SwiftUI

struct HomeView: View {
    @State private var hasProjects: Bool = true
    
    var body: some View {
        VStack(spacing: 0) {
            
            HomeHeaderView()
            ExperienceTypeSection()
                .padding(.top, 22)
            
            ProjectListSection(hasProjects: hasProjects)
                .padding(.top, 43)
            
            Spacer()
            
        }
    }
}
