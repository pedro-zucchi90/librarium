# Librarium - App de Gerenciamento de Hábitos

## 📱 Sobre o Projeto

Librarium é um aplicativo móvel desenvolvido em Flutter para ajudar usuários a criar, gerenciar e acompanhar seus hábitos diários. O app oferece uma interface intuitiva para estabelecer rotinas saudáveis e monitorar o progresso ao longo do tempo.

## ✨ Funcionalidades

### 🔐 Autenticação
- Login e registro de usuários
- Recuperação de senha
- Sessões persistentes

### 📊 Dashboard
- Visão geral dos hábitos do dia
- Resumo de progresso
- Estatísticas em tempo real

### ✅ Gerenciamento de Hábitos
- Criação de novos hábitos
- Categorização por tipo
- Definição de frequência semanal
- Configuração de lembretes
- Marcação de conclusão

### 📈 Estatísticas e Relatórios
- Progresso semanal/mensal
- Taxa de sucesso por hábito
- Sequências de dias consecutivos
- Análise por categoria

### 👤 Perfil do Usuário
- Informações pessoais
- Histórico de atividades
- Configurações do app
- Logout seguro

## 🏗️ Arquitetura do Projeto

```
lib/
├── main.dart                 # Ponto de entrada da aplicação
├── core/                     # Configurações globais
│   ├── theme.dart           # Temas e estilos
│   ├── constants.dart       # Constantes globais
│   └── utils.dart           # Funções auxiliares
├── models/                   # Modelos de dados
│   ├── user.dart            # Modelo de usuário
│   ├── habit.dart           # Modelo de hábito
│   └── habit_log.dart       # Modelo de log de hábitos
├── services/                 # Comunicação com API
│   ├── auth_service.dart    # Serviço de autenticação
│   └── habit_service.dart   # Serviço de hábitos
├── screens/                  # Telas principais
│   ├── login_screen.dart    # Tela de login
│   ├── register_screen.dart # Tela de registro
│   ├── dashboard_screen.dart # Dashboard principal
│   ├── habit_screen.dart    # Gerenciamento de hábitos
│   ├── stats_screen.dart    # Estatísticas
│   └── profile_screen.dart  # Perfil do usuário
├── widgets/                  # Componentes reutilizáveis
│   └── custom_button.dart   # Botão customizado
└── database/                 # Persistência local
    └── database_helper.dart  # Helper do banco SQLite
```

## 🚀 Funcionalidades

### 🎯 **MVP (Versão Essencial)**
- **Splash Screen**: Tela inicial com tema dark/fantasy e verificação de login
- **Autenticação de Usuários**: Login e registro com validação e seleção de avatar
- **Dashboard "Salão do Caçador"**: Visão geral com XP, nível e barra de progresso
- **Gerenciamento de Hábitos**: Criar, editar, excluir e visualizar hábitos com ícones
- **Detalhes do Hábito**: Histórico de progresso, estatísticas e botão "Marcar como feito"
- **Perfil do Usuário**: Avatar, XP, nível atual e evolução do personagem
- **Tema Dark/Fantasy**: Interface com cores escuras e elementos de fantasia

### 📊 **Funcionalidades Intermediárias**
- **Estatísticas "Profecia dos Gráficos"**: Gráficos de progresso e desempenho
- **Sistema de XP e Níveis**: Progressão gamificada do usuário
- **Avatares Personalizáveis**: Seleção de personagens para o perfil

### ⚔️ **Funcionalidades Avançadas (Futuras)**
- **Conquistas e Relíquias**: Sistema de recompensas por metas atingidas
- **Ranking Global**: Comparação com outros usuários
- **Customização de Avatar**: Skins e itens desbloqueáveis
- **Modo Multiplayer**: Desafios e batalhas entre usuários
- **Loja do Abismo**: Itens cosméticos comprados com XP
- **Eventos Especiais**: Missões temporárias com recompensas exclusivas

## 🚀 Tecnologias Utilizadas

- **Flutter**: Framework de desenvolvimento mobile
- **Dart**: Linguagem de programação
- **SQLite**: Banco de dados local
- **Provider**: Gerenciamento de estado
- **Material Design**: Design system

## 📋 Pré-requisitos

- Flutter SDK 3.0.0 ou superior
- Dart SDK 3.0.0 ou superior
- Android Studio / VS Code
- Emulador Android ou dispositivo físico

## 🛠️ Instalação

1. **Clone o repositório**
   ```bash
   git clone https://github.com/seu-usuario/librarium.git
   cd librarium
   ```

2. **Instale as dependências**
   ```bash
   flutter pub get
   ```

3. **Execute o projeto**
   ```bash
   flutter run
   ```

## 📱 Como Usar

