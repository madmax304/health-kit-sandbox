# HealthKit Testing Guide - Development Environment

## Overview

Testing HealthKit data points requires different strategies depending on what you're testing. The iOS Simulator has limitations, so a combination of simulator testing, real device testing, and mock data is typically needed.

---

## 🖥️ iOS Simulator Testing

### Capabilities
- ✅ Can test HealthKit API integration
- ✅ Can test permission flows
- ✅ Can manually add sample data via Health app
- ✅ Can test data reading/writing logic

### Limitations
- ❌ No real sensor data (no automatic step counting, heart rate, etc.)
- ❌ No Apple Watch integration
- ❌ Limited background data collection
- ❌ Some data types may not be fully supported

### How to Add Test Data in Simulator

1. **Open Health App in Simulator**
   - Launch the Health app
   - Navigate to "Browse" tab
   - Select a category (e.g., Activity, Heart, Sleep)
   - Tap the "+" button to add data manually

2. **Manual Data Entry**
   - Enter values for specific dates/times
   - Can add multiple data points
   - Useful for testing specific scenarios

### Simulator Setup

```swift
// In your Xcode project:
// 1. Go to Signing & Capabilities
// 2. Click "+ Capability"
// 3. Add "HealthKit"
// 4. This adds the HealthKit entitlement automatically
```

---

## 📱 Real Device Testing

### Why Real Devices Are Essential

- **Sensor Data**: Access to actual accelerometer, gyroscope, barometer data
- **Apple Watch**: Can test watch-specific features (heart rate, ECG, etc.)
- **Background Collection**: Real background data collection behavior
- **Performance**: Actual performance with real data volumes
- **User Experience**: Real permission flows and user interactions

### Device Requirements

- **iPhone**: For basic activity tracking
- **Apple Watch**: For watch-specific features (Series 4+ for ECG, Series 6+ for SpO₂)
- **Test Account**: Use a dedicated test Apple ID

### Testing Checklist

- [ ] Test permission requests
- [ ] Test data reading with real sensor data
- [ ] Test data writing
- [ ] Test background updates
- [ ] Test with Apple Watch connected
- [ ] Test with no data available
- [ ] Test permission denial scenarios

---

## 🧪 Programmatic Test Data Creation

### Creating Sample Data in Code

You can programmatically create HealthKit samples for testing:

```swift
import HealthKit

class HealthKitTestDataGenerator {
    let healthStore = HKHealthStore()
    
    // Request authorization first
    func requestAuthorization(completion: @escaping (Bool, Error?) -> Void) {
        guard HKHealthStore.isHealthDataAvailable() else {
            completion(false, NSError(domain: "HealthKit", code: -1))
            return
        }
        
        let typesToRead: Set<HKObjectType> = [
            HKObjectType.quantityType(forIdentifier: .stepCount)!,
            HKObjectType.quantityType(forIdentifier: .heartRate)!,
            HKObjectType.quantityType(forIdentifier: .activeEnergyBurned)!
        ]
        
        let typesToWrite: Set<HKSampleType> = [
            HKObjectType.quantityType(forIdentifier: .stepCount)!,
            HKObjectType.quantityType(forIdentifier: .heartRate)!,
            HKObjectType.quantityType(forIdentifier: .activeEnergyBurned)!
        ]
        
        healthStore.requestAuthorization(toShare: typesToWrite, 
                                        read: typesToRead, 
                                        completion: completion)
    }
    
    // Create sample step count data
    func createStepCountSample(count: Double, date: Date) -> HKQuantitySample {
        let stepCountType = HKQuantityType.quantityType(forIdentifier: .stepCount)!
        let stepCountQuantity = HKQuantity(unit: HKUnit.count(), doubleValue: count)
        
        return HKQuantitySample(
            type: stepCountType,
            quantity: stepCountQuantity,
            start: date,
            end: date,
            metadata: nil
        )
    }
    
    // Create sample heart rate data
    func createHeartRateSample(bpm: Double, date: Date) -> HKQuantitySample {
        let heartRateType = HKQuantityType.quantityType(forIdentifier: .heartRate)!
        let heartRateQuantity = HKQuantity(unit: HKUnit(from: "count/min"), doubleValue: bpm)
        
        return HKQuantitySample(
            type: heartRateType,
            quantity: heartRateQuantity,
            start: date,
            end: date,
            metadata: nil
        )
    }
    
    // Create sample active energy data
    func createActiveEnergySample(kilocalories: Double, date: Date) -> HKQuantitySample {
        let energyType = HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned)!
        let energyQuantity = HKQuantity(unit: HKUnit.kilocalorie(), doubleValue: kilocalories)
        
        return HKQuantitySample(
            type: energyType,
            quantity: energyQuantity,
            start: date,
            end: date,
            metadata: nil
        )
    }
    
    // Create sample sleep data
    func createSleepSample(startDate: Date, endDate: Date) -> HKCategorySample {
        let sleepType = HKCategoryType.categoryType(forIdentifier: .sleepAnalysis)!
        
        return HKCategorySample(
            type: sleepType,
            value: HKCategoryValueSleepAnalysis.asleep.rawValue,
            start: startDate,
            end: endDate,
            metadata: nil
        )
    }
    
    // Save sample to HealthKit
    func saveSample(_ sample: HKSample, completion: @escaping (Bool, Error?) -> Void) {
        healthStore.save(sample, withCompletion: completion)
    }
    
    // Generate test data for a date range
    func generateTestDataForWeek(startingFrom date: Date) {
        let calendar = Calendar.current
        
        for dayOffset in 0..<7 {
            guard let dayDate = calendar.date(byAdding: .day, value: dayOffset, to: date) else { continue }
            
            // Generate steps (8000-12000 per day)
            let steps = Double.random(in: 8000...12000)
            let stepSample = createStepCountSample(count: steps, date: dayDate)
            saveSample(stepSample) { success, error in
                if let error = error {
                    print("Error saving steps: \(error)")
                }
            }
            
            // Generate heart rate samples throughout the day
            for hour in 6...22 {
                guard let hourDate = calendar.date(bySettingHour: hour, minute: 0, second: 0, of: dayDate) else { continue }
                let bpm = Double.random(in: 60...100)
                let hrSample = createHeartRateSample(bpm: bpm, date: hourDate)
                saveSample(hrSample) { success, error in
                    if let error = error {
                        print("Error saving heart rate: \(error)")
                    }
                }
            }
            
            // Generate active energy
            let calories = Double.random(in: 300...800)
            let energySample = createActiveEnergySample(kilocalories: calories, date: dayDate)
            saveSample(energySample) { success, error in
                if let error = error {
                    print("Error saving energy: \(error)")
                }
            }
        }
    }
}
```

