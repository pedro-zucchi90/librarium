# Documentação Técnica Detalhada - Modelo Habito (Habit.js)

## 🎯 Modelo Habito (Habit.js) - Análise Técnica Completa

### **Bibliotecas e Dependências**
```javascript
const mongoose = require('mongoose');  // ODM para MongoDB
```

**Explicação da Biblioteca:**
- **mongoose**: Object Document Mapper para MongoDB
  - Gerencia relacionamentos com usuários
  - Implementa validações e middleware
  - Fornece métodos de instância e estáticos

### **Estrutura do Schema com Validações Avançadas**
```javascript
const esquemaHabito = new mongoose.Schema({
  idUsuario: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Usuario',                    // Referência para população
    required: [true, 'ID do usuário é obrigatório']
  },
  titulo: {
    type: String,
    required: [true, 'Título do hábito é obrigatório'],
    trim: true,                        // Remove espaços em branco
    maxlength: [100, 'Título deve ter no máximo 100 caracteres']
  },
  descricao: {
    type: String,
    trim: true,
    maxlength: [500, 'Descrição deve ter no máximo 500 caracteres']
  },
  frequencia: {
    type: String,
    required: [true, 'Frequência é obrigatória'],
    enum: ['diario', 'semanal', 'mensal'],
    default: 'diario'
  },
  categoria: {
    type: String,
    enum: ['saude', 'estudo', 'trabalho', 'pessoal', 'social', 'criativo'],
    default: 'pessoal'
  },
  dificuldade: {
    type: String,
    enum: ['facil', 'medio', 'dificil', 'lendario'],
    default: 'medio'
  },
  recompensaExperiencia: {
    type: Number,
    default: function () {
      // Função que calcula recompensa baseada na dificuldade
      const recompensas = { 
        facil: 10, 
        medio: 20, 
        dificil: 35, 
        lendario: 50 
      };
      return recompensas[this.dificuldade] || 20;
    }
  },
  icone: {
    type: String,
    default: 'espada'
  },
  cor: {
    type: String,
    default: '#8B5CF6' // Tema roxo
  },
  ativo: {
    type: Boolean,
    default: true
  },
  diasAlvo: {
    type: [String], // ['segunda', 'terca', etc] para hábitos semanais
    default: []
  },
  horarioLembrete: {
    type: String, // Formato HH:MM
    default: null
  },
  sequencia: {
    atual: { type: Number, default: 0 },
    maiorSequencia: { type: Number, default: 0 }
  },
  estatisticas: {
    totalConclusoes: { type: Number, default: 0 },
    totalPerdidos: { type: Number, default: 0 },
    taxaConclusao: { type: Number, default: 0 }
  }
}, {
  timestamps: true  // Adiciona createdAt e updatedAt automaticamente
});
```

**Detalhes das Validações:**
- **idUsuario**: Referência obrigatória para usuário proprietário
- **titulo**: Campo obrigatório com limite de 100 caracteres
- **descricao**: Campo opcional com limite de 500 caracteres
- **frequencia**: Enum com valores específicos para tipos de hábito
- **categoria**: Classificação para organização e filtros
- **dificuldade**: Sistema de níveis com recompensas automáticas
- **diasAlvo**: Array para hábitos semanais específicos
- **horarioLembrete**: Formato HH:MM para notificações

### **Sistema de Recompensas Automáticas**
```javascript
recompensaExperiencia: {
  type: Number,
  default: function () {
    const recompensas = { 
      facil: 10, 
      medio: 20, 
      dificil: 35, 
      lendario: 50 
    };
    return recompensas[this.dificuldade] || 20;
  }
}
```

**Lógica de Recompensas:**
- **Fácil**: 10 XP - Hábitos simples e rápidos
- **Médio**: 20 XP - Hábitos de complexidade padrão
- **Difícil**: 35 XP - Hábitos que requerem esforço
- **Lendário**: 50 XP - Hábitos excepcionalmente desafiadores

**Implementação Técnica:**
- **Função default**: Executada na criação do documento
- **Acesso ao contexto**: `this.dificuldade` refere-se ao campo atual
- **Fallback**: Retorna 20 XP se dificuldade não for reconhecida

### **Sistema de Sequência e Estatísticas**
```javascript
sequencia: {
  atual: { type: Number, default: 0 },        // Sequência atual
  maiorSequencia: { type: Number, default: 0 } // Recorde pessoal
},
estatisticas: {
  totalConclusoes: { type: Number, default: 0 },  // Total de vezes concluído
  totalPerdidos: { type: Number, default: 0 },    // Total de vezes perdido
  taxaConclusao: { type: Number, default: 0 }     // Porcentagem de sucesso
}
```

