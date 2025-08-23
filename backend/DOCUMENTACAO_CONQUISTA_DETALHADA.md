# Documentação Técnica Detalhada - Modelo Conquista (Achievement.js)

## 🏆 Modelo Conquista (Achievement.js) - Análise Técnica Completa

### **Bibliotecas e Dependências**
```javascript
const mongoose = require('mongoose');  // ODM para MongoDB
```

**Explicação da Biblioteca:**
- **mongoose**: Object Document Mapper para MongoDB
  - Gerencia relacionamentos com usuários
  - Implementa validações e middleware
  - Fornece sistema de índices otimizados para consultas

### **Estrutura do Schema com Validações Avançadas**
```javascript
const esquemaConquista = new mongoose.Schema({
  idUsuario: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Usuario',                    // Referência para população
    required: [true, 'ID do usuário é obrigatório']
  },
  titulo: {
    type: String,
    required: [true, 'Título da conquista é obrigatório'],
    trim: true,                        // Remove espaços em branco
    maxlength: [100, 'Título deve ter no máximo 100 caracteres']
  },
  descricao: {
    type: String,
    required: [true, 'Descrição da conquista é obrigatória'],
    trim: true,
    maxlength: [300, 'Descrição deve ter no máximo 300 caracteres']
  },
  tipo: {
    type: String,
    required: [true, 'Tipo da conquista é obrigatório'],
    enum: [
      'primeira_semana', 'sequencia_7_dias', 'sequencia_30_dias',
      'nivel_10', 'nivel_20', 'nivel_30',
      'cacador_lendario', 'mestre_habitos', 'guardiao_tempo'
    ],
    default: 'primeira_semana'
  },
  categoria: {
    type: String,
    enum: ['progresso', 'tempo', 'nivel', 'especial'],
    default: 'progresso'
  },
  icone: {
    type: String,
    default: 'medalha'
  },
  cor: {
    type: String,
    default: '#FFD700' // Dourado
  },
  experienciaRecompensa: {
    type: Number,
    default: 50
  },
  raridade: {
    type: String,
    enum: ['comum', 'raro', 'epico', 'lendario'],
    default: 'comum'
  },
  desbloqueadaEm: {
    type: Date,
    default: Date.now
  },
  condicoes: {
    tipo: { type: String },     // Tipo de condição
    valor: { type: Number },    // Valor necessário para desbloquear
    periodo: { type: String }   // Período de avaliação
  },
  visivel: {
    type: Boolean,
    default: true
  }
}, {
  timestamps: true  // Adiciona createdAt e updatedAt automaticamente
});
```

**Detalhes das Validações:**
- **idUsuario**: Referência obrigatória para o usuário
- **titulo**: Campo obrigatório com limite de 100 caracteres
- **descricao**: Campo obrigatório com limite de 300 caracteres
- **tipo**: Enum com valores específicos para tipos de conquista
- **categoria**: Classificação para organização e filtros
- **icone**: Ícone visual da conquista (padrão: medalha)
- **cor**: Cor temática da conquista (padrão: dourado)
- **experienciaRecompensa**: XP ganho ao desbloquear (padrão: 50)
- **raridade**: Nível de raridade da conquista
- **desbloqueadaEm**: Timestamp de quando foi desbloqueada
- **condicoes**: Estrutura para verificação de desbloqueio
- **visivel**: Controla se a conquista aparece para o usuário

### **Sistema de Tipos de Conquista**
```javascript
tipo: {
  type: String,
  required: [true, 'Tipo da conquista é obrigatório'],
  enum: [
    'primeira_semana',      // Primeira semana de atividade
    'sequencia_7_dias',     // 7 dias consecutivos
    'sequencia_30_dias',    // 30 dias consecutivos
    'nivel_10',            // Alcançar nível 10
    'nivel_20',            // Alcançar nível 20
    'nivel_30',            // Alcançar nível 30
    'cacador_lendario',    // Conquista especial de caçador
    'mestre_habitos',      // Mestre em gerenciamento de hábitos
    'guardiao_tempo'       // Guardião do tempo
  ],
  default: 'primeira_semana'
}
```

**Categorização dos Tipos:**
- **Temporais**: `primeira_semana`, `sequencia_7_dias`, `sequencia_30_dias`
- **Nível**: `nivel_10`, `nivel_20`, `nivel_30`
- **Especiais**: `cacador_lendario`, `mestre_habitos`, `guardiao_tempo`

