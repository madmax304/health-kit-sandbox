//
//  AIAssistantManager.swift
//  HealthKitAssistant
//

import Foundation

// Foundation Models framework (when available in iOS 26+)
#if canImport(FoundationModels)
import FoundationModels

// MARK: - Foundation Models Tools

// Get Steps Tool
struct GetStepsTool: Tool {
    let name = "getSteps"
    let description = "Get step count for a date range"
    
    private let healthKitTools: HealthKitTools
    
    init(healthKitTools: HealthKitTools) {
        self.healthKitTools = healthKitTools
    }
    
    @Generable
    struct Arguments {
        @Guide(description: "Start date for the query in ISO8601 format (YYYY-MM-DD)")
        let startDate: String
        
        @Guide(description: "End date for the query in ISO8601 format (YYYY-MM-DD)")
        let endDate: String
    }
    
    func call(arguments: Arguments) async throws -> String {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withFullDate]
        
        guard let startDate = formatter.date(from: arguments.startDate),
              let endDate = formatter.date(from: arguments.endDate) else {
            throw NSError(domain: "GetStepsTool", code: 1, userInfo: [NSLocalizedDescriptionKey: "Invalid date format"])
        }
        
        return try await healthKitTools.getSteps(startDate: startDate, endDate: endDate)
    }
}

// Get Heart Rate Tool
struct GetHeartRateTool: Tool {
    let name = "getHeartRate"
    let description = "Get heart rate data for a date range"
    
    private let healthKitTools: HealthKitTools
    
    init(healthKitTools: HealthKitTools) {
        self.healthKitTools = healthKitTools
    }
    
    @Generable
    struct Arguments {
        @Guide(description: "Start date for the query in ISO8601 format (YYYY-MM-DD)")
        let startDate: String
        
        @Guide(description: "End date for the query in ISO8601 format (YYYY-MM-DD)")
        let endDate: String
    }
    
    func call(arguments: Arguments) async throws -> String {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withFullDate]
        
        guard let startDate = formatter.date(from: arguments.startDate),
              let endDate = formatter.date(from: arguments.endDate) else {
            throw NSError(domain: "GetHeartRateTool", code: 1, userInfo: [NSLocalizedDescriptionKey: "Invalid date format"])
        }
        
        return try await healthKitTools.getHeartRate(startDate: startDate, endDate: endDate)
    }
}

// Get Sleep Tool
struct GetSleepTool: Tool {
    let name = "getSleep"
    let description = "Get sleep data for a date range"
    
    private let healthKitTools: HealthKitTools
    
    init(healthKitTools: HealthKitTools) {
        self.healthKitTools = healthKitTools
    }
    
    @Generable
    struct Arguments {
        @Guide(description: "Start date for the query in ISO8601 format (YYYY-MM-DD)")
        let startDate: String
        
        @Guide(description: "End date for the query in ISO8601 format (YYYY-MM-DD)")
        let endDate: String
    }
    
    func call(arguments: Arguments) async throws -> String {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withFullDate]
        
        guard let startDate = formatter.date(from: arguments.startDate),
              let endDate = formatter.date(from: arguments.endDate) else {
            throw NSError(domain: "GetSleepTool", code: 1, userInfo: [NSLocalizedDescriptionKey: "Invalid date format"])
        }
        
        return try await healthKitTools.getSleep(startDate: startDate, endDate: endDate)
    }
}

// Get Active Energy Tool
struct GetActiveEnergyTool: Tool {
    let name = "getActiveEnergy"
    let description = "Get active calories burned for a date range"
    
    private let healthKitTools: HealthKitTools
    
    init(healthKitTools: HealthKitTools) {
        self.healthKitTools = healthKitTools
    }
    
    @Generable
    struct Arguments {
        @Guide(description: "Start date for the query in ISO8601 format (YYYY-MM-DD)")
        let startDate: String
        
        @Guide(description: "End date for the query in ISO8601 format (YYYY-MM-DD)")
        let endDate: String
    }
    
    func call(arguments: Arguments) async throws -> String {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withFullDate]
        
        guard let startDate = formatter.date(from: arguments.startDate),
              let endDate = formatter.date(from: arguments.endDate) else {
            throw NSError(domain: "GetActiveEnergyTool", code: 1, userInfo: [NSLocalizedDescriptionKey: "Invalid date format"])
        }
        
        return try await healthKitTools.getActiveEnergy(startDate: startDate, endDate: endDate)
    }
}

