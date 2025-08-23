# Documentação Técnica Detalhada - Modelo Progresso (Progress.js)

## 📊 Modelo Progresso (Progress.js) - Análise Técnica Completa

### **Bibliotecas e Dependências**
```javascript
const mongoose = require('mongoose');  // ODM para MongoDB
```

**Explicação da Biblioteca:**
- **mongoose**: Object Document Mapper para MongoDB
  - Gerencia relacionamentos com hábitos e usuários
  - Implementa validações e middleware
  - Fornece sistema de índices otimizados

### **Estrutura do Schema com Validações Avançadas**
```javascript
const esquemaProgresso = new mongoose.Schema({
  idHabito: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Habito',                     // Referência para população
    required: [true, 'ID do hábito é obrigatório']
  },
  idUsuario: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Usuario',                    // Referência para população
    required: [true, 'ID do usuário é obrigatório']
  },
  data: {
    type: Date,
    required: [true, 'Data é obrigatória'],
    default: Date.now
  },
  status: {
    type: String,
    required: [true, 'Status é obrigatório'],
    enum: ['concluido', 'perdido', 'parcial'],
    default: 'concluido'
  },
  observacoes: {
    type: String,
    maxlength: [200, 'Observações devem ter no máximo 200 caracteres']
  },
  experienciaGanha: {
    type: Number,
    default: 0
  },
  concluidoEm: {
    type: Date,
    default: Date.now
  },
  dificuldade: {
    type: String,
    enum: ['facil', 'medio', 'dificil', 'lendario']
  }
}, {
  timestamps: true  // Adiciona createdAt e updatedAt automaticamente
});
```

**Detalhes das Validações:**
- **idHabito**: Referência obrigatória para o hábito
- **idUsuario**: Referência obrigatória para o usuário
- **data**: Campo obrigatório com valor padrão (data atual)
- **status**: Enum com valores específicos para tipos de progresso
- **observacoes**: Campo opcional com limite de 200 caracteres
- **experienciaGanha**: XP ganho pela conclusão (pode ser 0)
- **concluidoEm**: Timestamp de quando foi concluído
- **dificuldade**: Nível de dificuldade no momento da conclusão

### **Sistema de Índices para Performance e Integridade**
```javascript
// Índice único composto - garante uma entrada por hábito por dia
esquemaProgresso.index({ idHabito: 1, data: 1 }, { unique: true });

// Índices para consultas eficientes
esquemaProgresso.index({ idUsuario: 1, data: -1 });  // Ordenação decrescente
esquemaProgresso.index({ idHabito: 1, status: 1 });  // Filtros por status
```

**Explicação Detalhada dos Índices:**

#### **Índice Único Composto: `{ idHabito: 1, data: 1, unique: true }`**
- **Propósito**: Previne múltiplas entradas para o mesmo hábito no mesmo dia
- **Estrutura**: 
  - `idHabito: 1` - Ordenação ascendente por ID do hábito
  - `data: 1` - Ordenação ascendente por data
  - `unique: true` - Garante unicidade da combinação
- **Casos de Uso**:
  - Evita duplicação de progresso diário
  - Permite apenas uma entrada por hábito por dia
  - Otimiza consultas por hábito + data

#### **Índice de Consulta: `{ idUsuario: 1, data: -1 }`**
- **Propósito**: Otimiza consultas de histórico do usuário
- **Estrutura**:
  - `idUsuario: 1` - Ordenação ascendente por ID do usuário
  - `data: -1` - Ordenação decrescente por data (mais recente primeiro)
- **Casos de Uso**:
  - Histórico de progresso do usuário
  - Dashboard com atividades recentes
  - Relatórios de performance temporal

#### **Índice de Status: `{ idHabito: 1, status: 1 }`**
- **Propósito**: Otimiza filtros por hábito e status
- **Estrutura**:
  - `idHabito: 1` - Ordenação ascendente por ID do hábito
  - `status: 1` - Ordenação ascendente por status
- **Casos de Uso**:
  - Estatísticas de conclusão por hábito
  - Filtros de progresso por status
  - Relatórios de performance

### **Sistema de Status de Progresso**
```javascript
status: {
  type: String,
  required: [true, 'Status é obrigatório'],
  enum: ['concluido', 'perdido', 'parcial'],
  default: 'concluido'
}
```

**Tipos de Status:**
- **concluido**: Hábito foi completado com sucesso
- **perdido**: Hábito não foi realizado no dia
- **parcial**: Hábito foi realizado parcialmente

