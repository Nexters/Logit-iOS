//
//  AddFlowCoordinator.swift
//  Logit
//
//  Created by 임재현 on 1/26/26.
//

import SwiftUI

struct AddFlowCoordinator: View {
    @Environment(\.dismiss) var dismiss
    @StateObject private var viewModel = AddFlowViewModel()
    
    var body: some View {
        NavigationStack(path: $viewModel.path) {
            VStack(spacing: 20) {
                Text("Add Flow 시작!")
                    .font(.title)
                
                Button("지원정보 입력으로") {
                    viewModel.navigateToApplicationInfo()
                }
                
                Button("취소") {
                    dismiss()
                }
            }
            .navigationDestination(for: AddFlowRoute.self) { route in
                viewModel.destination(for: route)
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("취소") {
                        dismiss()
                    }
                }
            }
        }
        .environmentObject(viewModel)
        .presentationDetents([.large])
        .presentationDragIndicator(.hidden)
    }
}
