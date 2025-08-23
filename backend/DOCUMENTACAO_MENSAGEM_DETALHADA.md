# Documentação Técnica Detalhada - Modelo Mensagem (Message.js)

## 💬 Modelo Mensagem (Message.js) - Análise Técnica Completa

### **Bibliotecas e Dependências**
```javascript
const mongoose = require('mongoose');  // ODM para MongoDB
```

**Explicação da Biblioteca:**
- **mongoose**: Object Document Mapper para MongoDB
  - Gerencia relacionamentos entre usuários e mensagens
  - Implementa validações e middleware
  - Fornece sistema de índices otimizados para comunicação

### **Estrutura do Schema com Validações Avançadas**
```javascript
const esquemaMensagem = new mongoose.Schema({
  remetente: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Usuario',                    // Referência para população
    required: [true, 'Remetente é obrigatório']
  },
  destinatario: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Usuario',                    // Referência para população
    required: [true, 'Destinatário é obrigatório']
  },
  tipo: {
    type: String,
    enum: ['privada', 'publica', 'sistema', 'notificacao'],
    default: 'privada'
  },
  texto: {
    type: String,
    required: [true, 'Texto da mensagem é obrigatório'],
    trim: true,                        // Remove espaços em branco
    maxlength: [1000, 'Mensagem deve ter no máximo 1000 caracteres']
  },
  assunto: {
    type: String,
    trim: true,
    maxlength: [100, 'Assunto deve ter no máximo 100 caracteres']
  },
  prioridade: {
    type: String,
    enum: ['baixa', 'normal', 'alta', 'urgente'],
    default: 'normal'
  },
  lida: {
    type: Boolean,
    default: false
  },
  dataLeitura: {
    type: Date,
    default: null
  },
  respostaPara: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Mensagem',                   // Referência para mensagem respondida
    default: null
  },
  thread: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Mensagem',                   // Referência para mensagem principal da thread
    default: null
  },
  reacao: {
    tipo: { 
      type: String, 
      enum: ['like', 'love', 'wow', 'sad', 'angry'] 
    },
    usuario: { 
      type: mongoose.Schema.Types.ObjectId, 
      ref: 'Usuario' 
    }
  },
  anexos: [{
    tipo: { 
      type: String, 
      enum: ['imagem', 'link', 'arquivo'] 
    },
    url: String,        // URL do recurso
    nome: String,       // Nome descritivo
    tamanho: Number     // Tamanho em bytes
  }],
  metadados: {
    ipRemetente: String,
    userAgent: String,
    dispositivo: String
  },
  configuracoes: {
    permiteResposta: { type: Boolean, default: true },
    notificacaoPush: { type: Boolean, default: true },
    modoPrivado: { type: Boolean, default: false }
  }
}, {
  timestamps: true  // Adiciona createdAt e updatedAt automaticamente
});
```

**Detalhes das Validações:**
- **remetente**: Referência obrigatória para o usuário que envia
- **destinatario**: Referência obrigatória para o usuário que recebe
- **tipo**: Enum com tipos de mensagem disponíveis
- **texto**: Campo obrigatório com limite de 1000 caracteres
- **assunto**: Campo opcional com limite de 100 caracteres
- **prioridade**: Nível de urgência da mensagem
- **lida**: Status de leitura da mensagem
- **dataLeitura**: Timestamp de quando foi lida
- **respostaPara**: Referência para mensagem respondida
- **thread**: Referência para mensagem principal da conversa
- **reacao**: Sistema de reações com tipo e usuário
- **anexos**: Array de arquivos/links anexados
- **metadados**: Informações técnicas da mensagem
- **configuracoes**: Opções específicas da mensagem

### **Sistema de Tipos de Mensagem**
```javascript
tipo: {
  type: String,
  enum: ['privada', 'publica', 'sistema', 'notificacao'],
  default: 'privada'
}
```

**Explicação dos Tipos:**
- **privada**: Mensagem entre usuários específicos
- **publica**: Mensagem visível para todos
- **sistema**: Mensagens automáticas do sistema
- **notificacao**: Notificações e alertas

### **Sistema de Prioridades**
```javascript
prioridade: {
  type: String,
  enum: ['baixa', 'normal', 'alta', 'urgente'],
  default: 'normal'
}
```