**Lógica de Status:**
- **concluido**: Adiciona XP completo e incrementa sequência
- **perdido**: Zera sequência atual, mantém recorde
- **parcial**: Adiciona XP reduzido, mantém sequência

### **Sistema de Experiência e Recompensas**
```javascript
experienciaGanha: {
  type: Number,
  default: 0
},
concluidoEm: {
  type: Date,
  default: Date.now
}
```

**Cálculo de Experiência:**
```javascript
// Exemplo de cálculo baseado no status
function calcularExperiencia(status, dificuldadeHabito) {
  const multiplicadores = {
    concluido: 1.0,    // 100% da recompensa
    parcial: 0.5,      // 50% da recompensa
    perdido: 0.0       // 0% da recompensa
  };
  
  const recompensasBase = {
    facil: 10,
    medio: 20,
    dificil: 35,
    lendario: 50
  };
  
  const recompensaBase = recompensasBase[dificuldadeHabito] || 20;
  return Math.floor(recompensaBase * multiplicadores[status]);
}
```

### **Validações Customizadas**

#### **Validação de Data Única por Hábito**
```javascript
// Validação customizada para garantir unicidade
esquemaProgresso.path('data').validate(function (data) {
  if (!this.idHabito) return true; // Só valida se hábito estiver definido
  
  // Verifica se já existe progresso para este hábito nesta data
  return this.constructor.findOne({
    idHabito: this.idHabito,
    data: {
      $gte: new Date(data.getFullYear(), data.getMonth(), data.getDate()),
      $lt: new Date(data.getFullYear(), data.getMonth(), data.getDate() + 1)
    },
    _id: { $ne: this._id } // Exclui o documento atual na edição
  }).then(existing => !existing);
}, 'Já existe progresso registrado para este hábito nesta data');
```

#### **Validação de Status vs Experiência**
```javascript
// Validação de consistência entre status e experiência
esquemaProgresso.pre('save', function (next) {
  if (this.status === 'perdido' && this.experienciaGanha > 0) {
    return next(new Error('Hábitos perdidos não podem ganhar experiência'));
  }
  
  if (this.status === 'concluido' && this.experienciaGanha === 0) {
    return next(new Error('Hábitos concluídos devem ganhar experiência'));
  }
  
  next();
});
```

### **Métodos de Instância**

#### **Método - Calcular Experiência Baseada no Status**
```javascript
esquemaProgresso.methods.calcularExperiencia = function () {
  const recompensasBase = {
    facil: 10,
    medio: 20,
    dificil: 35,
    lendario: 50
  };
  
  const multiplicadores = {
    concluido: 1.0,
    parcial: 0.5,
    perdido: 0.0
  };
  
  const recompensaBase = recompensasBase[this.dificuldade] || 20;
  const multiplicador = multiplicadores[this.status] || 0;
  
  this.experienciaGanha = Math.floor(recompensaBase * multiplicador);
  return this.experienciaGanha;
};
```

#### **Método - Verificar Se Pode Ser Editado**
```javascript
esquemaProgresso.methods.podeSerEditado = function () {
  const agora = new Date();
  const dataProgresso = new Date(this.data);
  const diffDias = Math.floor((agora - dataProgresso) / (1000 * 60 * 60 * 24));
  
  // Permite edição apenas no mesmo dia ou no dia seguinte
  return diffDias <= 1;
};
```

### **Métodos Estáticos**

#### **Buscar Progresso por Período**
```javascript
esquemaProgresso.statics.buscarPorPeriodo = function (usuarioId, dataInicio, dataFim) {
  return this.find({
    idUsuario: usuarioId,
    data: {
      $gte: dataInicio,
      $lte: dataFim
    }
  })
    .sort({ data: -1 })
    .populate('idHabito', 'titulo categoria dificuldade');
};
```

#### **Calcular Estatísticas por Período**
```javascript
esquemaProgresso.statics.calcularEstatisticas = async function (usuarioId, dataInicio, dataFim) {
  const progressos = await this.find({
    idUsuario: usuarioId,
    data: { $gte: dataInicio, $lte: dataFim }
  });
  
  const estatisticas = {
    total: progressos.length,
    concluidos: progressos.filter(p => p.status === 'concluido').length,
    perdidos: progressos.filter(p => p.status === 'perdido').length,
    parciais: progressos.filter(p => p.status === 'parcial').length,
    totalXP: progressos.reduce((total, p) => total + p.experienciaGanha, 0),
    taxaConclusao: 0
  };
  
  if (estatisticas.total > 0) {
    estatisticas.taxaConclusao = (estatisticas.concluidos / estatisticas.total) * 100;
  }
  
  return estatisticas;
};
```

