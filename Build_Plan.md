# Build Plan: HealthKit Conversational Assistant

## 🎯 Project Goal

**Users can talk to their HealthKit data using natural language.**

---

## 📋 Pre-Code Checklist

### ✅ What We've Covered:
- [x] HealthKit data types and capabilities
- [x] Foundation Models framework understanding
- [x] Tool calling concept
- [x] Architecture approach
- [x] Simplest possible implementation

### 🔍 What We Need to Decide:

1. **Tech Stack**
   - SwiftUI vs UIKit?
   - iOS version target?
   - Project structure?

2. **Build Phases**
   - What to build first?
   - What order?
   - MVP scope?

3. **Tool Priority**
   - Which tools first?
   - How many for MVP?

4. **UI Approach**
   - Chat interface design
   - Loading states
   - Error handling UI

5. **Project Structure**
   - File organization
   - Naming conventions
   - Architecture pattern

---

## 🏗️ Recommended Tech Stack

### **SwiftUI** ✅
- Modern, declarative
- Easier for chat UI
- Less boilerplate
- Good for learning

### **iOS 18+** ✅
- Foundation Models requires iOS 18+
- Latest features
- Apple Intelligence support

### **Architecture: MVVM** ✅
- Clean separation
- Testable
- Standard iOS pattern

---

## 📁 Project Structure

```
HealthKitAssistant/
├── App/
│   ├── HealthKitAssistantApp.swift
│   └── ContentView.swift
├── Models/
│   ├── HealthDataModels.swift
│   └── Message.swift
├── Managers/
│   ├── HealthKitManager.swift
│   └── AIAssistantManager.swift
├── Tools/
│   ├── HealthKitTools.swift
│   └── ToolDefinitions.swift
├── Views/
│   ├── ChatView.swift
│   ├── MessageBubble.swift
│   └── PermissionView.swift
└── Utilities/
    └── Extensions.swift
```

---

## 🚀 Build Phases

### **Phase 1: Foundation (Week 1)**
**Goal:** Get basic structure working

**Tasks:**
1. ✅ Create Xcode project
2. ✅ Set up HealthKit capability
3. ✅ Create basic SwiftUI structure
4. ✅ HealthKit permission request
5. ✅ Basic chat UI (no AI yet)
6. ✅ Test HealthKit access

**Deliverable:** App that requests permission and shows basic UI

---

### **Phase 2: First Tool (Week 1-2)**
**Goal:** Get one tool working with Foundation Models

**Tasks:**
1. ✅ Set up Foundation Models framework
2. ✅ Create LLMSession
3. ✅ Build getSteps() tool
4. ✅ Register tool with model
5. ✅ Connect chat to AI
6. ✅ Test: "How many steps today?"

**Deliverable:** User can ask about steps, get AI response

---

### **Phase 3: More Tools (Week 2)**
**Goal:** Add 2-3 more common tools

**Tasks:**
1. ✅ Add getHeartRate() tool
2. ✅ Add getSleep() tool
3. ✅ Add getActiveEnergy() tool
4. ✅ Test complex queries
5. ✅ Handle missing data gracefully

**Deliverable:** User can ask about multiple health metrics

---

### **Phase 4: Polish (Week 3)**
**Goal:** Better UX and error handling

**Tasks:**
1. ✅ Improve chat UI
2. ✅ Add loading states
3. ✅ Better error messages
4. ✅ Handle edge cases
5. ✅ Test on real device

**Deliverable:** Polished, working app

---

## 🛠️ Tool Priority

### **MVP Tools (Phase 2):**

1. **getSteps(startDate, endDate)** ⭐⭐⭐
   - Most common query
   - Works on iPhone
   - Simple data type
   - **Build first**

### **Phase 3 Tools:**

2. **getHeartRate(startDate, endDate)** ⭐⭐
   - Watch data
   - Common query
   - Similar pattern to steps

3. **getSleep(startDate, endDate)** ⭐⭐
   - Watch data
   - Category type (slightly different)
   - Popular query

4. **getActiveEnergy(startDate, endDate)** ⭐
   - Watch data
   - Similar to steps
   - Quick to add

### **Future Tools (Phase 4+):**

5. getWorkouts()
6. getRestingHeartRate()
7. getHRV()
8. getDistance()
9. compareMetrics()
10. getSummary()

---

## 🎨 UI Design

### **Chat Interface:**

```
┌─────────────────────────────────┐
│  Health Assistant        [⚙️]   │
├─────────────────────────────────┤
│                                 │
│  👤 How many steps today?       │
│                                 │
│  🤖 You've taken 8,234 steps   │
│     today! That's 82% of your   │
│     10,000 step goal.           │
│                                 │
│  👤 What about this week?       │
│                                 │
│  🤖 This week you've averaged   │
│     9,156 steps per day. Your   │
│     best day was Tuesday with   │
│     12,345 steps!              │
│                                 │
│  [Typing indicator...]          │
│                                 │
├─────────────────────────────────┤
│  [Type your question...]        │
│  [Send]                         │
└─────────────────────────────────┘
```

