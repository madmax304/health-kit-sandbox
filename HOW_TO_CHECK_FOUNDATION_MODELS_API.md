# How to Check Foundation Models API in Xcode

## Quick Steps

1. **Open the project in Xcode**
   - Open `HealthKitAssistant.xcodeproj`

2. **Open AIAssistantManager.swift**
   - Navigate to `HealthKitAssistant/Managers/AIAssistantManager.swift`
   - Find the `setupFoundationModels()` function (around line 35)

3. **Check what's available**
   - In the `#if canImport(FoundationModels)` block, start typing:
     - Type `LLM` and see what autocompletes
     - Type `SystemLanguage` and see what autocompletes
     - Type `FoundationModels.` and see what's available

4. **Look for these classes/types:**
   - `LLMSession` or `LLMRequest` or similar
   - `SystemLanguageModel` or `LanguageModel` or similar
   - Tool registration methods

5. **Check Apple's Documentation**
   - In Xcode, Cmd+Click on any FoundationModels type
   - Or go to Help → Developer Documentation
   - Search for "FoundationModels"

## What to Look For

The API might look like one of these patterns:

### Pattern 1: Session-based
```swift
let model = SystemLanguageModel.default
let session = LLMSession(model: model, systemPrompt: "...")
session.addUserMessage("...")
let response = try await session.generate()
```

### Pattern 2: Request-based
```swift
let request = LLMRequest(prompt: "...", tools: [...])
let response = try await request.generate()
```

### Pattern 3: Direct model
```swift
let model = SystemLanguageModel.default
let response = try await model.generate(prompt: "...", tools: [...])
```

## Once You Find It

1. Note the exact class names
2. Note the method names
3. Note how tools are registered
4. Share the information or implement it directly
