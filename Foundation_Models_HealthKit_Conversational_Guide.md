# Foundation Models Framework: Conversational HealthKit Queries

## Overview

Apple's Foundation Models framework enables you to build conversational interfaces where users can talk to their HealthKit data using natural language. This guide covers everything you need to build an AI-powered health assistant.

---

## 🎯 What You're Building

**Goal:** Users can have natural conversations about their health data.

**Examples:**
- "How many steps did I take this week?"
- "What's my average heart rate?"
- "How did I sleep last night?"
- "Am I getting enough exercise?"
- "Show me my workout trends"
- "Compare my activity this week to last week"

---

## 🏗️ Foundation Models Framework Architecture

### **Core Components**

#### **1. LLMRequest**
- Represents a single request to the model
- Contains the prompt/message
- Can include tool definitions
- Returns structured responses

#### **2. LLMSession**
- Maintains conversation state
- Remembers context across messages
- Enables multi-turn conversations
- Handles tool calling

#### **3. Tool Calling**
- Model can call your app functions
- Perfect for querying HealthKit
- Model decides when to fetch data
- Your app provides the tools

#### **4. Guided Generation**
- Ensures consistent response formats
- Useful for structured data extraction
- Can define response schemas

---

## 🔧 Technical Stack

### **Required Frameworks**

```swift
import FoundationModels  // Foundation Models framework
import HealthKit        // HealthKit for health data
import SwiftUI          // UI (or UIKit)
```

### **System Requirements**
- iOS 18+ (or later, depending on release)
- Apple Intelligence compatible device
- Apple Intelligence enabled
- HealthKit capability enabled

---

## 🎨 Architecture Pattern

### **The Flow**

```
User Query
    ↓
LLMSession (with context)
    ↓
Model analyzes query intent
    ↓
Model calls tools (if needed)
    ↓
Your app queries HealthKit
    ↓
Data returned to model
    ↓
Model generates response
    ↓
Display to user
```

### **Key Pattern: Tool Calling**

Instead of you parsing queries and fetching data, the **model decides** what data it needs and calls your tools.

**Example:**
```
User: "How many steps did I take this week?"

Model thinks: "I need steps data for this week"
Model calls: getSteps(startDate: "2024-01-01", endDate: "2024-01-07")
Your app: Queries HealthKit, returns data
Model: "You took 58,234 steps this week, averaging 8,319 steps per day."
```

---

## 📝 Implementation Overview

### **1. Define HealthKit Tools**

Create functions that the model can call to fetch health data:

```swift
// Tool definitions for the model
struct HealthKitTools {
    // Get steps for a date range
    func getSteps(startDate: Date, endDate: Date) -> [StepData]
    
    // Get heart rate data
    func getHeartRate(startDate: Date, endDate: Date) -> [HeartRateData]
    
    // Get sleep data
    func getSleep(startDate: Date, endDate: Date) -> [SleepData]
    
    // Get workouts
    func getWorkouts(startDate: Date, endDate: Date) -> [WorkoutData]
    
    // Get active energy (calories)
    func getActiveEnergy(startDate: Date, endDate: Date) -> [EnergyData]
    
    // Get any health metric
    func getHealthMetric(metric: String, startDate: Date, endDate: Date) -> HealthData
}
```

### **2. Create LLMSession**

Set up a session that maintains conversation context:

```swift
class HealthAssistant {
    let session: LLMSession
    let healthKitTools: HealthKitTools
    
    init() {
        // Initialize session with system prompt
        session = LLMSession(
            systemPrompt: """
            You are a helpful health assistant. You can access the user's 
            HealthKit data through available tools. When users ask about 
            their health, use the tools to fetch relevant data and provide 
            clear, encouraging insights.
            """
        )
        
        // Register tools
        session.registerTools([
            getStepsTool,
            getHeartRateTool,
            getSleepTool,
            getWorkoutsTool,
            // ... more tools
        ])
    }
}
```

### **3. Handle User Queries**

Process natural language queries:

```swift
func handleQuery(_ userMessage: String) async -> String {
    // Add user message to session
    session.addUserMessage(userMessage)
    
    // Generate response (model will call tools as needed)
    let response = await session.generateResponse()
    
    return response.text
}
```

