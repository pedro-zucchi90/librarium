# Documentação Técnica Detalhada - Modelo Batalha (Battle.js)

## ⚔️ Modelo Batalha (Battle.js) - Análise Técnica Completa

### **Bibliotecas e Dependências**
```javascript
const mongoose = require('mongoose');  // ODM para MongoDB
```

**Explicação da Biblioteca:**
- **mongoose**: Object Document Mapper para MongoDB
  - Gerencia relacionamentos entre usuários e batalhas
  - Implementa validações e middleware
  - Fornece sistema de índices otimizados para competições

### **Estrutura do Schema com Validações Avançadas**
```javascript
const esquemaBatalha = new mongoose.Schema({
  titulo: {
    type: String,
    required: [true, 'Título da batalha é obrigatório'],
    trim: true,                        // Remove espaços em branco
    maxlength: [100, 'Título deve ter no máximo 100 caracteres']
  },
  descricao: {
    type: String,
    required: [true, 'Descrição da batalha é obrigatória'],
    trim: true,
    maxlength: [500, 'Descrição deve ter no máximo 500 caracteres']
  },
  criador: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Usuario',                    // Referência para população
    required: [true, 'Criador da batalha é obrigatório']
  },
  participantes: [{
    usuario: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'Usuario'
    },
    pontos: { type: Number, default: 0 },
    posicao: { type: Number, default: 0 },
    dataEntrada: { type: Date, default: Date.now },
    status: {
      type: String,
      enum: ['ativo', 'inativo', 'eliminado'],
      default: 'ativo'
    }
  }],
  dataInicio: {
    type: Date,
    required: [true, 'Data de início é obrigatória']
  },
  dataFim: {
    type: Date,
    required: [true, 'Data de fim é obrigatória']
  },
  status: {
    type: String,
    enum: ['preparacao', 'em_andamento', 'finalizada', 'cancelada'],
    default: 'preparacao'
  },
  tipo: {
    type: String,
    enum: ['eliminacao', 'pontuacao', 'sequencia', 'personalizada'],
    default: 'pontuacao'
  },
  criterios: [{
    nome: String,                    // Nome do critério
    descricao: String,              // Descrição detalhada
    peso: { type: Number, default: 1 }, // Peso na pontuação final
    tipo: { 
      type: String, 
      enum: ['sequencia', 'contagem', 'soma', 'media'] 
    }
  }],
  recompensas: {
    primeiro: { type: Number, default: 100 },    // XP para 1º lugar
    segundo: { type: Number, default: 75 },      // XP para 2º lugar
    terceiro: { type: Number, default: 50 },     // XP para 3º lugar
    participacao: { type: Number, default: 10 }  // XP para participação
  },
  maxParticipantes: {
    type: Number,
    default: 10,
    min: 2,
    max: 100
  },
  visibilidade: {
    type: String,
    enum: ['publica', 'privada', 'por_convite'],
    default: 'publica'
  },
  tags: [String],                    // Tags para categorização
  configuracao: {
    permiteEntradaTardia: { type: Boolean, default: false },
    reiniciaPontuacao: { type: Boolean, default: false },
    modoEliminacao: { type: Boolean, default: false }
  }
}, {
  timestamps: true  // Adiciona createdAt e updatedAt automaticamente
});
```

**Detalhes das Validações:**
- **titulo**: Campo obrigatório com limite de 100 caracteres
- **descricao**: Campo obrigatório com limite de 500 caracteres
- **criador**: Referência obrigatória para o usuário criador
- **participantes**: Array de participantes com pontuação e status
- **dataInicio/dataFim**: Datas obrigatórias para período da batalha
- **status**: Enum com estados da batalha
- **tipo**: Tipo de sistema de pontuação
- **criterios**: Array de critérios personalizados para pontuação
- **recompensas**: XP distribuído por posição
- **maxParticipantes**: Limite de participantes (2-100)
- **visibilidade**: Controle de acesso à batalha
- **tags**: Categorização e busca
- **configuracao**: Opções específicas da batalha

