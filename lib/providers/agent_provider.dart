import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/chat_message.dart';
import '../services/api_service.dart';

class AgentState {
  final List<ChatMessage> messages;
  final bool isLoading;
  final String? error;
  final bool isConfigured;

  const AgentState({
    this.messages = const [],
    this.isLoading = false,
    this.error,
    this.isConfigured = false,
  });

  AgentState copyWith({
    List<ChatMessage>? messages,
    bool? isLoading,
    String? error,
    bool? isConfigured,
  }) {
    return AgentState(
      messages: messages ?? this.messages,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      isConfigured: isConfigured ?? this.isConfigured,
    );
  }
}

class AgentNotifier extends StateNotifier<AgentState> {
  final ApiService _apiService;

  AgentNotifier(this._apiService) : super(const AgentState());

  void configure(String apiKey) {
    _apiService.configure(apiKey);
    state = state.copyWith(isConfigured: _apiService.isConfigured);
  }

  Future<void> sendMessage(String content) async {
    if (content.trim().isEmpty) return;

    final userMessage = ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      content: content,
      type: MessageType.user,
      timestamp: DateTime.now(),
      status: MessageStatus.sent,
    );

    final thinkingMessage = ChatMessage(
      id: '${userMessage.id}_thinking',
      content: 'Thinking...',
      type: MessageType.agent,
      timestamp: DateTime.now(),
      status: MessageStatus.sending,
    );

    state = state.copyWith(
      messages: [...state.messages, userMessage, thinkingMessage],
      isLoading: true,
      error: null,
    );

    try {
      final response = await _apiService.processRequest(content);

      final agentMessage = ChatMessage(
        id: '${userMessage.id}_response',
        content: response.thought,
        type: MessageType.agent,
        timestamp: DateTime.now(),
        status: MessageStatus.sent,
        toolName: response.tool,
        toolParams: response.params,
      );

      final updatedMessages = state.messages
          .where((m) => m.id != thinkingMessage.id)
          .toList()
        ..add(agentMessage);

      state = state.copyWith(
        messages: updatedMessages,
        isLoading: false,
      );
    } catch (e) {
      final errorMessages = state.messages
          .where((m) => m.id != thinkingMessage.id)
          .toList()
        ..add(ChatMessage(
          id: '${userMessage.id}_error',
          content: 'Error: ${e.toString()}',
          type: MessageType.system,
          timestamp: DateTime.now(),
          status: MessageStatus.error,
        ));

      state = state.copyWith(
        messages: errorMessages,
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  void clearHistory() {
    state = state.copyWith(messages: [], error: null);
  }

  Future<void> loadHistory() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.getStringList('chat_history');
    state = state.copyWith(messages: []);
  }

  Future<void> saveHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      'chat_history',
      state.messages.map((m) => '${m.type.name}:${m.content}').toList(),
    );
  }
}

final apiServiceProvider = Provider<ApiService>((ref) => ApiService());

final agentProvider = StateNotifierProvider<AgentNotifier, AgentState>((ref) {
  return AgentNotifier(ref.watch(apiServiceProvider));
});