**Hierarquia de Prioridades:**
- **baixa**: Mensagens informativas
- **normal**: Comunicação padrão
- **alta**: Mensagens importantes
- **urgente**: Mensagens críticas

### **Sistema de Reações com Estrutura Aninhada**
```javascript
reacao: {
  tipo: { 
    type: String, 
    enum: ['like', 'love', 'wow', 'sad', 'angry'] 
  },
  usuario: { 
    type: mongoose.Schema.Types.ObjectId, 
    ref: 'Usuario' 
  }
}
```

**Funcionalidades das Reações:**
- **like**: 👍 Aprovação básica
- **love**: ❤️ Aprovação emocional
- **wow**: 😮 Surpresa/impressão
- **sad**: 😢 Tristeza/solidariedade
- **angry**: 😠 Desaprovação/raiva

### **Sistema de Anexos Flexível**
```javascript
anexos: [{
  tipo: { 
    type: String, 
    enum: ['imagem', 'link', 'arquivo'] 
  },
  url: String,        // URL do recurso
  nome: String,       // Nome descritivo
  tamanho: Number     // Tamanho em bytes
}]
```

**Tipos de Anexo:**
- **imagem**: JPG, PNG, GIF, etc.
- **link**: URLs externas
- **arquivo**: PDFs, documentos, etc.

### **Sistema de Índices para Performance**
```javascript
// Índices para consultas eficientes
esquemaMensagem.index({ remetente: 1, destinatario: 1 });
esquemaMensagem.index({ destinatario: 1, lida: 1 });
esquemaMensagem.index({ destinatario: 1, createdAt: -1 });
esquemaMensagem.index({ tipo: 1, createdAt: -1 });
esquemaMensagem.index({ thread: 1, createdAt: 1 });
esquemaMensagem.index({ 'reacao.usuario': 1 });
```

**Explicação dos Índices:**
- **`{ remetente: 1, destinatario: 1 }`**: Mensagens entre usuários específicos
- **`{ destinatario: 1, lida: 1 }`**: Status de leitura por destinatário
- **`{ destinatario: 1, createdAt: -1 }`**: Histórico de mensagens por destinatário
- **`{ tipo: 1, createdAt: -1 }`**: Mensagens por tipo e data
- **`{ thread: 1, createdAt: 1 }`**: Mensagens em thread por ordem cronológica
- **`{ 'reacao.usuario': 1 }`**: Reações por usuário

### **Validações Customizadas**

#### **Validação de Usuários Diferentes**
```javascript
// Validação de remetente e destinatário diferentes
esquemaMensagem.pre('save', function (next) {
  if (this.remetente.toString() === this.destinatario.toString()) {
    return next(new Error('Remetente e destinatário devem ser usuários diferentes'));
  }
  
  next();
});
```

#### **Validação de Tamanho de Anexos**
```javascript
// Validação de tamanho total de anexos
esquemaMensagem.pre('save', function (next) {
  if (this.anexos && this.anexos.length > 0) {
    const tamanhoTotal = this.anexos.reduce((total, anexo) => total + (anexo.tamanho || 0), 0);
    const limiteMaximo = 10 * 1024 * 1024; // 10MB
    
    if (tamanhoTotal > limiteMaximo) {
      return next(new Error('Tamanho total dos anexos excede 10MB'));
    }
  }
  
  next();
});
```

### **Métodos de Instância**

#### **Método - Marcação como Lida**
```javascript
esquemaMensagem.methods.marcarComoLida = function () {
  this.lida = true;
  this.dataLeitura = new Date();
  return this.save();
};
```

**Funcionalidades:**
1. Marca mensagem como lida
2. Registra timestamp de leitura
3. Retorna Promise para operações assíncronas

#### **Método - Verificação de Resposta**
```javascript
esquemaMensagem.methods.podeSerRespondida = function () {
  const agora = new Date();
  const limiteResposta = new Date(this.createdAt.getTime() + (30 * 24 * 60 * 60 * 1000));
  return agora <= limiteResposta;
};
```

**Cálculo de Limite:**
- **30 dias** = 30 × 24 × 60 × 60 × 1000 milissegundos
- **this.createdAt.getTime()** = timestamp de criação
- **Comparação** com data atual

