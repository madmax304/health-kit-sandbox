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
                        
                        if !healthKitManager.isAuthorized {
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
                    if !healthKitManager.isAuthorized {
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
                loadHealthData()
            }
            .refreshable {
                await refreshData()
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
            
            if let sleepHours = lastNightSleep {
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
        guard healthKitManager.isAuthorized else {
            isLoading = false
            errorMessage = "HealthKit permission required. Tap 'Enable' to grant access."
            return
        }
        
        Task {
            await refreshData()
        }
    }
    
    private func refreshData() async {
        isLoading = true
        errorMessage = nil
        
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
                self.todayCalories = calories
                self.avgHeartRate = heartRateData.average
                self.lastNightSleep = sleepDuration != nil ? sleepDuration! / 3600.0 : nil
                self.isLoading = false
            }
        } catch {
            await MainActor.run {
                self.errorMessage = "Error loading health data: \(error.localizedDescription)"
                self.isLoading = false
            }
        }
    }
    
    private func requestAuthorization() {
        Task {
            do {
                try await healthKitManager.requestAuthorization()
                await refreshData()
            } catch {
                await MainActor.run {
                    errorMessage = "Failed to authorize: \(error.localizedDescription)"
                }
            }
        }
    }
}