#### **Buscar Sequência Consecutiva**
```javascript
esquemaProgresso.statics.buscarSequenciaConsecutiva = async function (usuarioId, habitoId) {
  const progressos = await this.find({
    idUsuario: usuarioId,
    idHabito: habitoId,
    status: 'concluido'
  }).sort({ data: -1 });
  
  if (progressos.length === 0) return 0;
  
  let sequenciaAtual = 0;
  let maiorSequencia = 0;
  let dataAnterior = null;
  
  for (const progresso of progressos) {
    const dataAtual = progresso.data.toISOString().split('T')[0];
    
    if (!dataAnterior || this.saoDiasConsecutivos(dataAnterior, dataAtual)) {
      sequenciaAtual++;
      maiorSequencia = Math.max(maiorSequencia, sequenciaAtual);
    } else {
      sequenciaAtual = 1;
    }
    
    dataAnterior = dataAtual;
  }
  
  return maiorSequencia;
};
```

#### **Método Auxiliar - Verificar Dias Consecutivos**
```javascript
esquemaProgresso.statics.saoDiasConsecutivos = function (data1, data2) {
  const d1 = new Date(data1);
  const d2 = new Date(data2);
  const diffTempo = Math.abs(d2 - d1);
  const diffDias = Math.ceil(diffTempo / (1000 * 60 * 60 * 24));
  return diffDias === 1;
};
```

### **Sistema de Agregações para Relatórios**

#### **Relatório de Performance por Categoria**
```javascript
esquemaProgresso.statics.relatorioPorCategoria = async function (usuarioId, dataInicio, dataFim) {
  return this.aggregate([
    // Filtra por usuário e período
    { $match: {
      idUsuario: mongoose.Types.ObjectId(usuarioId),
      data: { $gte: dataInicio, $lte: dataFim }
    }},
    
    // Popula dados do hábito
    { $lookup: {
      from: 'habitos',
      localField: 'idHabito',
      foreignField: '_id',
      as: 'habito'
    }},
    
    // Desempacota o array do hábito
    { $unwind: '$habito' },
    
    // Agrupa por categoria
    { $group: {
      _id: '$habito.categoria',
      total: { $sum: 1 },
      concluidos: { $sum: { $cond: [{ $eq: ['$status', 'concluido'] }, 1, 0] } },
      perdidos: { $sum: { $cond: [{ $eq: ['$status', 'perdido'] }, 1, 0] } },
      parciais: { $sum: { $cond: [{ $eq: ['$status', 'parcial'] }, 1, 0] } },
      totalXP: { $sum: '$experienciaGanha' }
    }},
    
    // Calcula taxa de conclusão
    { $addFields: {
      taxaConclusao: {
        $multiply: [
          { $divide: ['$concluidos', '$total'] },
          100
        ]
      }
    }},
    
    // Ordena por taxa de conclusão
    { $sort: { taxaConclusao: -1 } }
  ]);
};
```

#### **Relatório de Tendências Temporais**
```javascript
esquemaProgresso.statics.relatorioTendencias = async function (usuarioId, dias = 30) {
  const dataInicio = new Date();
  dataInicio.setDate(dataInicio.getDate() - dias);
  
  return this.aggregate([
    // Filtra por usuário e período
    { $match: {
      idUsuario: mongoose.Types.ObjectId(usuarioId),
      data: { $gte: dataInicio }
    }},
    
    // Agrupa por dia
    { $group: {
      _id: {
        $dateToString: { format: '%Y-%m-%d', date: '$data' }
      },
      total: { $sum: 1 },
      concluidos: { $sum: { $cond: [{ $eq: ['$status', 'concluido'] }, 1, 0] } },
      totalXP: { $sum: '$experienciaGanha' }
    }},
    
    // Calcula taxa de conclusão diária
    { $addFields: {
      taxaConclusao: {
        $multiply: [
          { $divide: ['$concluidos', '$total'] },
          100
        ]
      }
    }},
    
    // Ordena por data
    { $sort: { _id: 1 } }
  ]);
};
```

### **Exemplos de Uso Avançado**

