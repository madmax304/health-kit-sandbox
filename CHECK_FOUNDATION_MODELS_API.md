# Check Foundation Models API - Direct Method

## Option 1: Check in Xcode Documentation

1. **Open Xcode**
2. **Go to Help → Developer Documentation** (or press Cmd+Shift+0)
3. **Search for "FoundationModels"**
4. **Look at the API Reference** - it should list all available classes

## Option 2: Check Framework Header

1. **In Xcode, with your project open**
2. **Go to Window → Devices and Simulators**
3. **Select your iOS 26 device**
4. **Or check the SDK path:**
   - `/Applications/Xcode.app/Contents/Developer/Platforms/iPhoneOS.platform/Developer/SDKs/iPhoneOS.sdk/System/Library/Frameworks/FoundationModels.framework/Headers/`

## Option 3: Use Swift's Reflection

Try adding this to your code temporarily:

```swift
#if canImport(FoundationModels)
import FoundationModels

// This will print all available types
let foundationModelsModule = FoundationModels.self
print("FoundationModels module: \(foundationModelsModule)")

// Try to see what's available
let mirror = Mirror(reflecting: FoundationModels.self)
print("Available: \(mirror)")
#endif
```

## Option 4: Check Apple's Documentation Online

Go directly to:
- https://developer.apple.com/documentation/FoundationModels

This should show you the complete API reference with all classes and methods.

## Option 5: Check WWDC Session Code

The WWDC sessions mentioned should have sample code. Check:
- WWDC 2025 Session 286: "Meet the Foundation Models Framework"
- Look for sample code or code snippets in the session

## What to Look For

Once you find the documentation, look for:
- Main entry point class (might be `LanguageModel`, `FoundationModel`, `LLM`, etc.)
- Session management class
- Tool registration methods
- Query/request processing methods