### **4. Tool Implementation**

Each tool queries HealthKit and returns formatted data:

```swift
func getStepsTool(startDate: Date, endDate: Date) async -> ToolResult {
    // Query HealthKit
    let steps = await healthStore.querySteps(
        from: startDate,
        to: endDate
    )
    
    // Format for model
    return ToolResult(
        data: steps,
        summary: "Retrieved \(steps.count) step samples"
    )
}
```

---

## 🛠️ Key Foundation Models Features

### **1. Tool Calling**

**What it is:**
- Model can call your app functions
- Model decides what data it needs
- You provide tool definitions
- Model uses tools automatically

**Why it's powerful:**
- No need to parse user queries manually
- Model understands intent
- Model knows what data to fetch
- Handles complex, multi-step queries

**Example:**
```
User: "Compare my steps this week to last week"

Model process:
1. Calls getSteps(thisWeek)
2. Calls getSteps(lastWeek)
3. Compares data
4. Generates response: "This week you took 58,234 steps vs 
   52,180 last week - that's an 11.6% increase!"
```

### **2. Stateful Sessions**

**What it is:**
- Maintains conversation context
- Remembers previous messages
- Enables follow-up questions
- Context-aware responses

**Why it's powerful:**
```
User: "How many steps today?"
Assistant: "You've taken 8,234 steps today."

User: "What about yesterday?"
Assistant: "Yesterday you took 9,156 steps."
// Model remembers we're talking about steps
```

### **3. Guided Generation**

**What it is:**
- Define response structure
- Ensure consistent formats
- Extract structured data
- Validate responses

**Use cases:**
- Extracting dates from queries
- Parsing health metrics
- Structured summaries
- Data validation

### **4. System Prompts**

**What it is:**
- Instructions for the model
- Define assistant personality
- Set behavior guidelines
- Context about available data

**Example:**
```
"You are a helpful, encouraging health assistant. 
You have access to the user's HealthKit data including:
- Steps, distance, flights climbed
- Heart rate, HRV, resting heart rate
- Sleep duration and stages
- Workouts and active energy
- And more...

When users ask questions:
1. Use tools to fetch relevant data
2. Provide clear, encouraging insights
3. Be specific with numbers and dates
4. Offer helpful context when relevant
5. Never provide medical advice"
```

---

## 🎯 Implementation Strategy

### **Phase 1: Basic Query Handling**

**Goal:** Simple queries work

**Tools to implement:**
- `getSteps(dateRange)`
- `getHeartRate(dateRange)`
- `getSleep(dateRange)`

**Example queries:**
- "How many steps today?"
- "What's my heart rate?"
- "How did I sleep?"

### **Phase 2: Advanced Queries**

**Goal:** Complex queries with comparisons

**Additional tools:**
- `compareMetrics(metric, period1, period2)`
- `getAverage(metric, period)`
- `getTrend(metric, period)`

**Example queries:**
- "Compare my steps this week to last week"
- "What's my average heart rate this month?"
- "Show me my sleep trends"

### **Phase 3: Insights & Summaries**

**Goal:** AI-generated insights

**Enhancements:**
- Pattern recognition prompts
- Correlation analysis
- Personalized recommendations

**Example queries:**
- "Give me a summary of my week"
- "What patterns do you see in my data?"
- "How can I improve my sleep?"

---

## 📊 Data Flow Example

### **Complete Flow: "How did I sleep this week?"**

```
1. User sends query: "How did I sleep this week?"

2. LLMSession receives message
   - Adds to conversation history
   - Analyzes intent: needs sleep data for this week

3. Model decides to call tool:
   - Calls: getSleep(startDate: "2024-01-01", endDate: "2024-01-07")

4. Your app executes tool:
   - Queries HealthKit for sleep data
   - Returns: [
       { date: "2024-01-01", duration: 7.5, quality: "good" },
       { date: "2024-01-02", duration: 8.0, quality: "excellent" },
       // ... more days
     ]

5. Model receives data:
   - Analyzes: "Average 7.4 hours, consistent quality"
   - Generates response

6. Response returned:
   "You slept well this week! You averaged 7.4 hours of sleep 
    per night, with consistent quality. Your best night was 
    Tuesday with 8 hours. Keep up the good sleep habits!"

7. Display to user
```