#### **Método - Adicionar Reação**
```javascript
esquemaMensagem.methods.adicionarReacao = function (usuarioId, tipoReacao) {
  if (!['like', 'love', 'wow', 'sad', 'angry'].includes(tipoReacao)) {
    throw new Error('Tipo de reação inválido');
  }
  
  this.reacao = {
    tipo: tipoReacao,
    usuario: usuarioId
  };
  
  return this.save();
};
```

#### **Método - Remover Reação**
```javascript
esquemaMensagem.methods.removerReacao = function (usuarioId) {
  if (this.reacao && this.reacao.usuario.toString() === usuarioId.toString()) {
    this.reacao = undefined;
    return this.save();
  }
  
  return this.save();
};
```

#### **Método - Verificar Se Pode Ser Editada**
```javascript
esquagemMensagem.methods.podeSerEditada = function (usuarioId) {
  // Apenas o remetente pode editar
  if (this.remetente.toString() !== usuarioId.toString()) {
    return false;
  }
  
  // Mensagens do sistema não podem ser editadas
  if (this.tipo === 'sistema') {
    return false;
  }
  
  // Limite de tempo para edição (1 hora)
  const agora = new Date();
  const limiteEdicao = new Date(this.createdAt.getTime() + (60 * 60 * 1000));
  
  return agora <= limiteEdicao;
};
```

### **Métodos Estáticos**

#### **Método Estático - Obter Conversa**
```javascript
esquemaMensagem.statics.obterConversa = async function (usuario1Id, usuario2Id, limite = 50) {
  return this.find({
    $or: [
      { remetente: usuario1Id, destinatario: usuario2Id },
      { remetente: usuario2Id, destinatario: usuario1Id }
    ]
  })
    .sort({ createdAt: -1 })  // Mais recentes primeiro
    .limit(limite)             // Limite de mensagens
    .populate('remetente', 'nomeUsuario avatar')      // Popula dados do remetente
    .populate('destinatario', 'nomeUsuario avatar')   // Popula dados do destinatário
    .populate('respostaPara', 'texto remetente');     // Popula mensagem respondida
};
```

**Funcionalidades Avançadas:**
- **$or**: Busca mensagens em ambas as direções
- **.sort()**: Ordenação por data (decrescente)
- **.limit()**: Paginação para performance
- **.populate()**: Carrega dados relacionados automaticamente

#### **Método Estático - Estatísticas**
```javascript
esquemaMensagem.statics.obterEstatisticas = async function (usuarioId) {
  const totalEnviadas = await this.countDocuments({ remetente: usuarioId });
  const totalRecebidas = await this.countDocuments({ destinatario: usuarioId });
  const naoLidas = await this.countDocuments({ 
    destinatario: usuarioId, 
    lida: false 
  });

  return {
    totalEnviadas,
    totalRecebidas,
    naoLidas,
    total: totalEnviadas + totalRecebidas
  };
};
```

**Otimizações de Performance:**
- **countDocuments()**: Mais eficiente que find().length
- **Consultas paralelas**: Executa contagens simultaneamente
- **Índices otimizados**: Usa índices criados para consultas rápidas

#### **Método Estático - Buscar Mensagens por Tipo**
```javascript
esquemaMensagem.statics.buscarPorTipo = function (usuarioId, tipo, filtros = {}) {
  const query = {
    $or: [
      { remetente: usuarioId },
      { destinatario: usuarioId }
    ],
    tipo: tipo
  };
  
  // Aplica filtros opcionais
  if (filtros.lida !== undefined) query.lida = filtros.lida;
  if (filtros.prioridade) query.prioridade = filtros.prioridade;
  
  return this.find(query)
    .sort({ createdAt: -1 })
    .populate('remetente', 'nomeUsuario avatar')
    .populate('destinatario', 'nomeUsuario avatar');
};
```

#### **Método Estático - Buscar Mensagens Não Lidas**
```javascript
esquemaMensagem.statics.buscarNaoLidas = function (usuarioId, limite = 20) {
  return this.find({
    destinatario: usuarioId,
    lida: false
  })
    .sort({ createdAt: -1 })
    .limit(limite)
    .populate('remetente', 'nomeUsuario avatar')
    .populate('destinatario', 'nomeUsuario avatar');
};
```

#### **Método Estático - Marcar Como Lida em Lote**
```javascript
esquemaMensagem.statics.marcarComoLidaEmLote = async function (usuarioId, mensagemIds) {
  const agora = new Date();
  
  const resultado = await this.updateMany(
    {
      _id: { $in: mensagemIds },
      destinatario: usuarioId,
      lida: false
    },
    {
      $set: {
        lida: true,
        dataLeitura: agora
      }
    }
  );
  
  return resultado.modifiedCount;
};
```