### **Sistema de Categorias**
```javascript
categoria: {
  type: String,
  enum: ['progresso', 'tempo', 'nivel', 'especial'],
  default: 'progresso'
}
```

**Explicação das Categorias:**
- **progresso**: Baseadas em avanço de hábitos e sequências
- **tempo**: Baseadas em duração de atividade
- **nivel**: Baseadas em nível alcançado
- **especial**: Conquistas únicas e especiais

### **Sistema de Raridade**
```javascript
raridade: {
  type: String,
  enum: ['comum', 'raro', 'epico', 'lendario'],
  default: 'comum'
}
```

**Hierarquia de Raridade:**
- **comum**: Conquistas básicas e frequentes
- **raro**: Conquistas intermediárias
- **épico**: Conquistas avançadas e desafiadoras
- **lendário**: Conquistas excepcionalmente raras

### **Sistema de Condições Dinâmicas**
```javascript
condicoes: {
  tipo: { type: String },     // Tipo de condição
  valor: { type: Number },    // Valor necessário
  periodo: { type: String }   // Período de avaliação
}
```

**Tipos de Condição Suportados:**
- **sequencia**: Verifica maior sequência consecutiva
- **nivel**: Verifica nível atual do usuário
- **habitos_concluidos**: Verifica total de hábitos concluídos
- **dias_ativo**: Verifica dias de atividade contínua

**Períodos de Avaliação:**
- **diario**: Avaliação diária
- **semanal**: Avaliação semanal
- **mensal**: Avaliação mensal
- **total**: Avaliação do total acumulado

### **Sistema de Índices para Performance**
```javascript
// Índices para consultas eficientes
esquemaConquista.index({ idUsuario: 1, tipo: 1 });
esquemaConquista.index({ idUsuario: 1, desbloqueadaEm: -1 });
esquemaConquista.index({ raridade: 1, categoria: 1 });
```

**Explicação dos Índices:**
- **`{ idUsuario: 1, tipo: 1 }`**: Consultas por usuário e tipo
- **`{ idUsuario: 1, desbloqueadaEm: -1 }`**: Histórico de conquistas por usuário
- **`{ raridade: 1, categoria: 1 }`**: Filtros por raridade e categoria

### **Métodos de Instância**

#### **Método - Verificação de Desbloqueio**
```javascript
esquemaConquista.methods.verificarDesbloqueio = function (dadosUsuario) {
  const { tipo, valor } = this.condicoes;

  switch (tipo) {
    case 'sequencia':
      return dadosUsuario.maiorSequencia >= valor;
    case 'nivel':
      return dadosUsuario.nivel >= valor;
    case 'habitos_concluidos':
      return dadosUsuario.totalHabitosConcluidos >= valor;
    case 'dias_ativo':
      return dadosUsuario.diasAtivo >= valor;
    default:
      return false;
  }
};
```

**Algoritmo de Verificação:**
1. **Extração**: Obtém tipo e valor das condições
2. **Switch**: Avalia baseado no tipo de condição
3. **Comparação**: Verifica se o valor do usuário atende ao requisito
4. **Retorno**: Boolean indicando se deve ser desbloqueada

**Casos de Uso:**
- **sequencia**: Verifica se maior sequência ≥ valor requerido
- **nivel**: Verifica se nível atual ≥ valor requerido
- **habitos_concluidos**: Verifica se total de hábitos ≥ valor requerido
- **dias_ativo**: Verifica se dias ativos ≥ valor requerido

#### **Método - Calcular Raridade Baseada em Condições**
```javascript
esquemaConquista.methods.calcularRaridade = function () {
  const { tipo, valor } = this.condicoes;
  
  // Lógica de raridade baseada no tipo e valor
  if (tipo === 'sequencia') {
    if (valor >= 100) return 'lendario';
    if (valor >= 50) return 'epico';
    if (valor >= 30) return 'raro';
    return 'comum';
  }
  
  if (tipo === 'nivel') {
    if (valor >= 30) return 'lendario';
    if (valor >= 20) return 'epico';
    if (valor >= 10) return 'raro';
    return 'comum';
  }
  
  if (tipo === 'habitos_concluidos') {
    if (valor >= 100) return 'lendario';
    if (valor >= 50) return 'epico';
    if (valor >= 25) return 'raro';
    return 'comum';
  }
  
  return 'comum';
};
```

