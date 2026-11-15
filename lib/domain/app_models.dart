const kAllowedDomain = 'iba.edu.pk';

class Room {
  final String id, name;
  final int floor, capacity;
  const Room({required this.id, required this.name, required this.floor, required this.capacity});
}

class AppUser {
  final String uid, name, email, role;
  const AppUser({required this.uid, required this.name, required this.email, required this.role});
  bool get isAdmin => role == 'admin';
}

class AuthFailure implements Exception {
  final String message;
  AuthFailure(this.message);
  @override String toString() => message;
}

class InvalidEmailDomainException implements Exception {
  @override String toString() => 'Use your IBA email (must contain $kAllowedDomain)';
}

class Validators {
  static bool isAllowedEmail(String email) =>
      email.trim().toLowerCase().contains(kAllowedDomain);
}

abstract class AuthRepository {
  Stream<AppUser?> watchCurrentUser();
  Future<void> signUp({required String name, required String email, required String password});
  Future<void> signIn({required String email, required String password});
  Future<void> signOut();
}

abstract class RoomRepository {
  Stream<List<Room>> watchRooms();
}