### **Components Needed:**
- Message list (scrollable)
- Message bubbles (user vs assistant)
- Text input field
- Send button
- Loading indicator
- Error message display

---

## 🔧 Key Components

### **1. HealthKitManager**
**Responsibility:** HealthKit access and queries

**Methods:**
- `requestAuthorization()`
- `querySteps(startDate, endDate)`
- `queryHeartRate(startDate, endDate)`
- `querySleep(startDate, endDate)`
- etc.

### **2. AIAssistantManager**
**Responsibility:** Foundation Models integration

**Methods:**
- `initializeSession()`
- `registerTools()`
- `processQuery(_ text: String)`
- `handleToolCall()`

### **3. HealthKitTools**
**Responsibility:** Tool implementations

**Tools:**
- `getSteps(startDate, endDate)`
- `getHeartRate(startDate, endDate)`
- `getSleep(startDate, endDate)`
- etc.

### **4. ChatView**
**Responsibility:** UI and user interaction

**Features:**
- Message display
- Input handling
- Loading states
- Error display

---

## 📝 Implementation Details

### **System Prompt:**

```
"You are a helpful, encouraging health assistant. 
You have access to the user's HealthKit data through 
available tools. When users ask about their health:

1. Use the appropriate tools to fetch data
2. Provide clear, encouraging insights
3. Be specific with numbers and dates
4. Offer helpful context when relevant
5. Never provide medical advice

Available tools:
- getSteps: Get step count for a date range
- getHeartRate: Get heart rate data for a date range
- getSleep: Get sleep data for a date range
- getActiveEnergy: Get active calories for a date range"
```

### **Error Handling:**

**HealthKit Errors:**
- Permission denied → Show permission request
- No data available → "I don't have data for that period"
- Query failed → "Sorry, I couldn't fetch that data"

**Foundation Models Errors:**
- Model unavailable → Fallback message
- Tool call failed → "I had trouble accessing that data"
- Timeout → "That took too long, please try again"

---

## 🧪 Testing Strategy

### **Phase 1 Testing:**
- [ ] HealthKit permission flow
- [ ] Basic UI renders
- [ ] Navigation works

### **Phase 2 Testing:**
- [ ] Foundation Models initializes
- [ ] Tool registration works
- [ ] Simple query: "steps today"
- [ ] Response generated

### **Phase 3 Testing:**
- [ ] Multiple tools work
- [ ] Complex queries work
- [ ] Missing data handled
- [ ] Error cases handled

### **Phase 4 Testing:**
- [ ] Real device testing
- [ ] Apple Watch data
- [ ] Performance testing
- [ ] Edge cases

---

## 🚨 Potential Issues & Solutions

### **Issue 1: Foundation Models Not Available**
**Solution:** Check device compatibility, show helpful message

### **Issue 2: HealthKit Permission Denied**
**Solution:** Show permission request, explain why needed

### **Issue 3: No Data Available**
**Solution:** Graceful message, suggest alternatives

### **Issue 4: Tool Call Fails**
**Solution:** Error handling, retry logic, user-friendly message

### **Issue 5: Slow Responses**
**Solution:** Loading indicators, async handling

---

## 📋 Pre-Build Checklist

### **Before Writing Code:**

- [x] Understand HealthKit data types
- [x] Understand Foundation Models
- [x] Understand tool calling
- [x] Decide on tech stack
- [x] Plan project structure
- [x] Plan build phases
- [x] Plan tool priority
- [x] Plan UI approach
- [x] Plan error handling

### **Ready to Build:**

- [ ] Xcode project created
- [ ] HealthKit capability added
- [ ] Foundation Models framework available
- [ ] Test device/simulator ready
- [ ] Apple ID for testing

---

## 🎯 Success Criteria

### **MVP (Phase 2):**
- ✅ User can ask "How many steps today?"
- ✅ App queries HealthKit
- ✅ AI generates natural response
- ✅ Response displayed in chat

### **Phase 3:**
- ✅ Multiple health metrics queryable
- ✅ Complex queries work
- ✅ Error handling works

### **Phase 4:**
- ✅ Polished UI
- ✅ Works on real device
- ✅ Handles edge cases
- ✅ Good user experience

---

## 🚀 Ready to Start?

**Next Steps:**
1. Create Xcode project
2. Set up HealthKit capability
3. Create basic SwiftUI structure
4. Start with Phase 1 tasks

**Let's build!** 🎉

