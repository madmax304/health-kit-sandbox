# Project Setup Instructions

## Creating the Xcode Project

Since I've created all the source files, you need to create the Xcode project and add these files:

### Step 1: Create New Xcode Project

1. Open Xcode
2. File → New → Project
3. Choose "iOS" → "App"
4. Name: `HealthKitAssistant`
5. Interface: SwiftUI
6. Language: Swift
7. Save to: `/Users/maxwellanderson/Documents/Health Kit Sandbox/`

### Step 2: Add Source Files

Add all the files I created to your Xcode project:

**App:**
- `HealthKitAssistantApp.swift`
- `ContentView.swift`

**Models:**
- `Models/Message.swift`
- `Models/HealthDataModels.swift`

**Managers:**
- `Managers/HealthKitManager.swift`
- `Managers/AIAssistantManager.swift`

**Tools:**
- `Tools/HealthKitTools.swift`

**Views:**
- `Views/ChatView.swift`
- `Views/MessageBubble.swift`

**Configuration:**
- `Info.plist` (update the existing one with the HealthKit usage descriptions)

### Step 3: Enable HealthKit Capability

1. Select your project target
2. Go to "Signing & Capabilities" tab
3. Click "+ Capability"
4. Add "HealthKit"
5. This will automatically add the HealthKit entitlement

### Step 4: Update Info.plist

Make sure your `Info.plist` includes:
- `NSHealthShareUsageDescription`
- `NSHealthUpdateUsageDescription`

(I've created an `Info.plist` file with these - merge with your project's existing one)

### Step 5: Set Minimum iOS Version

1. Select project target
2. Go to "General" tab
3. Set "Minimum Deployments" to iOS 18.0 (or later)

### Step 6: Build and Run

1. Connect a device or use simulator
2. Build (⌘B)
3. Run (⌘R)

## Project Structure

```
HealthKitAssistant/
├── HealthKitAssistantApp.swift
├── ContentView.swift
├── Models/
│   ├── Message.swift
│   └── HealthDataModels.swift
├── Managers/
│   ├── HealthKitManager.swift
│   └── AIAssistantManager.swift
├── Tools/
│   └── HealthKitTools.swift
├── Views/
│   ├── ChatView.swift
│   └── MessageBubble.swift
└── Info.plist
```

## Testing

1. **First Launch:**
   - App will request HealthKit permission
   - Grant permission
   - Chat interface appears

2. **Test Queries:**
   - "How many steps today?"
   - "What's my heart rate?"
   - "How did I sleep?"
   - "How many calories did I burn?"

3. **Test on Real Device:**
   - For best results, test on a real iPhone
   - Apple Watch data will be available if paired

## Notes

- The current implementation uses a simplified query parser
- When Foundation Models framework is fully available (iOS 18+), the `AIAssistantManager` can be updated to use the actual Foundation Models API
- All HealthKit queries are async and handle errors gracefully
- The app only reads HealthKit data (no writing)

## Troubleshooting

**HealthKit permission denied:**
- Go to Settings → Privacy & Security → Health
- Enable access for HealthKitAssistant

**No data available:**
- Make sure you have health data in the Health app
- For watch data, ensure Apple Watch is paired and synced

**Build errors:**
- Make sure all files are added to the target
- Check that HealthKit framework is imported
- Verify iOS deployment target is 18.0+

