# Fixing HealthKit Entitlement Error

## The Error
```
Failed to determine authorization status: Error Domain=com.apple.healthkit Code=4 
"Missing com.apple.developer.healthkit entitlement."
```

## What This Means
The app is trying to access HealthKit, but the entitlement isn't being recognized. This is usually a code signing issue.

## Solution Steps

### 1. Set Your Development Team in Xcode
1. Open `HealthKitAssistant.xcodeproj` in Xcode
2. Select the project in the navigator (top item)
3. Select the **HealthKitAssistant** target
4. Go to **Signing & Capabilities** tab
5. Under **Signing**, check **"Automatically manage signing"**
6. Select your **Team** from the dropdown (your Apple Developer account)
7. If you don't have a team, you can use "Personal Team" (your Apple ID)

### 2. Verify HealthKit Capability
In the same **Signing & Capabilities** tab:
- Make sure **HealthKit** capability is listed and enabled
- If it's not there, click **"+ Capability"** and add **HealthKit**

### 3. Clean Build Folder
In Xcode:
- **Product > Clean Build Folder** (Shift+Cmd+K)
- Or in terminal:
```bash
cd "/Users/maxwellanderson/Documents/Health Kit Sandbox"
rm -rf ~/Library/Developer/Xcode/DerivedData/HealthKitAssistant-*
```

### 4. Rebuild
- **Product > Build** (Cmd+B)
- Or run the app again

### 5. If Still Not Working
1. **Check Entitlements File**:
   - Make sure `HealthKitAssistant.entitlements` is in the project
   - Right-click it in Xcode > **Get Info**
   - Make sure it's included in the target

2. **Verify Build Settings**:
   - In Xcode, select the target
   - Go to **Build Settings** tab
   - Search for "CODE_SIGN_ENTITLEMENTS"
   - Should be: `HealthKitAssistant/HealthKitAssistant.entitlements`

3. **Check Info.plist**:
   - Make sure `NSHealthShareUsageDescription` and `NSHealthUpdateUsageDescription` are present
   - These are required for HealthKit

## For Simulator Testing
- HealthKit works on simulator, but you need proper code signing
- Make sure you're signed with a valid development team
- "Personal Team" works fine for development

## Current Status
✅ Entitlements file exists: `HealthKitAssistant.entitlements`
✅ Entitlements file is linked in build settings
✅ HealthKit capability is enabled in project.yml
✅ Info.plist has required privacy descriptions

⚠️ **Action Required**: Set your development team in Xcode's Signing & Capabilities tab