### Primeiro Acesso
1. Abra o app e aguarde a Splash Screen
2. Toque em "Criar Conta" para registrar
3. Escolha seu avatar preferido
4. Preencha suas informações pessoais
5. Faça login com suas credenciais
6. Explore o "Salão do Caçador" (Dashboard)

### Criando Hábitos
1. No "Salão do Caçador", toque na aba de Hábitos
2. Toque no botão "+" para criar um novo hábito
3. Preencha o título e descrição
4. Selecione a categoria com ícone visual
5. Defina a frequência semanal (1-7x por semana)
6. Escolha os dias da semana
7. Salve o hábito

### Acompanhando Progresso
1. Use o "Salão do Caçador" para ver o resumo diário e XP atual
2. Toque em um hábito para ver seus detalhes e histórico
3. Use o botão "Marcar como Concluído" para ganhar XP
4. Visualize estatísticas na "Profecia dos Gráficos"
5. Acompanhe seu nível e progressão no perfil
6. Monitore sequências e metas de hábitos

## 🔧 Configuração

### Variáveis de Ambiente
Crie um arquivo `.env` na raiz do projeto:
```env
API_BASE_URL=https://sua-api.com
API_KEY=sua-chave-api
```

### Banco de Dados
O app utiliza SQLite localmente. As tabelas são criadas automaticamente na primeira execução.

## 📊 Estrutura do Banco de Dados

### Tabela: users
- `id`: Identificador único
- `email`: Email do usuário
- `name`: Nome completo
- `created_at`: Data de criação
- `last_login`: Último login

### Tabela: habits
- `id`: Identificador único
- `user_id`: Referência ao usuário
- `title`: Título do hábito
- `description`: Descrição detalhada
- `category`: Categoria do hábito
- `frequency`: Frequência semanal
- `days_of_week`: Dias da semana
- `reminder_time`: Horário do lembrete
- `is_active`: Status ativo/inativo
- `created_at`: Data de criação
- `last_completed`: Última conclusão

### Tabela: habit_logs
- `id`: Identificador único
- `habit_id`: Referência ao hábito
- `user_id`: Referência ao usuário
- `completed_at`: Data de conclusão
- `notes`: Observações
- `rating`: Avaliação (1-5)

## 🎨 Temas e Estilos

O app suporta temas claro e escuro, com cores personalizáveis definidas em `lib/core/constants.dart`.

### Cores Principais
- **Primary**: Azul (#2196F3)
- **Secondary**: Ciano (#03DAC6)
- **Success**: Verde (#4CAF50)
- **Warning**: Laranja (#FF9800)
- **Error**: Vermelho (#B00020)

## 📱 Telas e Navegação

### Navegação Principal
- **Dashboard**: Visão geral e resumo
- **Hábitos**: Gerenciamento de hábitos
- **Estatísticas**: Relatórios e métricas
- **Perfil**: Configurações e informações

### Fluxo de Navegação
```
Login → Dashboard → [Hábitos | Estatísticas | Perfil]
  ↓
Registro → Dashboard
```

## 🔒 Segurança

- Senhas são validadas localmente
- Dados sensíveis são armazenados localmente
- Sessões são gerenciadas com segurança
- Logout limpa dados da sessão

## 📈 Funcionalidades Futuras

- [ ] Sincronização com nuvem
- [ ] Notificações push
- [ ] Compartilhamento de progresso
- [ ] Gamificação e conquistas
- [ ] Backup e restauração
- [ ] Temas personalizáveis
- [ ] Modo offline completo
- [ ] Integração com wearables

## 🐛 Solução de Problemas

### Erro de Dependências
```bash
flutter clean
flutter pub get
```

### Erro de Banco de Dados
```bash
# Desinstale o app e reinstale
flutter run
```

### Problemas de Performance
- Verifique se há muitos hábitos ativos
- Limpe logs antigos periodicamente
- Use o modo de economia de bateria

## 🤝 Contribuição

1. Faça um fork do projeto
2. Crie uma branch para sua feature
3. Commit suas mudanças
4. Push para a branch
5. Abra um Pull Request

## 📄 Licença

Este projeto está sob a licença MIT. Veja o arquivo [LICENSE](LICENSE) para mais detalhes.

## 👥 Autores

- **Seu Nome** - *Desenvolvimento inicial* - [seu-usuario](https://github.com/seu-usuario)

## 🙏 Agradecimentos

- Comunidade Flutter
- Material Design
- Contribuidores do projeto

## 📞 Suporte

Para suporte, entre em contato:
- Email: seu-email@exemplo.com
- Issues: [GitHub Issues](https://github.com/seu-usuario/librarium/issues)

---

**Librarium** - Transformando hábitos em conquistas! 🚀