#### **Registrar Progresso com Validações**
```javascript
async function registrarProgresso(habitoId, usuarioId, status, observacoes = '') {
  try {
    // Verifica se já existe progresso para hoje
    const hoje = new Date();
    const inicioDia = new Date(hoje.getFullYear(), hoje.getMonth(), hoje.getDate());
    const fimDia = new Date(hoje.getFullYear(), hoje.getMonth(), hoje.getDate() + 1);
    
    const progressoExistente = await Progresso.findOne({
      idHabito: habitoId,
      idUsuario: usuarioId,
      data: { $gte: inicioDia, $lt: fimDia }
    });
    
    if (progressoExistente) {
      throw new Error('Já existe progresso registrado para este hábito hoje');
    }
    
    // Busca o hábito para obter dificuldade
    const habito = await Habito.findById(habitoId);
    if (!habito) {
      throw new Error('Hábito não encontrado');
    }
    
    // Cria novo progresso
    const novoProgresso = new Progresso({
      idHabito: habitoId,
      idUsuario: usuarioId,
      data: hoje,
      status: status,
      observacoes: observacoes,
      dificuldade: habito.dificuldade
    });
    
    // Calcula experiência baseada no status
    novoProgresso.calcularExperiencia();
    
    // Salva o progresso
    await novoProgresso.save();
    
    // Atualiza estatísticas do hábito
    await atualizarEstatisticasHabito(habitoId, status);
    
    // Adiciona XP ao usuário se ganhou experiência
    if (novoProgresso.experienciaGanha > 0) {
      const usuario = await Usuario.findById(usuarioId);
      await usuario.adicionarExperiencia(novoProgresso.experienciaGanha);
    }
    
    console.log(`Progresso registrado: ${status} - +${novoProgresso.experienciaGanha} XP`);
    return novoProgresso;
    
  } catch (erro) {
    console.error('Erro ao registrar progresso:', erro.message);
    throw erro;
  }
}
```

#### **Gerar Relatório Completo de Performance**
```javascript
async function gerarRelatorioCompleto(usuarioId, dias = 30) {
  try {
    const dataInicio = new Date();
    dataInicio.setDate(dataInicio.getDate() - dias);
    const dataFim = new Date();
    
    // Estatísticas gerais
    const estatisticas = await Progresso.calcularEstatisticas(usuarioId, dataInicio, dataFim);
    
    // Relatório por categoria
    const porCategoria = await Progresso.relatorioPorCategoria(usuarioId, dataInicio, dataFim);
    
    // Tendências temporais
    const tendencias = await Progresso.relatorioTendencias(usuarioId, dias);
    
    // Relatório consolidado
    const relatorio = {
      periodo: {
        inicio: dataInicio,
        fim: dataFim,
        dias: dias
      },
      estatisticas: estatisticas,
      porCategoria: porCategoria,
      tendencias: tendencias,
      resumo: {
        totalHabitos: estatisticas.total,
        taxaConclusao: estatisticas.taxaConclusao.toFixed(1) + '%',
        totalXP: estatisticas.totalXP,
        mediaDiaria: (estatisticas.totalXP / dias).toFixed(1)
      }
    };
    
    console.log('=== RELATÓRIO DE PERFORMANCE ===');
    console.log(`Período: ${dias} dias`);
    console.log(`Total de hábitos: ${relatorio.resumo.totalHabitos}`);
    console.log(`Taxa de conclusão: ${relatorio.resumo.taxaConclusao}`);
    console.log(`XP total: ${relatorio.resumo.totalXP}`);
    console.log(`XP médio por dia: ${relatorio.resumo.mediaDiaria}`);
    
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
const progressos = await Progresso.find({ idUsuario: usuarioId })
  .select('data status experienciaGanha')
  .sort({ data: -1 })
  .limit(100)
  .lean(); // Retorna objetos JavaScript puros (mais rápido)

// Consulta com agregação para estatísticas complexas
const estatisticas = await Progresso.aggregate([
  { $match: { idUsuario: mongoose.Types.ObjectId(usuarioId) } },
  { $group: {
    _id: '$status',
    total: { $sum: 1 },
    totalXP: { $sum: '$experienciaGanha' }
  }}
]);
```

#### **Cache de Estatísticas**
```javascript
// Atualiza estatísticas apenas quando necessário
esquemaProgresso.post('save', async function () {
  // Atualiza estatísticas do hábito relacionado
  const Habito = require('./Habit');
  const habito = await Habito.findById(this.idHabito);
  
  if (habito) {
    // Busca todos os progressos do hábito
    const progressos = await this.constructor.find({ idHabito: this.idHabito });
    
    // Atualiza estatísticas
    habito.estatisticas.totalConclusoes = progressos.filter(p => p.status === 'concluido').length;
    habito.estatisticas.totalPerdidos = progressos.filter(p => p.status === 'perdido').length;
    habito.atualizarEstatisticas();
    
    await habito.save();
  }
});
```

---

*Documentação técnica detalhada do modelo Progresso - Sistema Librarium*
