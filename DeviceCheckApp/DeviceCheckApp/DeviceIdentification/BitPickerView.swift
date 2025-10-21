//
//  BitPickerView.swift
//  DeviceCheck
//
//  Created by Andy on 20.10.25.
//

import SwiftUI

struct BitPickerView: View {
    @Binding var bit0: Int
    @Binding var bit1: Int
    @Binding var isPresented: Bool
    
    let onConfirm: () -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            // Title
            Text("Select Bits")
                .font(.headline)
                .padding(.top, 20)
                .padding(.bottom, 10)
            
            // Pickers
            HStack(spacing: 40) {
                VStack {
                    Text("Bit 0")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    Picker("Bit 0", selection: $bit0) {
                        Text("0").tag(0)
                        Text("1").tag(1)
                    }
                    .pickerStyle(.wheel)
                    .frame(width: 80, height: 120)
                    .clipped()
                }
                
                VStack {
                    Text("Bit 1")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    Picker("Bit 1", selection: $bit1) {
                        Text("0").tag(0)
                        Text("1").tag(1)
                    }
                    .pickerStyle(.wheel)
                    .frame(width: 80, height: 120)
                    .clipped()
                }
            }
            .padding(.vertical, 20)
            
            // Buttons
            HStack(spacing: 16) {
                Button(action: {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                        isPresented = false
                    }
                }) {
                    Text("Cancel")
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.gray.opacity(0.2))
                        .foregroundColor(.primary)
                        .cornerRadius(12)
                }
                
                Button(action: {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                        isPresented = false
                    }
                    onConfirm()
                }) {
                    Text("Confirm")
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.orange)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                }
            }
            .padding(.horizontal, 40)
            .padding(.bottom, 30)
        }
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(UIColor.systemBackground))
                .shadow(color: .black.opacity(0.2), radius: 20, x: 0, y: -5)
                .padding(.horizontal, 20)
        )
        .ignoresSafeArea(edges: .bottom)
    }
}

#Preview {
    ZStack {
        Color.gray.opacity(0.3)
        VStack {
            Spacer()
            BitPickerView(
                bit0: .constant(0),
                bit1: .constant(1),
                isPresented: .constant(true),
                onConfirm: {}
            )
        }
    }
}

