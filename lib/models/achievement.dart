import 'package:flutter/material.dart';

class Achievement {
  final String id;
  final String nome;
  final String descricao;
  final String icone;
  final String cor;
  final String categoria;
  final int experienciaRecompensa;
  final bool desbloqueado;
  final DateTime? dataDesbloqueio;
  final Map<String, dynamic> criterios;
  final int progressoAtual;
  final int progressoNecessario;
  final String tipo; // 'automatico', 'personalizado'
  final bool raro; // conquistas raras/legendárias

  Achievement({
    required this.id,
    required this.nome,
    required this.descricao,
    required this.icone,
    required this.cor,
    required this.categoria,
    required this.experienciaRecompensa,
    this.desbloqueado = false,
    this.dataDesbloqueio,
    required this.criterios,
    this.progressoAtual = 0,
    required this.progressoNecessario,
    this.tipo = 'automatico',
    this.raro = false,
  });

  factory Achievement.fromJson(Map<String, dynamic> json) {
    return Achievement(
      id: json['_id'] ?? json['id'],
      nome: json['nome'] ?? '',
      descricao: json['descricao'] ?? '',
      icone: json['icone'] ?? 'trophy',
      cor: json['cor'] ?? '#D4AF37',
      categoria: json['categoria'] ?? 'geral',
      experienciaRecompensa: json['experienciaRecompensa'] ?? 0,
      desbloqueado: json['desbloqueado'] ?? false,
      dataDesbloqueio: json['dataDesbloqueio'] != null 
          ? DateTime.parse(json['dataDesbloqueio'])
          : null,
      criterios: json['criterios'] ?? {},
      progressoAtual: json['progressoAtual'] ?? 0,
      progressoNecessario: json['progressoNecessario'] ?? 1,
      tipo: json['tipo'] ?? 'automatico',
      raro: json['raro'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nome': nome,
      'descricao': descricao,
      'icone': icone,
      'cor': cor,
      'categoria': categoria,
      'experienciaRecompensa': experienciaRecompensa,
      'desbloqueio': desbloqueado,
      'dataDesbloqueio': dataDesbloqueio?.toIso8601String(),
      'criterios': criterios,
      'progressoAtual': progressoAtual,
      'progressoNecessario': progressoNecessario,
      'tipo': tipo,
      'raro': raro,
    };
  }

  // Getters para compatibilidade
  String get title => nome;
  String get description => descricao;
  bool get isUnlocked => desbloqueado;
  
  // Métodos de gamificação
  Color get corAchievement {
    return _parseColor(cor);
  }
  
  double get progressoPercentual {
    if (progressoNecessario == 0) return 0.0;
    return (progressoAtual / progressoNecessario).clamp(0.0, 1.0);
  }
  
  bool get podeDesbloquear {
    return progressoAtual >= progressoNecessario && !desbloqueado;
  }
  
  String get statusTexto {
    if (desbloqueado) {
      return 'Desbloqueado';
    } else if (progressoAtual > 0) {
      return '$progressoAtual/$progressoNecessario';
    } else {
      return 'Bloqueado';
    }
  }
  
  IconData get iconeFlutter {
    switch (icone) {
      case 'trophy':
        return Icons.emoji_events;
      case 'fire':
        return Icons.local_fire_department;
      case 'star':
        return Icons.star;
      case 'sword':
        return Icons.flash_on;
      case 'shield':
        return Icons.security;
      case 'crown':
        return Icons.workspace_premium;
      case 'gem':
        return Icons.diamond;
      case 'skull':
        return Icons.psychology;
      default:
        return Icons.emoji_events;
    }
  }

  static Color _parseColor(String hexColor) {
    hexColor = hexColor.replaceAll('#', '');
    if (hexColor.length == 6) {
      hexColor = 'FF' + hexColor;
    }
    return Color(int.parse(hexColor, radix: 16));
  }
}

// Conquistas padrão do sistema
class DefaultAchievements {
  static List<Achievement> get list => [
    Achievement(
      id: 'primeira_chama',
      nome: 'Primeira Chama',
      descricao: 'Complete seu primeiro hábito',
      icone: 'fire',
      cor: '#FF6B35',
      categoria: 'iniciante',
      experienciaRecompensa: 50,
      progressoNecessario: 1,
      criterios: {'tipo': 'primeiro_habito'},
    ),
    Achievement(
      id: 'semana_dedicacao',
      nome: 'Semana de Dedicação',
      descricao: 'Mantenha uma sequência de 7 dias',
      icone: 'star',
      cor: '#4CAF50',
      categoria: 'persistencia',
      experienciaRecompensa: 100,
      progressoNecessario: 7,
      criterios: {'tipo': 'sequencia_dias'},
    ),
    Achievement(
      id: 'mestre_persistencia',
      nome: 'Mestre da Persistência',
      descricao: 'Mantenha uma sequência de 30 dias',
      icone: 'crown',
      cor: '#9C27B0',
      categoria: 'persistencia',
      experienciaRecompensa: 500,
      progressoNecessario: 30,
      criterios: {'tipo': 'sequencia_dias'},
      raro: true,
    ),
    Achievement(
      id: 'cacador_iniciante',
      nome: 'Caçador Iniciante',
      descricao: 'Alcance o nível 10',
      icone: 'sword',
      cor: '#FF9800',
      categoria: 'nivel',
      experienciaRecompensa: 200,
      progressoNecessario: 10,
      criterios: {'tipo': 'nivel_usuario'},
    ),
    Achievement(
      id: 'guardiao_tempo',
      nome: 'Guardião do Tempo',
      descricao: 'Alcance o nível 20',
      icone: 'shield',
      cor: '#3F51B5',
      categoria: 'nivel',
      experienciaRecompensa: 500,
      progressoNecessario: 20,
      criterios: {'tipo': 'nivel_usuario'},
      raro: true,
    ),
    Achievement(
      id: 'conjurador_supremo',
      nome: 'Conjurador Supremo',
      descricao: 'Alcance o nível 30',
      icone: 'gem',
      cor: '#E91E63',
      categoria: 'nivel',
      experienciaRecompensa: 1000,
      progressoNecessario: 30,
      criterios: {'tipo': 'nivel_usuario'},
      raro: true,
    ),
    Achievement(
      id: 'sequencia_perfeita',
      nome: 'Sequência Perfeita',
      descricao: 'Complete todos os hábitos de uma semana',
      icone: 'star',
      cor: '#FFD700',
      categoria: 'perfeicao',
      experienciaRecompensa: 300,
      progressoNecessario: 1,
      criterios: {'tipo': 'semana_perfeita'},
      raro: true,
    ),
    Achievement(
      id: 'colecionador',
      nome: 'Colecionador',
      descricao: 'Crie 10 hábitos diferentes',
      icone: 'collection',
      cor: '#00BCD4',
      categoria: 'criacao',
      experienciaRecompensa: 150,
      progressoNecessario: 10,
      criterios: {'tipo': 'total_habitos'},
    ),
  ];
}
