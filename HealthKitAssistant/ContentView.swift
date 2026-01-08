//
//  ContentView.swift
//  HealthKitAssistant
//

import SwiftUI

struct ContentView: View {
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            ChatView()
                .tabItem {
                    Label("Chat", systemImage: "message.fill")
                }
                .tag(0)
            
            HealthDataView()
                .tabItem {
                    Label("Health Data", systemImage: "heart.text.square.fill")
                }
                .tag(1)
            
            // Uncomment to debug safe areas:
            // SafeAreaDebugView()
            //     .tabItem {
            //         Label("Debug", systemImage: "wrench.and.screwdriver")
            //     }
            //     .tag(2)
        }
    }
}

#Preview {
    ContentView()
}

