import 'package:flutter_test/flutter_test.dart';

void main() {
  group('API Response Parsing', () {
    test('should parse shifts from API response correctly', () {
      // Sample API response
      final apiResponse = {
        "success": true,
        "message": "Operation completed successfully",
        "data": {
          "success": true,
          "message": "Operation completed successfully",
          "data": {
            "shifts": [
              {
                "id": "3a27d344-46f1-4019-a70c-5e4c2f1c6e21",
                "userId": "93851bd2-cbfa-43d9-8515-cf9b6514cb65",
                "clockInTime": "2025-07-27T20:30:50.000Z",
                "clockOutTime": null,
                "lunchStartTime": null,
                "lunchEndTime": null,
                "status": "active",
                "createdAt": "2025-07-27T20:30:50.000Z",
                "updatedAt": "2025-07-27T20:30:50.000Z",
              },
              {
                "id": "d3faa262-29bc-4af8-a729-918fab259f23",
                "userId": "93851bd2-cbfa-43d9-8515-cf9b6514cb65",
                "clockInTime": "2025-07-27T20:28:28.000Z",
                "clockOutTime": "2025-07-27T20:30:49.000Z",
                "lunchStartTime": null,
                "lunchEndTime": null,
                "status": "completed",
                "createdAt": "2025-07-27T20:28:28.000Z",
                "updatedAt": "2025-07-27T20:30:49.000Z",
              },
            ],
            "total": 2,
          },
        },
        "timestamp": "2025-07-27T21:09:35.281Z",
        "endpoint": "/shifts/history?limit=10&offset=0",
      };

      // Test parsing logic
      final result = apiResponse;
      final data = result['data'] as Map<String, dynamic>;
      final nestedData = data['data'] as Map<String, dynamic>;
      final shifts = nestedData['shifts'] as List;

      expect(result['success'], isTrue);
      expect(data, isNotNull);
      expect(shifts, isA<List>());
      expect(shifts.length, 2);

      // Test first shift
      final firstShift = shifts[0] as Map<String, dynamic>;
      expect(firstShift['id'], '3a27d344-46f1-4019-a70c-5e4c2f1c6e21');
      expect(firstShift['status'], 'active');
      expect(firstShift['clockInTime'], '2025-07-27T20:30:50.000Z');
      expect(firstShift['clockOutTime'], isNull);

      // Test second shift
      final secondShift = shifts[1] as Map<String, dynamic>;
      expect(secondShift['id'], 'd3faa262-29bc-4af8-a729-918fab259f23');
      expect(secondShift['status'], 'completed');
      expect(secondShift['clockInTime'], '2025-07-27T20:28:28.000Z');
      expect(secondShift['clockOutTime'], '2025-07-27T20:30:49.000Z');
    });

    test('should handle empty shifts array', () {
      final apiResponse = {
        "success": true,
        "message": "Operation completed successfully",
        "data": {
          "success": true,
          "message": "Operation completed successfully",
          "data": {"shifts": [], "total": 0},
        },
      };

      final result = apiResponse;
      final data = result['data'] as Map<String, dynamic>;
      final nestedData = data['data'] as Map<String, dynamic>;
      final shifts = nestedData['shifts'] as List;

      expect(result['success'], isTrue);
      expect(shifts.length, 0);
    });

    test('should handle missing shifts key', () {
      final apiResponse = {
        "success": true,
        "message": "Operation completed successfully",
        "data": {
          "success": true,
          "message": "Operation completed successfully",
          "data": {"total": 0},
        },
      };

      final result = apiResponse;
      final data = result['data'] as Map<String, dynamic>;
      final nestedData = data['data'] as Map<String, dynamic>;
      final shifts = nestedData['shifts'];

      expect(result['success'], isTrue);
      expect(shifts, isNull);
    });
  });
}
