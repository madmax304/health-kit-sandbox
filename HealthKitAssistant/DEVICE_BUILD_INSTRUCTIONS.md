# Building to Your iPhone Device

## Quick Setup

The build requires code signing. Here's how to set it up:

### Option 1: Using Xcode (Recommended)

1. **Open the project in Xcode:**
   ```bash
   open HealthKitAssistant.xcodeproj
   ```

2. **Select the project in the navigator** (top item)

3. **Select the "HealthKitAssistant" target**

4. **Go to "Signing & Capabilities" tab**

5. **Enable "Automatically manage signing"**

6. **Select your Team** (your Apple ID)

7. **Xcode will handle the rest automatically**

8. **Connect your iPhone via USB** and select it as the destination

9. **Click the Run button (⌘R)** or Product → Run

### Option 2: Command Line (If you have team ID)

If you know your Team ID, you can build from command line:

```bash
xcodebuild -project HealthKitAssistant.xcodeproj \
  -scheme HealthKitAssistant \
  -destination 'platform=iOS,name=Mack Sanderson' \
  DEVELOPMENT_TEAM=YOUR_TEAM_ID \
  CODE_SIGN_IDENTITY="Apple Development" \
  build
```

## Troubleshooting

**If you get "Untrusted Developer" on device:**
- Settings → General → VPN & Device Management
- Trust your developer certificate

**If build fails:**
- Make sure iPhone is connected via USB
- Make sure iPhone is unlocked
- Check "Signing & Capabilities" in Xcode

## What to Test on Device

Once installed:
1. Grant HealthKit permissions
2. Try queries like "How many steps today?"
3. Test conversation flow
4. Foundation Models may work if device supports Apple Intelligence