### **Sistema de Tipos de Batalha**
```javascript
tipo: {
  type: String,
  enum: ['eliminacao', 'pontuacao', 'sequencia', 'personalizada'],
  default: 'pontuacao'
}
```

**Explicação dos Tipos:**
- **eliminacao**: Sistema de eliminação progressiva
- **pontuacao**: Sistema de pontuação acumulativa
- **sequencia**: Baseado em sequências consecutivas
- **personalizada**: Critérios customizados pelo criador

### **Sistema de Status de Batalha**
```javascript
status: {
  type: String,
  enum: ['preparacao', 'em_andamento', 'finalizada', 'cancelada'],
  default: 'preparacao'
}
```

**Fluxo de Status:**
1. **preparacao**: Batalha criada, aceitando participantes
2. **em_andamento**: Batalha ativa, computando pontuações
3. **finalizada**: Batalha encerrada, resultados finais
4. **cancelada**: Batalha cancelada pelo criador

### **Sistema de Critérios Personalizados**
```javascript
criterios: [{
  nome: String,                    // Nome do critério
  descricao: String,              // Descrição detalhada
  peso: { type: Number, default: 1 }, // Peso na pontuação final
  tipo: { 
    type: String, 
    enum: ['sequencia', 'contagem', 'soma', 'media'] 
  }
}]
```

**Tipos de Critério:**
- **sequencia**: Maior sequência consecutiva
- **contagem**: Total de itens/eventos
- **soma**: Soma de valores
- **media**: Média de valores

### **Sistema de Índices para Performance**
```javascript
// Índices para consultas eficientes
esquemaBatalha.index({ status: 1, dataInicio: -1 });
esquemaBatalha.index({ criador: 1, status: 1 });
esquemaBatalha.index({ 'participantes.usuario': 1 });
esquemaBatalha.index({ tipo: 1, visibilidade: 1 });
esquemaBatalha.index({ tags: 1 });
```

**Explicação dos Índices:**
- **`{ status: 1, dataInicio: -1 }`**: Batalhas por status e data
- **`{ criador: 1, status: 1 }`**: Batalhas criadas por usuário
- **`{ 'participantes.usuario': 1 }`**: Batalhas por participante
- **`{ tipo: 1, visibilidade: 1 }`**: Filtros por tipo e visibilidade
- **`{ tags: 1 }`**: Busca por tags

### **Validações Customizadas**

#### **Validação de Datas**
```javascript
// Validação de datas de início e fim
esquemaBatalha.pre('save', function (next) {
  if (this.dataInicio >= this.dataFim) {
    return next(new Error('Data de início deve ser anterior à data de fim'));
  }
  
  if (this.dataInicio <= new Date()) {
    return next(new Error('Data de início deve ser futura'));
  }
  
  next();
});
```

#### **Validação de Participantes**
```javascript
// Validação de número máximo de participantes
esquemaBatalha.pre('save', function (next) {
  if (this.participantes.length > this.maxParticipantes) {
    return next(new Error(`Máximo de ${this.maxParticipantes} participantes permitido`));
  }
  
  next();
});
```

### **Métodos de Instância**

#### **Método - Adicionar Participante**
```javascript
esquemaBatalha.methods.adicionarParticipante = function (usuarioId) {
  // Verifica se já é participante
  const jaParticipa = this.participantes.some(p => 
    p.usuario.toString() === usuarioId.toString()
  );
  
  if (jaParticipa) {
    throw new Error('Usuário já é participante desta batalha');
  }
  
  // Verifica se há vagas
  if (this.participantes.length >= this.maxParticipantes) {
    throw new Error('Batalha está lotada');
  }
  
  // Adiciona participante
  this.participantes.push({
    usuario: usuarioId,
    pontos: 0,
    posicao: this.participantes.length + 1,
    dataEntrada: new Date(),
    status: 'ativo'
  });
  
  return this.save();
};
```