#### **Método - Verificar Se Pode Ser Desbloqueada**
```javascript
esquemaConquista.methods.podeSerDesbloqueada = function (dadosUsuario) {
  // Verifica se já foi desbloqueada
  if (this.desbloqueadaEm && this.desbloqueadaEm < new Date()) {
    return false;
  }
  
  // Verifica se as condições foram atendidas
  return this.verificarDesbloqueio(dadosUsuario);
};
```

### **Métodos Estáticos**

#### **Buscar Conquistas por Usuário**
```javascript
esquemaConquista.statics.buscarPorUsuario = function (usuarioId, filtros = {}) {
  const query = { idUsuario: usuarioId };
  
  // Aplica filtros opcionais
  if (filtros.categoria) query.categoria = filtros.categoria;
  if (filtros.raridade) query.raridade = filtros.raridade;
  if (filtros.visivel !== undefined) query.visivel = filtros.visivel;
  
  return this.find(query)
    .sort({ desbloqueadaEm: -1, raridade: -1 })
    .populate('idUsuario', 'nomeUsuario nivel avatar');
};
```

#### **Calcular Estatísticas de Conquistas**
```javascript
esquemaConquista.statics.calcularEstatisticas = async function (usuarioId) {
  const conquistas = await this.find({ idUsuario: usuarioId });
  
  const estatisticas = {
    total: conquistas.length,
    porCategoria: {},
    porRaridade: {},
    totalXP: 0,
    ultimaConquista: null
  };
  
  // Agrupa por categoria
  conquistas.forEach(conquista => {
    if (!estatisticas.porCategoria[conquista.categoria]) {
      estatisticas.porCategoria[conquista.categoria] = 0;
    }
    estatisticas.porCategoria[conquista.categoria]++;
    
    // Agrupa por raridade
    if (!estatisticas.porRaridade[conquista.raridade]) {
      estatisticas.porRaridade[conquista.raridade] = 0;
    }
    estatisticas.porRaridade[conquista.raridade]++;
    
    // Soma XP total
    estatisticas.totalXP += conquista.experienciaRecompensa;
    
    // Atualiza última conquista
    if (!estatisticas.ultimaConquista || 
        conquista.desbloqueadaEm > estatisticas.ultimaConquista.desbloqueadaEm) {
      estatisticas.ultimaConquista = conquista;
    }
  });
  
  return estatisticas;
};
```

#### **Verificar Conquistas Disponíveis**
```javascript
esquemaConquista.statics.verificarDisponiveis = async function (usuarioId) {
  // Busca todas as conquistas disponíveis no sistema
  const todasConquistas = await this.find({ visivel: true });
  
  // Busca conquistas já desbloqueadas pelo usuário
  const conquistasDesbloqueadas = await this.find({ 
    idUsuario: usuarioId,
    desbloqueadaEm: { $exists: true }
  });
  
  // Filtra conquistas não desbloqueadas
  const conquistasDisponiveis = todasConquistas.filter(conquista => {
    return !conquistasDesbloqueadas.some(desbloqueada => 
      desbloqueada.tipo === conquista.tipo
    );
  });
  
  return conquistasDisponiveis;
};
```

#### **Sistema de Conquistas Automáticas**
```javascript
esquemaConquista.statics.verificarConquistasAutomaticas = async function (usuarioId) {
  const Usuario = require('./User');
  const Habito = require('./Habit');
  const Progresso = require('./Progress');
  
  const usuario = await Usuario.findById(usuarioId);
  if (!usuario) return [];
  
  // Busca conquistas disponíveis
  const conquistasDisponiveis = await this.verificarDisponiveis(usuarioId);
  
  const conquistasDesbloqueadas = [];
  
  for (const conquista of conquistasDisponiveis) {
    if (conquista.verificarDesbloqueio(usuario)) {
      // Desbloqueia a conquista
      conquista.idUsuario = usuarioId;
      conquista.desbloqueadaEm = new Date();
      conquista.raridade = conquista.calcularRaridade();
      
      await conquista.save();
      conquistasDesbloqueadas.push(conquista);
      
      // Adiciona XP ao usuário
      await usuario.adicionarExperiencia(conquista.experienciaRecompensa);
    }
  }
  
  return conquistasDesbloqueadas;
};
```

### **Sistema de Agregações para Relatórios**

