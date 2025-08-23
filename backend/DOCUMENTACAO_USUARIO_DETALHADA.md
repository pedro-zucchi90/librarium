# Documentação Técnica Detalhada - Modelo Usuario (User.js)

## 🧑‍💻 Modelo Usuario (User.js) - Análise Técnica Completa

### **Bibliotecas e Dependências**
```javascript
const mongoose = require('mongoose');  // ODM para MongoDB
const bcrypt = require('bcrypt');      // Criptografia de senhas
```

**Explicação das Bibliotecas:**
- **mongoose**: Object Document Mapper para MongoDB
  - Fornece schema, validações, middleware e métodos
  - Gerencia relacionamentos entre documentos
  - Implementa padrões de design para MongoDB
- **bcrypt**: Biblioteca de criptografia de senhas
  - Algoritmo bcrypt com salt automático
  - Proteção contra ataques de força bruta
  - Configurável para diferentes níveis de segurança

### **Estrutura do Schema com Validações Avançadas**
```javascript
const esquemaUsuario = new mongoose.Schema({
  nomeUsuario: {
    type: String,
    required: [true, 'Nome de usuário é obrigatório'],
    unique: true,                    // Índice único automático
    trim: true,                      // Remove espaços em branco
    minlength: [3, 'Mínimo 3 caracteres'],
    maxlength: [25, 'Máximo 25 caracteres']
  },
  email: {
    type: String,
    required: [true, 'Email é obrigatório'],
    unique: true,
    lowercase: true,                 // Converte para minúsculas
    match: [/^\w+([.-]?\w+)*@\w+([.-]?\w+)*(\.\w{2,3})+$/, 'Email inválido']
    // Regex para validação de email
  },
  senha: {
    type: String,
    required: [true, 'Senha é obrigatória'],
    minlength: [6, 'Mínimo 6 caracteres']
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
    default: 'aspirante',
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
  timestamps: true  // Adiciona createdAt e updatedAt automaticamente
});
```

**Detalhes das Validações:**
- **required**: Array com valor booleano e mensagem personalizada
- **unique**: Cria índice único no banco de dados
- **trim**: Remove espaços em branco no início e fim
- **minlength/maxlength**: Validação de comprimento com mensagens
- **match**: Validação com expressão regular
- **enum**: Lista de valores permitidos
- **default**: Valor padrão (pode ser função)

### **Campos Virtuais (Computed Fields)**
```javascript
// Campo virtual que calcula nível baseado na experiência
esquemaUsuario.virtual('nivelCalculado').get(function () {
  return Math.floor(this.experiencia / 100) + 1;
  // Fórmula: cada 100 XP = 1 nível
});

// Campo virtual para título baseado no nível
esquemaUsuario.virtual('tituloCalculado').get(function () {
  const nivel = this.nivelCalculado;
  if (nivel >= 31) return 'Conjurador Supremo';
  if (nivel >= 21) return 'Guardião do Librarium';
  if (nivel >= 11) return 'Caçador';
  return 'Aspirante';
});
```

**Funcionamento dos Campos Virtuais:**
- **Não são salvos no banco**: Calculados dinamicamente
- **Executados quando acessados**: Lazy evaluation
- **Acesso via getter**: `usuario.nivelCalculado`
- **Performance**: Cálculo sob demanda

### **Middleware (Hooks) - Criptografia de Senha**
```javascript
// Hook executado ANTES de salvar (pre-save)
esquemaUsuario.pre('save', async function (next) {
  // Só criptografa se a senha foi modificada
  if (!this.isModified('senha')) {
    return next();
  }

  try {
    // Gera salt com 12 rounds (custo computacional)
    const sal = await bcrypt.genSalt(12);
    // Hash da senha com o salt gerado
    this.senha = await bcrypt.hash(this.senha, sal);
    next();
  } catch (erro) {
    next(erro); // Passa erro para o próximo middleware
  }
});
```

**Explicação Técnica Detalhada:**
- **bcrypt.genSalt(12)**:
  - **Custo 12** = 2^12 = 4.096 iterações
  - **Maior segurança** = mais lento para computar
  - **Recomendado** para produção
  - **Salt único** para cada senha
- **bcrypt.hash()**:
  - Aplica o algoritmo bcrypt com o salt
  - Resultado: hash + salt + custo em uma string
  - Formato: `$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LewdBPj4J/HS.iQm.`
- **this.isModified()**:
  - Verifica se o campo foi alterado na sessão atual
  - Evita re-criptografia desnecessária
  - Método do Mongoose para controle de modificações

**Fluxo de Criptografia:**
1. **Verificação**: Campo senha foi modificado?
2. **Geração de Salt**: 12 rounds de complexidade
3. **Hash**: Aplicação do algoritmo bcrypt
4. **Armazenamento**: Hash + salt no campo senha
5. **Continuidade**: Chama próximo middleware

