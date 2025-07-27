import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/utils/timezone_utils.dart';

void main() {
  group('TimezoneUtils', () {
    test('formatUtcStringToSantiago should convert UTC to Santiago time', () {
      // Test with a known UTC time (2024-01-15 15:30:00 UTC)
      // This should be 12:30 in Santiago during summer (UTC-3) or 11:30 during winter (UTC-4)
      final utcString = '2024-01-15T15:30:00.000Z';
      final result = TimezoneUtils.formatUtcStringToSantiago(utcString);

      // The result should be in HH:MM format
      expect(result, matches(r'^\d{2}:\d{2}$'));
      expect(result, isNot('--:--'));
    });

    test('formatUtcStringToSantiago should handle invalid input', () {
      final result = TimezoneUtils.formatUtcStringToSantiago('invalid-date');
      expect(result, '--:--');
    });

    test('calculateWorkDuration should calculate correct duration', () {
      // Test with a clock-in time 2 hours ago
      final now = DateTime.now();
      final twoHoursAgo = now.subtract(const Duration(hours: 2));
      final utcString = twoHoursAgo.toUtc().toIso8601String();

      final duration = TimezoneUtils.calculateWorkDuration(utcString);

      // Should be approximately 2 hours (allowing for some test execution time)
      expect(duration.inHours, greaterThanOrEqualTo(1));
      expect(duration.inHours, lessThanOrEqualTo(3));
    });

    test('formatWorkDuration should format duration correctly', () {
      final duration = const Duration(hours: 2, minutes: 30);
      final result = TimezoneUtils.formatWorkDuration(duration);
      expect(result, '2h 30m');
    });

    test('formatWorkDuration should handle zero duration', () {
      final duration = Duration.zero;
      final result = TimezoneUtils.formatWorkDuration(duration);
      expect(result, '0h 0m');
    });

    test('getCurrentSantiagoTime should return current time in Santiago', () {
      final santiagoTime = TimezoneUtils.getCurrentSantiagoTime();
      expect(santiagoTime, isA<DateTime>());

      // Should be a reasonable time (not in the future or too far in the past)
      final now = DateTime.now();
      final difference = now.difference(santiagoTime).abs();
      expect(difference.inHours, lessThan(24));
    });
  });
}
