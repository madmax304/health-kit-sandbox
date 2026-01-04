//
//  HealthDataModels.swift
//  HealthKitAssistant
//

import Foundation

// Data models for HealthKit query results
struct StepData: Codable {
    let count: Int
    let dateRange: DateRange
    
    struct DateRange: Codable {
        let start: Date
        let end: Date
    }
}

struct HeartRateData: Codable {
    let average: Double?
    let samples: [HeartRateSample]
    
    struct HeartRateSample: Codable {
        let value: Double
        let timestamp: Date
    }
}

struct SleepData: Codable {
    let duration: TimeInterval // in seconds
    let startDate: Date
    let endDate: Date
    let stages: [SleepStage]
    
    struct SleepStage: Codable {
        let type: String // "asleep", "inBed", "awake"
        let start: Date
        let end: Date
    }
}

struct ActiveEnergyData: Codable {
    let calories: Double
    let dateRange: DateRange
    
    struct DateRange: Codable {
        let start: Date
        let end: Date
    }
}