**Estrutura de Dados:**
- **sequencia.atual**: Contador de dias consecutivos atuais
- **sequencia.maiorSequencia**: Maior sequência já alcançada
- **estatisticas.totalConclusoes**: Contador de sucessos
- **estatisticas.totalPerdidos**: Contador de falhas
- **estatisticas.taxaConclusao**: Porcentagem calculada automaticamente

### **Método - Atualização de Estatísticas**
```javascript
esquemaHabito.methods.atualizarEstatisticas = function () {
  const total = this.estatisticas.totalConclusoes + this.estatisticas.totalPerdidos;
  
  // Calcula taxa de conclusão em porcentagem
  this.estatisticas.taxaConclusao = total > 0 
    ? (this.estatisticas.totalConclusoes / total) * 100 
    : 0;
};
```

**Algoritmo Matemático:**
- **Fórmula**: `Taxa = (Conclusões / Total) × 100`
- **Exemplo 1**: 8 conclusões + 2 perdidos = 10 total
  - Taxa: (8/10) × 100 = 80%
- **Exemplo 2**: 0 conclusões + 0 perdidos = 0 total
  - Taxa: 0 (evita divisão por zero)

**Casos de Uso:**
- **Após cada conclusão**: Atualiza estatísticas em tempo real
- **Relatórios**: Fornece métricas de performance
- **Gamificação**: Base para conquistas e recompensas

### **Método - Atualização de Sequência**
```javascript
esquemaHabito.methods.atualizarSequencia = function (concluido) {
  if (concluido) {
    this.sequencia.atual += 1;
    // Atualiza maior sequência se necessário
    if (this.sequencia.atual > this.sequencia.maiorSequencia) {
      this.sequencia.maiorSequencia = this.sequencia.atual;
    }
  } else {
    // Reset da sequência atual se não concluído
    this.sequencia.atual = 0;
  }
};
```

**Algoritmo de Sequência Detalhado:**
1. **Verificação de Status**: Recebe boolean indicando se foi concluído
2. **Se Concluído**:
   - Incrementa sequência atual
   - Verifica se bateu recorde pessoal
   - Atualiza maior sequência se necessário
3. **Se Não Concluído**:
   - Zera sequência atual (quebra a corrente)
   - Mantém maior sequência intacta

**Exemplo de Execução:**
```javascript
// Sequência: 5 dias consecutivos
habito.sequencia.atual = 5;
habito.sequencia.maiorSequencia = 5;

// Dia 6: Concluído
habito.atualizarSequencia(true);
// Resultado: atual = 6, maiorSequencia = 6

// Dia 7: Não concluído
habito.atualizarSequencia(false);
// Resultado: atual = 0, maiorSequencia = 6 (mantém recorde)
```

### **Sistema de Dias Alvo para Hábitos Semanais**
```javascript
diasAlvo: {
  type: [String], // Array de strings
  default: []
}
```

**Valores Possíveis:**
```javascript
const diasSemana = [
  'domingo', 'segunda', 'terca', 'quarta', 
  'quinta', 'sexta', 'sabado'
];
```

**Implementação de Validação:**
```javascript
// Validação customizada para dias da semana
esquemaHabito.path('diasAlvo').validate(function (dias) {
  const diasValidos = ['domingo', 'segunda', 'terca', 'quarta', 'quinta', 'sexta', 'sabado'];
  
  if (this.frequencia === 'semanal' && dias.length === 0) {
    return false; // Hábitos semanais devem ter dias alvo
  }
  
  return dias.every(dia => diasValidos.includes(dia));
}, 'Dias da semana devem ser válidos para hábitos semanais');
```

### **Sistema de Horário de Lembrete**
```javascript
horarioLembrete: {
  type: String, // Formato HH:MM
  default: null
}
```

**Validação de Formato:**
```javascript
// Validação de formato HH:MM
esquemaHabito.path('horarioLembrete').validate(function (horario) {
  if (!horario) return true; // Campo opcional
  
  const regexHorario = /^([01]?[0-9]|2[0-3]):[0-5][0-9]$/;
  return regexHorario.test(horario);
}, 'Horário deve estar no formato HH:MM (00:00 a 23:59)');
```

