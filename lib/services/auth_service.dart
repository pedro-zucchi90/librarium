import '../models/user.dart';

abstract class AuthService {
  Future<User?> signIn(String email, String password);
  Future<User> signUp(String email, String password, String name);
  Future<void> signOut();
  Future<User?> getCurrentUser();
  Future<void> resetPassword(String email);
}

class MockAuthService implements AuthService {
  User? _currentUser;

  @override
  Future<User?> signIn(String email, String password) async {
    // Simulação de delay de rede
    await Future.delayed(Duration(seconds: 1));
    
    if (email == 'test@example.com' && password == '123456') {
      _currentUser = User(
        id: '1',
        email: email,
        name: 'Usuário Teste',
        createdAt: DateTime.now(),
        lastLogin: DateTime.now(),
      );
      return _currentUser;
    }
    return null;
  }

  @override
  Future<User> signUp(String email, String password, String name) async {
    await Future.delayed(Duration(seconds: 1));
    
    _currentUser = User(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      email: email,
      name: name,
      createdAt: DateTime.now(),
    );
    return _currentUser!;
  }

  @override
  Future<void> signOut() async {
    await Future.delayed(Duration(milliseconds: 500));
    _currentUser = null;
  }

  @override
  Future<User?> getCurrentUser() async {
    return _currentUser;
  }

  @override
  Future<void> resetPassword(String email) async {
    await Future.delayed(Duration(seconds: 1));
    // Simulação de envio de email
  }
}
