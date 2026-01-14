# Xcode API Check Instructions

## Step-by-Step: Find Foundation Models API

### 1. Open Xcode
- Open `HealthKitAssistant.xcodeproj`

### 2. Open AIAssistantManager.swift
- Navigate to: `HealthKitAssistant/Managers/AIAssistantManager.swift`
- Go to line ~36 (the `setupFoundationModels()` function)

### 3. Check Available API
In the `#if canImport(FoundationModels)` block, try typing these and see what autocompletes:

**Option A: Check for Session-based API**
```swift
// Type this and see what autocompletes:
let session = LLM
// or
let session = FoundationModels.
```

**Option B: Check for Model-based API**
```swift
// Type this and see what autocompletes:
let model = SystemLanguage
// or
let model = Language
```

**Option C: Check for Request-based API**
```swift
// Type this and see what autocompletes:
let request = LLMRequest
// or
let request = FoundationModels.
```

### 4. Once You See Autocomplete
1. **Note the exact class name** (e.g., `LLMSession`, `SystemLanguageModel`, etc.)
2. **Click on it** to see the documentation
3. **Check the initializer** - what parameters does it take?
4. **Check for methods** like:
   - `generate()`, `generateResponse()`, `process()`
   - `addMessage()`, `addUserMessage()`
   - `registerTool()`, `addTool()`

### 5. Check Tool Registration
Type:
```swift
session.
```
And see what methods are available for registering tools.

### 6. Share What You Find
Once you see the API, you can either:
- Share the class/method names with me
- Or implement it directly in the code

## Quick Test
Try adding this temporary code in `setupFoundationModels()` to see what's available:

```swift
#if canImport(FoundationModels)
import FoundationModels

// Try these one at a time to see what compiles:
// Option 1:
let test1 = LLMSession.self

// Option 2:
let test2 = SystemLanguageModel.self

// Option 3:
let test3 = LLMRequest.self
#endif
```

The one that doesn't give an error is the correct API!