#### **Método - Remover Participante**
```javascript
esquemaBatalha.methods.removerParticipante = function (usuarioId) {
  const index = this.participantes.findIndex(p => 
    p.usuario.toString() === usuarioId.toString()
  );
  
  if (index === -1) {
    throw new Error('Usuário não é participante desta batalha');
  }
  
  // Remove participante
  this.participantes.splice(index, 1);
  
  // Recalcula posições
  this.recalcularPosicoes();
  
  return this.save();
};
```

#### **Método - Recalcular Posições**
```javascript
esquemaBatalha.methods.recalcularPosicoes = function () {
  // Ordena participantes por pontuação (decrescente)
  this.participantes.sort((a, b) => b.pontos - a.pontos);
  
  // Atualiza posições
  this.participantes.forEach((participante, index) => {
    participante.posicao = index + 1;
  });
};
```

#### **Método - Calcular Pontuação Personalizada**
```javascript
esquemaBatalha.methods.calcularPontuacaoPersonalizada = async function (jogadorId, progressos) {
  let pontos = 0;

  for (const criterio of this.criterios) {
    let valorCriterio = 0;

    switch (criterio.tipo) {
      case 'sequencia':
        valorCriterio = this.calcularSequenciaConsecutiva(progressos);
        break;
      case 'contagem':
        valorCriterio = progressos.length;
        break;
      case 'soma':
        valorCriterio = progressos.reduce((total, p) => total + p.experienciaGanha, 0);
        break;
      case 'media':
        valorCriterio = progressos.length > 0
          ? progressos.reduce((total, p) => total + p.experienciaGanha, 0) / progressos.length
          : 0;
        break;
    }

    // Aplica peso do critério
    pontos += valorCriterio * criterio.peso;
  }

  return pontos;
};
```

**Algoritmo de Pontuação:**
1. **Itera** por cada critério configurado
2. **Calcula** valor baseado no tipo do critério
3. **Aplica** peso multiplicativo
4. **Soma** todos os critérios ponderados

#### **Método - Calcular Sequência Consecutiva**
```javascript
esquemaBatalha.methods.calcularSequenciaConsecutiva = function (progressos) {
  if (progressos.length === 0) return 0;

  // Converte datas para formato YYYY-MM-DD para comparação
  const datas = progressos.map(p => p.data.toISOString().split('T')[0]).sort();
  
  let sequenciaAtual = 1;
  let maiorSequencia = 1;

  for (let i = 1; i < datas.length; i++) {
    const dataAtual = new Date(datas[i]);
    const dataAnterior = new Date(datas[i - 1]);
    
    // Calcula diferença em dias
    const diffDias = Math.floor((dataAtual - dataAnterior) / (1000 * 60 * 60 * 24));

    if (diffDias === 1) {
      // Dias consecutivos - incrementa sequência
      sequenciaAtual++;
      maiorSequencia = Math.max(maiorSequencia, sequenciaAtual);
    } else {
      // Quebra na sequência - reset
      sequenciaAtual = 1;
    }
  }

  return maiorSequencia;
};
```

**Algoritmo de Sequência Consecutiva:**
1. **Ordena** datas cronologicamente
2. **Itera** pelas datas ordenadas
3. **Calcula** diferença entre datas consecutivas
4. **Incrementa** sequência se diferença = 1 dia
5. **Reseta** sequência se houver quebra
6. **Mantém** registro da maior sequência encontrada

#### **Método - Atualizar Pontuação**
```javascript
esquemaBatalha.methods.atualizarPontuacao = async function (usuarioId, novosProgressos) {
  const participante = this.participantes.find(p => 
    p.usuario.toString() === usuarioId.toString()
  );
  
  if (!participante) {
    throw new Error('Usuário não é participante desta batalha');
  }
  
  // Calcula nova pontuação
  const novaPontuacao = await this.calcularPontuacaoPersonalizada(usuarioId, novosProgressos);
  
  // Atualiza pontuação
  participante.pontos = novaPontuacao;
  
  // Recalcula posições
  this.recalcularPosicoes();
  
  return this.save();
};
```