#endif

@MainActor
class AIAssistantManager: ObservableObject {
    private let healthKitTools: HealthKitTools
    private let healthKitManager: HealthKitManager
    
    @Published var isProcessing = false
    @Published var errorMessage: String?
    
    #if canImport(FoundationModels)
    // Foundation Models
    private let model = SystemLanguageModel.default
    private var session: LanguageModelSession?
    
    // HealthKit tools for Foundation Models
    private var healthKitToolsForFM: [any Tool] = []
    #endif
    
    init(healthKitManager: HealthKitManager) {
        self.healthKitManager = healthKitManager
        self.healthKitTools = HealthKitTools(healthKitManager: healthKitManager)
        setupFoundationModels()
    }
    
    // Setup Foundation Models session
    private func setupFoundationModels() {
        #if canImport(FoundationModels)
        // Foundation Models framework is available!
        print("✅ Foundation Models framework detected")
        
        // Check model availability
        switch model.availability {
        case .available:
            print("✅ SystemLanguageModel is available")
            
            // Create tools
            createTools()
            
            // Create session with instructions for multi-turn conversations
            let instructions = """
            You are a helpful health assistant. You can access the user's HealthKit data 
            through available tools. When users ask about their health:
            
            1. Use the appropriate tools to fetch data
            2. Provide clear, encouraging insights
            3. Be specific with numbers and dates
            4. Offer helpful context when relevant
            5. Never provide medical advice
            """
            
            // Create session with tools and instructions
            // Tools must come before instructions in the initializer
            session = LanguageModelSession(tools: healthKitToolsForFM, instructions: instructions)
            print("✅ LanguageModelSession created with \(healthKitToolsForFM.count) tools and instructions")
            
        case .unavailable(.deviceNotEligible):
            print("⚠️ Model unavailable: Device not eligible for Apple Intelligence")
            print("   Falling back to pattern matching")
            
        case .unavailable(.appleIntelligenceNotEnabled):
            print("⚠️ Model unavailable: Apple Intelligence not enabled in Settings")
            print("   Please enable Apple Intelligence in Settings > Apple Intelligence")
            print("   Falling back to pattern matching")
            
        case .unavailable(.modelNotReady):
            print("⚠️ Model unavailable: Model not ready (downloading or system reasons)")
            print("   The model may still be downloading. Please wait and try again.")
            print("   Falling back to pattern matching")
            
        case .unavailable(let other):
            print("⚠️ Model unavailable: \(other)")
            print("   Falling back to pattern matching")
        }
        #else
        // Foundation Models framework not available - using pattern matching
        print("ℹ️ Using pattern matching (Foundation Models framework not available in SDK)")
        #endif
    }
    
    #if canImport(FoundationModels)
    // Create HealthKit tools for Foundation Models
    private func createTools() {
        healthKitToolsForFM = [
            GetStepsTool(healthKitTools: healthKitTools),
            GetHeartRateTool(healthKitTools: healthKitTools),
            GetSleepTool(healthKitTools: healthKitTools),
            GetActiveEnergyTool(healthKitTools: healthKitTools)
        ]
        print("✅ Created \(healthKitToolsForFM.count) HealthKit tools for Foundation Models")
    }
    #endif
    
    // Process a user query using Foundation Models
    func processQuery(_ userMessage: String) async throws -> String {
        await MainActor.run {
            isProcessing = true
            errorMessage = nil
        }
        
        defer {
            Task { @MainActor in
                isProcessing = false
            }
        }
        
        #if canImport(FoundationModels)
        // Use Foundation Models if available
        return try await processWithFoundationModels(userMessage)
        #else
        // Fallback to pattern matching for now
        return try await processWithPatternMatching(userMessage)
        #endif
    }
    