---

## 🔑 Key Concepts

### **1. Tool Definitions**

Tools must be clearly defined for the model:

```swift
struct ToolDefinition {
    let name: String
    let description: String
    let parameters: [Parameter]
    let handler: (Parameters) -> ToolResult
}

// Example
let getStepsTool = ToolDefinition(
    name: "getSteps",
    description: "Get step count data for a date range",
    parameters: [
        Parameter(name: "startDate", type: .date),
        Parameter(name: "endDate", type: .date)
    ],
    handler: { params in
        // Query HealthKit
        // Return data
    }
)
```

### **2. Context Management**

Session maintains context:

```swift
// Session remembers:
- Previous messages
- Tool calls and results
- User preferences (if stored)
- Current conversation topic
```

### **3. Error Handling**

Handle cases gracefully:

```swift
// When data unavailable:
- Model should explain why
- Suggest alternatives
- Be helpful, not technical

// When tool fails:
- Return error to model
- Model can explain to user
- Suggest retry or alternative
```

---

## 🎨 User Experience Patterns

### **1. Chat Interface**

**Simple approach:**
- Text input
- Message bubbles
- Loading states
- Error messages

**Features:**
- Scrollable history
- Clear send button
- Typing indicators
- Message timestamps

### **2. Query Suggestions**

**Help users get started:**
- "How many steps today?"
- "What's my heart rate?"
- "How did I sleep?"
- "Show me my workouts"

### **3. Follow-up Questions**

**Leverage stateful sessions:**
- "Tell me more"
- "What about yesterday?"
- "Compare to last week"
- "Show me the details"

---

## 🚀 Getting Started Steps

### **1. Set Up Foundation Models**

```swift
// Import framework
import FoundationModels

// Check availability
guard LLM.isAvailable else {
    // Handle not available
}

// Create session
let session = LLMSession(
    systemPrompt: "You are a health assistant..."
)
```

### **2. Set Up HealthKit**

```swift
// Request permissions
healthStore.requestAuthorization(...)

// Implement query functions
func querySteps(from: Date, to: Date) async -> [StepData]
```

### **3. Define Tools**

```swift
// Create tool definitions
let tools = [
    createStepsTool(),
    createHeartRateTool(),
    createSleepTool(),
    // ...
]

// Register with session
session.registerTools(tools)
```

### **4. Handle Queries**

```swift
func processQuery(_ text: String) async {
    // Add to session
    session.addUserMessage(text)
    
    // Generate response
    let response = await session.generateResponse()
    
    // Display
    displayMessage(response.text)
}
```

---

## 💡 Best Practices

### **1. Tool Design**

**Do:**
- ✅ Make tools specific and focused
- ✅ Return well-formatted data
- ✅ Include helpful summaries
- ✅ Handle errors gracefully

**Don't:**
- ❌ Make tools too generic
- ❌ Return raw HealthKit objects
- ❌ Forget error handling
- ❌ Over-complicate tool logic

### **2. System Prompts**

**Do:**
- ✅ Be clear about available data
- ✅ Set personality/ton
- ✅ Define boundaries (no medical advice)
- ✅ Explain tool capabilities

**Don't:**
- ❌ Be too vague
- ❌ Promise unavailable features
- ❌ Give medical advice
- ❌ Over-complicate instructions

### **3. Error Handling**

**Do:**
- ✅ Handle missing data gracefully
- ✅ Explain errors in user-friendly terms
- ✅ Suggest alternatives
- ✅ Log errors for debugging

**Don't:**
- ❌ Show technical errors to users
- ❌ Crash on missing data
- ❌ Give up on first error
- ❌ Forget to handle edge cases

### **4. Performance**

**Do:**
- ✅ Cache frequently accessed data
- ✅ Optimize HealthKit queries
- ✅ Limit tool call complexity
- ✅ Use async/await properly

**Don't:**
- ❌ Query HealthKit synchronously
- ❌ Fetch unnecessary data
- ❌ Block UI thread
- ❌ Ignore query performance

---