### **Sistema de Agregações para Relatórios**

#### **Relatório de Mensagens por Período**
```javascript
esquemaMensagem.statics.relatorioPorPeriodo = async function (usuarioId, dataInicio, dataFim) {
  return this.aggregate([
    // Filtra mensagens do usuário no período
    { $match: {
      $or: [
        { remetente: mongoose.Types.ObjectId(usuarioId) },
        { destinatario: mongoose.Types.ObjectId(usuarioId) }
      ],
      createdAt: { $gte: dataInicio, $lte: dataFim }
    }},
    
    // Agrupa por dia
    { $group: {
      _id: {
        $dateToString: { format: '%Y-%m-%d', date: '$createdAt' }
      },
      total: { $sum: 1 },
      enviadas: { $sum: { $cond: [{ $eq: ['$remetente', mongoose.Types.ObjectId(usuarioId)] }, 1, 0] } },
      recebidas: { $sum: { $cond: [{ $eq: ['$destinatario', mongoose.Types.ObjectId(usuarioId)] }, 1, 0] } },
      lidas: { $sum: { $cond: [{ $eq: ['$lida', true] }, 1, 0] } }
    }},
    
    // Calcula taxa de leitura
    { $addFields: {
      taxaLeitura: {
        $multiply: [
          { $divide: ['$lidas', '$recebidas'] },
          100
        ]
      }
    }},
    
    // Ordena por data
    { $sort: { _id: 1 } }
  ]);
};
```

#### **Relatório de Atividade de Mensagens**
```javascript
esquemaMensagem.statics.relatorioAtividade = async function (usuarioId, dias = 30) {
  const dataInicio = new Date();
  dataInicio.setDate(dataInicio.getDate() - dias);
  
  return this.aggregate([
    // Filtra mensagens do usuário no período
    { $match: {
      $or: [
        { remetente: mongoose.Types.ObjectId(usuarioId) },
        { destinatario: mongoose.Types.ObjectId(usuarioId) }
      ],
      createdAt: { $gte: dataInicio }
    }},
    
    // Agrupa por tipo
    { $group: {
      _id: '$tipo',
      total: { $sum: 1 },
      enviadas: { $sum: { $cond: [{ $eq: ['$remetente', mongoose.Types.ObjectId(usuarioId)] }, 1, 0] } },
      recebidas: { $sum: { $cond: [{ $eq: ['$destinatario', mongoose.Types.ObjectId(usuarioId)] }, 1, 0] } }
    }},
    
    // Ordena por total
    { $sort: { total: -1 } }
  ]);
};
```

### **Exemplos de Uso Avançado**

#### **Sistema de Mensagens em Lote**
```javascript
async function enviarMensagemEmLote(remetenteId, destinatarios, texto, assunto = null) {
  try {
    const mensagens = destinatarios.map(destinatarioId => ({
      remetente: remetenteId,
      destinatario: destinatarioId,
      tipo: 'privada',
      texto: texto,
      assunto: assunto,
      prioridade: 'normal'
    }));
    
    const resultado = await Mensagem.insertMany(mensagens);
    
    console.log(`📨 ${resultado.length} mensagem(ns) enviada(s) com sucesso!`);
    
    // Notifica destinatários
    for (const destinatarioId of destinatarios) {
      await notificarUsuario(destinatarioId, 'nova_mensagem', {
        remetente: remetenteId,
        assunto: assunto
      });
    }
    
    return resultado;
    
  } catch (erro) {
    console.error('Erro ao enviar mensagens em lote:', erro.message);
    throw erro;
  }
}
```

