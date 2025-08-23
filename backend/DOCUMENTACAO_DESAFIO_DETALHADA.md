# Documentação Técnica Detalhada - Modelo Desafio (Challenge.js)

## 🎲 Modelo Desafio (Challenge.js) - Análise Técnica Completa

### **Bibliotecas e Dependências**
```javascript
const mongoose = require('mongoose');  // ODM para MongoDB
```

**Explicação da Biblioteca:**
- **mongoose**: Object Document Mapper para MongoDB
  - Gerencia relacionamentos entre usuários e desafios
  - Implementa validações e middleware
  - Fornece sistema de índices otimizados para competições amigáveis

### **Estrutura do Schema com Validações Avançadas**
```javascript
const esquemaDesafio = new mongoose.Schema({
  titulo: {
    type: String,
    required: [true, 'Título do desafio é obrigatório'],
    trim: true,                        // Remove espaços em branco
    maxlength: [100, 'Título deve ter no máximo 100 caracteres']
  },
  descricao: {
    type: String,
    required: [true, 'Descrição do desafio é obrigatória'],
    trim: true,
    maxlength: [500, 'Descrição deve ter no máximo 500 caracteres']
  },
  criador: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Usuario',                    // Referência para população
    required: [true, 'Criador do desafio é obrigatório']
  },
  destinatario: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Usuario',                    // Referência para população
    required: [true, 'Destinatário do desafio é obrigatório']
  },
  tipo: {
    type: String,
    enum: ['sequencia', 'pontuacao', 'tempo', 'personalizado'],
    default: 'sequencia'
  },
  objetivo: {
    tipo: { type: String },           // Tipo de objetivo
    valor: { type: Number },          // Valor alvo
    unidade: { type: String }         // Unidade de medida
  },
  dataInicio: {
    type: Date,
    required: [true, 'Data de início é obrigatória'],
    default: Date.now
  },
  dataFim: {
    type: Date,
    required: [true, 'Data de fim é obrigatória']
  },
  status: {
    type: String,
    enum: ['pendente', 'aceito', 'recusado', 'em_andamento', 'concluido', 'expirado'],
    default: 'pendente'
  },
  recompensas: {
    experiencia: { type: Number, default: 50 },
    titulo: { type: String, default: null },
    badge: { type: String, default: null }
  },
  progresso: {
    criador: {
      atual: { type: Number, default: 0 },
      meta: { type: Number, default: 0 }
    },
    destinatario: {
      atual: { type: Number, default: 0 },
      meta: { type: Number, default: 0 }
    }
  },
  mensagens: [{
    usuario: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'Usuario'
    },
    texto: String,
    data: { type: Date, default: Date.now }
  }],
  vencedor: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Usuario',
    default: null
  },
  resultado: {
    vencedor: { type: String, enum: ['criador', 'destinatario', 'empate'], default: null },
    pontuacaoCriador: { type: Number, default: 0 },
    pontuacaoDestinatario: { type: Number, default: 0 },
    dataConclusao: { type: Date, default: null }
  },
  configuracoes: {
    permiteEntradaTardia: { type: Boolean, default: false },
    modoPrivado: { type: Boolean, default: false },
    notificacoes: { type: Boolean, default: true }
  }
}, {
  timestamps: true  // Adiciona createdAt e updatedAt automaticamente
});
```

**Detalhes das Validações:**
- **titulo**: Campo obrigatório com limite de 100 caracteres
- **descricao**: Campo obrigatório com limite de 500 caracteres
- **criador**: Referência obrigatória para o usuário criador
- **destinatario**: Referência obrigatória para o usuário desafiado
- **tipo**: Enum com tipos de desafio disponíveis
- **objetivo**: Estrutura para definir meta do desafio
- **dataInicio/dataFim**: Datas para período do desafio
- **status**: Enum com estados do desafio
- **recompensas**: XP, títulos e badges oferecidos
- **progresso**: Acompanhamento de ambos os participantes
- **mensagens**: Sistema de comunicação entre participantes
- **vencedor**: Usuário vencedor (se houver)
- **resultado**: Detalhes finais da competição
- **configuracoes**: Opções específicas do desafio

