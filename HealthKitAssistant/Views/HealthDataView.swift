//
//  HealthDataView.swift
//  HealthKitAssistant
//

import SwiftUI
import HealthKit

struct HealthDataView: View {
    @StateObject private var healthKitManager = HealthKitManager()
    @State private var todaySteps: Int = 0
    @State private var todayCalories: Double = 0
    @State private var avgHeartRate: Double? = nil
    @State private var lastNightSleep: Double? = nil
    @State private var isLoading = true
    @State private var errorMessage: String? = nil
    @State private var showSettingsAlert = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(.systemGroupedBackground)
                
                if isLoading {
                    ProgressView("Loading health data...")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if let error = errorMessage {
                    VStack(spacing: 16) {
                        Image(systemName: "exclamationmark.triangle")
                            .font(.system(size: 50))
                            .foregroundColor(.orange)
                        Text(error)
                            .font(.body)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                        
                        // Only show Enable button if queries haven't worked yet
                        if !healthKitManager.hasQueriedSuccessfully && healthKitManager.authorizationStatus == .notDetermined {
                            Button("Enable HealthKit") {
                                requestAuthorization()
                            }
                            .buttonStyle(.borderedProminent)
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    ScrollView {
                        VStack(spacing: 20) {
                            // Today's Summary
                            summaryCard
                            
                            // Activity Metrics
                            activitySection
                            
                            // Heart Health
                            heartSection
                            
                            // Sleep
                            sleepSection
                        }
                        .padding()
                    }
                }
            }
            .navigationTitle("Health Data")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    // Only show Enable button if queries haven't worked yet
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
            .onAppear {
                // Check authorization status first
                Task { @MainActor in
                    healthKitManager.checkAuthorizationStatus()
                    loadHealthData()
                }
            }
            .onReceive(NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)) { _ in
                // Check authorization and refresh when app comes back from Settings
                Task { @MainActor in
                    healthKitManager.checkAuthorizationStatus()
                    await refreshData()
                }
            }
            .refreshable {
                await refreshData()
            }
            .alert("HealthKit Permission Required", isPresented: $showSettingsAlert) {
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
    }
    
    // MARK: - Summary Card
    private var summaryCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Today's Summary")
                .font(.headline)
                .foregroundColor(.secondary)
            
            HStack(spacing: 20) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("\(todaySteps)")
                        .font(.system(size: 32, weight: .bold))
                    Text("Steps")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text("\(Int(todayCalories))")
                        .font(.system(size: 32, weight: .bold))
                    Text("Calories")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color(.systemBackground))
        .cornerRadius(12)
    }
    
    // MARK: - Activity Section
    private var activitySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Activity")
                .font(.headline)
                .foregroundColor(.secondary)
            
            VStack(spacing: 12) {
                healthMetricRow(
                    icon: "figure.walk",
                    title: "Steps",
                    value: "\(todaySteps)",
                    color: .blue
                )
                
                healthMetricRow(
                    icon: "flame.fill",
                    title: "Active Calories",
                    value: "\(Int(todayCalories))",
                    color: .orange
                )
            }
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color(.systemBackground))
        .cornerRadius(12)
    }
    
    // MARK: - Heart Section
    private var heartSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Heart Health")
                .font(.headline)
                .foregroundColor(.secondary)
            
            if let heartRate = avgHeartRate {
                healthMetricRow(
                    icon: "heart.fill",
                    title: "Average Heart Rate",
                    value: "\(Int(heartRate)) bpm",
                    color: .red
                )
            } else {
                Text("No heart rate data available")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .padding(.vertical, 8)
            }
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color(.systemBackground))
        .cornerRadius(12)
    }
    
    // MARK: - Sleep Section
    private var sleepSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Sleep")
                .font(.headline)
                .foregroundColor(.secondary)
            
            if let sleepHours = lastNightSleep, sleepHours > 0, sleepHours.isFinite {
                let hours = Int(sleepHours)
                let minutes = Int((sleepHours - Double(hours)) * 60)
                healthMetricRow(
                    icon: "moon.fill",
                    title: "Last Night",
                    value: "\(hours)h \(minutes)m",
                    color: .purple
                )
            } else {
                Text("No sleep data available")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .padding(.vertical, 8)
            }
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color(.systemBackground))
        .cornerRadius(12)
    }
    
    // MARK: - Helper Views
    private func healthMetricRow(icon: String, title: String, value: String, color: Color) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
                .frame(width: 30)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                Text(value)
                    .font(.title3)
                    .fontWeight(.semibold)
            }
            
            Spacer()
        }
        .padding(.vertical, 4)
    }
    
    // MARK: - Functions
    private func loadHealthData() {
        // Always try to load - queries will handle authorization errors
        // Don't block based on status check which can be wrong
        Task {
            await refreshData()
        }
    }
    
    private func refreshData() async {
        await MainActor.run {
            isLoading = true
            errorMessage = nil
        }
        
        // Don't block based on authorization status - try the queries
        // The queries will fail with proper errors if truly not authorized
        // Sometimes status check is wrong but queries work
        print("✅ HealthDataView: Attempting to load data...")
        
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: Date())
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay) ?? Date()
        
        do {
            // Load steps
            let steps = try await healthKitManager.querySteps(startDate: startOfDay, endDate: endOfDay)
            
            // Load calories
            let calories = try await healthKitManager.queryActiveEnergy(startDate: startOfDay, endDate: endOfDay)
            
            // Load heart rate
            let heartRateData = try await healthKitManager.queryHeartRate(startDate: startOfDay, endDate: endOfDay)
            
            // Load sleep (last night)
            let yesterday = calendar.date(byAdding: .day, value: -1, to: startOfDay) ?? startOfDay
            let sleepData = try await healthKitManager.querySleep(startDate: yesterday, endDate: startOfDay)
            let sleepDuration = sleepData.first?.duration ?? nil
            
            await MainActor.run {
                self.todaySteps = steps
                self.todayCalories = calories.isFinite && calories >= 0 ? calories : 0.0
                self.avgHeartRate = heartRateData.average?.isFinite == true && heartRateData.average! > 0 ? heartRateData.average : nil
                
                // Safely calculate sleep hours
                if let duration = sleepDuration, duration > 0, duration.isFinite {
                    let hours = duration / 3600.0
                    self.lastNightSleep = hours.isFinite && hours > 0 && hours < 24 ? hours : nil
                } else {
                    self.lastNightSleep = nil
                }
                
                self.isLoading = false
            }
        } catch {
            let errorDesc = error.localizedDescription.lowercased()
            let userMessage: String
            
            if errorDesc.contains("no data available") || errorDesc.contains("predicate") {
                userMessage = "No health data available for today. Make sure you have health data in the Health app, or try adding test data in the simulator's Health app."
            } else if errorDesc.contains("authorization") || errorDesc.contains("permission") {
                userMessage = "HealthKit permission required. Tap 'Enable' to grant access."
            } else {
                userMessage = "Error loading health data: \(error.localizedDescription)"
            }
            
            await MainActor.run {
                self.errorMessage = userMessage
                self.isLoading = false
            }
        }
    }
    
    private func requestAuthorization() {
        print("🔐 Enable button tapped in HealthDataView - requesting authorization")
        Task { @MainActor in
            do {
                try await healthKitManager.requestAuthorization()
                print("🔐 Authorization completed, checking status...")
                // Give system time to update
                try? await Task.sleep(nanoseconds: 200_000_000) // 0.2 seconds
                // Update authorization status
                healthKitManager.checkAuthorizationStatus()
                print("🔐 Status check complete, isAuthorized: \(healthKitManager.isAuthorized)")
                // Refresh data after authorization
                await refreshData()
            } catch {
                print("🔐 Authorization error: \(error.localizedDescription)")
                
                // Check if permission was previously denied
                if healthKitManager.authorizationStatus == .sharingDenied {
                    // Show alert to open Settings
                    showSettingsAlert = true
                } else {
                    errorMessage = "Failed to authorize: \(error.localizedDescription). Please go to Settings > Privacy & Security > Health to enable access."
                }
            }
        }
    }
}

