import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/user.dart';
import '../models/habit.dart';
import '../models/achievement.dart';
import '../models/progress.dart';

class ApiService {
  static const String baseUrl = 'http://localhost:3000/api';
  static String? _authToken;

  // Configuração do token de autenticação
  static void setAuthToken(String token) {
    _authToken = token;
  }

  static void clearAuthToken() {
    _authToken = null;
  }

  static Map<String, String> get _headers {
    final headers = {
      'Content-Type': 'application/json',
    };
    
    if (_authToken != null) {
      headers['Authorization'] = 'Bearer $_authToken';
    }
    
    return headers;
  }

  // Métodos de autenticação
  static Future<Map<String, dynamic>> login(String email, String senha) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/login'),
        headers: _headers,
        body: jsonEncode({
          'email': email,
          'senha': senha,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['token']) {
          setAuthToken(data['token']);
        }
        return data;
      } else {
        throw Exception('Falha no login: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erro de conexão: $e');
    }
  }

  static Future<Map<String, dynamic>> register(String nomeUsuario, String email, String senha) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/registrar'),
        headers: _headers,
        body: jsonEncode({
          'nomeUsuario': nomeUsuario,
          'email': email,
          'senha': senha,
        }),
      );

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        if (data['token']) {
          setAuthToken(data['token']);
        }
        return data;
      } else {
        throw Exception('Falha no registro: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erro de conexão: $e');
    }
  }

  static Future<User?> getProfile() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/auth/perfil'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return User.fromJson(data);
      } else {
        throw Exception('Falha ao obter perfil: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erro de conexão: $e');
    }
  }

  static Future<User> updateProfile(Map<String, dynamic> updates) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/auth/perfil'),
        headers: _headers,
        body: jsonEncode(updates),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return User.fromJson(data);
      } else {
        throw Exception('Falha ao atualizar perfil: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erro de conexão: $e');
    }
  }

  // Métodos de hábitos
  static Future<List<Habit>> getHabits() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/habitos'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => Habit.fromJson(json)).toList();
      } else {
        throw Exception('Falha ao obter hábitos: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erro de conexão: $e');
    }
  }

  static Future<Habit> createHabit(Map<String, dynamic> habitData) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/habitos'),
        headers: _headers,
        body: jsonEncode(habitData),
      );

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return Habit.fromJson(data);
      } else {
        throw Exception('Falha ao criar hábito: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erro de conexão: $e');
    }
  }

  static Future<Habit> updateHabit(String id, Map<String, dynamic> updates) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/habitos/$id'),
        headers: _headers,
        body: jsonEncode(updates),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return Habit.fromJson(data);
      } else {
        throw Exception('Falha ao atualizar hábito: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erro de conexão: $e');
    }
  }

  static Future<void> deleteHabit(String id) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/habitos/$id'),
        headers: _headers,
      );

      if (response.statusCode != 200) {
        throw Exception('Falha ao deletar hábito: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erro de conexão: $e');
    }
  }

  static Future<Map<String, dynamic>> completeHabit(String id, String status, {String? observacoes}) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/habitos/$id/concluir'),
        headers: _headers,
        body: jsonEncode({
          'status': status,
          'observacoes': observacoes,
        }),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Falha ao completar hábito: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erro de conexão: $e');
    }
  }

  // Métodos de conquistas
  static Future<List<Achievement>> getAchievements() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/conquistas'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => Achievement.fromJson(json)).toList();
      } else {
        throw Exception('Falha ao obter conquistas: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erro de conexão: $e');
    }
  }

  static Future<Achievement> createAchievement(Map<String, dynamic> achievementData) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/conquistas'),
        headers: _headers,
        body: jsonEncode(achievementData),
      );

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return Achievement.fromJson(data);
      } else {
        throw Exception('Falha ao criar conquista: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erro de conexão: $e');
    }
  }

  // Métodos de progresso
  static Future<List<Progress>> getHabitProgress(String habitId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/habitos/$habitId/progresso'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => Progress.fromJson(json)).toList();
      } else {
        throw Exception('Falha ao obter progresso: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erro de conexão: $e');
    }
  }

  // Métodos de estatísticas
  static Future<Map<String, dynamic>> getStats() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/estatisticas'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Falha ao obter estatísticas: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erro de conexão: $e');
    }
  }

  static Future<Map<String, dynamic>> getWeeklyChart() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/estatisticas/grafico-semanal'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Falha ao obter gráfico semanal: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erro de conexão: $e');
    }
  }

  static Future<Map<String, dynamic>> getHeatmap() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/estatisticas/heatmap'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Falha ao obter heatmap: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erro de conexão: $e');
    }
  }

  // Métodos de usuário
  static Future<Map<String, dynamic>> getDashboard() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/usuarios/dashboard'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Falha ao obter dashboard: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erro de conexão: $e');
    }
  }

  static Future<List<Map<String, dynamic>>> getRanking() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/usuarios/ranking'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.cast<Map<String, dynamic>>();
      } else {
        throw Exception('Falha ao obter ranking: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erro de conexão: $e');
    }
  }

  // Métodos de integração
  static Future<Map<String, dynamic>> getGoogleCalendarAuth() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/integracoes/google-calendar/auth'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Falha ao obter auth do Google Calendar: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erro de conexão: $e');
    }
  }

  static Future<Map<String, dynamic>> syncGoogleCalendar() async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/integracoes/google-calendar/sincronizar'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Falha ao sincronizar Google Calendar: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erro de conexão: $e');
    }
  }

  // Métodos de notificações
  static Future<Map<String, dynamic>> subscribePushNotifications(String subscription) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/notificacoes/push/subscribe'),
        headers: _headers,
        body: jsonEncode({
          'subscription': subscription,
        }),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Falha ao subscrever notificações: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erro de conexão: $e');
    }
  }

  // Métodos de exportação/importação
  static Future<String> exportData(String format) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/dados/exportar?formato=$format'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        return response.body;
      } else {
        throw Exception('Falha ao exportar dados: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erro de conexão: $e');
    }
  }

  static Future<Map<String, dynamic>> importData(String data, String format) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/dados/importar'),
        headers: _headers,
        body: jsonEncode({
          'dados': data,
          'formato': format,
        }),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Falha ao importar dados: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erro de conexão: $e');
    }
  }

  // Verificação de saúde da API
  static Future<bool> checkApiHealth() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/saude'),
        headers: _headers,
      );

      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}
