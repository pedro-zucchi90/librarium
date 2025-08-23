# 🏆 Tela de Conquistas - Librarium

## 📱 Visão Geral

A tela de conquistas (`AchievementScreen`) é uma interface completa para visualizar e gerenciar as conquistas do usuário no Librarium. Ela apresenta um design dark fantasy inspirado em Hollow Knight e Devil May Cry.

## ✨ Funcionalidades

### 🎯 Principais
- **Listagem de Conquistas**: Exibe todas as conquistas disponíveis
- **Filtros Avançados**: Por categoria e raridade
- **Progresso Visual**: Barra de progresso geral
- **Detalhes Interativos**: Modal com informações detalhadas
- **Animações Suaves**: Transições e efeitos visuais

### 🎨 Design
- **Tema Dark Fantasy**: Cores e estilos temáticos
- **Gradientes Dourados**: Para elementos de destaque
- **Ícones Temáticos**: Representação visual das conquistas
- **Estados Visuais**: Diferenciação entre conquistas desbloqueadas e bloqueadas

## 🏗️ Estrutura da Tela

### 📋 Componentes Principais

1. **AppBar**
   - Título: "Relíquias do Caçador"
   - Botão de refresh

2. **Filtros**
   - Dropdown de categorias
   - Dropdown de raridades

3. **Estatísticas**
   - Progresso geral das conquistas
   - Contador de desbloqueadas/total

4. **Lista de Conquistas**
   - Cards individuais para cada conquista
   - Status visual (desbloqueada/bloqueada)
   - Informações de recompensa

5. **Modal de Detalhes**
   - Informações completas da conquista
   - Ícone grande
   - Status detalhado

## 🔧 Integração com Backend

### 📡 API Endpoints Utilizados
- `GET /api/conquistas` - Listar conquistas do usuário
- `GET /api/conquistas/categoria/:categoria` - Filtrar por categoria
- `GET /api/conquistas/raridade/:raridade` - Filtrar por raridade

### 🔄 Fluxo de Dados
1. **Carregamento Inicial**: Chama API para buscar conquistas
2. **Fallback**: Se API falhar, carrega conquistas padrão
3. **Filtros**: Aplicados localmente para performance
4. **Atualização**: Botão refresh para recarregar dados

## 🎮 Gamificação

### 🏆 Tipos de Conquistas
- **Iniciante**: Primeiras conquistas
- **Persistência**: Sequências de dias
- **Nível**: Baseadas no nível do usuário
- **Perfeição**: Conquistas especiais
- **Criação**: Baseadas em criação de hábitos

### 💎 Raridades
- **Comum**: Conquistas básicas
- **Raro**: Conquistas especiais
- **Épico**: Conquistas difíceis
- **Lendário**: Conquistas únicas

## 🎨 Personalização

### 🎨 Cores e Temas
```dart
// Cores principais
primary: Color(0xFF8B0000) // Vermelho carmesim
secondary: Color(0xFF3B60E4) // Azul etéreo
success: Color(0xFF4CAF50) // Verde sucesso

// Gradientes
gradientGold: LinearGradient(
  colors: [Color(0xFFC0A060), Color(0xFFD4AF37)]
)
```

### 🎭 Estados Visuais
- **Desbloqueada**: Cores vibrantes, ícone de check
- **Bloqueada**: Cores acinzentadas, ícone de cadeado
- **Rara**: Badge especial "RARO"

## 📱 Navegação

### 🔗 Integração com Dashboard
- **Bottom Navigation**: Ícone de troféu na barra inferior
- **Acesso Rápido**: Card clicável no dashboard principal
- **Navegação Programática**: `widget.onTabChanged(3)`

## 🧪 Testes

### ✅ Testes Implementados
- Estado de carregamento
- Exibição de filtros
- Estado vazio
- Interações básicas

### 🧪 Como Executar
```bash
flutter test test/achievement_screen_test.dart
```

## 🚀 Próximas Melhorias

### 🔮 Funcionalidades Futuras
- [ ] Animações de desbloqueio
- [ ] Notificações push para novas conquistas
- [ ] Compartilhamento de conquistas
- [ ] Sons e efeitos sonoros
- [ ] Modo offline completo

### 🎨 Melhorias Visuais
- [ ] Partículas e efeitos especiais
- [ ] Animações mais elaboradas
- [ ] Temas personalizáveis
- [ ] Modo escuro/claro

## 📝 Notas Técnicas

### 🔧 Dependências
- `flutter/material.dart` - Widgets básicos
- `../core/constants.dart` - Constantes do app
- `../models/achievement.dart` - Modelo de dados
- `../services/api_service.dart` - Serviços de API
- `../core/theme.dart` - Temas e estilos

### ⚡ Performance
- **Filtros Locais**: Aplicados no cliente para rapidez
- **Lazy Loading**: Lista com scroll infinito
- **Cache**: Dados mantidos em memória
- **Otimização**: Widgets otimizados para rebuild

---

**🎮 Que a caçada pelas conquistas comece!** ⚔️