    #if canImport(FoundationModels)
    // Process query using Foundation Models
    private func processWithFoundationModels(_ userMessage: String) async throws -> String {
        // Check if model is available
        guard model.availability == .available else {
            print("⚠️ Foundation Models not available, falling back to pattern matching")
            return try await processWithPatternMatching(userMessage)
        }
        
        // Ensure session exists
        guard let session = session else {
            print("⚠️ LanguageModelSession not created, falling back to pattern matching")
            return try await processWithPatternMatching(userMessage)
        }
        
        // Check if session is already responding
        guard !session.isResponding else {
            print("⚠️ Session is already processing a request, falling back to pattern matching")
            return try await processWithPatternMatching(userMessage)
        }
        
        do {
            // Call the model with the user's message and tools
            // Tools are provided when calling respond()
            // Check documentation for exact method signature
            // Possible: respond(to:tools:) or respond(to:options:) with tools in options
            
            let response: LanguageModelSession.Response<String>
            
            // Call the model - tools are already registered with the session
            response = try await session.respond(to: userMessage)
            
            // Extract the string content from the response
            let responseText = response.content
            
            print("✅ Foundation Models generated response")
            return responseText
            
        } catch {
            print("❌ Foundation Models error: \(error)")
            
            // Handle specific errors
            if let generationError = error as? LanguageModelSession.GenerationError {
                switch generationError {
                case .exceededContextWindowSize(let size):
                    print("⚠️ Context window exceeded: \(size) tokens")
                    print("   Consider breaking up the conversation or starting a new session")
                default:
                    print("⚠️ Generation error: \(generationError)")
                }
            }
            
            print("   Falling back to pattern matching")
            return try await processWithPatternMatching(userMessage)
        }
    }
    #endif
    
    // Fallback: Process with pattern matching (current implementation)
    private func processWithPatternMatching(_ userMessage: String) async throws -> String {
        // First check if it's a general conversation query
        let lowercased = userMessage.lowercased().trimmingCharacters(in: .whitespaces)
        
        // Handle general conversation
        if lowercased.isEmpty {
            return "I'm here to help! Ask me about your health data."
        }
        
        if lowercased == "hello" || lowercased == "hi" || lowercased == "hey" {
            return "Hello! I'm your health assistant. I can help you understand your health data. Try asking about your steps, heart rate, sleep, or calories burned."
        }
        
        if lowercased.contains("help") {
            return """
            I can help you with:
            • Steps: "How many steps today?"
            • Heart rate: "What's my heart rate?"
            • Sleep: "How did I sleep?"
            • Calories: "How many calories did I burn?"
            
            Just ask me in natural language! If you haven't granted HealthKit permission yet, I'll help you do that.
            """
        }
        
        // Parse the query to determine intent and extract date ranges
        let (intent, startDate, endDate) = parseQuery(userMessage)
        
        // If unknown intent, provide helpful response
        guard intent != .unknown else {
            return generateHelpfulResponse(for: userMessage)
        }
        
        // Don't block based on authorization status check - let the actual queries try
        // Sometimes the status check is wrong but queries work
        // The queries themselves will throw proper errors if truly not authorized
        print("✅ AIAssistant: Processing query - intent: \(intent), date range: \(startDate) to \(endDate)")
        
        do {
            let result: String
            
            switch intent {
            case .steps:
                result = try await healthKitTools.getSteps(startDate: startDate, endDate: endDate)
            case .heartRate:
                result = try await healthKitTools.getHeartRate(startDate: startDate, endDate: endDate)
            case .sleep:
                result = try await healthKitTools.getSleep(startDate: startDate, endDate: endDate)
            case .activeEnergy:
                result = try await healthKitTools.getActiveEnergy(startDate: startDate, endDate: endDate)
            case .unknown:
                result = generateHelpfulResponse(for: userMessage)
            }
            
            print("✅ AIAssistant: Query successful, result: \(result.prefix(50))...")
            
            // Format the response in a natural way
            let response = formatResponse(for: intent, data: result, userQuery: userMessage)
            
            await MainActor.run {
                errorMessage = nil
            }
            
            return response
            
        } catch {
            // Handle HealthKit errors gracefully
            let errorDescription = error.localizedDescription.lowercased()
            
            if errorDescription.contains("authorization") || 
               errorDescription.contains("permission") ||
               errorDescription.contains("not authorized") {
                return "I need access to your HealthKit data to answer that question. Please tap 'Enable' in the top right corner to grant permission, or go to Settings > Privacy & Security > Health and enable access for HealthKitAssistant."
            }
            
            // For other errors, provide helpful message
            return "I had trouble accessing your health data. Make sure HealthKit permissions are granted and that you have health data available for that time period."
        }
    }
    