### **Sistema de Tipos de Desafio**
```javascript
tipo: {
  type: String,
  enum: ['sequencia', 'pontuacao', 'tempo', 'personalizado'],
  default: 'sequencia'
}
```

**Explicação dos Tipos:**
- **sequencia**: Baseado em sequências consecutivas de hábitos
- **pontuacao**: Baseado em pontuação total acumulada
- **tempo**: Baseado em tempo de atividade
- **personalizado**: Critérios customizados pelo criador

### **Sistema de Status com Transições**
```javascript
status: {
  type: String,
  enum: ['pendente', 'aceito', 'recusado', 'em_andamento', 'concluido', 'expirado'],
  default: 'pendente'
}
```

**Fluxo de Status Detalhado:**
1. **pendente** → **aceito** (quando destinatário aceita)
2. **pendente** → **recusado** (quando destinatário recusa)
3. **aceito** → **em_andamento** (quando desafio inicia)
4. **em_andamento** → **concluido** (quando desafio termina)
5. **pendente** → **expirado** (quando prazo vence)

**Regras de Transição:**
- **pendente** → **aceito**: Apenas destinatário pode aceitar
- **pendente** → **recusado**: Apenas destinatário pode recusar
- **aceito** → **em_andamento**: Automático na data de início
- **em_andamento** → **concluido**: Automático na data de fim ou quando objetivo é atingido
- **pendente** → **expirado**: Automático quando dataFim é ultrapassada

### **Sistema de Objetivos**
```javascript
objetivo: {
  tipo: { type: String },           // Tipo de objetivo
  valor: { type: Number },          // Valor alvo
  unidade: { type: String }         // Unidade de medida
}
```

**Tipos de Objetivo Suportados:**
- **sequencia**: Maior sequência consecutiva
- **pontuacao**: Total de pontos acumulados
- **tempo**: Tempo total de atividade
- **habitos**: Número de hábitos concluídos

**Unidades de Medida:**
- **sequencia**: dias
- **pontuacao**: pontos
- **tempo**: horas
- **habitos**: quantidade

### **Sistema de Progresso**
```javascript
progresso: {
  criador: {
    atual: { type: Number, default: 0 },
    meta: { type: Number, default: 0 }
  },
  destinatario: {
    atual: { type: Number, default: 0 },
    meta: { type: Number, default: 0 }
  }
}
```

**Estrutura de Progresso:**
- **criador.atual**: Progresso atual do criador
- **criador.meta**: Meta definida para o criador
- **destinatario.atual**: Progresso atual do destinatário
- **destinatario.meta**: Meta definida para o destinatário

### **Sistema de Índices para Performance**
```javascript
// Índices para consultas eficientes
esquemaDesafio.index({ criador: 1, status: 1 });
esquemaDesafio.index({ destinatario: 1, status: 1 });
esquemaDesafio.index({ status: 1, dataFim: 1 });
esquemaDesafio.index({ tipo: 1, status: 1 });
esquemaDesafio.index({ 'resultado.vencedor': 1 });
```

**Explicação dos Índices:**
- **`{ criador: 1, status: 1 }`**: Desafios criados por usuário
- **`{ destinatario: 1, status: 1 }`**: Desafios recebidos por usuário
- **`{ status: 1, dataFim: 1 }`**: Desafios por status e prazo
- **`{ tipo: 1, status: 1 }`**: Filtros por tipo e status
- **`{ 'resultado.vencedor': 1 }`**: Desafios por vencedor

### **Validações Customizadas**

