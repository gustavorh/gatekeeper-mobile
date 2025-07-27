import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/services/user_service.dart';

void main() {
  group('UserService', () {
    test('computeUserInitials should return correct initials', () {
      expect(UserService.computeUserInitials('John', 'Doe'), 'JD');
      expect(UserService.computeUserInitials('Mary', 'Jane'), 'MJ');
      expect(UserService.computeUserInitials('A', 'B'), 'AB');
      expect(UserService.computeUserInitials('', 'Doe'), 'D');
      expect(UserService.computeUserInitials('John', ''), 'J');
      expect(UserService.computeUserInitials('', ''), '');
    });

    test('getFullName should return correct full name', () {
      expect(UserService.getFullName('John', 'Doe'), 'John Doe');
      expect(UserService.getFullName('Mary', 'Jane'), 'Mary Jane');
      expect(UserService.getFullName('A', 'B'), 'A B');
      expect(UserService.getFullName('', 'Doe'), 'Doe');
      expect(UserService.getFullName('John', ''), 'John');
      expect(UserService.getFullName('', ''), '');
    });
  });
}
