import 'package:flutter_test/flutter_test.dart';
import 'package:shadow_agent/models/chat_message.dart';

void main() {
  group('ChatMessage', () {
    test('creates user message correctly', () {
      final message = ChatMessage(
        id: '1',
        content: 'Hello',
        type: MessageType.user,
        timestamp: DateTime(2024, 1, 1),
      );

      expect(message.isUser, true);
      expect(message.isAgent, false);
      expect(message.content, 'Hello');
    });

    test('creates agent message correctly', () {
      final message = ChatMessage(
        id: '2',
        content: 'I am here to help',
        type: MessageType.agent,
        timestamp: DateTime(2024, 1, 1),
        toolName: 'FlightSearch',
        toolParams: {'destination': 'NYC'},
      );

      expect(message.isAgent, true);
      expect(message.isUser, false);
      expect(message.toolName, 'FlightSearch');
    });

    test('copyWith creates new instance with updated values', () {
      final original = ChatMessage(
        id: '1',
        content: 'Original',
        type: MessageType.user,
        timestamp: DateTime(2024, 1, 1),
      );

      final copied = original.copyWith(content: 'Updated');

      expect(copied.content, 'Updated');
      expect(copied.id, original.id);
      expect(original.content, 'Original');
    });
  });
}
