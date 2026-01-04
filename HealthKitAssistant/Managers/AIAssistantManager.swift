//
//  AIAssistantManager.swift
//  HealthKitAssistant
//

import Foundation

@MainActor
class AIAssistantManager: ObservableObject {
    private let healthKitTools: HealthKitTools
    private let healthKitManager: HealthKitManager
    
    @Published var isProcessing = false
    @Published var errorMessage: String?
    
    // Note: Foundation Models framework API may vary
    // This is a placeholder structure - actual implementation will depend on
    // the exact Foundation Models API when iOS 18+ is available
    
    init(healthKitManager: HealthKitManager) {
        self.healthKitManager = healthKitManager
        self.healthKitTools = HealthKitTools(healthKitManager: healthKitManager)
    }
    
    // Process a user query and generate a response
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
        
        // Parse the query to determine intent and extract date ranges
        let (intent, startDate, endDate) = parseQuery(userMessage)
        
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
                result = "I can help you with steps, heart rate, sleep, and active calories. Try asking something like 'How many steps today?' or 'What's my heart rate?'"
            }
            
            // Format the response in a natural way
            let response = formatResponse(for: intent, data: result, userQuery: userMessage)
            
            await MainActor.run {
                errorMessage = nil
            }
            
            return response
            
        } catch {
            await MainActor.run {
                errorMessage = error.localizedDescription
            }
            throw error
        }
    }
    
    // Parse user query to determine intent and date range
    private func parseQuery(_ query: String) -> (intent: QueryIntent, startDate: Date, endDate: Date) {
        let lowercased = query.lowercased()
        let calendar = Calendar.current
        
        // Determine intent
        var intent: QueryIntent = .unknown
        if lowercased.contains("step") {
            intent = .steps
        } else if lowercased.contains("heart") || lowercased.contains("bpm") || lowercased.contains("pulse") {
            intent = .heartRate
        } else if lowercased.contains("sleep") {
            intent = .sleep
        } else if lowercased.contains("calorie") || lowercased.contains("energy") || lowercased.contains("burned") {
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
        } else if lowercased.contains("this week") || lowercased.contains("week") {
            startDate = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: Date())) ?? Date()
            endDate = Date()
        } else if lowercased.contains("last week") {
            let lastWeek = calendar.date(byAdding: .weekOfYear, value: -1, to: Date()) ?? Date()
            startDate = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: lastWeek)) ?? Date()
            endDate = calendar.date(byAdding: .day, value: 7, to: startDate) ?? Date()
        } else if lowercased.contains("this month") || lowercased.contains("month") {
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
        // For now, return the data directly
        // In a full Foundation Models implementation, the model would generate this
        return data
    }
    
    enum QueryIntent {
        case steps
        case heartRate
        case sleep
        case activeEnergy
        case unknown
    }
}

