import 'package:flutter_test/flutter_test.dart';
import 'package:shadow_agent/services/api_service.dart';

void main() {
  group('ApiService', () {
    late ApiService apiService;

    setUp(() {
      apiService = ApiService();
    });

    test('returns mock response for flight queries', () async {
      apiService.configure('test_key');
      final response = await apiService.processRequest('Find me a flight to NYC');

      expect(response.tool, 'FlightSearch');
      expect(response.thought, isNotEmpty);
    });

    test('returns mock response for refund queries', () async {
      apiService.configure('test_key');
      final response = await apiService.processRequest('I want a refund for my flight');

      expect(response.tool, 'RefundHunter');
    });

    test('returns mock response for subscription queries', () async {
      apiService.configure('test_key');
      final response = await apiService.processRequest('Cancel my Netflix subscription');

      expect(response.tool, 'SubscriptionKiller');
    });

    test('isConfigured returns true when API key is set', () {
      apiService.configure('valid_key');
      expect(apiService.isConfigured, true);
    });

    test('isConfigured returns false when API key is empty', () {
      apiService.configure('');
      expect(apiService.isConfigured, false);
    });

    test('isConfigured returns false when API key is placeholder', () {
      apiService.configure('YOUR_API_KEY');
      expect(apiService.isConfigured, false);
    });
  });
}
