const mongoose = require('mongoose');
const bcrypt = require('bcrypt');

const esquemaUsuario = new mongoose.Schema({
  nomeUsuario: {
    type: String,
    required: [true, 'Nome de usuário é obrigatório'],
    unique: true,
    trim: true,
    minlength: [3, 'Nome de usuário deve ter pelo menos 3 caracteres'],
    maxlength: [20, 'Nome de usuário deve ter no máximo 20 caracteres']
  },
  email: {
    type: String,
    required: [true, 'Email é obrigatório'],
    unique: true,
    lowercase: true,
    match: [/^\w+([.-]?\w+)*@\w+([.-]?\w+)*(\.\w{2,3})+$/, 'Por favor, insira um email válido']
  },
  senha: {
    type: String,
    required: [true, 'Senha é obrigatória'],
    minlength: [6, 'Senha deve ter pelo menos 6 caracteres']
  },
  experiencia: {
    type: Number,
    default: 0,
    min: 0
  },
  nivel: {
    type: Number,
    default: 1,
    min: 1
  },
  avatar: {
    type: String,
    default: 'aspirante', // Tipo de avatar inicial
    enum: ['aspirante', 'cacador', 'guardiao', 'conjurador']
  },
  personalizacaoAvatar: {
    arma: { type: String, default: 'espada_basica' },
    armadura: { type: String, default: 'manto_basico' },
    acessorio: { type: String, default: 'nenhum' }
  },
  titulo: {
    type: String,
    default: 'Aspirante'
  },
  dataEntrada: {
    type: Date,
    default: Date.now
  },
  ultimaAtividade: {
    type: Date,
    default: Date.now
  },
  sequencia: {
    atual: { type: Number, default: 0 },
    maiorSequencia: { type: Number, default: 0 }
  },
  preferencias: {
    notificacoes: { type: Boolean, default: true },
    tema: { type: String, default: 'escuro', enum: ['escuro', 'hollow', 'carmesim'] },
    idioma: { type: String, default: 'pt-BR' }
  }
}, {
  timestamps: true
});

// Calcular nível baseado na experiência
esquemaUsuario.virtual('nivelCalculado').get(function() {
  return Math.floor(this.experiencia / 100) + 1; // 100 XP por nível
});

// Obter título baseado no nível
esquemaUsuario.virtual('tituloCalculado').get(function() {
  const nivel = this.nivelCalculado;
  if (nivel >= 31) {
    return 'Conjurador Supremo';
  }
  if (nivel >= 21) {
    return 'Guardião do Librarium';
  }
  if (nivel >= 11) {
    return 'Caçador';
  }
  return 'Aspirante';
});

// Criptografar senha antes de salvar
esquemaUsuario.pre('save', async function(next) {
  if (!this.isModified('senha')) {
    return next();
  }
  
  try {
    const sal = await bcrypt.genSalt(12);
    this.senha = await bcrypt.hash(this.senha, sal);
    next();
  } catch (erro) {
    next(erro);
  }
});

// Atualizar nível e título baseado na experiência
esquemaUsuario.pre('save', function(next) {
  this.nivel = this.nivelCalculado;
  this.titulo = this.tituloCalculado;
  
  // Atualizar avatar baseado no nível
  if (this.nivel >= 31) {
    this.avatar = 'conjurador';
  } else if (this.nivel >= 21) {
    this.avatar = 'guardiao';
  } else if (this.nivel >= 11) {
    this.avatar = 'cacador';
  } else {
    this.avatar = 'aspirante';
  }
  
  next();
});

// Método para comparar senha
esquemaUsuario.methods.compararSenha = async function(senhaCandidata) {
  return bcrypt.compare(senhaCandidata, this.senha);
};

// Método para adicionar experiência
esquemaUsuario.methods.adicionarExperiencia = function(quantidade) {
  this.experiencia += quantidade;
  return this.save();
};

// Atualizar última atividade
esquemaUsuario.methods.atualizarUltimaAtividade = function() {
  this.ultimaAtividade = new Date();
  return this.save();
};

module.exports = mongoose.model('Usuario', esquemaUsuario);
