enum MessageType { user, agent, system }

enum MessageStatus { idle, sending, sent, error }

class ChatMessage {
  final String id;
  final String content;
  final MessageType type;
  final DateTime timestamp;
  final MessageStatus status;
  final String? toolName;
  final Map<String, dynamic>? toolParams;

  const ChatMessage({
    required this.id,
    required this.content,
    required this.type,
    required this.timestamp,
    this.status = MessageStatus.sent,
    this.toolName,
    this.toolParams,
  });

  ChatMessage copyWith({
    String? id,
    String? content,
    MessageType? type,
    DateTime? timestamp,
    MessageStatus? status,
    String? toolName,
    Map<String, dynamic>? toolParams,
  }) {
    return ChatMessage(
      id: id ?? this.id,
      content: content ?? this.content,
      type: type ?? this.type,
      timestamp: timestamp ?? this.timestamp,
      status: status ?? this.status,
      toolName: toolName ?? this.toolName,
      toolParams: toolParams ?? this.toolParams,
    );
  }

  bool get isUser => type == MessageType.user;
  bool get isAgent => type == MessageType.agent;
  bool get isSystem => type == MessageType.system;
}