#### **Validação de Datas**
```javascript
// Validação de datas de início e fim
esquemaDesafio.pre('save', function (next) {
  if (this.dataInicio >= this.dataFim) {
    return next(new Error('Data de início deve ser anterior à data de fim'));
  }
  
  // Para desafios novos, data de início deve ser futura
  if (this.isNew && this.dataInicio <= new Date()) {
    return next(new Error('Data de início deve ser futura para novos desafios'));
  }
  
  next();
});
```

#### **Validação de Usuários**
```javascript
// Validação de usuários diferentes
esquemaDesafio.pre('save', function (next) {
  if (this.criador.toString() === this.destinatario.toString()) {
    return next(new Error('Criador e destinatário devem ser usuários diferentes'));
  }
  
  next();
});
```

#### **Validação de Status**
```javascript
// Validação de transições de status
esquemaDesafio.pre('save', function (next) {
  if (this.isModified('status')) {
    const transicoesValidas = {
      pendente: ['aceito', 'recusado', 'expirado'],
      aceito: ['em_andamento'],
      em_andamento: ['concluido'],
      recusado: [],
      concluido: [],
      expirado: []
    };
    
    const statusAnterior = this.constructor.findById(this._id).status || 'pendente';
    const transicoes = transicoesValidas[statusAnterior] || [];
    
    if (!transicoes.includes(this.status)) {
      return next(new Error(`Transição de status inválida: ${statusAnterior} → ${this.status}`));
    }
  }
  
  next();
});
```

### **Métodos de Instância**

#### **Método - Aceitar Desafio**
```javascript
esquemaDesafio.methods.aceitarDesafio = function (usuarioId) {
  if (this.status !== 'pendente') {
    throw new Error('Desafio não está pendente');
  }
  
  if (this.destinatario.toString() !== usuarioId.toString()) {
    throw new Error('Apenas o destinatário pode aceitar o desafio');
  }
  
  this.status = 'aceito';
  return this.save();
};
```

#### **Método - Recusar Desafio**
```javascript
esquemaDesafio.methods.recusarDesafio = function (usuarioId) {
  if (this.status !== 'pendente') {
    throw new Error('Desafio não está pendente');
  }
  
  if (this.destinatario.toString() !== usuarioId.toString()) {
    throw new Error('Apenas o destinatário pode recusar o desafio');
  }
  
  this.status = 'recusado';
  return this.save();
};
```

#### **Método - Verificação de Expiração**
```javascript
esquemaDesafio.methods.verificarExpiracao = function () {
  if (this.status === 'pendente' && new Date() > this.dataFim) {
    this.status = 'expirado';
    return true;
  }
  return false;
};
```

**Lógica de Expiração:**
- Só verifica desafios **pendentes**
- Compara data atual com **dataFim**
- Atualiza status automaticamente
- Retorna true se expirou

#### **Método - Atualizar Progresso**
```javascript
esquemaDesafio.methods.atualizarProgresso = function (usuarioId, novoProgresso) {
  if (this.status !== 'em_andamento') {
    throw new Error('Desafio não está em andamento');
  }
  
  if (this.criador.toString() === usuarioId.toString()) {
    this.progresso.criador.atual = novoProgresso;
  } else if (this.destinatario.toString() === usuarioId.toString()) {
    this.progresso.destinatario.atual = novoProgresso;
  } else {
    throw new Error('Usuário não é participante deste desafio');
  }
  
  // Verifica se o desafio foi concluído
  this.verificarConclusao();
  
  return this.save();
};
```

