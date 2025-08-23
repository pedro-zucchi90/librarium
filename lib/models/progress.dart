import 'package:flutter/material.dart';

class Progress {
  final String id;
  final String idHabito;
  final String idUsuario;
  final DateTime data;
  final String status; // 'concluido', 'perdido', 'parcial'
  final String? observacoes;
  final int experienciaGanha;
  final String dificuldade;
  final Map<String, dynamic> metadados;

  Progress({
    required this.id,
    required this.idHabito,
    required this.idUsuario,
    required this.data,
    required this.status,
    this.observacoes,
    this.experienciaGanha = 0,
    this.dificuldade = 'medio',
    this.metadados = const {},
  });

  factory Progress.fromJson(Map<String, dynamic> json) {
    return Progress(
      id: json['_id'] ?? json['id'],
      idHabito: json['idHabito'] ?? json['id_habito'] ?? '',
      idUsuario: json['idUsuario'] ?? json['id_usuario'] ?? '',
      data: DateTime.parse(json['data'] ?? DateTime.now().toIso8601String()),
      status: json['status'] ?? 'parcial',
      observacoes: json['observacoes'],
      experienciaGanha: json['experienciaGanha'] ?? 0,
      dificuldade: json['dificuldade'] ?? 'medio',
      metadados: json['metadados'] ?? {},
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'idHabito': idHabito,
      'idUsuario': idUsuario,
      'data': data.toIso8601String(),
      'status': status,
      'observacoes': observacoes,
      'experienciaGanha': experienciaGanha,
      'dificuldade': dificuldade,
      'metadados': metadados,
    };
  }

  // Métodos de gamificação
  bool get foiConcluido => status == 'concluido';
  bool get foiPerdido => status == 'perdido';
  bool get foiParcial => status == 'parcial';
  
  Color get corStatus {
    switch (status) {
      case 'concluido':
        return Color(0xFF4CAF50);
      case 'perdido':
        return Color(0xFFF44336);
      case 'parcial':
        return Color(0xFFFF9800);
      default:
        return Color(0xFF9E9E9E);
    }
  }
  
  IconData get iconeStatus {
    switch (status) {
      case 'concluido':
        return Icons.check_circle;
      case 'perdido':
        return Icons.cancel;
      case 'parcial':
        return Icons.pending;
      default:
        return Icons.help;
    }
  }
  
  String get statusTexto {
    switch (status) {
      case 'concluido':
        return 'Concluído';
      case 'perdido':
        return 'Perdido';
      case 'parcial':
        return 'Parcial';
      default:
        return 'Desconhecido';
    }
  }
  
  String get dataFormatada {
    final hoje = DateTime.now();
    final ontem = hoje.subtract(Duration(days: 1));
    
    if (data.year == hoje.year && data.month == hoje.month && data.day == hoje.day) {
      return 'Hoje';
    } else if (data.year == ontem.year && data.month == ontem.month && data.day == ontem.day) {
      return 'Ontem';
    } else {
      return '${data.day.toString().padLeft(2, '0')}/${data.month.toString().padLeft(2, '0')}';
    }
  }
  
  bool get isHoje {
    final hoje = DateTime.now();
    return data.year == hoje.year && data.month == hoje.month && data.day == hoje.day;
  }
  
  bool get isEstaSemana {
    final hoje = DateTime.now();
    final inicioSemana = hoje.subtract(Duration(days: hoje.weekday - 1));
    final fimSemana = inicioSemana.add(Duration(days: 6));
    
    return data.isAfter(inicioSemana.subtract(Duration(days: 1))) && 
           data.isBefore(fimSemana.add(Duration(days: 1)));
  }
}

// Estatísticas de progresso
class ProgressStats {
  final int totalConclusoes;
  final int totalPerdidos;
  final int totalParciais;
  final double taxaConclusao;
  final int experienciaTotal;
  final int sequenciaAtual;
  final int maiorSequencia;
  final Map<String, int> conclusoesPorDia;
  final Map<String, int> conclusoesPorCategoria;

  ProgressStats({
    this.totalConclusoes = 0,
    this.totalPerdidos = 0,
    this.totalParciais = 0,
    this.taxaConclusao = 0.0,
    this.experienciaTotal = 0,
    this.sequenciaAtual = 0,
    this.maiorSequencia = 0,
    this.conclusoesPorDia = const {},
    this.conclusoesPorCategoria = const {},
  });

  factory ProgressStats.fromJson(Map<String, dynamic> json) {
    return ProgressStats(
      totalConclusoes: json['totalConclusoes'] ?? 0,
      totalPerdidos: json['totalPerdidos'] ?? 0,
      totalParciais: json['totalParciais'] ?? 0,
      taxaConclusao: (json['taxaConclusao'] ?? 0.0).toDouble(),
      experienciaTotal: json['experienciaTotal'] ?? 0,
      sequenciaAtual: json['sequenciaAtual'] ?? 0,
      maiorSequencia: json['maiorSequencia'] ?? 0,
      conclusoesPorDia: Map<String, int>.from(json['conclusoesPorDia'] ?? {}),
      conclusoesPorCategoria: Map<String, int>.from(json['conclusoesPorCategoria'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalConclusoes': totalConclusoes,
      'totalPerdidos': totalPerdidos,
      'totalParciais': totalParciais,
      'taxaConclusao': taxaConclusao,
      'experienciaTotal': experienciaTotal,
      'sequenciaAtual': sequenciaAtual,
      'maiorSequencia': maiorSequencia,
      'conclusoesPorDia': conclusoesPorDia,
      'conclusoesPorCategoria': conclusoesPorCategoria,
    };
  }

  // Métodos de cálculo
  int get totalAtividades => totalConclusoes + totalPerdidos + totalParciais;
  
  double get taxaSucesso {
    if (totalAtividades == 0) return 0.0;
    return (totalConclusoes / totalAtividades) * 100;
  }
  
  String get taxaConclusaoFormatada {
    return '${taxaConclusao.toStringAsFixed(1)}%';
  }
  
  String get sequenciaTexto {
    if (sequenciaAtual == 0) return 'Sem sequência';
    if (sequenciaAtual == 1) return '1 dia';
    return '$sequenciaAtual dias';
  }
  
  bool get temSequenciaAtiva => sequenciaAtual > 0;
  
  Color get corTaxaConclusao {
    if (taxaConclusao >= 80) return Color(0xFF4CAF50);
    if (taxaConclusao >= 60) return Color(0xFFFF9800);
    if (taxaConclusao >= 40) return Color(0xFFFF5722);
    return Color(0xFFF44336);
  }
}