#### **Método - Finalizar Batalha**
```javascript
esquemaBatalha.methods.finalizarBatalha = async function () {
  if (this.status !== 'em_andamento') {
    throw new Error('Batalha não está em andamento');
  }
  
  // Atualiza status
  this.status = 'finalizada';
  
  // Distribui recompensas
  await this.distribuirRecompensas();
  
  return this.save();
};
```

#### **Método - Distribuir Recompensas**
```javascript
esquemaBatalha.methods.distribuirRecompensas = async function () {
  const Usuario = require('./User');
  
  // Ordena participantes por posição
  const participantesOrdenados = [...this.participantes].sort((a, b) => a.posicao - b.posicao);
  
  for (let i = 0; i < participantesOrdenados.length; i++) {
    const participante = participantesOrdenados[i];
    let xpGanho = this.recompensas.participacao; // XP base por participação
    
    // XP por posição
    if (i === 0) xpGanho += this.recompensas.primeiro;
    else if (i === 1) xpGanho += this.recompensas.segundo;
    else if (i === 2) xpGanho += this.recompensas.terceiro;
    
    // Adiciona XP ao usuário
    const usuario = await Usuario.findById(participante.usuario);
    if (usuario) {
      await usuario.adicionarExperiencia(xpGanho);
    }
  }
};
```

### **Métodos Estáticos**

#### **Buscar Batalhas por Usuário**
```javascript
esquemaBatalha.statics.buscarPorUsuario = function (usuarioId, filtros = {}) {
  const query = {
    $or: [
      { criador: usuarioId },
      { 'participantes.usuario': usuarioId }
    ]
  };
  
  // Aplica filtros opcionais
  if (filtros.status) query.status = filtros.status;
  if (filtros.tipo) query.tipo = filtros.tipo;
  if (filtros.visibilidade) query.visibilidade = filtros.visibilidade;
  
  return this.find(query)
    .sort({ dataInicio: -1 })
    .populate('criador', 'nomeUsuario avatar nivel')
    .populate('participantes.usuario', 'nomeUsuario avatar nivel');
};
```

#### **Buscar Batalhas Disponíveis**
```javascript
esquemaBatalha.statics.buscarDisponiveis = function (usuarioId, filtros = {}) {
  const query = {
    status: 'preparacao',
    visibilidade: { $in: ['publica', 'por_convite'] },
    'participantes.usuario': { $ne: usuarioId }, // Não participa
    criador: { $ne: usuarioId } // Não é criador
  };
  
  // Aplica filtros opcionais
  if (filtros.tipo) query.tipo = filtros.tipo;
  if (filtros.tags && filtros.tags.length > 0) {
    query.tags = { $in: filtros.tags };
  }
  
  return this.find(query)
    .sort({ dataInicio: 1 })
    .populate('criador', 'nomeUsuario avatar nivel')
    .populate('participantes.usuario', 'nomeUsuario avatar nivel');
};
```

#### **Calcular Ranking de Batalha**
```javascript
esquemaBatalha.statics.calcularRanking = async function (batalhaId) {
  const batalha = await this.findById(batalhaId)
    .populate('participantes.usuario', 'nomeUsuario avatar nivel');
  
  if (!batalha) return null;
  
  // Ordena participantes por pontuação
  const ranking = [...batalha.participantes]
    .sort((a, b) => b.pontos - a.pontos)
    .map((participante, index) => ({
      posicao: index + 1,
      usuario: participante.usuario,
      pontos: participante.pontos,
      dataEntrada: participante.dataEntrada,
      status: participante.status
    }));
  
  return {
    batalha: {
      titulo: batalha.titulo,
      status: batalha.status,
      dataInicio: batalha.dataInicio,
      dataFim: batalha.dataFim
    },
    ranking: ranking
  };
};
```

