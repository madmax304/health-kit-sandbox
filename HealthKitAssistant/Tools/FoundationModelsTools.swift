//
//  FoundationModelsTools.swift
//  HealthKitAssistant
//
//  Tools that conform to Foundation Models Tool protocol
//

#if canImport(FoundationModels)
import FoundationModels
import Foundation

// MARK: - Get Steps Tool

struct GetStepsTool: Tool {
    let name = "getSteps"
    let description = "Get step count for a date range"
    
    private let healthKitTools: HealthKitTools
    
    init(healthKitTools: HealthKitTools) {
        self.healthKitTools = healthKitTools
    }
    
    @Generable
    struct Arguments {
        @Guide(description: "Start date for the query")
        let startDate: Date
        
        @Guide(description: "End date for the query")
        let endDate: Date
    }
    
    func call(arguments: Arguments) async throws -> String {
        return try await healthKitTools.getSteps(startDate: arguments.startDate, endDate: arguments.endDate)
    }
}

// MARK: - Get Heart Rate Tool

struct GetHeartRateTool: Tool {
    let name = "getHeartRate"
    let description = "Get heart rate data for a date range"
    
    private let healthKitTools: HealthKitTools
    
    init(healthKitTools: HealthKitTools) {
        self.healthKitTools = healthKitTools
    }
    
    @Generable
    struct Arguments {
        @Guide(description: "Start date for the query")
        let startDate: Date
        
        @Guide(description: "End date for the query")
        let endDate: Date
    }
    
    func call(arguments: Arguments) async throws -> String {
        return try await healthKitTools.getHeartRate(startDate: arguments.startDate, endDate: arguments.endDate)
    }
}

// MARK: - Get Sleep Tool

struct GetSleepTool: Tool {
    let name = "getSleep"
    let description = "Get sleep data for a date range"
    
    private let healthKitTools: HealthKitTools
    
    init(healthKitTools: HealthKitTools) {
        self.healthKitTools = healthKitTools
    }
    
    @Generable
    struct Arguments {
        @Guide(description: "Start date for the query")
        let startDate: Date
        
        @Guide(description: "End date for the query")
        let endDate: Date
    }
    
    func call(arguments: Arguments) async throws -> String {
        return try await healthKitTools.getSleep(startDate: arguments.startDate, endDate: arguments.endDate)
    }
}

// MARK: - Get Active Energy Tool

struct GetActiveEnergyTool: Tool {
    let name = "getActiveEnergy"
    let description = "Get active calories burned for a date range"
    
    private let healthKitTools: HealthKitTools
    
    init(healthKitTools: HealthKitTools) {
        self.healthKitTools = healthKitTools
    }
    
    @Generable
    struct Arguments {
        @Guide(description: "Start date for the query")
        let startDate: Date
        
        @Guide(description: "End date for the query")
        let endDate: Date
    }
    
    func call(arguments: Arguments) async throws -> String {
        return try await healthKitTools.getActiveEnergy(startDate: arguments.startDate, endDate: arguments.endDate)
    }
}

#endif