    // Generate a helpful response for unknown queries
    private func generateHelpfulResponse(for query: String) -> String {
        let lowercased = query.lowercased().trimmingCharacters(in: .whitespaces)
        
        // More conversational responses
        if lowercased.isEmpty {
            return "Hi! I'm your health assistant. What would you like to know about your health data?"
        }
        
        if lowercased == "hello" || lowercased == "hi" || lowercased == "hey" {
            return "Hello! 👋 I'm here to help you understand your health data. You can ask me about your steps, heart rate, sleep, calories, and more. What would you like to know?"
        }
        
        if lowercased.contains("help") {
            return """
            I can help you understand your health data! Here's what I can do:
            
            📊 **Activity & Fitness:**
            • "How many steps today?"
            • "What's my step count this week?"
            • "How many calories did I burn?"
            
            ❤️ **Heart Health:**
            • "What's my heart rate?"
            • "Show me my resting heart rate"
            
            😴 **Sleep:**
            • "How did I sleep?"
            • "How much sleep did I get last night?"
            
            Just ask me in natural language - I'll understand! If you need to grant HealthKit permission, I'll help you with that too.
            """
        }
        
        // Try to understand what they're asking about
        if lowercased.contains("what") || lowercased.contains("tell me") || lowercased.contains("show me") {
            return "I'd love to help! Could you be more specific? For example:\n• 'How many steps today?'\n• 'What's my heart rate?'\n• 'How did I sleep?'\n\nOr type 'help' to see all the things I can help with!"
        }
        
        // Default friendly response
        return "I'm not sure I understood that. I'm great at answering questions about your health data! Try asking:\n\n• 'How many steps today?'\n• 'What's my heart rate?'\n• 'How did I sleep?'\n• 'How many calories did I burn?'\n\nOr type 'help' for more options!"
    }
    