### **Sistema de Agregações para Relatórios**

#### **Relatório de Performance por Tipo de Batalha**
```javascript
esquemaBatalha.statics.relatorioPorTipo = async function (usuarioId) {
  return this.aggregate([
    // Filtra batalhas do usuário
    { $match: {
      $or: [
        { criador: mongoose.Types.ObjectId(usuarioId) },
        { 'participantes.usuario': mongoose.Types.ObjectId(usuarioId) }
      ]
    }},
    
    // Desempacota participantes
    { $unwind: '$participantes' },
    
    // Filtra apenas participações do usuário
    { $match: {
      'participantes.usuario': mongoose.Types.ObjectId(usuarioId)
    }},
    
    // Agrupa por tipo de batalha
    { $group: {
      _id: '$tipo',
      total: { $sum: 1 },
      vitorias: { $sum: { $cond: [{ $eq: ['$participantes.posicao', 1] }, 1, 0] } },
      totalPontos: { $sum: '$participantes.pontos' },
      mediaPontos: { $avg: '$participantes.pontos' }
    }},
    
    // Calcula taxa de vitória
    { $addFields: {
      taxaVitoria: {
        $multiply: [
          { $divide: ['$vitorias', '$total'] },
          100
        ]
      }
    }},
    
    // Ordena por total de participações
    { $sort: { total: -1 } }
  ]);
};
```

#### **Relatório de Batalhas por Período**
```javascript
esquemaBatalha.statics.relatorioPorPeriodo = async function (usuarioId, dataInicio, dataFim) {
  return this.aggregate([
    // Filtra batalhas do usuário no período
    { $match: {
      $or: [
        { criador: mongoose.Types.ObjectId(usuarioId) },
        { 'participantes.usuario': mongoose.Types.ObjectId(usuarioId) }
      ],
      dataInicio: { $gte: dataInicio, $lte: dataFim }
    }},
    
    // Desempacota participantes
    { $unwind: '$participantes' },
    
    // Filtra apenas participações do usuário
    { $match: {
      'participantes.usuario': mongoose.Types.ObjectId(usuarioId)
    }},
    
    // Agrupa por mês
    { $group: {
      _id: {
        ano: { $year: '$dataInicio' },
        mes: { $month: '$dataInicio' }
      },
      total: { $sum: 1 },
      totalPontos: { $sum: '$participantes.pontos' },
      vitorias: { $sum: { $cond: [{ $eq: ['$participantes.posicao', 1] }, 1, 0] } }
    }},
    
    // Ordena por data
    { $sort: { '_id.ano': 1, '_id.mes': 1 } }
  ]);
};
```

### **Exemplos de Uso Avançado**

#### **Criar Batalha Personalizada**
```javascript
async function criarBatalhaPersonalizada(dadosBatalha, criadorId) {
  try {
    const novaBatalha = new Batalha({
      titulo: dadosBatalha.titulo,
      descricao: dadosBatalha.descricao,
      criador: criadorId,
      dataInicio: dadosBatalha.dataInicio,
      dataFim: dadosBatalha.dataFim,
      tipo: 'personalizada',
      criterios: dadosBatalha.criterios,
      recompensas: dadosBatalha.recompensas,
      maxParticipantes: dadosBatalha.maxParticipantes,
      visibilidade: dadosBatalha.visibilidade,
      tags: dadosBatalha.tags
    });
    
    // Adiciona criador como primeiro participante
    await novaBatalha.adicionarParticipante(criadorId);
    
    await novaBatalha.save();
    
    console.log(`⚔️ Batalha "${novaBatalha.titulo}" criada com sucesso!`);
    return novaBatalha;
    
  } catch (erro) {
    console.error('Erro ao criar batalha:', erro.message);
    throw erro;
  }
}
```

