//
//  ChatView.swift
//  HealthKitAssistant
//

import SwiftUI

struct ChatView: View {
    @StateObject private var healthKitManager = HealthKitManager()
    @StateObject private var aiAssistant: AIAssistantManager
    @State private var messages: [Message] = []
    @State private var inputText: String = ""
    @State private var showPermissionAlert = false
    @FocusState private var isInputFocused: Bool
    
    init() {
        let manager = HealthKitManager()
        _healthKitManager = StateObject(wrappedValue: manager)
        _aiAssistant = StateObject(wrappedValue: AIAssistantManager(healthKitManager: manager))
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Messages - takes remaining space
                messagesList
                
                // Input bar at bottom
                inputBar
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Health Assistant")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    // Only show Enable button if queries haven't worked yet
                    // If queries work, permissions are granted (regardless of status check)
                    if !healthKitManager.hasQueriedSuccessfully && healthKitManager.authorizationStatus == .notDetermined {
                        Button("Enable") {
                            requestAuthorization()
                        }
                        .font(.subheadline)
                        .fontWeight(.semibold)
                    }
                }
            }
            .toolbarBackground(Color(.systemGroupedBackground), for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
        }
        .ignoresSafeArea(.keyboard, edges: .bottom)
        .onAppear {
            checkAuthorization()
        }
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)) { _ in
            // Check authorization when app comes back from Settings
            checkAuthorization()
        }
        .alert("HealthKit Permission Required", isPresented: $showPermissionAlert) {
            Button("Open Settings") {
                // Open directly to Privacy & Security > Health
                if let url = URL(string: "App-Prefs:Privacy&path=HEALTH") {
                    if UIApplication.shared.canOpenURL(url) {
                        UIApplication.shared.open(url)
                    } else {
                        // Fallback to general settings
                        if let settingsUrl = URL(string: UIApplication.openSettingsURLString) {
                            UIApplication.shared.open(settingsUrl)
                        }
                    }
                } else {
                    // Fallback to general settings
                    if let settingsUrl = URL(string: UIApplication.openSettingsURLString) {
                        UIApplication.shared.open(settingsUrl)
                    }
                }
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("HealthKit permission was previously denied. Please go to Settings > Privacy & Security > Health > HealthKitAssistant and enable access to your health data.")
        }
    }
    
    // MARK: - Messages List
    private var messagesList: some View {
        ScrollViewReader { proxy in
            ScrollView {
                LazyVStack(spacing: 4) {
                    if messages.isEmpty {
                        welcomeView
                            .padding(.vertical, 12)
                            .frame(maxWidth: .infinity)
                    }
                    
                    ForEach(messages) { message in
                        MessageRow(message: message)
                            .id(message.id)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 2)
                    }
                    
                    if aiAssistant.isProcessing {
                        TypingIndicator()
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                    }
                }
                .padding(.vertical, 8)
                .frame(maxWidth: .infinity)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .onChange(of: messages.count) {
                if let lastMessage = messages.last {
                    withAnimation(.easeOut(duration: 0.3)) {
                        proxy.scrollTo(lastMessage.id, anchor: .bottom)
                    }
                }
            }
        }
    }
    
    // MARK: - Welcome View
    private var welcomeView: some View {
        VStack(spacing: 20) {
            Image(systemName: "heart.text.square.fill")
                .font(.system(size: 60))
                .foregroundColor(.blue)
            
            VStack(spacing: 8) {
                Text("Ask me about your health")
                    .font(.title2)
                    .fontWeight(.semibold)
                
                Text("Get insights about your activity, heart rate, sleep, and more")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
            }
            
            VStack(spacing: 10) {
                Text("Try asking:")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding(.top, 8)
                
                suggestionChip("How many steps today?")
                suggestionChip("What's my heart rate?")
                suggestionChip("How did I sleep?")
                suggestionChip("Calories burned?")
            }
        }
    }
    
    private func suggestionChip(_ text: String) -> some View {
        Button(action: {
            inputText = text
            sendMessage()
        }) {
            Text(text)
                .font(.subheadline)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(Color(.systemGray6))
                .cornerRadius(16)
        }
        .buttonStyle(.plain)
    }
    
    // MARK: - Input Bar
    private var inputBar: some View {
        VStack(spacing: 0) {
            Divider()
            
            HStack(spacing: 12) {
                TextField("Message", text: $inputText, axis: .vertical)
                    .textFieldStyle(.plain)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .background(Color(.systemGray6))
                    .cornerRadius(20)
                    .lineLimit(1...4)
                    .focused($isInputFocused)
                    .disabled(aiAssistant.isProcessing)
                
                Button(action: sendMessage) {
                    Image(systemName: "arrow.up.circle.fill")
                        .font(.system(size: 32))
                        .foregroundColor(canSend ? .blue : .gray)
                }
                .disabled(!canSend)
            }
            .padding(.horizontal, 16)
            .padding(.top, 8)
            .padding(.bottom, 8)
            .background(Color(.systemBackground))
        }
        .background(Color(.systemBackground))
    }
    
    private var canSend: Bool {
        !inputText.trimmingCharacters(in: .whitespaces).isEmpty && !aiAssistant.isProcessing
    }
    
    // MARK: - Functions
    private func checkAuthorization() {
        // Check authorization status asynchronously to avoid blocking UI
        Task { @MainActor in
            healthKitManager.checkAuthorizationStatus()
            print("🔐 Initial authorization check: isAuthorized = \(healthKitManager.isAuthorized)")
        }
    }
    
    private func requestAuthorization() {
        print("🔐 Enable button tapped - requesting authorization")
        Task { @MainActor in
            do {
                try await healthKitManager.requestAuthorization()
                print("🔐 Authorization completed, checking status...")
                // Check status again after a brief delay to ensure UI updates
                try? await Task.sleep(nanoseconds: 200_000_000) // 0.2 seconds
                healthKitManager.checkAuthorizationStatus()
                print("🔐 Status check complete, isAuthorized: \(healthKitManager.isAuthorized)")
            } catch {
                print("🔐 Authorization error: \(error.localizedDescription)")
                
                // Check if permission was previously denied
                if healthKitManager.authorizationStatus == .sharingDenied {
                    // Show alert to open Settings
                    showPermissionAlert = true
                } else {
                    // Show error message in chat
                    let errorMsg = Message(
                        content: "Failed to request HealthKit permission: \(error.localizedDescription). Please go to Settings > Privacy & Security > Health to enable access.",
                        isUser: false
                    )
                    messages.append(errorMsg)
                }
            }
        }
    }
    
    private func sendMessage() {
        guard canSend else { return }
        
        let userMessage = inputText
        inputText = ""
        isInputFocused = false
        
        // Add user message immediately
        let userMsg = Message(content: userMessage, isUser: true)
        messages.append(userMsg)
        
        // Process with AI (always process - AI will handle permission issues)
        Task {
            do {
                // Always process the query - the AI will handle permission issues gracefully
                let response = try await aiAssistant.processQuery(userMessage)
                let assistantMsg = Message(content: response, isUser: false)
                await MainActor.run {
                    messages.append(assistantMsg)
                }
            } catch {
                await MainActor.run {
                    // AI should have handled the error, but just in case
                    let errorMsg = Message(
                        content: "Sorry, I encountered an error: \(error.localizedDescription)",
                        isUser: false
                    )
                    messages.append(errorMsg)
                }
            }
        }
    }
    
}