    // Parse user query to determine intent and date range
    private func parseQuery(_ query: String) -> (intent: QueryIntent, startDate: Date, endDate: Date) {
        let lowercased = query.lowercased()
        let calendar = Calendar.current
        
        // Determine intent - expanded to handle more natural language
        var intent: QueryIntent = .unknown
        
        // Steps: walk, walked, walking, distance, activity, active, move, moved, movement
        if lowercased.contains("step") || 
           lowercased.contains("walk") || 
           lowercased.contains("distance") ||
           (lowercased.contains("how") && lowercased.contains("active")) ||
           (lowercased.contains("much") && lowercased.contains("move")) {
            intent = .steps
        } 
        // Heart rate: heart, bpm, pulse, heartbeat, cardiac
        else if lowercased.contains("heart") || 
                lowercased.contains("bpm") || 
                lowercased.contains("pulse") ||
                lowercased.contains("heartbeat") ||
                lowercased.contains("cardiac") {
            intent = .heartRate
        } 
        // Sleep: sleep, slept, sleeping, rest, rested, bedtime, nap
        else if lowercased.contains("sleep") || 
                lowercased.contains("rest") ||
                lowercased.contains("bedtime") ||
                lowercased.contains("nap") {
            intent = .sleep
        } 
        // Calories/Energy: calorie, energy, burn, burned, burned calories, active calories
        else if lowercased.contains("calorie") || 
                (lowercased.contains("energy") && !lowercased.contains("heart")) ||
                lowercased.contains("burn") ||
                (lowercased.contains("active") && !lowercased.contains("step")) {
            intent = .activeEnergy
        }
        
        // Determine date range
        var startDate = Date()
        var endDate = Date()
        
        if lowercased.contains("today") {
            startDate = calendar.startOfDay(for: Date())
            endDate = calendar.date(byAdding: .day, value: 1, to: startDate) ?? Date()
        } else if lowercased.contains("yesterday") {
            startDate = calendar.startOfDay(for: calendar.date(byAdding: .day, value: -1, to: Date()) ?? Date())
            endDate = calendar.startOfDay(for: Date())
        } else if lowercased.contains("this week") || (lowercased.contains("week") && !lowercased.contains("last")) {
            startDate = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: Date())) ?? Date()
            endDate = Date()
        } else if lowercased.contains("last week") {
            let lastWeek = calendar.date(byAdding: .weekOfYear, value: -1, to: Date()) ?? Date()
            startDate = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: lastWeek)) ?? Date()
            endDate = calendar.date(byAdding: .day, value: 7, to: startDate) ?? Date()
        } else if lowercased.contains("this month") || (lowercased.contains("month") && !lowercased.contains("last")) {
            startDate = calendar.date(from: calendar.dateComponents([.year, .month], from: Date())) ?? Date()
            endDate = Date()
        } else if lowercased.contains("last month") {
            let lastMonth = calendar.date(byAdding: .month, value: -1, to: Date()) ?? Date()
            startDate = calendar.date(from: calendar.dateComponents([.year, .month], from: lastMonth)) ?? Date()
            endDate = calendar.date(from: calendar.dateComponents([.year, .month], from: Date())) ?? Date()
        } else {
            // Default to today
            startDate = calendar.startOfDay(for: Date())
            endDate = Date()
        }
        
        return (intent, startDate, endDate)
    }
    
    // Format response in a natural way
    private func formatResponse(for intent: QueryIntent, data: String, userQuery: String) -> String {
        // For now, return the data directly with some natural language wrapping
        // When Foundation Models is active, it will generate this automatically
        
        switch intent {
        case .steps:
            if let count = extractNumber(from: data) {
                return "You've taken \(count) steps. \(getStepsContext(count))"
            }
        case .heartRate:
            if let avg = extractHeartRate(from: data) {
                return "Your average heart rate is \(Int(avg)) bpm. \(getHeartRateContext(avg))"
            }
        case .sleep:
            return formatSleepResponse(data)
        case .activeEnergy:
            if let calories = extractCalories(from: data) {
                return "You've burned \(Int(calories)) active calories. \(getCaloriesContext(calories))"
            }
        case .unknown:
            return data
        }
        
        return data
    }
    
    // Helper functions for natural language responses
    private func extractNumber(from text: String) -> Int? {
        // Extract the first number before "steps"
        // Format: "The user took 29511 steps between..."
        if let stepsRange = text.range(of: "steps", options: .caseInsensitive) {
            let beforeSteps = String(text[..<stepsRange.lowerBound])
            // Find the last number before "steps"
            if let match = beforeSteps.range(of: #"\d+"#, options: .regularExpression, range: nil, locale: nil) {
                let numberString = String(beforeSteps[match])
                return Int(numberString)
            }
        }
        return nil
    }
    
    private func extractHeartRate(from text: String) -> Double? {
        // Extract number before "bpm"
        let pattern = #"(\d+)\s*bpm"#
        if let range = text.range(of: pattern, options: .regularExpression) {
            let match = String(text[range])
            if let numberRange = match.range(of: #"\d+"#, options: .regularExpression) {
                return Double(String(match[numberRange]))
            }
        }
        return nil
    }
    
    private func extractCalories(from text: String) -> Double? {
        // Extract the first number before "calories" or "active calories"
        // Format: "The user burned 372 active calories between..."
        if let caloriesRange = text.range(of: "calories", options: .caseInsensitive) {
            let beforeCalories = String(text[..<caloriesRange.lowerBound])
            // Find the last number before "calories"
            if let match = beforeCalories.range(of: #"\d+"#, options: .regularExpression, range: nil, locale: nil) {
                let numberString = String(beforeCalories[match])
                return Double(numberString)
            }
        }
        return nil
    }
    
    private func getStepsContext(_ count: Int) -> String {
        if count >= 10000 {
            return "Great job hitting your 10,000 step goal! 🎉"
        } else if count >= 8000 {
            return "You're doing well! Just \(10000 - count) more steps to reach your goal."
        } else {
            return "Keep moving! Try to reach 10,000 steps today."
        }
    }
    
    private func getHeartRateContext(_ bpm: Double) -> String {
        if bpm < 60 {
            return "Your heart rate is on the lower side, which is normal for well-trained athletes."
        } else if bpm > 100 {
            return "Your heart rate is elevated. This could be from exercise or stress."
        } else {
            return "Your heart rate is in a healthy range."
        }
    }
    
    private func getCaloriesContext(_ calories: Double) -> String {
        if calories >= 500 {
            return "Excellent activity level today! 💪"
        } else if calories >= 300 {
            return "Good activity! Keep it up."
        } else {
            return "Try to get more movement in today."
        }
    }
    
    private func formatSleepResponse(_ data: String) -> String {
        if data.contains("No sleep data") {
            return "I don't have sleep data for that period. Make sure your Apple Watch is tracking your sleep."
        }
        
        // Extract sleep duration from the data
        let lines = data.components(separatedBy: "\n")
        var response = "Here's your sleep data:\n\n"
        
        for line in lines where line.contains("hours") {
            response += "\(line)\n"
        }
        
        return response
    }
    
    enum QueryIntent {
        case steps
        case heartRate
        case sleep
        case activeEnergy
        case unknown
    }
}