### Usage Example

```swift
let generator = HealthKitTestDataGenerator()

generator.requestAuthorization { success, error in
    if success {
        // Generate test data for the past week
        let weekAgo = Calendar.current.date(byAdding: .day, value: -7, to: Date())!
        generator.generateTestDataForWeek(startingFrom: weekAgo)
    }
}
```

---

## 🎭 Mock Data Strategy

### Dependency Injection Pattern

Create a protocol to abstract HealthKit access:

```swift
protocol HealthDataProvider {
    func fetchSteps(startDate: Date, endDate: Date, completion: @escaping ([HKQuantitySample]) -> Void)
    func fetchHeartRate(startDate: Date, endDate: Date, completion: @escaping ([HKQuantitySample]) -> Void)
}

class HealthKitProvider: HealthDataProvider {
    let healthStore = HKHealthStore()
    
    func fetchSteps(startDate: Date, endDate: Date, completion: @escaping ([HKQuantitySample]) -> Void) {
        let stepType = HKQuantityType.quantityType(forIdentifier: .stepCount)!
        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: .strictStartDate)
        
        let query = HKSampleQuery(sampleType: stepType, predicate: predicate, limit: HKObjectQueryNoLimit, sortDescriptors: nil) { query, samples, error in
            guard let samples = samples as? [HKQuantitySample] else {
                completion([])
                return
            }
            completion(samples)
        }
        
        healthStore.execute(query)
    }
    
    func fetchHeartRate(startDate: Date, endDate: Date, completion: @escaping ([HKQuantitySample]) -> Void) {
        // Similar implementation for heart rate
    }
}

class MockHealthDataProvider: HealthDataProvider {
    func fetchSteps(startDate: Date, endDate: Date, completion: @escaping ([HKQuantitySample]) -> Void) {
        // Return mock data for testing
        let mockSamples = createMockStepSamples(startDate: startDate, endDate: endDate)
        completion(mockSamples)
    }
    
    func fetchHeartRate(startDate: Date, endDate: Date, completion: @escaping ([HKQuantitySample]) -> Void) {
        // Return mock heart rate data
    }
    
    private func createMockStepSamples(startDate: Date, endDate: Date) -> [HKQuantitySample] {
        // Generate mock samples
        return []
    }
}
```

### Unit Testing with Mocks

```swift
class HealthDataServiceTests: XCTestCase {
    var mockProvider: MockHealthDataProvider!
    var service: HealthDataService!
    
    override func setUp() {
        super.setUp()
        mockProvider = MockHealthDataProvider()
        service = HealthDataService(provider: mockProvider)
    }
    
    func testStepCountAggregation() {
        let expectation = XCTestExpectation(description: "Steps fetched")
        
        service.getDailySteps { steps in
            XCTAssertEqual(steps, 10000)
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1.0)
    }
}
```

