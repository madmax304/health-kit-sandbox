# Implement Foundation Models - Quick Guide

## The Problem
Foundation Models framework is detected, but the API isn't implemented yet. The app is falling back to pattern matching.

## The Solution
You need to check the actual API in Xcode and implement it. Here's how:

## Quick Steps

### 1. Open Xcode
- Open `HealthKitAssistant.xcodeproj`

### 2. Check the API
- Open `HealthKitAssistant/Managers/AIAssistantManager.swift`
- Go to line ~36 (`setupFoundationModels()` function)
- In the `#if canImport(FoundationModels)` block, try typing:

```swift
let test = LLMSession
```

OR

```swift
let test = SystemLanguageModel
```

OR

```swift
let test = FoundationModels.
```

See what autocompletes! That's your API.

### 3. Once You Find It

**If you see `LLMSession`:**
```swift
// In setupFoundationModels():
llmSession = LLMSession(systemPrompt: systemPrompt)
// or
llmSession = LLMSession(model: SystemLanguageModel.default, systemPrompt: systemPrompt)

// Then register tools:
registerTools()

// In processWithFoundationModels():
session.addUserMessage(userMessage)
let response = try await session.generate()
return response.text
```

**If you see `SystemLanguageModel`:**
```swift
// In setupFoundationModels():
let model = SystemLanguageModel.default
llmSession = model.createSession(systemPrompt: systemPrompt)
// ... similar pattern
```

### 4. Tool Registration

Once you have the session, check how to register tools:
```swift
session.registerTool(...)
// or
session.addTool(...)
// or
model.registerTool(...)
```

### 5. Test It

After implementing:
1. Build the project
2. Run on your iOS 26 device
3. Try a query like "How many steps today?"
4. Check console logs - should see Foundation Models being used

## Need Help?

If you find the API but aren't sure how to implement it, share:
- The class name (e.g., `LLMSession`)
- The initializer signature
- Available methods for tool registration
- Available methods for generating responses

And I can help you implement it!