#### **Sistema de Mensagens Automáticas**
```javascript
async function enviarMensagemSistema(destinatarioId, tipo, texto, dados = {}) {
  try {
    const mensagem = new Mensagem({
      remetente: null, // Sistema
      destinatario: destinatarioId,
      tipo: 'sistema',
      texto: texto,
      prioridade: 'normal',
      configuracoes: {
        permiteResposta: false,
        notificacaoPush: true
      }
    });
    
    // Adiciona dados específicos do tipo
    if (tipo === 'conquista') {
      mensagem.assunto = '🏆 Nova Conquista Desbloqueada!';
      mensagem.prioridade = 'alta';
    } else if (tipo === 'lembrete') {
      mensagem.assunto = '⏰ Lembrete de Hábito';
      mensagem.prioridade = 'normal';
    }
    
    await mensagem.save();
    
    console.log(`🤖 Mensagem do sistema enviada para usuário ${destinatarioId}`);
    
    // Notifica usuário
    await notificarUsuario(destinatarioId, 'mensagem_sistema', {
      tipo: tipo,
      assunto: mensagem.assunto
    });
    
    return mensagem;
    
  } catch (erro) {
    console.error('Erro ao enviar mensagem do sistema:', erro.message);
    throw erro;
  }
}
```

#### **Gerar Relatório Completo de Mensagens**
```javascript
async function gerarRelatorioMensagens(usuarioId, dias = 30) {
  try {
    const dataInicio = new Date();
    dataInicio.setDate(dataInicio.getDate() - dias);
    const dataFim = new Date();
    
    // Estatísticas gerais
    const estatisticas = await Mensagem.obterEstatisticas(usuarioId);
    
    // Relatório por período
    const porPeriodo = await Mensagem.relatorioPorPeriodo(usuarioId, dataInicio, dataFim);
    
    // Relatório de atividade
    const atividade = await Mensagem.relatorioAtividade(usuarioId, dias);
    
    // Mensagens não lidas
    const naoLidas = await Mensagem.buscarNaoLidas(usuarioId, 100);
    
    // Relatório consolidado
    const relatorio = {
      periodo: {
        inicio: dataInicio,
        fim: dataFim,
        dias: dias
      },
      estatisticas: estatisticas,
      porPeriodo: porPeriodo,
      atividade: atividade,
      naoLidas: naoLidas.length,
      resumo: {
        totalMensagens: estatisticas.total,
        taxaLeitura: estatisticas.totalRecebidas > 0 
          ? (estatisticas.totalRecebidas - estatisticas.naoLidas) / estatisticas.totalRecebidas * 100
          : 0,
        mensagensPorDia: (estatisticas.total / dias).toFixed(1)
      }
    };
    
    console.log('=== RELATÓRIO DE MENSAGENS ===');
    console.log(`Período: ${dias} dias`);
    console.log(`Total de mensagens: ${relatorio.resumo.totalMensagens}`);
    console.log(`Taxa de leitura: ${relatorio.resumo.taxaLeitura.toFixed(1)}%`);
    console.log(`Mensagens por dia: ${relatorio.resumo.mensagensPorDia}`);
    console.log(`Não lidas: ${relatorio.naoLidas}`);
    
    return relatorio;
    
  } catch (erro) {
    console.error('Erro ao gerar relatório:', erro.message);
    throw erro;
  }
}
```

### **Considerações de Performance**

#### **Otimização de Consultas**
```javascript
// Consulta otimizada com projeção
const mensagens = await Mensagem.find({ destinatario: usuarioId })
  .select('texto assunto createdAt lida')
  .sort({ createdAt: -1 })
  .limit(50)
  .lean();

// Consulta com agregação para estatísticas complexas
const estatisticas = await Mensagem.aggregate([
  { $match: { destinatario: mongoose.Types.ObjectId(usuarioId) } },
  { $group: {
    _id: '$tipo',
    total: { $sum: 1 },
    lidas: { $sum: { $cond: [{ $eq: ['$lida', true] }, 1, 0] } }
  }}
]);
```

#### **Cache de Mensagens Não Lidas**
```javascript
// Cache de contagem de mensagens não lidas
let cacheNaoLidas = new Map();
const CACHE_DURATION = 1 * 60 * 1000; // 1 minuto

esquemaMensagem.statics.getContagemNaoLidas = async function (usuarioId) {
  const agora = Date.now();
  const cache = cacheNaoLidas.get(usuarioId);
  
  if (cache && (agora - cache.timestamp) < CACHE_DURATION) {
    return cache.contagem;
  }
  
  const contagem = await this.countDocuments({
    destinatario: usuarioId,
    lida: false
  });
  
  cacheNaoLidas.set(usuarioId, {
    contagem: contagem,
    timestamp: agora
  });
  
  return contagem;
};
```

---

*Documentação técnica detalhada do modelo Mensagem - Sistema Librarium*
