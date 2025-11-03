//
//  AppAttestView.swift
//  DeviceCheck
//
//  Created by Andy on 20.10.25.
//

import SwiftUI

struct AppAttestView: View {
    @StateObject private var viewModel = AppAttestViewModel()
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 30) {
                    // Challenge Display
                    VStack(spacing: 20) {
                        CopyableTextFieldView(
                            value: viewModel.challenge,
                            title: "Challenge"
                        )
                    }
                    .padding(.top, 40)
                    .padding(.horizontal, 20)
                    
                    // Key ID Display
                    VStack(spacing: 20) {
                        CopyableTextFieldView(
                            value: viewModel.keyId,
                            title: "Key ID"
                        )
                    }
                    .padding(.horizontal, 20)
                    
                    // Action Buttons
                    VStack(spacing: 16) {
                        Button(action: {
                            Task {
                                await viewModel.fetchChallenge()
                            }
                        }) {
                            HStack {
                                if viewModel.isFetchChallengeInProgress {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                } else {
                                    Image(systemName: "arrow.down.circle")
                                }
                                Text("Fetch Challenge")
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
                            Task {
                                await viewModel.generateKeyId()
                            }
                        }) {
                            HStack {
                                if viewModel.isGenerateKeyIdInProgress {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                } else {
                                    Image(systemName: "key")
                                }
                                Text("Generate Key ID")
                                    .fontWeight(.semibold)
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.purple)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                        }
                        .disabled(viewModel.isLoading)
                        
                        Button(action: {
                            Task {
                                await viewModel.attestKey()
                            }
                        }) {
                            HStack {
                                if viewModel.isAttestKeyInProgress {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                } else {
                                    Image(systemName: "shield.checkered")
                                }
                                Text("Attest Key")
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
                                await viewModel.createAssertion()
                            }
                        }) {
                            HStack {
                                if viewModel.isCreateAssertionInProgress {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                } else {
                                    Image(systemName: "checkmark.seal")
                                }
                                Text("Create Assertion")
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
            .navigationTitle("App Attest")
        }
    }
}

#Preview {
    AppAttestView()
}

