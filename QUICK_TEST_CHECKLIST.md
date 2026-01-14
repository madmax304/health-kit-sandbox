# Quick Test Checklist - Run This Now

## 🚀 Quick Simulator Test (5 minutes)

### 1. Launch App
- [ ] Open Xcode
- [ ] Select iPhone 17 simulator (or any iOS 18+)
- [ ] Run app (Cmd+R)
- [ ] App launches without crash ✅

### 2. UI Check
- [ ] See "Chat" tab
- [ ] See "Health Data" tab
- [ ] Full screen (no cut-off) ✅
- [ ] Welcome message displays ✅
- [ ] Input field visible ✅

### 3. Basic Interaction
- [ ] Type "hello" in chat
- [ ] Tap send button
- [ ] See response message ✅
- [ ] Messages scroll properly ✅

### 4. Permission Test
- [ ] See "Enable" button (top right)
- [ ] Tap "Enable"
- [ ] Permission dialog appears ✅
- [ ] Grant permission
- [ ] "Enable" button disappears ✅

### 5. Health Data View
- [ ] Tap "Health Data" tab
- [ ] View loads (may show error if no data) ✅
- [ ] Can switch back to Chat ✅

### 6. AI Queries (Pattern Matching)
Try these queries:
- [ ] "help" → Shows help message ✅
- [ ] "how many steps today?" → Shows steps response (or permission error) ✅
- [ ] "what's my heart rate?" → Shows heart rate response ✅

---

## ⚠️ If Something Fails

### App Crashes:
- Check console for error messages
- Verify code signing is set up
- Check entitlements file

### UI Issues:
- Check safe area handling
- Verify TabView structure
- Check NavigationStack

### Permission Issues:
- Verify HealthKit capability enabled
- Check Info.plist has privacy descriptions
- Verify code signing team is set

### No Responses:
- Check AIAssistantManager is initialized
- Verify HealthKitManager is working
- Check console for errors

---

## ✅ Ready for Device?

If all simulator tests pass:
- [x] App launches
- [x] UI works
- [x] Basic interactions work
- [x] Permission flow works
- [x] No crashes

**Then you're ready to test on device!**

---

## 📱 Device Testing Priority

1. **Real HealthKit Data** - Test with actual step/heart rate data
2. **Apple Watch** - Test watch data sync (if you have watch)
3. **Foundation Models** - Test if LLM is available on device
4. **Performance** - Test with real data volumes
5. **Battery** - Monitor battery usage
