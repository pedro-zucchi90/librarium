import 'package:flutter/material.dart';

class Habit {
  final String id;
  final String idUsuario;
  final String titulo;
  final String descricao;
  final String frequencia; // 'diario', 'semanal', 'mensal'
  final String categoria; // 'saude', 'estudo', 'trabalho', 'fitness', 'criatividade', 'social'
  final String dificuldade; // 'facil', 'medio', 'dificil', 'lendario'
  final int recompensaExperiencia;
  final String icone;
  final String cor;
  final bool ativo;
  final Sequencia sequencia;
  final Estatisticas estatisticas;
  final DateTime createdAt;
  final DateTime? lastCompleted;
  final List<String> diasSemana; // ['monday', 'tuesday', etc.]
  final TimeOfDay? horarioLembrete;
  final bool notificacoes;

  Habit({
    required this.id,
    required this.idUsuario,
    required this.titulo,
    required this.descricao,
    required this.frequencia,
    required this.categoria,
    required this.dificuldade,
    this.recompensaExperiencia = 10,
    this.icone = 'sword',
    this.cor = '#8B0000',
    this.ativo = true,
    this.sequencia = const Sequencia(),
    this.estatisticas = const Estatisticas(),
    required this.createdAt,
    this.lastCompleted,
    this.diasSemana = const [],
    this.horarioLembrete,
    this.notificacoes = true,
  });

  factory Habit.fromJson(Map<String, dynamic> json) {
    return Habit(
      id: json['_id'] ?? json['id'],
      idUsuario: json['idUsuario'] ?? json['user_id'] ?? '',
      titulo: json['titulo'] ?? json['title'] ?? '',
      descricao: json['descricao'] ?? json['description'] ?? '',
      frequencia: json['frequencia'] ?? 'diario',
      categoria: json['categoria'] ?? json['category'] ?? 'geral',
      dificuldade: json['dificuldade'] ?? 'medio',
      recompensaExperiencia: json['recompensaExperiencia'] ?? 10,
      icone: json['icone'] ?? 'sword',
      cor: json['cor'] ?? '#8B0000',
      ativo: json['ativo'] ?? true,
      sequencia: Sequencia.fromJson(json['sequencia'] ?? {}),
      estatisticas: Estatisticas.fromJson(json['estatisticas'] ?? {}),
      createdAt: DateTime.parse(json['createdAt'] ?? json['created_at'] ?? DateTime.now().toIso8601String()),
      lastCompleted: json['lastCompleted'] != null 
          ? DateTime.parse(json['lastCompleted']) 
          : null,
      diasSemana: List<String>.from(json['diasSemana'] ?? json['days_of_week'] ?? []),
      horarioLembrete: json['horarioLembrete'] != null 
          ? _parseTimeOfDay(json['horarioLembrete'])
          : null,
      notificacoes: json['notificacoes'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'idUsuario': idUsuario,
      'titulo': titulo,
      'descricao': descricao,
      'frequencia': frequencia,
      'categoria': categoria,
      'dificuldade': dificuldade,
      'recompensaExperiencia': recompensaExperiencia,
      'icone': icone,
      'cor': cor,
      'ativo': ativo,
      'sequencia': sequencia.toJson(),
      'estatisticas': estatisticas.toJson(),
      'createdAt': createdAt.toIso8601String(),
      'lastCompleted': lastCompleted?.toIso8601String(),
      'diasSemana': diasSemana,
      'horarioLembrete': horarioLembrete?.toString(),
      'notificacoes': notificacoes,
    };
  }

  // Getters para compatibilidade
  String get title => titulo;
  String get description => descricao;
  String get category => categoria;
  bool get isActive => ativo;
  
  // Métodos de gamificação
  Color get corHabit {
    return _parseColor(cor);
  }
  
  String get iconeCategoria {
    switch (categoria.toLowerCase()) {
      case 'saude':
        return 'heart';
      case 'estudo':
        return 'book';
      case 'trabalho':
        return 'briefcase';
      case 'fitness':
        return 'dumbbell';
      case 'criatividade':
        return 'paintbrush';
      case 'social':
        return 'users';
      default:
        return 'star';
    }
  }
  
  String get nomeDificuldade {
    switch (dificuldade.toLowerCase()) {
      case 'facil':
        return 'Fácil';
      case 'medio':
        return 'Médio';
      case 'dificil':
        return 'Difícil';
      case 'lendario':
        return 'Lendário';
      default:
        return 'Médio';
    }
  }
  
  Color get corDificuldade {
    switch (dificuldade.toLowerCase()) {
      case 'facil':
        return Color(0xFF4CAF50);
      case 'medio':
        return Color(0xFFFF9800);
      case 'dificil':
        return Color(0xFFF44336);
      case 'lendario':
        return Color(0xFF9C27B0);
      default:
        return Color(0xFFFF9800);
    }
  }

  static TimeOfDay _parseTimeOfDay(String timeString) {
    final parts = timeString.split(':');
    return TimeOfDay(
      hour: int.parse(parts[0]),
      minute: int.parse(parts[1]),
    );
  }

  static Color _parseColor(String hexColor) {
    hexColor = hexColor.replaceAll('#', '');
    if (hexColor.length == 6) {
      hexColor = 'FF' + hexColor;
    }
    return Color(int.parse(hexColor, radix: 16));
  }
}

class Sequencia {
  final int atual;
  final int maiorSequencia;

  const Sequencia({
    this.atual = 0,
    this.maiorSequencia = 0,
  });

  factory Sequencia.fromJson(Map<String, dynamic> json) {
    return Sequencia(
      atual: json['atual'] ?? 0,
      maiorSequencia: json['maiorSequencia'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'atual': atual,
      'maiorSequencia': maiorSequencia,
    };
  }
}

class Estatisticas {
  final int totalConclusoes;
  final int totalPerdidos;
  final double taxaConclusao;

  const Estatisticas({
    this.totalConclusoes = 0,
    this.totalPerdidos = 0,
    this.taxaConclusao = 0.0,
  });

  factory Estatisticas.fromJson(Map<String, dynamic> json) {
    return Estatisticas(
      totalConclusoes: json['totalConclusoes'] ?? 0,
      totalPerdidos: json['totalPerdidos'] ?? 0,
      taxaConclusao: (json['taxaConclusao'] ?? 0.0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalConclusoes': totalConclusoes,
      'totalPerdidos': totalPerdidos,
      'taxaConclusao': taxaConclusao,
    };
  }
}

class TimeOfDay {
  final int hour;
  final int minute;

  TimeOfDay({required this.hour, required this.minute});

  @override
  String toString() {
    return '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
  }
}