#### **Método - Verificar Conclusão**
```javascript
esquemaDesafio.methods.verificarConclusao = function () {
  if (this.status !== 'em_andamento') return false;
  
  const criadorConcluiu = this.progresso.criador.atual >= this.progresso.criador.meta;
  const destinatarioConcluiu = this.progresso.destinatario.atual >= this.progresso.destinatario.meta;
  
  if (criadorConcluiu || destinatarioConcluiu) {
    this.status = 'concluido';
    this.resultado.dataConclusao = new Date();
    
    // Determina vencedor
    if (criadorConcluiu && !destinatarioConcluiu) {
      this.resultado.vencedor = 'criador';
      this.vencedor = this.criador;
    } else if (destinatarioConcluiu && !criadorConcluiu) {
      this.resultado.vencedor = 'destinatario';
      this.vencedor = this.destinatario;
    } else {
      this.resultado.vencedor = 'empate';
    }
    
    // Calcula pontuações finais
    this.resultado.pontuacaoCriador = this.progresso.criador.atual;
    this.resultado.pontuacaoDestinatario = this.progresso.destinatario.atual;
    
    return true;
  }
  
  return false;
};
```

#### **Método - Adicionar Mensagem**
```javascript
esquemaDesafio.methods.adicionarMensagem = function (usuarioId, texto) {
  if (![this.criador.toString(), this.destinatario.toString()].includes(usuarioId.toString())) {
    throw new Error('Apenas participantes podem enviar mensagens');
  }
  
  this.mensagens.push({
    usuario: usuarioId,
    texto: texto,
    data: new Date()
  });
  
  return this.save();
};
```

### **Métodos Estáticos**

#### **Buscar Desafios por Usuário**
```javascript
esquemaDesafio.statics.buscarPorUsuario = function (usuarioId, filtros = {}) {
  const query = {
    $or: [
      { criador: usuarioId },
      { destinatario: usuarioId }
    ]
  };
  
  // Aplica filtros opcionais
  if (filtros.status) query.status = filtros.status;
  if (filtros.tipo) query.tipo = filtros.tipo;
  
  return this.find(query)
    .sort({ createdAt: -1 })
    .populate('criador', 'nomeUsuario avatar nivel')
    .populate('destinatario', 'nomeUsuario avatar nivel');
};
```

#### **Buscar Desafios Pendentes**
```javascript
esquemaDesafio.statics.buscarPendentes = function (usuarioId) {
  return this.find({
    destinatario: usuarioId,
    status: 'pendente'
  })
    .sort({ dataFim: 1 })
    .populate('criador', 'nomeUsuario avatar nivel');
};
```

#### **Verificar Desafios Expirados**
```javascript
esquemaDesafio.statics.verificarExpirados = async function () {
  const agora = new Date();
  
  const desafiosExpirados = await this.find({
    status: 'pendente',
    dataFim: { $lt: agora }
  });
  
  for (const desafio of desafiosExpirados) {
    desafio.status = 'expirado';
    await desafio.save();
  }
  
  return desafiosExpirados.length;
};
```

#### **Calcular Estatísticas de Desafios**
```javascript
esquemaDesafio.statics.calcularEstatisticas = async function (usuarioId) {
  const desafios = await this.find({
    $or: [
      { criador: usuarioId },
      { destinatario: usuarioId }
    ]
  });
  
  const estatisticas = {
    total: desafios.length,
    criados: desafios.filter(d => d.criador.toString() === usuarioId.toString()).length,
    recebidos: desafios.filter(d => d.destinatario.toString() === usuarioId.toString()).length,
    porStatus: {},
    vitorias: 0,
    derrotas: 0,
    empates: 0
  };
  
  // Agrupa por status
  desafios.forEach(desafio => {
    if (!estatisticas.porStatus[desafio.status]) {
      estatisticas.porStatus[desafio.status] = 0;
    }
    estatisticas.porStatus[desafio.status]++;
    
    // Conta resultados
    if (desafio.status === 'concluido' && desafio.resultado.vencedor) {
      if (desafio.vencedor && desafio.vencedor.toString() === usuarioId.toString()) {
        estatisticas.vitorias++;
      } else if (desafio.resultado.vencedor === 'empate') {
        estatisticas.empates++;
      } else {
        estatisticas.derrotas++;
      }
    }
  });
  
  return estatisticas;
};
```

### **Sistema de Agregações para Relatórios**

