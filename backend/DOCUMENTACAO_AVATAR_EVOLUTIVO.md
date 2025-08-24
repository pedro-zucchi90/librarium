# 🎭 Sistema de Avatar Evolutivo - Librarium

## 📋 Visão Geral

O sistema de Avatar Evolutivo do Librarium permite que os usuários vejam seus avatares evoluírem visualmente conforme progridem no sistema de hábitos. O avatar evolui baseado em:

- **Nível do usuário** (XP acumulado)
- **Conquistas desbloqueadas**
- **Sequências de hábitos**
- **Eficiência e consistência**

## 🎯 Funcionalidades Principais

### 1. Evolução Automática do Avatar

#### Níveis de Avatar
- **Aspirante** (Nível 1-10): Avatar básico com equipamentos simples
- **Caçador** (Nível 11-20): Avatar com equipamentos de nível 1
- **Guardião** (Nível 21-30): Avatar com equipamentos de nível 2
- **Conjurador** (Nível 31-39): Avatar com equipamentos de nível 3
- **Conjurador Avançado** (Nível 40-49): Avatar com equipamentos de nível 4
- **Conjurador Supremo** (Nível 50+): Avatar com equipamentos de nível 5

#### Estágios de Evolução
- **Inicial**: Primeira forma do avatar
- **Intermediária**: Forma evoluída
- **Evoluída**: Forma avançada
- **Avançada**: Forma superior
- **Suprema**: Forma máxima

### 2. Sistema de Equipamentos

#### Categorias de Equipamento
- **Arma**: Espadas de diferentes níveis e raridades
- **Armadura**: Proteções variadas
- **Acessório**: Coroas e itens especiais
- **Aura**: Efeitos visuais baseados no nível
- **Partículas**: Efeitos especiais

#### Desbloqueios Automáticos
- **Baseados em Nível**: Equipamentos desbloqueados conforme o usuário sobe de nível
- **Baseados em Conquistas**: Equipamentos especiais por conquistas épicas e lendárias
- **Baseados em Sequências**: Equipamentos por manter sequências longas
- **Baseados em XP**: Equipamentos por acumular experiência

### 3. Efeitos Visuais

#### Sistema de Aura
- **Nenhuma**: Sem efeito visual
- **Básica**: Aura sutil (nível 2+)
- **Elemental**: Aura moderada (nível 3+)
- **Mágica**: Aura intensa (nível 4+)
- **Divina**: Aura máxima (nível 5+)

#### Sistema de Partículas
- **Nenhuma**: Sem partículas
- **Poeira**: Partículas básicas (nível 2+)
- **Faíscas**: Partículas moderadas (nível 3+)
- **Estrelas**: Partículas intensas (nível 4+)

## 🔧 API Endpoints

### Avatar Routes (`/api/avatar`)

#### POST `/evolucao/verificar`
Verifica e aplica evolução automática do avatar.

**Resposta de Sucesso:**
```json
{
  "sucesso": true,
  "mensagem": "🎭 Avatar evoluiu! 2 mudanças aplicadas",
  "evolucoes": [
    {
      "tipo": "nivel",
      "descricao": "Avatar evoluiu para Caçador!",
      "nivel": 1
    }
  ],
  "avatar": { ... },
  "personalizacao": { ... }
}
```

#### GET `/estatisticas`
Obtém estatísticas completas do avatar.

**Resposta:**
```json
{
  "sucesso": true,
  "estatisticas": {
    "avatar": {
      "tipo": "cacador",
      "nivel": 1,
      "evolucao": "inicial",
      "desbloqueadoEm": "2024-01-01T00:00:00.000Z"
    },
    "equipamentos": { ... },
    "efeitos": { ... },
    "progresso": { ... }
  }
}
```

#### GET `/tema`
Obtém tema visual baseado no avatar atual.

**Resposta:**
```json
{
  "sucesso": true,
  "tema": {
    "corPrimaria": "#059669",
    "corSecundaria": "#10B981",
    "corDestaque": "#34D399",
    "gradiente": "linear-gradient(135deg, #059669, #10B981)"
  },
  "avatar": { ... }
}
```

#### GET `/progresso`
Obtém progresso de evolução do avatar.

**Resposta:**
```json
{
  "sucesso": true,
  "progresso": {
    "evolucao": {
      "nivelAtual": 1,
      "nivelMaximo": 5,
      "proximaEvolucao": {
        "nivel": 2,
        "nome": "Guardião",
        "requisito": "Nível 21"
      },
      "porcentagem": 20
    },
    "equipamentos": {
      "total": 3,
      "totalMaximo": 15,
      "porcentagem": 20,
      "porNivel": { "1": 3, "2": 0, "3": 0, "4": 0, "5": 0 }
    }
  }
}
```

