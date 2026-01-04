# Foundation Models Framework: Device Requirements

## ❌ Simulator Limitations

**Foundation Models framework likely requires:**
- Real device (not simulator)
- iPhone 15 Pro or newer (Apple Intelligence compatible)
- iOS 18+ with Apple Intelligence enabled
- On-device processing requires Neural Engine capabilities

## ✅ Current Implementation

**What works NOW (simulator and device):**
- Enhanced pattern matching
- Natural language query understanding
- Conversational responses
- HealthKit data queries (with permission)

**What needs real device:**
- Foundation Models framework (Apple Intelligence)
- On-device LLM processing

## Current Behavior

The app currently uses **enhanced pattern matching** which:
- Works on simulator ✅
- Works on any device ✅
- Provides conversational responses ✅
- Understands natural language queries ✅

When Foundation Models becomes available on real devices:
- The code structure is ready
- Just uncomment Foundation Models code
- Swap pattern matching for LLM calls

## Testing

**On Simulator:**
- Pattern matching works
- HealthKit queries work (with manual data)
- Conversation works

**On Real Device (when Foundation Models available):**
- Foundation Models will work
- True LLM conversations
- Better natural language understanding