#### **Relatório de Conquistas por Raridade**
```javascript
esquemaConquista.statics.relatorioPorRaridade = async function (usuarioId) {
  return this.aggregate([
    // Filtra por usuário
    { $match: { idUsuario: mongoose.Types.ObjectId(usuarioId) } },
    
    // Agrupa por raridade
    { $group: {
      _id: '$raridade',
      total: { $sum: 1 },
      totalXP: { $sum: '$experienciaRecompensa' },
      conquistas: { $push: { titulo: '$titulo', tipo: '$tipo', categoria: '$categoria' } }
    }},
    
    // Calcula porcentagem
    { $addFields: {
      porcentagem: {
        $multiply: [
          { $divide: ['$total', { $sum: '$total' }] },
          100
        ]
      }
    }},
    
    // Ordena por raridade (comum < raro < épico < lendário)
    { $sort: { 
      _id: { 
        $switch: {
          branches: [
            { case: 'comum', then: 1 },
            { case: 'raro', then: 2 },
            { case: 'epico', then: 3 },
            { case: 'lendario', then: 4 }
          ],
          default: 5
        }
      }
    }}
  ]);
};
```

#### **Relatório de Progresso de Conquistas**
```javascript
esquemaConquista.statics.relatorioProgresso = async function (usuarioId) {
  // Busca todas as conquistas disponíveis
  const todasConquistas = await this.find({ visivel: true });
  
  // Busca conquistas desbloqueadas pelo usuário
  const conquistasDesbloqueadas = await this.find({ 
    idUsuario: usuarioId,
    desbloqueadaEm: { $exists: true }
  });
  
  const Usuario = require('./User');
  const usuario = await Usuario.findById(usuarioId);
  
  const progresso = todasConquistas.map(conquista => {
    const desbloqueada = conquistasDesbloqueadas.find(d => d.tipo === conquista.tipo);
    
    if (desbloqueada) {
      return {
        ...conquista.toObject(),
        status: 'desbloqueada',
        desbloqueadaEm: desbloqueada.desbloqueadaEm,
        progresso: 100
      };
    }
    
    // Calcula progresso atual
    const progressoAtual = this.calcularProgressoConquista(conquista, usuario);
    
    return {
      ...conquista.toObject(),
      status: 'em_andamento',
      progresso: progressoAtual
    };
  });
  
  return progresso.sort((a, b) => b.progresso - a.progresso);
};
```

#### **Método Auxiliar - Calcular Progresso**
```javascript
esquemaConquista.statics.calcularProgressoConquista = function (conquista, usuario) {
  const { tipo, valor } = conquista.condicoes;
  
  switch (tipo) {
    case 'sequencia':
      return Math.min((usuario.sequencia.maiorSequencia / valor) * 100, 100);
    case 'nivel':
      return Math.min((usuario.nivel / valor) * 100, 100);
    case 'habitos_concluidos':
      // Assumindo que temos acesso ao total de hábitos concluídos
      const totalHabitos = usuario.totalHabitosConcluidos || 0;
      return Math.min((totalHabitos / valor) * 100, 100);
    case 'dias_ativo':
      const diasAtivo = Math.floor((new Date() - usuario.dataEntrada) / (1000 * 60 * 60 * 24));
      return Math.min((diasAtivo / valor) * 100, 100);
    default:
      return 0;
  }
};
```

### **Exemplos de Uso Avançado**

#### **Sistema de Conquistas Automáticas**
```javascript
async function verificarConquistasUsuario(usuarioId) {
  try {
    const conquistasDesbloqueadas = await Conquista.verificarConquistasAutomaticas(usuarioId);
    
    if (conquistasDesbloqueadas.length > 0) {
      console.log(`🎉 ${conquistasDesbloqueadas.length} nova(s) conquista(s) desbloqueada(s)!`);
      
      for (const conquista of conquistasDesbloqueadas) {
        console.log(`🏆 ${conquista.titulo} - +${conquista.experienciaRecompensa} XP`);
        console.log(`   ${conquista.descricao}`);
        console.log(`   Raridade: ${conquista.raridade}`);
      }
      
      // Envia notificação ao usuário
      await enviarNotificacaoConquista(usuarioId, conquistasDesbloqueadas);
    }
    
    return conquistasDesbloqueadas;
    
  } catch (erro) {
    console.error('Erro ao verificar conquistas:', erro.message);
    throw erro;
  }
}
```

