import '../models/user.dart';
import 'api_service.dart';

abstract class AuthService {
  Future<User?> signIn(String email, String password);
  Future<User> signUp(String email, String password, String name);
  Future<void> signOut();
  Future<User?> getCurrentUser();
  Future<void> resetPassword(String email);
  Future<User?> updateProfile(Map<String, dynamic> updates);
}

class RealAuthService implements AuthService {
  User? _currentUser;

  @override
  Future<User?> signIn(String email, String password) async {
    try {
      final response = await ApiService.login(email, password);
      
      if (response['usuario'] != null) {
        _currentUser = User.fromJson(response['usuario']);
        return _currentUser;
      }
      return null;
    } catch (e) {
      print('Erro no login: $e');
      return null;
    }
  }

  @override
  Future<User> signUp(String email, String password, String name) async {
    try {
      final response = await ApiService.register(name, email, password);
      
      if (response['usuario'] != null) {
        _currentUser = User.fromJson(response['usuario']);
        return _currentUser!;
      }
      throw Exception('Falha no registro');
    } catch (e) {
      print('Erro no registro: $e');
      rethrow;
    }
  }

  @override
  Future<void> signOut() async {
    ApiService.clearAuthToken();
    _currentUser = null;
  }

  @override
  Future<User?> getCurrentUser() async {
    if (_currentUser != null) {
      return _currentUser;
    }
    
    try {
      final user = await ApiService.getProfile();
      _currentUser = user;
      return user;
    } catch (e) {
      print('Erro ao obter usuário atual: $e');
      return null;
    }
  }

  @override
  Future<void> resetPassword(String email) async {
    // Implementar quando o backend tiver essa funcionalidade
    throw UnimplementedError('Reset de senha não implementado ainda');
  }

  @override
  Future<User?> updateProfile(Map<String, dynamic> updates) async {
    try {
      final updatedUser = await ApiService.updateProfile(updates);
      _currentUser = updatedUser;
      return updatedUser;
    } catch (e) {
      print('Erro ao atualizar perfil: $e');
      return null;
    }
  }
}

// Serviço mock para desenvolvimento offline
class MockAuthService implements AuthService {
  User? _currentUser;

  @override
  Future<User?> signIn(String email, String password) async {
    // Simulação de delay de rede
    await Future.delayed(Duration(seconds: 1));
    
    if (email == 'test@example.com' && password == '123456') {
      _currentUser = User(
        id: '1',
        nomeUsuario: 'Caçador Teste',
        email: email,
        experiencia: 150,
        nivel: 3,
        titulo: 'Aspirante',
        createdAt: DateTime.now(),
        lastLogin: DateTime.now(),
        conquistas: ['primeira_chama', 'semana_dedicacao'],
        totalHabitos: 5,
        totalConclusoes: 12,
        taxaConclusao: 75.0,
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
      nomeUsuario: name,
      email: email,
      experiencia: 0,
      nivel: 1,
      titulo: 'Aspirante',
      createdAt: DateTime.now(),
      conquistas: [],
      totalHabitos: 0,
      totalConclusoes: 0,
      taxaConclusao: 0.0,
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

  @override
  Future<User?> updateProfile(Map<String, dynamic> updates) async {
    await Future.delayed(Duration(seconds: 1));
    
    if (_currentUser != null) {
      // Simular atualização do perfil
      _currentUser = User(
        id: _currentUser!.id,
        nomeUsuario: updates['nomeUsuario'] ?? _currentUser!.nomeUsuario,
        email: updates['email'] ?? _currentUser!.email,
        experiencia: _currentUser!.experiencia,
        nivel: _currentUser!.nivel,
        titulo: _currentUser!.titulo,
        createdAt: _currentUser!.createdAt,
        lastLogin: _currentUser!.lastLogin,
        conquistas: _currentUser!.conquistas,
        totalHabitos: _currentUser!.totalHabitos,
        totalConclusoes: _currentUser!.totalConclusoes,
        taxaConclusao: _currentUser!.taxaConclusao,
      );
    }
    
    return _currentUser;
  }
}