---

## 🔧 Testing Tools & Utilities

### 1. Health App Export/Import

**Export Real Data:**
- Open Health app on device
- Go to Profile tab
- Tap "Export Health Data"
- Share the XML file

**Import to Test Device:**
- Open Health app on test device
- Go to Profile tab
- Tap "Import Health Data"
- Select the exported file

### 2. Third-Party Testing Tools

**HealthKit Sample Data Generator (if available):**
- Search GitHub for HealthKit test data generators
- Some developers create utilities to generate realistic test data

### 3. Custom Test Builds

Create a debug-only test data generator in your app:

```swift
#if DEBUG
class DebugHealthKitHelper {
    static func populateTestData() {
        // Only available in debug builds
        let generator = HealthKitTestDataGenerator()
        generator.generateTestDataForWeek(startingFrom: Date())
    }
}
#endif
```

---

## 📋 Testing Checklist

### Permission Testing
- [ ] Test initial permission request
- [ ] Test permission denial
- [ ] Test partial permission (some types allowed, others denied)
- [ ] Test permission re-request after denial
- [ ] Test app behavior when permissions are revoked

### Data Reading
- [ ] Test reading with no data available
- [ ] Test reading with limited data
- [ ] Test reading with large datasets
- [ ] Test date range queries
- [ ] Test data aggregation
- [ ] Test handling of missing data types

### Data Writing
- [ ] Test writing valid data
- [ ] Test writing invalid data (error handling)
- [ ] Test writing duplicate data
- [ ] Test data source priority
- [ ] Test metadata handling

### Device-Specific Testing
- [ ] Test on iPhone only (no watch)
- [ ] Test with Apple Watch connected
- [ ] Test watch-specific features (ECG, SpO₂)
- [ ] Test background data collection
- [ ] Test data sync between devices

### Edge Cases
- [ ] Test with device in airplane mode
- [ ] Test with HealthKit disabled
- [ ] Test with corrupted data
- [ ] Test with very old data
- [ ] Test with future-dated data
- [ ] Test timezone handling

---

## 🚨 Common Testing Issues

### Issue: Simulator Shows No Data
**Solution:** Manually add data via Health app, or use programmatic data generation

### Issue: Permission Denied
**Solution:** Reset simulator/device, or revoke and re-grant permissions in Settings > Health > Data Access & Devices

### Issue: Background Updates Not Working
**Solution:** Test on real device - simulator has limited background capabilities

### Issue: Watch Data Not Appearing
**Solution:** Ensure watch is paired, Health app has permissions, and watch is being worn

### Issue: Data Not Syncing
**Solution:** Check iCloud Health sync is enabled, ensure devices are signed into same Apple ID

---

## 📝 Best Practices

1. **Always Test on Real Devices**: Simulator is for initial development only
2. **Use Mock Data for Unit Tests**: Don't depend on HealthKit in unit tests
3. **Test Permission Flows**: Users will deny permissions - handle gracefully
4. **Test with No Data**: Your app should work even with empty HealthKit
5. **Test Data Validation**: Ensure your app handles invalid/corrupted data
6. **Test Performance**: Large datasets can be slow - optimize queries
7. **Test Privacy**: Never log or expose health data in debug builds

---

## 🔐 Privacy & Security Testing

- [ ] Verify data is encrypted at rest
- [ ] Verify data is encrypted in transit
- [ ] Test that data is not logged in console
- [ ] Test that data is not sent to analytics without consent
- [ ] Verify HIPAA compliance (if applicable)
- [ ] Test data deletion when app is uninstalled

---

## 📚 Additional Resources

- [Apple HealthKit Documentation](https://developer.apple.com/documentation/healthkit)
- [HealthKit Programming Guide](https://developer.apple.com/library/archive/documentation/HealthKit/Articles/HealthKitOverview.html)
- [HealthKit Sample Code](https://developer.apple.com/documentation/healthkit/samples)

---

## Quick Reference: Testing by Data Type

| Data Type | Simulator | Real Device | Watch Required |
|-----------|-----------|-------------|----------------|
| Steps | Manual entry | ✅ Auto | ❌ No |
| Heart Rate | Manual entry | ❌ No | ✅ Yes |
| Sleep Stages | Manual entry | ❌ No | ✅ Yes |
| ECG | ❌ No | ❌ No | ✅ Series 4+ |
| SpO₂ | ❌ No | ❌ No | ✅ Series 6+ |
| Distance | Manual entry | ✅ Auto | ❌ No |
| Active Energy | Manual entry | Limited | ✅ Yes (accurate) |
| Workouts | Manual entry | Limited | ✅ Yes |