#### **Sistema de Batalhas Automáticas**
```javascript
async function verificarBatalhasAutomaticas() {
  try {
    const agora = new Date();
    
    // Busca batalhas que devem iniciar
    const batalhasParaIniciar = await Batalha.find({
      status: 'preparacao',
      dataInicio: { $lte: agora }
    });
    
    for (const batalha of batalhasParaIniciar) {
      batalha.status = 'em_andamento';
      await batalha.save();
      
      console.log(`🚀 Batalha "${batalha.titulo}" iniciada!`);
      
      // Notifica participantes
      await notificarParticipantes(batalha, 'inicio');
    }
    
    // Busca batalhas que devem finalizar
    const batalhasParaFinalizar = await Batalha.find({
      status: 'em_andamento',
      dataFim: { $lte: agora }
    });
    
    for (const batalha of batalhasParaFinalizar) {
      await batalha.finalizarBatalha();
      
      console.log(`🏁 Batalha "${batalha.titulo}" finalizada!`);
      
      // Notifica participantes
      await notificarParticipantes(batalha, 'fim');
    }
    
  } catch (erro) {
    console.error('Erro ao verificar batalhas automáticas:', erro.message);
  }
}
```

#### **Gerar Relatório Completo de Batalhas**
```javascript
async function gerarRelatorioBatalhas(usuarioId) {
  try {
    // Estatísticas por tipo
    const porTipo = await Batalha.relatorioPorTipo(usuarioId);
    
    // Batalhas ativas
    const batalhasAtivas = await Batalha.buscarPorUsuario(usuarioId, { status: 'em_andamento' });
    
    // Batalhas disponíveis
    const batalhasDisponiveis = await Batalha.buscarDisponiveis(usuarioId);
    
    // Relatório consolidado
    const relatorio = {
      porTipo: porTipo,
      batalhasAtivas: batalhasAtivas.length,
      batalhasDisponiveis: batalhasDisponiveis.length,
      resumo: {
        totalParticipacoes: porTipo.reduce((total, tipo) => total + tipo.total, 0),
        totalVitorias: porTipo.reduce((total, tipo) => total + tipo.vitorias, 0),
        totalPontos: porTipo.reduce((total, tipo) => total + tipo.totalPontos, 0)
      }
    };
    
    console.log('=== RELATÓRIO DE BATALHAS ===');
    console.log(`Total de participações: ${relatorio.resumo.totalParticipacoes}`);
    console.log(`Total de vitórias: ${relatorio.resumo.totalVitorias}`);
    console.log(`Total de pontos: ${relatorio.resumo.totalPontos}`);
    console.log(`Batalhas ativas: ${relatorio.batalhasAtivas}`);
    console.log(`Batalhas disponíveis: ${relatorio.batalhasDisponiveis}`);
    
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
const batalhas = await Batalha.find({ status: 'em_andamento' })
  .select('titulo tipo dataInicio dataFim participantes')
  .sort({ dataInicio: 1 })
  .lean();

// Consulta com agregação para estatísticas complexas
const estatisticas = await Batalha.aggregate([
  { $match: { status: 'finalizada' } },
  { $group: {
    _id: '$tipo',
    total: { $sum: 1 },
    mediaParticipantes: { $avg: { $size: '$participantes' } }
  }}
]);
```

#### **Cache de Batalhas Ativas**
```javascript
// Cache de batalhas ativas para evitar consultas repetidas
let cacheBatalhasAtivas = null;
let cacheTimestamp = null;
const CACHE_DURATION = 2 * 60 * 1000; // 2 minutos

esquemaBatalha.statics.getBatalhasAtivas = async function () {
  const agora = Date.now();
  
  if (cacheBatalhasAtivas && cacheTimestamp && (agora - cacheTimestamp) < CACHE_DURATION) {
    return cacheBatalhasAtivas;
  }
  
  const batalhas = await this.find({ status: 'em_andamento' });
  
  cacheBatalhasAtivas = batalhas;
  cacheTimestamp = agora;
  
  return batalhas;
};
```

---

*Documentação técnica detalhada do modelo Batalha - Sistema Librarium*