**Exemplos de Horários Válidos:**
- `"08:00"` - 8 da manhã
- `"14:30"` - 2:30 da tarde
- `"22:15"` - 10:15 da noite

### **Métodos de Validação Customizados**

#### **Validação de Frequência vs Dias Alvo**
```javascript
esquemaHabito.pre('save', function (next) {
  if (this.frequencia === 'semanal' && this.diasAlvo.length === 0) {
    const erro = new Error('Hábitos semanais devem ter dias alvo definidos');
    return next(erro);
  }
  
  if (this.frequencia === 'diario' && this.diasAlvo.length > 0) {
    this.diasAlvo = []; // Limpa dias alvo para hábitos diários
  }
  
  next();
});
```

#### **Validação de Categoria vs Dificuldade**
```javascript
esquemaHabito.pre('save', function (next) {
  // Hábitos de saúde não podem ser lendários
  if (this.categoria === 'saude' && this.dificuldade === 'lendario') {
    const erro = new Error('Hábitos de saúde não podem ter dificuldade lendária');
    return next(erro);
  }
  
  next();
});
```

### **Métodos de Consulta Estáticos**

#### **Buscar Hábitos por Usuário e Status**
```javascript
esquemaHabito.statics.buscarPorUsuario = function (usuarioId, ativo = true) {
  return this.find({
    idUsuario: usuarioId,
    ativo: ativo
  }).sort({ createdAt: -1 });
};
```

#### **Buscar Hábitos por Categoria**
```javascript
esquemaHabito.statics.buscarPorCategoria = function (usuarioId, categoria) {
  return this.find({
    idUsuario: usuarioId,
    categoria: categoria,
    ativo: true
  }).sort({ titulo: 1 });
};
```

#### **Buscar Hábitos por Dificuldade**
```javascript
esquemaHabito.statics.buscarPorDificuldade = function (usuarioId, dificuldade) {
  return this.find({
    idUsuario: usuarioId,
    dificuldade: dificuldade,
    ativo: true
  }).sort({ recompensaExperiencia: -1 });
};
```

### **Métodos de Análise e Relatórios**

#### **Calcular Estatísticas Gerais**
```javascript
esquemaHabito.statics.obterEstatisticasGerais = async function (usuarioId) {
  const habitos = await this.find({ idUsuario: usuarioId });
  
  const estatisticas = {
    total: habitos.length,
    ativos: habitos.filter(h => h.ativo).length,
    porCategoria: {},
    porDificuldade: {},
    totalXP: 0,
    mediaTaxaConclusao: 0
  };
  
  // Agrupa por categoria
  habitos.forEach(habito => {
    if (!estatisticas.porCategoria[habito.categoria]) {
      estatisticas.porCategoria[habito.categoria] = 0;
    }
    estatisticas.porCategoria[habito.categoria]++;
    
    // Agrupa por dificuldade
    if (!estatisticas.porDificuldade[habito.dificuldade]) {
      estatisticas.porDificuldade[habito.dificuldade] = 0;
    }
    estatisticas.porDificuldade[habito.dificuldade]++;
    
    // Soma XP potencial
    estatisticas.totalXP += habitos.estatisticas.totalConclusoes * habitos.recompensaExperiencia;
    
    // Calcula média de taxa de conclusão
    estatisticas.mediaTaxaConclusao += habitos.estatisticas.taxaConclusao;
  });
  
  if (habitos.length > 0) {
    estatisticas.mediaTaxaConclusao /= habitos.length;
  }
  
  return estatisticas;
};
```

### **Sistema de Índices para Performance**
```javascript
// Índices para consultas frequentes
esquemaHabito.index({ idUsuario: 1, ativo: 1 });
esquemaHabito.index({ idUsuario: 1, categoria: 1 });
esquemaHabito.index({ idUsuario: 1, dificuldade: 1 });
esquemaHabito.index({ idUsuario: 1, frequencia: 1 });
esquemaHabito.index({ idUsuario: 1, createdAt: -1 });
```

**Explicação dos Índices:**
- **`{ idUsuario: 1, ativo: 1 }`**: Consultas por usuário e status
- **`{ idUsuario: 1, categoria: 1 }`**: Filtros por categoria
- **`{ idUsuario: 1, dificuldade: 1 }`**: Filtros por dificuldade
- **`{ idUsuario: 1, frequencia: 1 }`**: Filtros por frequência
- **`{ idUsuario: 1, createdAt: -1 }`**: Histórico ordenado por criação

