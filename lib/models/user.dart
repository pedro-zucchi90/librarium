import 'package:flutter/material.dart';

class User {
  final String id;
  final String nomeUsuario;
  final String email;
  final String? senha;
  final int experiencia;
  final int nivel;
  final String titulo;
  final String avatar;
  final PersonalizacaoAvatar personalizacaoAvatar;
  final Sequencia sequencia;
  final Preferencias preferencias;
  final DateTime createdAt;
  final DateTime? lastLogin;
  final List<String> conquistas;
  final int totalHabitos;
  final int totalConclusoes;
  final double taxaConclusao;

  User({
    required this.id,
    required this.nomeUsuario,
    required this.email,
    this.senha,
    this.experiencia = 0,
    this.nivel = 1,
    this.titulo = 'Aspirante',
    this.avatar = 'default',
    this.personalizacaoAvatar = const PersonalizacaoAvatar(),
    this.sequencia = const Sequencia(),
    this.preferencias = const Preferencias(),
    required this.createdAt,
    this.lastLogin,
    this.conquistas = const [],
    this.totalHabitos = 0,
    this.totalConclusoes = 0,
    this.taxaConclusao = 0.0,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['_id'] ?? json['id'],
      nomeUsuario: json['nomeUsuario'] ?? json['name'] ?? '',
      email: json['email'] ?? '',
      senha: json['senha'],
      experiencia: json['experiencia'] ?? 0,
      nivel: json['nivel'] ?? 1,
      titulo: json['titulo'] ?? 'Aspirante',
      avatar: json['avatar'] ?? 'default',
      personalizacaoAvatar: PersonalizacaoAvatar.fromJson(json['personalizacaoAvatar'] ?? {}),
      sequencia: Sequencia.fromJson(json['sequencia'] ?? {}),
      preferencias: Preferencias.fromJson(json['preferencias'] ?? {}),
      createdAt: DateTime.parse(json['createdAt'] ?? json['created_at'] ?? DateTime.now().toIso8601String()),
      lastLogin: json['lastLogin'] != null 
          ? DateTime.parse(json['lastLogin']) 
          : null,
      conquistas: List<String>.from(json['conquistas'] ?? []),
      totalHabitos: json['totalHabitos'] ?? 0,
      totalConclusoes: json['totalConclusoes'] ?? 0,
      taxaConclusao: (json['taxaConclusao'] ?? 0.0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nomeUsuario': nomeUsuario,
      'email': email,
      'senha': senha,
      'experiencia': experiencia,
      'nivel': nivel,
      'titulo': titulo,
      'avatar': avatar,
      'personalizacaoAvatar': personalizacaoAvatar.toJson(),
      'sequencia': sequencia.toJson(),
      'preferencias': preferencias.toJson(),
      'createdAt': createdAt.toIso8601String(),
      'lastLogin': lastLogin?.toIso8601String(),
      'conquistas': conquistas,
      'totalHabitos': totalHabitos,
      'totalConclusoes': totalConclusoes,
      'taxaConclusao': taxaConclusao,
    };
  }

  // Getters para compatibilidade
  String get name => nomeUsuario;
  
  // Métodos de gamificação
  int get xpParaProximoNivel {
    return nivel * 100;
  }
  
  double get progressoNivel {
    return (experiencia % 100) / 100.0;
  }
  
  bool get podeEvoluir {
    return experiencia >= xpParaProximoNivel;
  }
  
  String get proximoTitulo {
    if (nivel >= 30) return 'Conjurador Supremo';
    if (nivel >= 20) return 'Guardião do Librarium';
    if (nivel >= 10) return 'Caçador';
    return 'Aspirante';
  }
}

class PersonalizacaoAvatar {
  final String arma;
  final String armadura;
  final String acessorio;

  const PersonalizacaoAvatar({
    this.arma = 'espada_basica',
    this.armadura = 'armadura_basica',
    this.acessorio = 'nenhum',
  });

  factory PersonalizacaoAvatar.fromJson(Map<String, dynamic> json) {
    return PersonalizacaoAvatar(
      arma: json['arma'] ?? 'espada_basica',
      armadura: json['armadura'] ?? 'armadura_basica',
      acessorio: json['acessorio'] ?? 'nenhum',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'arma': arma,
      'armadura': armadura,
      'acessorio': acessorio,
    };
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

class Preferencias {
  final bool notificacoes;
  final String tema;
  final String idioma;
  final bool som;
  final bool vibracao;

  const Preferencias({
    this.notificacoes = true,
    this.tema = 'dark',
    this.idioma = 'pt_BR',
    this.som = true,
    this.vibracao = true,
  });

  factory Preferencias.fromJson(Map<String, dynamic> json) {
    return Preferencias(
      notificacoes: json['notificacoes'] ?? true,
      tema: json['tema'] ?? 'dark',
      idioma: json['idioma'] ?? 'pt_BR',
      som: json['som'] ?? true,
      vibracao: json['vibracao'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'notificacoes': notificacoes,
      'tema': tema,
      'idioma': idioma,
      'som': som,
      'vibracao': vibracao,
    };
  }
}
