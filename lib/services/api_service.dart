import 'dart:convert';
import 'package:google_generative_ai/google_generative_ai.dart';

class AgentResponse {
  final String thought;
  final String tool;
  final Map<String, dynamic> params;

  AgentResponse({
    required this.thought,
    required this.tool,
    required this.params,
  });

  factory AgentResponse.fromJson(Map<String, dynamic> json) {
    return AgentResponse(
      thought: json['thought'] as String? ?? '',
      tool: json['tool'] as String? ?? 'Unknown',
      params: json['params'] as Map<String, dynamic>? ?? {},
    );
  }
}

class ApiService {
  GenerativeModel? _model;
  String? _lastError;

  String? get lastError => _lastError;

  bool get isConfigured => _model != null;

  void configure(String apiKey) {
    if (apiKey.isEmpty || apiKey == 'YOUR_API_KEY') {
      _model = null;
      return;
    }
    _model = GenerativeModel(
      model: 'gemini-2.0-flash',
      apiKey: apiKey,
      generationConfig: GenerationConfig(
        temperature: 0.7,
        topK: 40,
        topP: 0.95,
        maxOutputTokens: 2048,
      ),
    );
  }

  Future<AgentResponse> processRequest(String userMessage) async {
    if (_model == null) {
      return _getMockResponse(userMessage);
    }

    final prompt = _buildPrompt(userMessage);

    try {
      final content = Content.text(prompt);
      final response = await _model!.generateContent([content]);
      final text = response.text ?? '';

      return _parseResponse(text);
    } catch (e) {
      _lastError = e.toString();
      return _getMockResponse(userMessage);
    }
  }

  String _buildPrompt(String userMessage) {
    return '''
You are SHADOW, an intelligent agent orchestrator. 
Your goal is to understand user requests and select the most appropriate tool to execute.

User Request: "$userMessage"

Available Tools:
1. FlightSearch - Search for flights (params: destination, departure, date, max_price)
2. RefundHunter - Find and process refunds (params: airline, flight_number, reason)
3. SubscriptionKiller - Cancel subscriptions (params: app_name, billing_cycle)
4. CalendarAssistant - Manage calendar events (params: action, event_details)
5. ExpenseTracker - Track expenses (params: category, amount, description)
6. SmartHomeController - Control smart home devices (params: device, action)

Respond ONLY with valid JSON in this exact format:
{"tool": "ToolName", "params": {"key": "value"}, "thought": "Your reasoning in 1-2 sentences"}

Do not include any other text, markdown, or explanation.
''';
  }

  AgentResponse _parseResponse(String text) {
    try {
      String jsonStr = text.trim();
      jsonStr = jsonStr.replaceAll(RegExp(r'^```json\s*'), '');
      jsonStr = jsonStr.replaceAll(RegExp(r'^```\s*'), '');
      jsonStr = jsonStr.replaceAll(RegExp(r'\s*```$'), '');
      jsonStr = jsonStr.trim();

      final json = jsonDecode(jsonStr) as Map<String, dynamic>;
      return AgentResponse.fromJson(json);
    } catch (e) {
      return _getMockResponse(text);
    }
  }

  AgentResponse _getMockResponse(String userMessage) {
    final msg = userMessage.toLowerCase();

    if (msg.contains('subscription')) {
      return AgentResponse(
        thought: 'User wants to cancel a subscription.',
        tool: 'SubscriptionKiller',
        params: {'app_name': 'Extracted from message', 'billing_cycle': 'monthly'},
      );
    } else if (msg.contains('refund') || msg.contains('money back')) {
      return AgentResponse(
        thought: 'User wants to find or process a refund.',
        tool: 'RefundHunter',
        params: {'reason': 'User requested', 'priority': 'high'},
      );
    } else if (msg.contains('flight') || msg.contains('book') || msg.contains('travel')) {
      return AgentResponse(
        thought: 'User wants to book or search for flights.',
        tool: 'FlightSearch',
        params: {'destination': 'Extracted from message', 'max_price': 500},
      );
    } else if (msg.contains('calendar') || msg.contains('schedule') || msg.contains('meeting')) {
      return AgentResponse(
        thought: 'User wants to manage calendar events.',
        tool: 'CalendarAssistant',
        params: {'action': 'create', 'event_details': userMessage},
      );
    } else if (msg.contains('expense') || msg.contains('spend') || msg.contains('budget')) {
      return AgentResponse(
        thought: 'User wants to track an expense.',
        tool: 'ExpenseTracker',
        params: {'description': userMessage, 'category': 'General'},
      );
    } else if (msg.contains('light') || msg.contains('home') || msg.contains('thermostat')) {
      return AgentResponse(
        thought: 'User wants to control smart home devices.',
        tool: 'SmartHomeController',
        params: {'device': 'Auto-detected', 'action': 'toggle'},
      );
    } else if (msg.contains('cancel') || msg.contains('stop')) {
      return AgentResponse(
        thought: 'User wants to cancel something.',
        tool: 'SubscriptionKiller',
        params: {'app_name': 'Extracted from message', 'billing_cycle': 'monthly'},
      );
    }

    return AgentResponse(
      thought: 'I understand your request. Let me help you with that.',
      tool: 'GeneralAssistant',
      params: {'original_message': userMessage},
    );
  }
}
