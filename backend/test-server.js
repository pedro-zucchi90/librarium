// Teste simples do servidor
console.log('🔮 Testando o servidor do Librarium...');

try {
  // Verificar se as dependências estão instaladas
  require('express');
  require('mongoose');
  require('bcrypt');
  require('jsonwebtoken');
  require('cors');
  require('helmet');
  require('express-rate-limit');
  require('dotenv');
  
  console.log('✅ Todas as dependências foram encontradas');
  
  // Testar carregamento dos modelos
  const Usuario = require('./models/User');
  const Habito = require('./models/Habit');
  const Progresso = require('./models/Progress');
  const Conquista = require('./models/Achievement');
  
  console.log('✅ Todos os modelos carregados com sucesso');
  
  // Testar configurações
  const conectarBancoDados = require('./config/db');
  const { gerarToken, verificarToken } = require('./config/jwt');
  
  console.log('✅ Configurações carregadas com sucesso');
  
  // Testar middleware
  const { autenticarUsuario } = require('./middleware/auth');
  
  console.log('✅ Middleware carregado com sucesso');
  
  // Testar rotas
  const rotasAuth = require('./routes/authRoutes');
  const rotasHabitos = require('./routes/habitRoutes');
  const rotasUsuarios = require('./routes/userRoutes');
  const rotasEstatisticas = require('./routes/statsRoutes');
  
  console.log('✅ Todas as rotas carregadas com sucesso');
  
  console.log('🎮 Servidor pronto para iniciar!');
  console.log('📚 Execute: npm start ou node server.js');
  
} catch (erro) {
  console.error('💀 Erro ao testar o servidor:', erro.message);
  console.error('Stack:', erro.stack);
  process.exit(1);
}
