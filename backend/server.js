const express = require('express');
const cors = require('cors');
const helmet = require('helmet');
const rateLimit = require('express-rate-limit');
require('dotenv').config();

const conectarBancoDados = require('./config/db');
const rotasAuth = require('./routes/authRoutes');
const rotasHabitos = require('./routes/habitRoutes');
const rotasUsuarios = require('./routes/userRoutes');
const rotasEstatisticas = require('./routes/statsRoutes');
const rotasLoja = require('./routes/shopRoutes');
const rotasMultiplayer = require('./routes/multiplayerRoutes');
const rotasIntegracao = require('./routes/integrationRoutes');

const app = express();
const PORT = process.env.PORT || 3000;

// Middleware de segurança
app.use(helmet());

// Limitação de taxa
const limitador = rateLimit({
  windowMs: process.env.RATE_LIMIT_WINDOW_MS || 15 * 60 * 1000, // 15 minutos
  max: process.env.RATE_LIMIT_MAX_REQUESTS || 100, // limitar cada IP a 100 requisições por janela
  message: {
    erro: 'Muitas tentativas',
    mensagem: '⚔️ Você está fazendo muitas requisições. Tente novamente em alguns minutos.'
  }
});
app.use(limitador);

// Configuração CORS
app.use(cors({
  origin: process.env.FRONTEND_URL || 'http://localhost:3001',
  credentials: true
}));

// Middleware de parsing do corpo da requisição
app.use(express.json({ limit: '10mb' }));
app.use(express.urlencoded({ extended: true }));

// Conexão com banco de dados
conectarBancoDados();

// Rotas
app.use('/api/auth', rotasAuth);
app.use('/api/habitos', rotasHabitos);
app.use('/api/usuarios', rotasUsuarios);
app.use('/api/estatisticas', rotasEstatisticas);
app.use('/api/loja', rotasLoja);
app.use('/api/multiplayer', rotasMultiplayer);
app.use('/api/integracao', rotasIntegracao);

// Endpoint de verificação de saúde
app.get('/api/saude', (req, res) => {
  res.json({ 
    status: 'ativo', 
    mensagem: '⚔️ O servidor do Librarium está funcionando...',
    timestamp: new Date().toISOString(),
    versao: '1.0.0'
  });
});

// Middleware de tratamento de erros
app.use((err, req, res, next) => {
  console.error('💥 Erro:', err.stack);
  res.status(500).json({ 
    erro: 'Algo deu errado nas sombras...',
    mensagem: process.env.NODE_ENV === 'development' ? err.message : 'Erro interno do servidor'
  });
});

// Tratador 404
app.use('*', (req, res) => {
  res.status(404).json({ 
    erro: 'Caminho não encontrado',
    mensagem: '🌑 Este caminho não existe no Librarium...' 
  });
});

app.listen(PORT, () => {
  console.log(`🗡️ Servidor do Librarium rodando na porta ${PORT}`);
  console.log(`🎮 Pronto para a caçada...`);
  console.log(`📚 Acesse: http://localhost:${PORT}/api/saude`);
});

module.exports = app;