## 🎯 Recommended Tool Set

### **Core Tools (Start Here)**

1. **getSteps(startDate, endDate)**
   - Returns step count data
   - Handles daily/weekly/monthly queries

2. **getHeartRate(startDate, endDate)**
   - Returns heart rate samples
   - Can aggregate (average, min, max)

3. **getSleep(startDate, endDate)**
   - Returns sleep duration and stages
   - Handles nightly queries

4. **getWorkouts(startDate, endDate)**
   - Returns workout list
   - Includes type, duration, calories

5. **getActiveEnergy(startDate, endDate)**
   - Returns calories burned
   - Daily/weekly totals

### **Advanced Tools (Add Later)**

6. **compareMetrics(metric, period1, period2)**
   - Compare any metric across periods
   - Returns differences and percentages

7. **getTrend(metric, period)**
   - Show trends over time
   - Identify patterns

8. **getSummary(period)**
   - Comprehensive health summary
   - Multiple metrics at once

9. **getInsights(metric, period)**
   - AI-generated insights
   - Pattern recognition

10. **getRecommendations()**
    - Personalized suggestions
    - Based on user's data

---

## 🔍 Query Examples & Tool Calls

### **Simple Query**

**User:** "How many steps today?"

**Tool Call:**
```
getSteps(
    startDate: "2024-01-15 00:00:00",
    endDate: "2024-01-15 23:59:59"
)
```

**Response:**
"You've taken 8,234 steps today. That's 82% of your 10,000 step goal!"

### **Complex Query**

**User:** "Compare my activity this week to last week"

**Tool Calls:**
```
getSteps(startDate: "2024-01-08", endDate: "2024-01-14")
getSteps(startDate: "2024-01-01", endDate: "2024-01-07")
getActiveEnergy(startDate: "2024-01-08", endDate: "2024-01-14")
getActiveEnergy(startDate: "2024-01-01", endDate: "2024-01-07")
```

**Response:**
"This week you took 58,234 steps vs 52,180 last week - that's an 11.6% increase! You also burned 2,450 calories compared to 2,180 last week. Great progress!"

### **Insight Query**

**User:** "What patterns do you see in my sleep?"

**Tool Calls:**
```
getSleep(startDate: "2024-01-01", endDate: "2024-01-14")
getSteps(startDate: "2024-01-01", endDate: "2024-01-14")
getWorkouts(startDate: "2024-01-01", endDate: "2024-01-14")
```

**Response:**
"I notice you sleep better on days when you exercise. On workout days, you average 7.8 hours vs 6.9 hours on rest days. Your sleep quality also improves when you get 8,000+ steps. Try to maintain consistent activity for better sleep!"

---

## 📚 Resources

### **Apple Documentation**
- Foundation Models Framework docs
- HealthKit documentation
- Swift concurrency (async/await)

### **Example Projects**
- HealthGPT (Stanford) - Open source reference
- Apple sample code (when available)

### **Key WWDC Sessions**
- "Meet the Foundation Models framework"
- "Integrate Foundation Models in your app"
- HealthKit sessions

---

## 🎯 Summary

**Foundation Models Framework provides:**

1. **LLMSession** - Conversation state management
2. **Tool Calling** - Model can call your HealthKit functions
3. **Stateful Context** - Remembers conversation history
4. **Guided Generation** - Structured, consistent responses
5. **On-Device Processing** - Privacy-first, fast

**Your job:**
1. Define HealthKit query tools
2. Register tools with session
3. Handle user queries
4. Display AI responses

**The model's job:**
1. Understand user intent
2. Decide which tools to call
3. Process returned data
4. Generate natural language responses

**Result:**
Users can have natural conversations about their health data without you manually parsing queries or building complex query logic!

---

## 🚀 Next Steps

1. **Set up Foundation Models** - Get framework integrated
2. **Implement core tools** - Steps, heart rate, sleep
3. **Create basic chat UI** - Simple message interface
4. **Test with real queries** - "How many steps today?"
5. **Iterate and expand** - Add more tools, improve responses

The beauty of this approach: **The model handles the complexity of understanding queries and deciding what data to fetch. You just provide the tools to access HealthKit data.**

