# HealthKit Assistant

A conversational health assistant that lets users talk to their HealthKit data using natural language.

## Features

- Natural language queries about health data
- Supports steps, heart rate, sleep, and active calories
- Clean, simple chat interface
- Privacy-first: All processing on-device

## Requirements

- iOS 18.0+
- Xcode 15.0+
- HealthKit capability enabled
- Apple Intelligence compatible device (for Foundation Models)

## Setup

1. Open the project in Xcode
2. Enable HealthKit capability:
   - Select project target
   - Go to "Signing & Capabilities"
   - Click "+ Capability"
   - Add "HealthKit"
3. Build and run

## Usage

1. Launch the app
2. Grant HealthKit permissions when prompted
3. Ask questions like:
   - "How many steps today?"
   - "What's my heart rate?"
   - "How did I sleep?"
   - "How many calories did I burn?"

## Architecture

- **HealthKitManager**: Handles HealthKit queries and permissions
- **AIAssistantManager**: Processes queries and generates responses
- **HealthKitTools**: Tool functions that query HealthKit data
- **ChatView**: Main UI with chat interface

## Note on Foundation Models

The current implementation uses a simplified query parser. For full Foundation Models integration (when iOS 18+ is available), the `AIAssistantManager` will be updated to use the Foundation Models framework for true natural language understanding and tool calling.

