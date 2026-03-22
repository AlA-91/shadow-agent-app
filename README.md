# SHADOW Agent

**AI Agent Orchestrator with Premium Android 16 UI**

A conversational AI agent that interprets natural language requests and triggers appropriate tools for task automation.

## Features

- **Premium UI** - Android 16 style with gradients, animations, and glassmorphism
- **Gemini AI** - Real API integration with intelligent tool selection
- **Quick Actions** - Tap to send common commands
- **Tool Chips** - Visual feedback for triggered tools
- **Chat History** - Persistent conversation storage
- **State Management** - Riverpod for reactive updates

## Available Tools

| Tool | Description |
|------|-------------|
| FlightSearch | Search and book flights |
| RefundHunter | Process refunds |
| SubscriptionKiller | Cancel subscriptions |
| CalendarAssistant | Manage calendar events |
| ExpenseTracker | Track expenses |
| SmartHomeController | Control smart home |

## Setup

1. Get a Gemini API key from [Google AI Studio](https://aistudio.google.com/apikey)
2. Create `.env` file:
   ```
   GEMINI_API_KEY=your_api_key_here
   ```
3. Install dependencies:
   ```bash
   flutter pub get
   ```
4. Run the app:
   ```bash
   flutter run
   ```

## Tech Stack

- Flutter 3.7+
- Riverpod (state management)
- Google Generative AI
- Material Design 3

## Project Structure

```
lib/
├── main.dart              # App entry & UI
├── models/
│   └── chat_message.dart  # Message model
├── providers/
│   └── agent_provider.dart # State management
└── services/
    └── api_service.dart   # Gemini API
```

## License

MIT