### **Middleware - Atualização Automática de Nível**
```javascript
esquemaUsuario.pre('save', function (next) {
  // Atualiza campos baseados nos virtuais
  this.nivel = this.nivelCalculado;
  this.titulo = this.tituloCalculado;

  // Lógica de avatar baseada no nível
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
```

**Ordem de Execução dos Hooks:**
1. **Primeiro hook**: Criptografia de senha
2. **Segundo hook**: Atualização de nível/avatar
3. **Salvamento**: No banco de dados
4. **Pós-hooks**: Se existirem (post-save)

**Lógica de Avatars por Nível:**
- **Nível 1-10**: "aspirante" (iniciante)
- **Nível 11-20**: "cacador" (intermediário)
- **Nível 21-30**: "guardiao" (avançado)
- **Nível 31+**: "conjurador" (mestre)

### **Métodos de Instância - Comparação de Senha**
```javascript
esquemaUsuario.methods.compararSenha = async function (senhaCandidata) {
  // bcrypt.compare() compara senha em texto plano com hash
  return bcrypt.compare(senhaCandidata, this.senha);
};
```

**Funcionamento Interno Detalhado:**
1. **Extração do Salt**: bcrypt extrai salt do hash armazenado
2. **Aplicação do Algoritmo**: Aplica bcrypt na senha candidata
3. **Comparação Segura**: Compara hashes resultantes
4. **Proteção contra Timing Attacks**: Tempo de resposta constante

**Exemplo de Uso:**
```javascript
// No processo de login
const usuario = await Usuario.findOne({ email: emailDigitado });
if (usuario && await usuario.compararSenha(senhaDigitada)) {
  // Login bem-sucedido
  console.log('Senha correta!');
} else {
  // Login falhou
  console.log('Email ou senha incorretos');
}
```

### **Métodos de Instância - Adição de Experiência**
```javascript
esquemaUsuario.methods.adicionarExperiencia = function (quantidade) {
  this.experiencia += quantidade;
  // Retorna Promise do save() para permitir await
  return this.save();
};
```

**Fluxo de Execução Detalhado:**
1. **Incremento**: Adiciona XP ao campo experiência
2. **Chamada do Save**: Dispara todos os hooks pre-save
3. **Hook de Nível**: Atualiza nível, título e avatar automaticamente
4. **Salvamento**: Persiste todas as mudanças no banco
5. **Retorno**: Promise resolvida com usuário atualizado

**Exemplo de Uso:**
```javascript
// Adicionar XP por completar hábito
try {
  await usuario.adicionarExperiencia(20);
  console.log(`XP adicionado! Novo nível: ${usuario.nivel}`);
  console.log(`Novo título: ${usuario.titulo}`);
  console.log(`Novo avatar: ${usuario.avatar}`);
} catch (erro) {
  console.error('Erro ao adicionar XP:', erro);
}
```

### **Métodos de Instância - Atualização de Atividade**
```javascript
esquemaUsuario.methods.atualizarUltimaAtividade = function () {
  this.ultimaAtividade = new Date();
  return this.save();
};
```

**Casos de Uso:**
- **Login**: Atualiza atividade ao fazer login
- **Ações**: Atualiza ao executar ações no sistema
- **Heartbeat**: Atualiza periodicamente para manter sessão ativa

### **Sistema de Índices MongoDB**
```javascript
// Índices criados automaticamente pelo Mongoose
// baseado nas configurações do schema

// Índice único para email
{ email: 1 }

// Índice único para nomeUsuario
{ nomeUsuario: 1 }

// Índice para consultas por nível
{ nivel: 1 }

// Índice para consultas por experiência
{ experiencia: 1 }
```

**Tipos de Índice:**
- **1**: Ordenação ascendente
- **-1**: Ordenação descendente
- **unique: true**: Índice único (previne duplicatas)
- **sparse**: Índice que ignora documentos sem o campo

### **Validações de Segurança**
```javascript
// Validação de email com regex robusta
match: [/^\w+([.-]?\w+)*@\w+([.-]?\w+)*(\.\w{2,3})+$/, 'Email inválido']

// Validação de comprimento de senha
minlength: [6, 'Senha deve ter pelo menos 6 caracteres']

// Validação de nome de usuário
minlength: [3, 'Nome de usuário deve ter pelo menos 3 caracteres'],
maxlength: [25, 'Nome de usuário deve ter no máximo 25 caracteres']
```

**Regex de Email Explicada:**
- **^\w+**: Começa com um ou mais caracteres alfanuméricos
- **([.-]?\w+)\***: Seguido por zero ou mais grupos de ponto/hífen + caracteres
- **@**: Símbolo @ obrigatório
- **\w+**: Domínio principal
- **([.-]?\w+)\***: Subdomínios opcionais
- **(\.\w{2,3})+**: Extensões de domínio (.com, .org, etc.)

### **Exemplos de Uso Avançado**

