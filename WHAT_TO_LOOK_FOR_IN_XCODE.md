# What to Look For in Xcode Autocomplete

## When You Check `session.respond(to:`

### What You'll See

When you place your cursor after `respond(to:` and press Escape, you'll see something like one of these:

### Scenario 1: Only One Parameter
```
respond(to: String) async throws -> Response<String>
```
**This means:** Tools are NOT passed here. Tools might be passed when creating the session instead.

### Scenario 2: Two Parameters (What We Want!)
```
respond(to: String, tools: [any Tool]) async throws -> Response<String>
```
**This means:** ✅ Tools ARE passed here! We can use this.

### Scenario 3: Options Parameter
```
respond(to: String, options: GenerationOptions) async throws -> Response<String>
```
**This means:** Tools might be inside `GenerationOptions`. Check what `GenerationOptions` contains.

### Scenario 4: Both Tools and Options
```
respond(to: String, tools: [any Tool], options: GenerationOptions?) async throws -> Response<String>
```
**This means:** ✅ Tools can be passed directly, and options are optional.

## What to Tell Me

Just tell me which scenario you see! For example:
- "I see `respond(to: String)` - only one parameter"
- "I see `respond(to: String, tools: [any Tool])` - tools parameter exists!"
- "I see `respond(to: String, options: GenerationOptions)` - tools might be in options"

## Also Check: LanguageModelSession Initializer

Go to line ~200 and check:
```swift
session = LanguageModelSession(instructions: instructions)
```

When you click on `LanguageModelSession(`, do you see:
- `LanguageModelSession(instructions: String)` - only instructions
- `LanguageModelSession(instructions: String, tools: [any Tool])` - tools parameter! ✅

## Quick Test

If you see a `tools:` parameter anywhere, try typing it:
- After `respond(to: userMessage, ` - type `tools` and see if it autocompletes
- After `LanguageModelSession(instructions: instructions, ` - type `tools` and see if it autocompletes

That will tell us exactly where tools go!
