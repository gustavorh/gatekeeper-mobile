import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;

class TimezoneUtils {
  static bool _initialized = false;

  static void initialize() {
    if (!_initialized) {
      tz.initializeTimeZones();
      _initialized = true;
    }
  }

  /// Convert UTC DateTime to America/Santiago timezone
  static DateTime utcToSantiago(DateTime utcDateTime) {
    initialize();
    return tz.TZDateTime.from(utcDateTime, tz.getLocation('America/Santiago'));
  }

  /// Convert UTC DateTime string to America/Santiago timezone
  static DateTime utcStringToSantiago(String utcString) {
    initialize();
    final utcDateTime = DateTime.parse(utcString);
    return utcToSantiago(utcDateTime);
  }

  /// Format DateTime to HH:MM format in Santiago timezone
  static String formatTimeToSantiago(DateTime dateTime) {
    final santiagoTime = utcToSantiago(dateTime);
    final hour = santiagoTime.hour.toString().padLeft(2, '0');
    final minute = santiagoTime.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  /// Format UTC DateTime string to HH:MM format in Santiago timezone
  static String formatUtcStringToSantiago(String utcString) {
    try {
      final utcDateTime = DateTime.parse(utcString);
      return formatTimeToSantiago(utcDateTime);
    } catch (e) {
      return '--:--';
    }
  }

  /// Get current time in Santiago timezone
  static DateTime getCurrentSantiagoTime() {
    initialize();
    return tz.TZDateTime.now(tz.getLocation('America/Santiago'));
  }

  /// Calculate duration between UTC clock-in time and current Santiago time
  static Duration calculateWorkDuration(String utcClockInTime) {
    try {
      final clockInSantiago = utcStringToSantiago(utcClockInTime);
      final nowSantiago = getCurrentSantiagoTime();
      return nowSantiago.difference(clockInSantiago);
    } catch (e) {
      return Duration.zero;
    }
  }

  /// Format work duration as "Xh Ym"
  static String formatWorkDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;
    return '${hours}h ${minutes}m';
  }
}
