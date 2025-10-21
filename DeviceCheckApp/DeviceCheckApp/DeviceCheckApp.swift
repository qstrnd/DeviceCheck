//
//  DeviceCheckApp.swift
//  DeviceCheck
//
//  Created by Andy on 20.10.25.
//

import SwiftUI

@main
struct DeviceCheckApp: App {
    var body: some Scene {
        WindowGroup {
            TabView {
                DeviceIdentificationView()
                    .tabItem {
                        Label("Device ID", systemImage: "laptopcomputer")
                    }
                
                AppAttestView()
                    .tabItem {
                        Label("App Attest", systemImage: "checkmark.seal")
                    }
            }
        }
    }
}