// MARK: - Message Row
struct MessageRow: View {
    let message: Message
    
    var body: some View {
        HStack(alignment: .bottom, spacing: 8) {
            if message.isUser {
                Spacer(minLength: 60)
            }
            
            VStack(alignment: message.isUser ? .trailing : .leading, spacing: 4) {
                Text(message.content)
                    .font(.body)
                    .foregroundColor(message.isUser ? .white : .primary)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .background(
                        message.isUser ?
                            Color.blue :
                            Color(.systemGray5)
                    )
                    .cornerRadius(18)
                
                Text(message.timestamp, style: .time)
                    .font(.caption2)
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 4)
            }
            
            if !message.isUser {
                Spacer(minLength: 60)
            }
        }
    }
}

// MARK: - Typing Indicator
struct TypingIndicator: View {
    @State private var animating = false
    
    var body: some View {
        HStack(spacing: 4) {
            ForEach(0..<3) { index in
                Circle()
                    .fill(Color.secondary)
                    .frame(width: 8, height: 8)
                    .opacity(animating ? (Double(index) * 0.3 + 0.4) : 1.0)
                    .animation(
                        Animation.easeInOut(duration: 0.6)
                            .repeatForever()
                            .delay(Double(index) * 0.2),
                        value: animating
                    )
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(Color(.systemGray5))
        .cornerRadius(18)
        .onAppear {
            animating = true
        }
    }
}