#### GET `/historico`
Obtém histórico de evoluções e desbloqueios.

#### GET `/proximos-desbloqueios`
Obtém próximos desbloqueios disponíveis.

## 🎨 Temas Visuais

### Cores por Tipo de Avatar

#### Aspirante
- **Primária**: #6B7280 (Cinza)
- **Secundária**: #9CA3AF (Cinza claro)
- **Destaque**: #D1D5DB (Cinza muito claro)

#### Caçador
- **Primária**: #059669 (Verde escuro)
- **Secundária**: #10B981 (Verde)
- **Destaque**: #34D399 (Verde claro)

#### Guardião
- **Primária**: #1D4ED8 (Azul escuro)
- **Secundária**: #3B82F6 (Azul)
- **Destaque**: #60A5FA (Azul claro)

#### Conjurador
- **Primária**: #7C3AED (Roxo)
- **Secundária**: #8B5CF6 (Roxo claro)
- **Destaque**: #A78BFA (Roxo muito claro)

#### Conjurador Avançado
- **Primária**: #DC2626 (Vermelho escuro)
- **Secundária**: #EF4444 (Vermelho)
- **Destaque**: #F87171 (Vermelho claro)

#### Conjurador Supremo
- **Primária**: #F59E0B (Amarelo escuro)
- **Secundária**: #FBBF24 (Amarelo)
- **Destaque**: #FCD34D (Amarelo claro)

## 🚀 Como Usar

### 1. Verificação Automática
O sistema verifica automaticamente a evolução do avatar a cada 5 minutos.

### 2. Verificação Manual
```javascript
// Verificar evolução manualmente
const response = await fetch('/api/avatar/evolucao/verificar', {
  method: 'POST',
  headers: {
    'Authorization': `Bearer ${token}`,
    'Content-Type': 'application/json'
  }
});
```

### 3. Obter Estatísticas
```javascript
// Obter estatísticas do avatar
const response = await fetch('/api/avatar/estatisticas', {
  headers: {
    'Authorization': `Bearer ${token}`
  }
});
```

### 4. Obter Tema Visual
```javascript
// Obter tema baseado no avatar
const response = await fetch('/api/avatar/tema', {
  headers: {
    'Authorization': `Bearer ${token}`
  }
});
```

## 🔄 Integração com Outros Sistemas

### Sistema de Conquistas
- Desbloqueia equipamentos especiais
- Fornece recompensas visuais
- Sincroniza com progresso do usuário

### Sistema de Níveis
- Evolução automática baseada em XP
- Desbloqueios progressivos
- Sincronização em tempo real

### Sistema de Hábitos
- Base para cálculos de eficiência
- Influencia na evolução do avatar
- Determina desbloqueios de equipamentos

## 📊 Métricas e Analytics

### Dados Coletados
- Tempo para cada evolução
- Equipamentos mais desbloqueados
- Padrões de uso
- Eficiência do sistema

### Relatórios Disponíveis
- Progresso de evolução
- Estatísticas de equipamentos
- Histórico de mudanças
- Análise de tendências

## 🛠️ Configuração e Personalização

### Variáveis de Ambiente
```env
# Configurações do avatar
AVATAR_EVOLUCAO_AUTOMATICA=true
AVATAR_VERIFICACAO_INTERVALO=300000
AVATAR_MAX_NIVEL=5
AVATAR_EFEITOS_ATIVOS=true
```

### Configurações do Banco
- **Coleção**: `usuarios`
- **Campos**: `avatar`, `personalizacaoAvatar`
- **Índices**: Otimizados para consultas de evolução

## 🔮 Roadmap Futuro

### Versão 1.1
- [ ] Animações de evolução
- [ ] Sons de desbloqueio
- [ ] Mais tipos de equipamentos

### Versão 1.2
- [ ] Customização avançada
- [ ] Temas sazonais
- [ ] Eventos especiais

### Versão 2.0
- [ ] Avatar 3D
- [ ] Realidade aumentada
- [ ] Integração com wearables

## 📝 Notas de Implementação

### Performance
- Verificações assíncronas
- Cache de temas visuais
- Otimização de consultas

### Segurança
- Validação de dados
- Autenticação obrigatória
- Rate limiting aplicado

### Escalabilidade
- Arquitetura modular
- Serviços independentes
- Banco de dados otimizado

---

**Desenvolvido para o Librarium - Sistema de Gerenciamento de Hábitos** 🗡️
