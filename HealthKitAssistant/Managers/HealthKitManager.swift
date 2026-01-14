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
    @Published var hasQueriedSuccessfully: Bool = false // Track if queries have ever worked
    
    // Check if HealthKit is available
    var isHealthDataAvailable: Bool {
        HKHealthStore.isHealthDataAvailable()
    }
    
    init() {
        // Don't check authorization in init - do it asynchronously in onAppear
        // This prevents blocking the main thread on launch
    }
    
    // Check current authorization status
    func checkAuthorizationStatus() {
        guard isHealthDataAvailable else {
            authorizationStatus = .notDetermined
            isAuthorized = false
            return
        }
        
        // Check multiple types to get accurate authorization status
        // Some types might be authorized while others aren't
        let stepType = HKQuantityType.quantityType(forIdentifier: .stepCount)!
        let heartRateType = HKQuantityType.quantityType(forIdentifier: .heartRate)!
        let sleepType = HKCategoryType.categoryType(forIdentifier: .sleepAnalysis)!
        let energyType = HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned)!
        
        let stepStatus = healthStore.authorizationStatus(for: stepType)
        let heartRateStatus = healthStore.authorizationStatus(for: heartRateType)
        let sleepStatus = healthStore.authorizationStatus(for: sleepType)
        let energyStatus = healthStore.authorizationStatus(for: energyType)
        
        // IMPORTANT: The authorization status check is unreliable on iOS
        // Even when permissions are granted, status can show as denied
        // We'll check by attempting a query instead - if queries work, we're authorized
        // For UI purposes, we'll use a more lenient check
        
        // If status says authorized for ANY type, we're definitely authorized
        let hasAnyAuthorization = stepStatus == .sharingAuthorized || 
                                  heartRateStatus == .sharingAuthorized || 
                                  sleepStatus == .sharingAuthorized ||
                                  energyStatus == .sharingAuthorized
        
        // Use the step status as the primary indicator
        authorizationStatus = stepStatus
        
        // NOTE: We're setting isAuthorized based on status, but queries will work
        // even if this says false. The queries themselves will fail if truly not authorized.
        // For now, only set to true if status explicitly says authorized
        // This prevents the "Enable" button loop, but queries will still work
        isAuthorized = hasAnyAuthorization
        
        let statusString = { (status: HKAuthorizationStatus) -> String in
            switch status {
            case .notDetermined: return "notDetermined"
            case .sharingDenied: return "sharingDenied"
            case .sharingAuthorized: return "sharingAuthorized"
            @unknown default: return "unknown(\(status.rawValue))"
            }
        }
        
        print("🔐 Authorization status checked:")
        print("   Steps: \(statusString(stepStatus)) (raw: \(stepStatus.rawValue))")
        print("   Heart Rate: \(statusString(heartRateStatus)) (raw: \(heartRateStatus.rawValue))")
        print("   Sleep: \(statusString(sleepStatus)) (raw: \(sleepStatus.rawValue))")
        print("   Active Energy: \(statusString(energyStatus)) (raw: \(energyStatus.rawValue))")
        print("   Overall isAuthorized: \(isAuthorized)")
        
        // If status shows denied but user says it's enabled, try a test query
        // Sometimes the status check is wrong but actual queries work
        if !hasAnyAuthorization && stepStatus == .sharingDenied {
            print("⚠️ Status shows denied, but testing if we can actually read data...")
            // We'll test this by attempting a query in the actual query functions
        }
    }
    
    // Request authorization for reading health data
    func requestAuthorization() async throws {
        guard isHealthDataAvailable else {
            throw HealthKitError.notAvailable
        }
        
        // Check current status first - check multiple types
        let stepType = HKQuantityType.quantityType(forIdentifier: .stepCount)!
        let heartRateType = HKQuantityType.quantityType(forIdentifier: .heartRate)!
        let stepStatus = healthStore.authorizationStatus(for: stepType)
        let heartRateStatus = healthStore.authorizationStatus(for: heartRateType)
        
        // If ALL types are denied, we can't show the dialog again - user must go to Settings
        // But if any are authorized, we can still request the others
        if stepStatus == .sharingDenied && heartRateStatus == .sharingDenied {
            print("🔐 All permissions were previously denied. User must go to Settings.")
            throw HealthKitError.authorizationDenied
        }
        
        // If some are already authorized, that's fine - we'll just request the rest
        if stepStatus == .sharingAuthorized || heartRateStatus == .sharingAuthorized {
            print("🔐 Some permissions already granted, requesting remaining types...")
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
        
        print("🔐 Requesting HealthKit authorization...")
        try await healthStore.requestAuthorization(toShare: Set<HKSampleType>(), read: typesToRead)
        print("🔐 Authorization request completed")
        
        // Give the system a moment to update the authorization status
        try? await Task.sleep(nanoseconds: 100_000_000) // 0.1 seconds
        
        // Update status on main thread
        await MainActor.run {
            self.checkAuthorizationStatus()
        }
    }
    
    // Query steps for a date range
    func querySteps(startDate: Date, endDate: Date) async throws -> Int {
        let stepType = HKQuantityType.quantityType(forIdentifier: .stepCount)!
        let authStatus = healthStore.authorizationStatus(for: stepType)
        
        print("🔍 Querying steps - Authorization status: \(authStatus.rawValue) (\(authStatus == .sharingAuthorized ? "authorized" : authStatus == .sharingDenied ? "denied" : "notDetermined"))")
        
        // Try the query even if status says denied - sometimes the status check is wrong
        // but the actual query will work if permissions are really enabled
        // The query itself will fail with a clear error if we're truly not authorized
        print("✅ Attempting to query steps from \(startDate) to \(endDate)")
        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: .strictStartDate)
        
        return try await withCheckedThrowingContinuation { continuation in
            let query = HKSampleQuery(
                sampleType: stepType,
                predicate: predicate,
                limit: HKObjectQueryNoLimit,
                sortDescriptors: [NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)]
            ) { query, samples, error in
                if let error = error {
                    print("❌ Steps query error: \(error.localizedDescription)")
                    // Check if it's an authorization error
                    let nsError = error as NSError
                    print("   Error domain: \(nsError.domain), code: \(nsError.code)")
                    if nsError.domain == "com.apple.healthkit" && nsError.code == 4 {
                        print("❌ This is an authorization error (code 4) - permission truly denied")
                        print("   This means the query itself failed, not just the status check")
                    }
                    continuation.resume(throwing: error)
                    return
                }
                
                guard let samples = samples as? [HKQuantitySample] else {
                    print("ℹ️ Steps query returned no samples (this is OK if no data exists)")
                    continuation.resume(returning: 0)
                    return
                }
                
                print("✅ Steps query successful! Found \(samples.count) samples")
                
                // Mark that queries work (permissions are actually granted)
                Task { @MainActor in
                    self.hasQueriedSuccessfully = true
                    self.isAuthorized = true
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
        let authStatus = healthStore.authorizationStatus(for: heartRateType)
        print("🔍 Querying heart rate - Status: \(authStatus.rawValue), attempting query...")
        // Don't block - let the query run, it will fail if truly not authorized
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
                
                // Mark that queries work (permissions are actually granted)
                Task { @MainActor in
                    self.hasQueriedSuccessfully = true
                    self.isAuthorized = true
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
        let authStatus = healthStore.authorizationStatus(for: sleepType)
        print("🔍 Querying sleep - Status: \(authStatus.rawValue), attempting query...")
        // Don't block - let the query run, it will fail if truly not authorized
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
                
                // Mark that queries work (permissions are actually granted)
                Task { @MainActor in
                    self.hasQueriedSuccessfully = true
                    self.isAuthorized = true
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
        let authStatus = healthStore.authorizationStatus(for: energyType)
        print("🔍 Querying active energy - Status: \(authStatus.rawValue), attempting query...")
        // Don't block - let the query run, it will fail if truly not authorized
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
                
                // Mark that queries work (permissions are actually granted)
                Task { @MainActor in
                    self.hasQueriedSuccessfully = true
                    self.isAuthorized = true
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

