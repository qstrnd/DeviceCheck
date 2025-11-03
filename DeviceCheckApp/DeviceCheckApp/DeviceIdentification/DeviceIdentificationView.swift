//
//  DeviceIdentificationView.swift
//  DeviceCheck
//
//  Created by Andy on 20.10.25.
//

import SwiftUI

struct DeviceIdentificationView: View {
    @StateObject private var viewModel = DeviceIdentificationViewModel()
    
    var body: some View {
        NavigationView {
            ZStack {
                ScrollView {
                    VStack(spacing: 30) {
                        // Device Token Display
                        VStack(spacing: 20) {
                            CopyableTextFieldView(
                                value: viewModel.deviceToken,
                                title: "Device Token"
                            )
                        }
                        .padding(.top, 40)
                        .padding(.horizontal, 20)
                        
                        // Bits Display
                        VStack(spacing: 20) {
                            Text("Device Bits")
                                .font(.headline)
                                .foregroundColor(.secondary)
                            
                            HStack(spacing: 10) {
                                BitView(value: viewModel.associatedBit0)
                                BitView(value: viewModel.associatedBit1)
                            }
                        }
                        
                        // Action Buttons
                        VStack(spacing: 16) {
                            Button(action: {
                                Task {
                                    await viewModel.queryRequest()
                                }
                            }) {
                                HStack {
                                    if viewModel.isQueryRequestInProgress {
                                        ProgressView()
                                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                    } else {
                                        Image(systemName: "magnifyingglass")
                                    }
                                    Text("Query Request")
                                        .fontWeight(.semibold)
                                }
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(12)
                            }
                            .disabled(viewModel.isLoading)
                            
                            Button(action: {
                                viewModel.showUpdatePicker()
                            }) {
                                HStack {
                                    if viewModel.isUpdateRequestInProgress {
                                        ProgressView()
                                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                    } else {
                                        Image(systemName: "arrow.triangle.2.circlepath")
                                    }
                                    Text("Update Request")
                                        .fontWeight(.semibold)
                                }
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.orange)
                                .foregroundColor(.white)
                                .cornerRadius(12)
                            }
                            .disabled(viewModel.isLoading)
                            
                            Button(action: {
                                Task {
                                    await viewModel.deviceValidation()
                                }
                            }) {
                                HStack {
                                    if viewModel.isValidationRequestInProgress {
                                        ProgressView()
                                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                    } else {
                                        Image(systemName: "checkmark.shield")
                                    }
                                    Text("Device Validation")
                                        .fontWeight(.semibold)
                                }
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.green)
                                .foregroundColor(.white)
                                .cornerRadius(12)
                            }
                            .disabled(viewModel.isLoading)
                        }
                        .padding(.horizontal, 20)
                        
                        // Status Message
                        if !viewModel.statusMessage.isEmpty {
                            Text(viewModel.statusMessage)
                                .font(.subheadline)
                                .foregroundColor(viewModel.isError ? .red : .green)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal)
                        }
                        
                        Spacer()
                    }
                    .padding(.bottom, 30)
                }
                .navigationTitle("Device Identification")
                
                // Overlay for dimming background when picker is shown
                if viewModel.showBitPicker {
                    Color.black.opacity(0.3)
                        .ignoresSafeArea()
                        .onTapGesture {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                                viewModel.showBitPicker = false
                            }
                        }
                        .transition(.opacity)
                }
                
                // Bit Picker View
                VStack {
                    Spacer()
                    
                    BitPickerView(
                        bit0: $viewModel.selectedBit0,
                        bit1: $viewModel.selectedBit1,
                        isPresented: $viewModel.showBitPicker,
                        onConfirm: {
                            Task {
                                await viewModel.updateRequest()
                            }
                        }
                    )
                    .transition(.move(edge: .bottom))
                    .offset(y: viewModel.showBitPicker ? 0 : 500)
                    
                    Spacer()
                        .frame(height: 20)
                }
                .animation(.spring(response: 0.5, dampingFraction: 0.8), value: viewModel.showBitPicker)
            }
        }
    }
}

struct BitView: View {
    let value: Int?
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.gray.opacity(0.2))
                .frame(width: 70, height: 70)
            
            if let value = value {
                Text("\(value)")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(.primary)
            }
        }
    }
}

#Preview {
    DeviceIdentificationView()
}