#### **Relatório de Performance por Tipo**
```javascript
esquemaDesafio.statics.relatorioPorTipo = async function (usuarioId) {
  return this.aggregate([
    // Filtra desafios do usuário
    { $match: {
      $or: [
        { criador: mongoose.Types.ObjectId(usuarioId) },
        { destinatario: mongoose.Types.ObjectId(usuarioId) }
      ]
    }},
    
    // Agrupa por tipo
    { $group: {
      _id: '$tipo',
      total: { $sum: 1 },
      vitorias: { $sum: { 
        $cond: [
          { 
            $and: [
              { $eq: ['$status', 'concluido'] },
              { $eq: ['$vencedor', mongoose.Types.ObjectId(usuarioId)] }
            ]
          }, 
          1, 
          0 
        ]
      }},
      concluidos: { $sum: { $cond: [{ $eq: ['$status', 'concluido'] }, 1, 0] } }
    }},
    
    // Calcula taxa de vitória
    { $addFields: {
      taxaVitoria: {
        $multiply: [
          { $divide: ['$vitorias', '$concluidos'] },
          100
        ]
      }
    }},
    
    // Ordena por total
    { $sort: { total: -1 } }
  ]);
};
```

#### **Relatório de Desafios por Período**
```javascript
esquemaDesafio.statics.relatorioPorPeriodo = async function (usuarioId, dataInicio, dataFim) {
  return this.aggregate([
    // Filtra desafios do usuário no período
    { $match: {
      $or: [
        { criador: mongoose.Types.ObjectId(usuarioId) },
        { destinatario: mongoose.Types.ObjectId(usuarioId) }
      ],
      createdAt: { $gte: dataInicio, $lte: dataFim }
    }},
    
    // Agrupa por mês
    { $group: {
      _id: {
        ano: { $year: '$createdAt' },
        mes: { $month: '$createdAt' }
      },
      total: { $sum: 1 },
      concluidos: { $sum: { $cond: [{ $eq: ['$status', 'concluido'] }, 1, 0] } },
      vitorias: { $sum: { 
        $cond: [
          { 
            $and: [
              { $eq: ['$status', 'concluido'] },
              { $eq: ['$vencedor', mongoose.Types.ObjectId(usuarioId)] }
            ]
          }, 
          1, 
          0 
        ]
      }}
    }},
    
    // Ordena por data
    { $sort: { '_id.ano': 1, '_id.mes': 1 } }
  ]);
};
```

### **Exemplos de Uso Avançado**

#### **Criar Desafio de Sequência**
```javascript
async function criarDesafioSequencia(criadorId, destinatarioId, dias, titulo, descricao) {
  try {
    const dataInicio = new Date();
    const dataFim = new Date();
    dataFim.setDate(dataFim.getDate() + dias);
    
    const novoDesafio = new Desafio({
      titulo: titulo,
      descricao: descricao,
      criador: criadorId,
      destinatario: destinatarioId,
      tipo: 'sequencia',
      objetivo: {
        tipo: 'sequencia',
        valor: dias,
        unidade: 'dias'
      },
      dataInicio: dataInicio,
      dataFim: dataFim,
      progresso: {
        criador: { atual: 0, meta: dias },
        destinatario: { atual: 0, meta: dias }
      },
      recompensas: {
        experiencia: 100,
        titulo: `Mestre da Sequência de ${dias} dias`,
        badge: 'sequencia_mestre'
      }
    });
    
    await novoDesafio.save();
    
    console.log(`🎯 Desafio "${titulo}" criado com sucesso!`);
    console.log(`Objetivo: ${dias} dias consecutivos`);
    console.log(`Prazo: ${dias} dias`);
    
    return novoDesafio;
    
  } catch (erro) {
    console.error('Erro ao criar desafio:', erro.message);
    throw erro;
  }
}
```

