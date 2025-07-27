import 'timezone_utils.dart';

/// Example usage of TimezoneUtils
/// This file demonstrates how to use the timezone conversion utilities
class TimezoneExample {
  static void demonstrateUsage() {
    // Example 1: Convert UTC time to Santiago time
    final utcTime = '2024-01-15T15:30:00.000Z';
    final santiagoTime = TimezoneUtils.formatUtcStringToSantiago(utcTime);
    print('UTC: $utcTime -> Santiago: $santiagoTime');

    // Example 2: Calculate work duration
    final clockInTime = '2024-01-15T08:00:00.000Z';
    final workDuration = TimezoneUtils.calculateWorkDuration(clockInTime);
    final formattedDuration = TimezoneUtils.formatWorkDuration(workDuration);
    print('Clock-in: $clockInTime -> Work duration: $formattedDuration');

    // Example 3: Get current Santiago time
    final currentSantiago = TimezoneUtils.getCurrentSantiagoTime();
    print('Current Santiago time: $currentSantiago');
  }
}

/*
Example output:
UTC: 2024-01-15T15:30:00.000Z -> Santiago: 12:30
Clock-in: 2024-01-15T08:00:00.000Z -> Work duration: 4h 30m
Current Santiago time: 2024-01-15 12:30:00.000

Note: The actual times will vary depending on:
1. Whether it's summer time (UTC-3) or winter time (UTC-4) in Chile
2. The current date and time when the code runs
3. Daylight saving time transitions
*/