#### **Criação com Validações e Tratamento de Erros**
```javascript
try {
  const novoUsuario = new Usuario({
    nomeUsuario: 'usuario123',
    email: 'usuario@email.com',
    senha: 'senha123'
  });
  
  // Validações automáticas executam aqui
  await novoUsuario.save();
  
  console.log('Usuário criado com sucesso!');
  console.log('ID:', novoUsuario._id);
  console.log('Nível inicial:', novoUsuario.nivel);
  console.log('Título:', novoUsuario.titulo);
  console.log('Avatar:', novoUsuario.avatar);
  
} catch (erro) {
  if (erro.code === 11000) {
    console.log('Erro: Usuário ou email já existe no sistema');
  } else if (erro.name === 'ValidationError') {
    console.log('Erro de validação:', erro.message);
    // Lista todos os erros de validação
    Object.keys(erro.errors).forEach(campo => {
      console.log(`${campo}: ${erro.errors[campo].message}`);
    });
  } else {
    console.log('Erro inesperado:', erro.message);
  }
}
```

#### **Operações com Transações para Consistência**
```javascript
const session = await mongoose.startSession();
session.startTransaction();

try {
  // Adiciona experiência
  await usuario.adicionarExperiencia(50);
  
  // Verifica se desbloqueou nova conquista
  const conquistas = await Conquista.find({ 
    idUsuario: usuario._id,
    desbloqueada: false 
  });
  
  for (const conquista of conquistas) {
    if (conquista.verificarDesbloqueio(usuario)) {
      conquista.desbloqueada = true;
      conquista.desbloqueadaEm = new Date();
      await conquista.save({ session });
      
      // Adiciona XP da conquista
      await usuario.adicionarExperiencia(conquista.experienciaRecompensa);
    }
  }
  
  await session.commitTransaction();
  console.log('Transação concluída com sucesso!');
  
} catch (erro) {
  await session.abortTransaction();
  console.error('Erro na transação:', erro);
  throw erro;
} finally {
  session.endSession();
}
```

#### **Consultas com Agregação para Estatísticas**
```javascript
const estatisticasUsuarios = await Usuario.aggregate([
  // Filtra usuários ativos
  { $match: { 
    ultimaAtividade: { $gte: new Date(Date.now() - 30 * 24 * 60 * 60 * 1000) }
  }},
  
  // Agrupa por avatar
  { $group: {
    _id: '$avatar',
    total: { $sum: 1 },
    mediaXP: { $avg: '$experiencia' },
    mediaNivel: { $avg: '$nivel' },
    totalXP: { $sum: '$experiencia' }
  }},
  
  // Ordena por total de usuários
  { $sort: { total: -1 } },
  
  // Projeta campos formatados
  { $project: {
    avatar: '$_id',
    totalUsuarios: '$total',
    experienciaMedia: { $round: ['$mediaXP', 2] },
    nivelMedio: { $round: ['$mediaNivel', 2] },
    experienciaTotal: '$totalXP'
  }}
]);
```

### **Considerações de Performance**

#### **Índices Otimizados**
```javascript
// Índices para consultas frequentes
{ email: 1 }                    // Login por email
{ nomeUsuario: 1 }              // Busca por nome de usuário
{ nivel: 1, experiencia: -1 }   // Ranking de usuários
{ ultimaAtividade: -1 }         // Usuários mais ativos
```

#### **Populações Seletivas**
```javascript
// Popula apenas campos necessários
const usuario = await Usuario.findById(id)
  .populate('habitos', 'titulo categoria ativo')
  .populate('conquistas', 'titulo icone')
  .select('nomeUsuario nivel avatar experiencia');

// Popula com filtros
const mensagens = await Mensagem.find({ destinatario: usuarioId })
  .populate({
    path: 'remetente',
    select: 'nomeUsuario avatar nivel',
    match: { ativo: true }
  })
  .limit(20);
```

### **Tratamento de Erros Específicos**

#### **Códigos de Erro MongoDB**
```javascript
// 11000: Duplicate key error (campo único)
if (erro.code === 11000) {
  const campo = Object.keys(erro.keyPattern)[0];
  console.log(`Erro: ${campo} já existe no sistema`);
}

// 121: Document validation failed
if (erro.code === 121) {
  console.log('Erro de validação do documento');
}

// 16755: Invalid BSON
if (erro.code === 16755) {
  console.log('Erro de formato de dados inválido');
}
```

#### **Erros de Validação do Mongoose**
```javascript
if (erro.name === 'ValidationError') {
  const erros = [];
  Object.keys(erro.errors).forEach(campo => {
    erros.push({
      campo: campo,
      mensagem: erro.errors[campo].message,
      valor: erro.errors[campo].value
    });
  });
  console.log('Erros de validação:', erros);
}
```

---

*Documentação técnica detalhada do modelo Usuario - Sistema Librarium*