#### **Gerar Relatório Completo de Conquistas**
```javascript
async function gerarRelatorioConquistas(usuarioId) {
  try {
    // Estatísticas gerais
    const estatisticas = await Conquista.calcularEstatisticas(usuarioId);
    
    // Relatório por raridade
    const porRaridade = await Conquista.relatorioPorRaridade(usuarioId);
    
    // Progresso das conquistas
    const progresso = await Conquista.relatorioProgresso(usuarioId);
    
    // Relatório consolidado
    const relatorio = {
      estatisticas: estatisticas,
      porRaridade: porRaridade,
      progresso: progresso,
      resumo: {
        totalConquistas: estatisticas.total,
        totalXP: estatisticas.totalXP,
        ultimaConquista: estatisticas.ultimaConquista?.titulo || 'Nenhuma',
        conquistasEmAndamento: progresso.filter(c => c.status === 'em_andamento').length
      }
    };
    
    console.log('=== RELATÓRIO DE CONQUISTAS ===');
    console.log(`Total de conquistas: ${relatorio.resumo.totalConquistas}`);
    console.log(`XP total ganho: ${relatorio.resumo.totalXP}`);
    console.log(`Última conquista: ${relatorio.resumo.ultimaConquista}`);
    console.log(`Conquistas em andamento: ${relatorio.resumo.conquistasEmAndamento}`);
    
    return relatorio;
    
  } catch (erro) {
    console.error('Erro ao gerar relatório:', erro.message);
    throw erro;
  }
}
```

#### **Sistema de Conquistas Temporais**
```javascript
async function verificarConquistasTemporais(usuarioId) {
  try {
    const hoje = new Date();
    const inicioSemana = new Date(hoje);
    inicioSemana.setDate(hoje.getDate() - 7);
    
    // Busca progressos da semana
    const Progresso = require('./Progress');
    const progressosSemana = await Progresso.find({
      idUsuario: usuarioId,
      data: { $gte: inicioSemana, $lte: hoje },
      status: 'concluido'
    });
    
    // Verifica conquista de primeira semana
    if (progressosSemana.length >= 7) {
      const conquistaPrimeiraSemana = await Conquista.findOne({
        tipo: 'primeira_semana',
        idUsuario: usuarioId
      });
      
      if (!conquistaPrimeiraSemana) {
        const novaConquista = new Conquista({
          idUsuario: usuarioId,
          titulo: 'Primeira Semana',
          descricao: 'Completou hábitos por 7 dias consecutivos',
          tipo: 'primeira_semana',
          categoria: 'tempo',
          experienciaRecompensa: 100,
          raridade: 'raro',
          condicoes: { tipo: 'dias_ativo', valor: 7, periodo: 'semanal' }
        });
        
        await novaConquista.save();
        console.log('🏆 Conquista "Primeira Semana" desbloqueada!');
      }
    }
    
  } catch (erro) {
    console.error('Erro ao verificar conquistas temporais:', erro.message);
  }
}
```

### **Considerações de Performance**

#### **Otimização de Consultas**
```javascript
// Consulta otimizada com projeção
const conquistas = await Conquista.find({ idUsuario: usuarioId })
  .select('titulo categoria raridade experienciaRecompensa')
  .sort({ desbloqueadaEm: -1 })
  .lean();

// Consulta com agregação para estatísticas complexas
const estatisticas = await Conquista.aggregate([
  { $match: { idUsuario: mongoose.Types.ObjectId(usuarioId) } },
  { $group: {
    _id: '$categoria',
    total: { $sum: 1 },
    totalXP: { $sum: '$experienciaRecompensa' }
  }}
]);
```

#### **Cache de Conquistas Disponíveis**
```javascript
// Cache de conquistas disponíveis para evitar consultas repetidas
let cacheConquistasDisponiveis = null;
let cacheTimestamp = null;
const CACHE_DURATION = 5 * 60 * 1000; // 5 minutos

esquemaConquista.statics.getConquistasDisponiveis = async function () {
  const agora = Date.now();
  
  if (cacheConquistasDisponiveis && cacheTimestamp && (agora - cacheTimestamp) < CACHE_DURATION) {
    return cacheConquistasDisponiveis;
  }
  
  const conquistas = await this.find({ visivel: true });
  
  cacheConquistasDisponiveis = conquistas;
  cacheTimestamp = agora;
  
  return conquistas;
};
```

---

*Documentação técnica detalhada do modelo Conquista - Sistema Librarium*
