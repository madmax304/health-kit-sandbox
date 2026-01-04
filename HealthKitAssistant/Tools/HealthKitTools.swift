//
//  HealthKitTools.swift
//  HealthKitAssistant
//

import Foundation

// Tool functions that Foundation Models can call
// These wrap HealthKitManager queries and format data for the AI model

actor HealthKitTools {
    private let healthKitManager: HealthKitManager
    
    init(healthKitManager: HealthKitManager) {
        self.healthKitManager = healthKitManager
    }
    
    // Get steps for a date range
    func getSteps(startDate: Date, endDate: Date) async throws -> String {
        let count = try await healthKitManager.querySteps(startDate: startDate, endDate: endDate)
        return "The user took \(count) steps between \(formatDate(startDate)) and \(formatDate(endDate))."
    }
    
    // Get heart rate for a date range
    func getHeartRate(startDate: Date, endDate: Date) async throws -> String {
        let data = try await healthKitManager.queryHeartRate(startDate: startDate, endDate: endDate)
        
        if let average = data.average {
            let sampleCount = data.samples.count
            return "The user's average heart rate was \(Int(average)) bpm between \(formatDate(startDate)) and \(formatDate(endDate)). There were \(sampleCount) heart rate readings."
        } else {
            return "No heart rate data available between \(formatDate(startDate)) and \(formatDate(endDate))."
        }
    }
    
    // Get sleep for a date range
    func getSleep(startDate: Date, endDate: Date) async throws -> String {
        let sleepData = try await healthKitManager.querySleep(startDate: startDate, endDate: endDate)
        
        if sleepData.isEmpty {
            return "No sleep data available between \(formatDate(startDate)) and \(formatDate(endDate))."
        }
        
        var summary = "Sleep data between \(formatDate(startDate)) and \(formatDate(endDate)):\n"
        for (index, sleep) in sleepData.enumerated() {
            let hours = Int(sleep.duration / 3600)
            let minutes = Int((sleep.duration.truncatingRemainder(dividingBy: 3600)) / 60)
            summary += "Night \(index + 1): \(hours) hours \(minutes) minutes of sleep from \(formatDateTime(sleep.startDate)) to \(formatDateTime(sleep.endDate)).\n"
        }
        
        return summary
    }
    
    // Get active energy (calories) for a date range
    func getActiveEnergy(startDate: Date, endDate: Date) async throws -> String {
        let calories = try await healthKitManager.queryActiveEnergy(startDate: startDate, endDate: endDate)
        return "The user burned \(Int(calories)) active calories between \(formatDate(startDate)) and \(formatDate(endDate))."
    }
    
    // Helper to format dates
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(from: date)
    }
    
    // Helper to format date and time
    private func formatDateTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

