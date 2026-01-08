//
//  SafeAreaDebugView.swift
//  HealthKitAssistant
//
//  Temporary diagnostic view to debug safe area issues

import SwiftUI

struct SafeAreaDebugView: View {
    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 0) {
                // Top safe area indicator
                Color.red.opacity(0.3)
                    .frame(height: geometry.safeAreaInsets.top)
                    .overlay(Text("Top Safe Area: \(Int(geometry.safeAreaInsets.top))pt").font(.caption))
                
                // Content area
                Color.blue.opacity(0.3)
                    .overlay(
                        VStack {
                            Text("Content Area")
                                .font(.title)
                            Text("Width: \(Int(geometry.size.width))pt")
                            Text("Height: \(Int(geometry.size.height))pt")
                            Text("Safe Top: \(Int(geometry.safeAreaInsets.top))pt")
                            Text("Safe Bottom: \(Int(geometry.safeAreaInsets.bottom))pt")
                        }
                    )
                
                // Bottom safe area indicator
                Color.green.opacity(0.3)
                    .frame(height: geometry.safeAreaInsets.bottom)
                    .overlay(Text("Bottom Safe Area: \(Int(geometry.safeAreaInsets.bottom))pt").font(.caption))
            }
        }
    }
}

