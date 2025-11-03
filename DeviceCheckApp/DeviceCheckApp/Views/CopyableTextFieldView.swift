//
//  CopyableTextFieldView.swift
//  DeviceCheck
//
//  Created by Andy on 20.10.25.
//

import SwiftUI

struct CopyableTextFieldView: View {
    let value: String?
    let title: String?
    
    init(value: String?, title: String? = nil) {
        self.value = value
        self.title = title
    }
    
    @State private var copied = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            if let title = title {
                Text(title)
                    .font(.headline)
                    .foregroundColor(.secondary)
            }
            
            HStack(spacing: 0) {
                ZStack {
                    if let value = value, !value.isEmpty {
                        Text(value)
                            .font(.system(.body, design: .monospaced))
                            .foregroundColor(.primary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .multilineTextAlignment(.leading)
                            .lineLimit(1)
                            .truncationMode(.tail)
                    } else {
                        Text("Empty")
                            .font(.system(.body, design: .monospaced))
                            .foregroundColor(.gray)
                            .frame(maxWidth: .infinity)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                
                if value != nil && !value!.isEmpty {
                    Button(action: {
                        if let value = value {
                            UIPasteboard.general.string = value
                            withAnimation {
                                copied = true
                            }
                            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                                withAnimation {
                                    copied = false
                                }
                            }
                        }
                    }) {
                        Image(systemName: copied ? "checkmark.circle.fill" : "doc.on.doc.fill")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.primary)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 12)
                    }
                }
            }
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.gray.opacity(0.2))
            )
        }
    }
}

#Preview {
    VStack(spacing: 20) {
        CopyableTextFieldView(
            value: "dGVzdGNoYWxsZW5nZWJhc2U2NGVuY29kZWRzdHJpbmc=",
            title: "Challenge"
        )
        CopyableTextFieldView(
            value: nil,
            title: "Key ID"
        )
    }
    .padding()
}