### **Exemplos de Uso Avançado**

#### **Criação de Hábito com Validações**
```javascript
try {
  const novoHabito = new Habito({
    idUsuario: usuarioId,
    titulo: 'Exercício Matinal',
    descricao: '30 minutos de exercício todos os dias',
    frequencia: 'diario',
    categoria: 'saude',
    dificuldade: 'medio',
    horarioLembrete: '07:00',
    diasAlvo: [] // Vazio para hábitos diários
  });
  
  await novoHabito.save();
  
  console.log('Hábito criado com sucesso!');
  console.log('Recompensa XP:', novoHabito.recompensaExperiencia);
  console.log('Ícone padrão:', novoHabito.icone);
  console.log('Cor padrão:', novoHabito.cor);
  
} catch (erro) {
  if (erro.name === 'ValidationError') {
    console.log('Erro de validação:', erro.message);
  } else {
    console.log('Erro inesperado:', erro.message);
  }
}
```

#### **Atualização de Estatísticas Após Conclusão**
```javascript
// Simula conclusão de hábito
async function concluirHabito(habitoId, usuarioId) {
  try {
    const habito = await Habito.findById(habitoId);
    if (!habito || habito.idUsuario.toString() !== usuarioId) {
      throw new Error('Hábito não encontrado ou não autorizado');
    }
    
    // Atualiza estatísticas
    habito.estatisticas.totalConclusoes += 1;
    habito.atualizarEstatisticas();
    
    // Atualiza sequência
    habito.atualizarSequencia(true);
    
    // Salva alterações
    await habito.save();
    
    // Adiciona XP ao usuário
    const usuario = await Usuario.findById(usuarioId);
    await usuario.adicionarExperiencia(habito.recompensaExperiencia);
    
    console.log(`Hábito concluído! +${habito.recompensaExperiencia} XP`);
    console.log(`Sequência atual: ${habito.sequencia.atual}`);
    console.log(`Taxa de conclusão: ${habito.estatisticas.taxaConclusao.toFixed(1)}%`);
    
  } catch (erro) {
    console.error('Erro ao concluir hábito:', erro.message);
  }
}
```

#### **Relatório de Performance de Hábitos**
```javascript
async function gerarRelatorioHabit(usuarioId) {
  try {
    const estatisticas = await Habito.obterEstatisticasGerais(usuarioId);
    
    console.log('=== RELATÓRIO DE HÁBITOS ===');
    console.log(`Total de hábitos: ${estatisticas.total}`);
    console.log(`Hábitos ativos: ${estatisticas.ativos}`);
    console.log(`XP total ganho: ${estatisticas.totalXP}`);
    console.log(`Taxa média de conclusão: ${estatisticas.mediaTaxaConclusao.toFixed(1)}%`);
    
    console.log('\n--- Por Categoria ---');
    Object.entries(estatisticas.porCategoria).forEach(([categoria, quantidade]) => {
      console.log(`${categoria}: ${quantidade} hábitos`);
    });
    
    console.log('\n--- Por Dificuldade ---');
    Object.entries(estatisticas.porDificuldade).forEach(([dificuldade, quantidade]) => {
      console.log(`${dificuldade}: ${quantidade} hábitos`);
    });
    
  } catch (erro) {
    console.error('Erro ao gerar relatório:', erro.message);
  }
}
```

### **Considerações de Performance**

#### **Otimização de Consultas**
```javascript
// Consulta otimizada com projeção
const habitos = await Habito.find({ idUsuario: usuarioId, ativo: true })
  .select('titulo categoria dificuldade recompensaExperiencia sequencia')
  .lean(); // Retorna objetos JavaScript puros (mais rápido)

// Consulta com agregação para estatísticas complexas
const estatisticas = await Habito.aggregate([
  { $match: { idUsuario: mongoose.Types.ObjectId(usuarioId) } },
  { $group: {
    _id: '$categoria',
    total: { $sum: 1 },
    mediaTaxa: { $avg: '$estatisticas.taxaConclusao' }
  }}
]);
```

#### **Cache de Estatísticas**
```javascript
// Atualiza estatísticas apenas quando necessário
esquemaHabito.pre('save', function (next) {
  if (this.isModified('estatisticas.totalConclusoes') || 
      this.isModified('estatisticas.totalPerdidos')) {
    this.atualizarEstatisticas();
  }
  next();
});
```

---

*Documentação técnica detalhada do modelo Habito - Sistema Librarium*
