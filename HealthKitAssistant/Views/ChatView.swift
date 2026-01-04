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
        NavigationView {
            VStack(spacing: 0) {
                // Messages
                ScrollViewReader { proxy in
                    ScrollView {
                        LazyVStack(spacing: 8) {
                            if messages.isEmpty {
                                welcomeView
                                    .padding(.top, 60)
                            }
                            
                            ForEach(messages) { message in
                                MessageBubble(message: message)
                                    .id(message.id)
                            }
                            
                            if aiAssistant.isProcessing {
                                HStack {
                                    ProgressView()
                                        .scaleEffect(0.8)
                                    Text("Thinking...")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                    Spacer()
                                }
                                .padding(.horizontal)
                            }
                        }
                        .padding(.vertical, 8)
                    }
                    .onChange(of: messages.count) {
                        if let lastMessage = messages.last {
                            withAnimation {
                                proxy.scrollTo(lastMessage.id, anchor: .bottom)
                            }
                        }
                    }
                }
                
                // Input bar
                inputBar
            }
            .navigationTitle("Health Assistant")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    if !healthKitManager.isAuthorized {
                        Button("Enable") {
                            requestAuthorization()
                        }
                    }
                }
            }
        }
        .onAppear {
            checkAuthorization()
        }
        .alert("HealthKit Permission Required", isPresented: $showPermissionAlert) {
            Button("Settings") {
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(url)
                }
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("This app needs access to your health data to answer questions.")
        }
    }
    
    // MARK: - Welcome View
    private var welcomeView: some View {
        VStack(spacing: 16) {
            Image(systemName: "heart.text.square.fill")
                .font(.system(size: 50))
                .foregroundColor(.blue)
            
            Text("Ask me about your health data")
                .font(.title2)
                .fontWeight(.semibold)
            
            Text("Try asking:")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .padding(.top, 8)
            
            VStack(spacing: 8) {
                suggestionButton("How many steps today?")
                suggestionButton("What's my heart rate?")
                suggestionButton("How did I sleep?")
                suggestionButton("How many calories did I burn?")
            }
        }
        .padding()
    }
    
    private func suggestionButton(_ text: String) -> some View {
        Button(action: {
            inputText = text
            sendMessage()
        }) {
            HStack {
                Text(text)
                    .font(.subheadline)
                Spacer()
                Image(systemName: "arrow.right")
                    .font(.caption)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(Color(.systemGray6))
            .cornerRadius(10)
        }
    }
    
    // MARK: - Input Bar
    private var inputBar: some View {
        HStack(spacing: 12) {
            TextField("Message", text: $inputText, axis: .vertical)
                .textFieldStyle(.roundedBorder)
                .lineLimit(1...4)
                .focused($isInputFocused)
                .disabled(aiAssistant.isProcessing)
            
            Button(action: sendMessage) {
                Image(systemName: "arrow.up.circle.fill")
                    .font(.title2)
                    .foregroundColor(inputText.isEmpty || aiAssistant.isProcessing ? .gray : .blue)
            }
            .disabled(inputText.isEmpty || aiAssistant.isProcessing)
        }
        .padding()
        .background(Color(.systemBackground))
    }
    
    // MARK: - Functions
    private func checkAuthorization() {
        if !healthKitManager.isAuthorized {
            showPermissionAlert = true
        }
    }
    
    private func requestAuthorization() {
        Task {
            do {
                try await healthKitManager.requestAuthorization()
            } catch {
                errorMessage = error.localizedDescription
            }
        }
    }
    
    @State private var errorMessage: String?
    
    private func sendMessage() {
        guard !inputText.trimmingCharacters(in: .whitespaces).isEmpty else { return }
        
        // If not authorized, show helpful message
        guard healthKitManager.isAuthorized else {
            let userMsg = Message(content: inputText, isUser: true)
            messages.append(userMsg)
            inputText = ""
            
            let errorMsg = Message(
                content: "I need access to your HealthKit data. Please tap 'Enable' in the top right to grant permission.",
                isUser: false
            )
            messages.append(errorMsg)
            showPermissionAlert = true
            return
        }
        
        let userMessage = inputText
        inputText = ""
        isInputFocused = false
        
        // Add user message
        let userMsg = Message(content: userMessage, isUser: true)
        messages.append(userMsg)
        
        // Process with AI
        Task {
            do {
                let response = try await aiAssistant.processQuery(userMessage)
                let assistantMsg = Message(content: response, isUser: false)
                await MainActor.run {
                    messages.append(assistantMsg)
                }
            } catch {
                await MainActor.run {
                    let errorMsg = Message(content: "Sorry, I encountered an error: \(error.localizedDescription)", isUser: false)
                    messages.append(errorMsg)
                }
            }
        }
    }
}
