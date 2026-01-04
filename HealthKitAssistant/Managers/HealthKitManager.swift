//
//  HealthKitManager.swift
//  HealthKitAssistant
//

import Foundation
import HealthKit

@MainActor
class HealthKitManager: ObservableObject {
    private let healthStore = HKHealthStore()
    
    @Published var authorizationStatus: HKAuthorizationStatus = .notDetermined
    @Published var isAuthorized: Bool = false
    
    // Check if HealthKit is available
    var isHealthDataAvailable: Bool {
        HKHealthStore.isHealthDataAvailable()
    }
    
    init() {
        checkAuthorizationStatus()
    }
    
    // Check current authorization status
    func checkAuthorizationStatus() {
        guard isHealthDataAvailable else {
            authorizationStatus = .notDetermined
            isAuthorized = false
            return
        }
        
        let stepType = HKQuantityType.quantityType(forIdentifier: .stepCount)!
        authorizationStatus = healthStore.authorizationStatus(for: stepType)
        isAuthorized = authorizationStatus == .sharingAuthorized
    }
    
    // Request authorization for reading health data
    func requestAuthorization() async throws {
        guard isHealthDataAvailable else {
            throw HealthKitError.notAvailable
        }
        
        // Define data types we want to read
        let typesToRead: Set<HKObjectType> = [
            HKQuantityType.quantityType(forIdentifier: .stepCount)!,
            HKQuantityType.quantityType(forIdentifier: .heartRate)!,
            HKQuantityType.quantityType(forIdentifier: .restingHeartRate)!,
            HKQuantityType.quantityType(forIdentifier: .heartRateVariabilitySDNN)!,
            HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned)!,
            HKQuantityType.quantityType(forIdentifier: .basalEnergyBurned)!,
            HKQuantityType.quantityType(forIdentifier: .appleExerciseTime)!,
            HKQuantityType.quantityType(forIdentifier: .distanceWalkingRunning)!,
            HKCategoryType.categoryType(forIdentifier: .sleepAnalysis)!,
            HKWorkoutType.workoutType()
        ]
        
        try await healthStore.requestAuthorization(toShare: Set<HKSampleType>(), read: typesToRead)
        
