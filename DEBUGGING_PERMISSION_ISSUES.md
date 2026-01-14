# Debugging Permission Issues on Device

## What I Just Fixed

1. **Removed unnecessary Task wrappers** - Since `HealthKitManager` is `@MainActor`, we don't need extra Task wrappers
2. **Added timing delays** - Give the system time to update authorization status after permission dialog
3. **Added debug logging** - Print statements to track the authorization flow
4. **Improved status checking** - More reliable status updates

## How to Debug

When you tap "Enable", check the Xcode console for these messages:

```
🔐 Enable button tapped - requesting authorization
🔐 Requesting HealthKit authorization...
🔐 Authorization request completed
🔐 Authorization completed, checking status...
🔐 Authorization status checked: sharingAuthorized, isAuthorized: true
🔐 Status check complete, isAuthorized: true
```

## Common Issues on Device

### Issue 1: Permission Dialog Doesn't Appear
**Possible causes:**
- Code signing not set up (no development team)
- Entitlements not properly signed
- App was previously denied and needs Settings

**Solution:**
1. Check Xcode → Signing & Capabilities → Make sure team is selected
2. Go to Settings → Privacy & Security → Health → Find your app
3. Enable all permissions manually

### Issue 2: Dialog Appears But Button Doesn't Disappear
**Possible causes:**
- Status check happening too quickly
- UI not observing the published property

**Solution:**
- The delay I added should help
- Check console logs to see if status is updating

### Issue 3: "No Data Available" Error
**This is normal if:**
- You haven't granted permission yet
- You don't have health data on your device
- The query date range has no data

**Solution:**
- Grant permission first
- Make sure you have health data (steps, heart rate, etc.)
- Try asking about a different date range

## What to Check in Console

1. **When app launches:**
   ```
   🔐 Initial authorization check: isAuthorized = false
   ```

2. **When you tap Enable:**
   ```
   🔐 Enable button tapped - requesting authorization
   🔐 Requesting HealthKit authorization...
   ```

3. **After permission dialog:**
   ```
   🔐 Authorization request completed
   🔐 Authorization status checked: sharingAuthorized, isAuthorized: true
   ```

## If Still Not Working

1. **Check Settings manually:**
   - Settings → Privacy & Security → Health
   - Find "HealthKitAssistant"
   - Enable all data types

2. **Check code signing:**
   - Xcode → Target → Signing & Capabilities
   - Make sure "Automatically manage signing" is checked
   - Select your development team

3. **Check entitlements:**
   - Verify `HealthKitAssistant.entitlements` exists
   - Verify `com.apple.developer.healthkit` = true

4. **Restart app:**
   - Sometimes the status needs a fresh check
   - Kill the app and relaunch

## Next Steps

Run the app and check the console logs. The debug messages will tell us exactly where the flow is breaking.