#### **Sistema de Desafios Automáticos**
```javascript
async function verificarDesafiosAutomaticos() {
  try {
    const agora = new Date();
    
    // Verifica desafios expirados
    const expirados = await Desafio.verificarExpirados();
    if (expirados > 0) {
      console.log(`⏰ ${expirados} desafio(s) expirado(s)`);
    }
    
    // Verifica desafios que devem iniciar
    const paraIniciar = await Desafio.find({
      status: 'aceito',
      dataInicio: { $lte: agora }
    });
    
    for (const desafio of paraIniciar) {
      desafio.status = 'em_andamento';
      await desafio.save();
      
      console.log(`🚀 Desafio "${desafio.titulo}" iniciado!`);
      
      // Notifica participantes
      await notificarParticipantesDesafio(desafio, 'inicio');
    }
    
    // Verifica desafios que devem finalizar
    const paraFinalizar = await Desafio.find({
      status: 'em_andamento',
      dataFim: { $lte: agora }
    });
    
    for (const desafio of paraFinalizar) {
      // Força verificação de conclusão
      desafio.verificarConclusao();
      await desafio.save();
      
      console.log(`🏁 Desafio "${desafio.titulo}" finalizado!`);
      
      // Notifica participantes
      await notificarParticipantesDesafio(desafio, 'fim');
    }
    
  } catch (erro) {
    console.error('Erro ao verificar desafios automáticos:', erro.message);
  }
}
```

#### **Gerar Relatório Completo de Desafios**
```javascript
async function gerarRelatorioDesafios(usuarioId) {
  try {
    // Estatísticas gerais
    const estatisticas = await Desafio.calcularEstatisticas(usuarioId);
    
    // Relatório por tipo
    const porTipo = await Desafio.relatorioPorTipo(usuarioId);
    
    // Desafios pendentes
    const pendentes = await Desafio.buscarPendentes(usuarioId);
    
    // Relatório consolidado
    const relatorio = {
      estatisticas: estatisticas,
      porTipo: porTipo,
      pendentes: pendentes.length,
      resumo: {
        totalDesafios: estatisticas.total,
        taxaVitoria: estatisticas.concluidos > 0 
          ? (estatisticas.vitorias / estatisticas.concluidos * 100).toFixed(1) + '%'
          : '0%',
        desafiosAtivos: estatisticas.porStatus['em_andamento'] || 0
      }
    };
    
    console.log('=== RELATÓRIO DE DESAFIOS ===');
    console.log(`Total de desafios: ${relatorio.resumo.totalDesafios}`);
    console.log(`Taxa de vitória: ${relatorio.resumo.taxaVitoria}`);
    console.log(`Desafios ativos: ${relatorio.resumo.desafiosAtivos}`);
    console.log(`Desafios pendentes: ${relatorio.pendentes}`);
    
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
const desafios = await Desafio.find({ status: 'em_andamento' })
  .select('titulo tipo dataFim progresso')
  .sort({ dataFim: 1 })
  .lean();

// Consulta com agregação para estatísticas complexas
const estatisticas = await Desafio.aggregate([
  { $match: { status: 'concluido' } },
  { $group: {
    _id: '$tipo',
    total: { $sum: 1 },
    mediaProgresso: { $avg: '$progresso.criador.atual' }
  }}
]);
```

#### **Cache de Desafios Ativos**
```javascript
// Cache de desafios ativos para evitar consultas repetidas
let cacheDesafiosAtivos = null;
let cacheTimestamp = null;
const CACHE_DURATION = 3 * 60 * 1000; // 3 minutos

esquemaDesafio.statics.getDesafiosAtivos = async function () {
  const agora = Date.now();
  
  if (cacheDesafiosAtivos && cacheTimestamp && (agora - cacheTimestamp) < CACHE_DURATION) {
    return cacheDesafiosAtivos;
  }
  
  const desafios = await this.find({ status: 'em_andamento' });
  
  cacheDesafiosAtivos = desafios;
  cacheTimestamp = agora;
  
  return desafios;
};
```

---

*Documentação técnica detalhada do modelo Desafio - Sistema Librarium*