        // Update status
        checkAuthorizationStatus()
    }
    
    // Query steps for a date range
    func querySteps(startDate: Date, endDate: Date) async throws -> Int {
        let stepType = HKQuantityType.quantityType(forIdentifier: .stepCount)!
        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: .strictStartDate)
        
        return try await withCheckedThrowingContinuation { continuation in
            let query = HKSampleQuery(
                sampleType: stepType,
                predicate: predicate,
                limit: HKObjectQueryNoLimit,
                sortDescriptors: [NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)]
            ) { query, samples, error in
                if let error = error {
                    continuation.resume(throwing: error)
                    return
                }
                
                guard let samples = samples as? [HKQuantitySample] else {
                    continuation.resume(returning: 0)
                    return
                }
                
                let total = samples.reduce(0.0) { total, sample in
                    total + sample.quantity.doubleValue(for: HKUnit.count())
                }
                
                continuation.resume(returning: Int(total))
            }
            
            healthStore.execute(query)
        }
    }
    
    // Query heart rate for a date range
    func queryHeartRate(startDate: Date, endDate: Date) async throws -> HeartRateData {
        let heartRateType = HKQuantityType.quantityType(forIdentifier: .heartRate)!
        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: .strictStartDate)
        
        return try await withCheckedThrowingContinuation { continuation in
            let query = HKSampleQuery(
                sampleType: heartRateType,
                predicate: predicate,
                limit: HKObjectQueryNoLimit,
                sortDescriptors: [NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)]
            ) { query, samples, error in
                if let error = error {
                    continuation.resume(throwing: error)
                    return
                }
                
                guard let samples = samples as? [HKQuantitySample] else {
                    continuation.resume(returning: HeartRateData(average: nil, samples: []))
                    return
                }
                
                let heartRateUnit = HKUnit(from: "count/min")
                let samplesData = samples.map { sample in
                    HeartRateData.HeartRateSample(
                        value: sample.quantity.doubleValue(for: heartRateUnit),
                        timestamp: sample.startDate
                    )
                }
                
                let average = samplesData.isEmpty ? nil : samplesData.map { $0.value }.reduce(0, +) / Double(samplesData.count)
                
                continuation.resume(returning: HeartRateData(average: average, samples: samplesData))
            }
            
            healthStore.execute(query)
        }
    }
    
    // Query sleep for a date range
    func querySleep(startDate: Date, endDate: Date) async throws -> [SleepData] {
        let sleepType = HKCategoryType.categoryType(forIdentifier: .sleepAnalysis)!
        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: .strictStartDate)
        
        return try await withCheckedThrowingContinuation { continuation in
            let query = HKSampleQuery(
                sampleType: sleepType,
                predicate: predicate,
                limit: HKObjectQueryNoLimit,
                sortDescriptors: [NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)]
            ) { query, samples, error in
                if let error = error {
                    continuation.resume(throwing: error)
                    return
                }
                
                guard let samples = samples as? [HKCategorySample] else {
                    continuation.resume(returning: [])
                    return
                }
                
                // Group sleep samples by night
                var sleepData: [SleepData] = []
                var currentSleep: SleepData?
                
                for sample in samples.sorted(by: { $0.startDate < $1.startDate }) {
                    let stageType: String
                    switch sample.value {
                    case HKCategoryValueSleepAnalysis.asleepUnspecified.rawValue:
                        stageType = "asleep"
                    case HKCategoryValueSleepAnalysis.inBed.rawValue:
                        stageType = "inBed"
                    case HKCategoryValueSleepAnalysis.awake.rawValue:
                        stageType = "awake"
                    case HKCategoryValueSleepAnalysis.asleepCore.rawValue:
                        stageType = "asleepCore"
                    case HKCategoryValueSleepAnalysis.asleepDeep.rawValue:
                        stageType = "asleepDeep"
                    case HKCategoryValueSleepAnalysis.asleepREM.rawValue:
                        stageType = "asleepREM"
                    default:
                        stageType = "unknown"
                    }
                    
                    let stage = SleepData.SleepStage(
                        type: stageType,
                        start: sample.startDate,
                        end: sample.endDate
                    )
                    
                    // If this is the start of a new sleep session
                    if currentSleep == nil || sample.startDate.timeIntervalSince(currentSleep!.endDate) > 3600 {
                        if let previous = currentSleep {
                            sleepData.append(previous)
                        }
                        currentSleep = SleepData(
                            duration: sample.endDate.timeIntervalSince(sample.startDate),
                            startDate: sample.startDate,
                            endDate: sample.endDate,
                            stages: [stage]
                        )
                    } else {
                        // Add to current sleep session
                        currentSleep = SleepData(
                            duration: currentSleep!.endDate.timeIntervalSince(currentSleep!.startDate),
                            startDate: currentSleep!.startDate,
                            endDate: max(currentSleep!.endDate, sample.endDate),
                            stages: currentSleep!.stages + [stage]
                        )
                    }
                }
                
                if let final = currentSleep {
                    sleepData.append(final)
                }
                
                continuation.resume(returning: sleepData)
            }
            
            healthStore.execute(query)
        }
    }
    
    // Query active energy (calories) for a date range
    func queryActiveEnergy(startDate: Date, endDate: Date) async throws -> Double {
        let energyType = HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned)!
        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: .strictStartDate)
        
        return try await withCheckedThrowingContinuation { continuation in
            let query = HKStatisticsQuery(
                quantityType: energyType,
                quantitySamplePredicate: predicate,
                options: .cumulativeSum
            ) { query, statistics, error in
                if let error = error {
                    continuation.resume(throwing: error)
                    return
                }
                
                guard let statistics = statistics,
                      let sum = statistics.sumQuantity() else {
                    continuation.resume(returning: 0.0)
                    return
                }
                
                let calories = sum.doubleValue(for: HKUnit.kilocalorie())
                continuation.resume(returning: calories)
            }
            
            healthStore.execute(query)
        }
    }
}

// Custom errors
enum HealthKitError: LocalizedError {
    case notAvailable
    case authorizationDenied
    case queryFailed
    
    var errorDescription: String? {
        switch self {
        case .notAvailable:
            return "HealthKit is not available on this device"
        case .authorizationDenied:
            return "HealthKit authorization was denied"
        case .queryFailed:
            return "Failed to query HealthKit data"
        }
    }
}

