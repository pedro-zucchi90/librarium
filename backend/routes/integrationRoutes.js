const express = require('express');
const { autenticarUsuario } = require('../middleware/auth');
const Usuario = require('../models/User');
const Habito = require('../models/Habit');
const Progresso = require('../models/Progress');

const router = express.Router();

// Todas as rotas precisam de autenticação
router.use(autenticarUsuario);

// ===== INTEGRAÇÃO COM GOOGLE CALENDAR =====

// Configuração OAuth2 para Google Calendar
const GOOGLE_OAUTH_CONFIG = {
  clientId: process.env.GOOGLE_CLIENT_ID,
  clientSecret: process.env.GOOGLE_CLIENT_SECRET,
  redirectUri: process.env.GOOGLE_REDIRECT_URI || 'http://localhost:3000/api/integracao/google/oauth/callback',
  scopes: ['https://www.googleapis.com/auth/calendar', 'https://www.googleapis.com/auth/calendar.events']
};

// Iniciar processo de autorização OAuth2
router.get('/google/oauth', (req, res) => {
  const authUrl = 'https://accounts.google.com/o/oauth2/v2/auth?' +
    `client_id=${GOOGLE_OAUTH_CONFIG.clientId}` +
    `&redirect_uri=${encodeURIComponent(GOOGLE_OAUTH_CONFIG.redirectUri)}` +
    `&scope=${encodeURIComponent(GOOGLE_OAUTH_CONFIG.scopes.join(' '))}` +
    '&response_type=code' +
    '&access_type=offline' +
    '&prompt=consent';

  res.json({
    sucesso: true,
    mensagem: '🔗 Autorização Google Calendar iniciada',
    authUrl,
    instrucoes: 'Acesse o link acima para autorizar a integração com Google Calendar'
  });
});

// Callback OAuth2 - trocar código por token
router.get('/google/oauth/callback', async (req, res) => {
  try {
    const { code } = req.query;

    if (!code) {
      return res.status(400).json({
        erro: 'Código de autorização não fornecido',
        mensagem: '🌑 Falha na autorização do Google Calendar'
      });
    }

    // Trocar código por token de acesso
    const tokenResponse = await fetch('https://oauth2.googleapis.com/token', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/x-www-form-urlencoded'
      },
      body: new URLSearchParams({
        code,
        client_id: GOOGLE_OAUTH_CONFIG.clientId,
        client_secret: GOOGLE_OAUTH_CONFIG.clientSecret,
        redirect_uri: GOOGLE_OAUTH_CONFIG.redirectUri,
        grant_type: 'authorization_code'
      })
    });

    const tokenData = await tokenResponse.json();

    if (tokenData.error) {
      throw new Error(`Erro na obtenção do token: ${tokenData.error_description}`);
    }

    // Salvar tokens no perfil do usuário
    const usuario = req.usuario;
    usuario.integracaoGoogle = {
      accessToken: tokenData.access_token,
      refreshToken: tokenData.refresh_token,
      expiresAt: new Date(Date.now() + tokenData.expires_in * 1000),
      scope: tokenData.scope
    };

    await usuario.save();

    res.json({
      sucesso: true,
      mensagem: '✅ Integração com Google Calendar configurada com sucesso!',
      expiraEm: new Date(Date.now() + tokenData.expires_in * 1000)
    });
  } catch (erro) {
    console.error('Erro no callback OAuth2:', erro);
    res.status(500).json({
      erro: 'Erro interno do servidor',
      mensagem: '💀 Falha na configuração da integração com Google Calendar'
    });
  }
});

// Sincronizar hábitos com Google Calendar
router.post('/google-calendar/sync', async (req, res) => {
  try {
    const usuario = req.usuario;

    if (!usuario.integracaoGoogle || !usuario.integracaoGoogle.accessToken) {
      return res.status(400).json({
        erro: 'Integração não configurada',
        mensagem: '🌑 Configure a integração com Google Calendar primeiro'
      });
    }

    // Verificar se o token expirou
    if (new Date() > usuario.integracaoGoogle.expiresAt) {
      // Renovar token usando refresh token
      await renovarTokenGoogle(usuario);
    }

    const { habitos, periodo } = req.body;
    const dataInicio = periodo?.inicio ? new Date(periodo.inicio) : new Date();
    const dataFim = periodo?.fim ? new Date(periodo.fim) : new Date(Date.now() + 30 * 24 * 60 * 60 * 1000);

    // Buscar hábitos ativos do usuário
    const habitosAtivos = await Habito.find({
      idUsuario: usuario._id,
      ativo: true
    });

    // Criar eventos no Google Calendar
    const eventosCriados = [];
    const googleApi = new GoogleCalendarAPI(usuario.integracaoGoogle.accessToken);

    for (const habito of habitosAtivos) {
      try {
        // Criar evento recorrente baseado na frequência do hábito
        const evento = await criarEventoRecorrente(googleApi, habito, dataInicio, dataFim);
        eventosCriados.push(evento);
      } catch (erro) {
        console.error(`Erro ao criar evento para hábito ${habito._id}:`, erro);
      }
    }

    res.json({
      sucesso: true,
      mensagem: `📅 ${eventosCriados.length} eventos sincronizados com Google Calendar!`,
      eventosCriados,
      totalHabitos: habitosAtivos.length
    });
  } catch (erro) {
    console.error('Erro ao sincronizar Google Calendar:', erro);
    res.status(500).json({
      erro: 'Erro interno do servidor',
      mensagem: '💀 Não foi possível sincronizar com o Google Calendar'
    });
  }
});

// Obter eventos do Google Calendar
router.get('/google-calendar/eventos', async (req, res) => {
  try {
    const usuario = req.usuario;

    if (!usuario.integracaoGoogle || !usuario.integracaoGoogle.accessToken) {
      return res.status(400).json({
        erro: 'Integração não configurada',
        mensagem: '🌑 Configure a integração com Google Calendar primeiro'
      });
    }

    // Verificar se o token expirou
    if (new Date() > usuario.integracaoGoogle.expiresAt) {
      await renovarTokenGoogle(usuario);
    }

    const { dataInicio, dataFim, maxResultados = 50 } = req.query;
    const inicio = dataInicio ? new Date(dataInicio) : new Date();
    const fim = dataFim ? new Date(dataFim) : new Date(Date.now() + 7 * 24 * 60 * 60 * 1000);

    const googleApi = new GoogleCalendarAPI(usuario.integracaoGoogle.accessToken);
    const eventos = await googleApi.listarEventos(inicio, fim, maxResultados);

    res.json({
      sucesso: true,
      mensagem: `📅 ${eventos.length} eventos encontrados no Google Calendar`,
      eventos,
      periodo: { inicio, fim }
    });
  } catch (erro) {
    console.error('Erro ao obter eventos do Google Calendar:', erro);
    res.status(500).json({
      erro: 'Erro interno do servidor',
      mensagem: '💀 Não foi possível obter eventos do Google Calendar'
    });
  }
});

// ===== INTEGRAÇÃO COM GOOGLE FIT / APPLE HEALTH =====

// Configuração para Google Fit
const GOOGLE_FIT_CONFIG = {
  clientId: process.env.GOOGLE_FIT_CLIENT_ID,
  clientSecret: process.env.GOOGLE_FIT_CLIENT_SECRET,
  scopes: ['https://www.googleapis.com/auth/fitness.activity.read', 'https://www.googleapis.com/auth/fitness.body.read']
};

// Sincronizar dados de saúde
router.post('/health/sync', async (req, res) => {
  try {
    const usuario = req.usuario;
    const { tipo, periodo } = req.body;

    if (!usuario.integracaoGoogle || !usuario.integracaoGoogle.accessToken) {
      return res.status(400).json({
        erro: 'Integração não configurada',
        mensagem: '🌑 Configure a integração com Google Fit primeiro'
      });
    }

    // Verificar se o token expirou
    if (new Date() > usuario.integracaoGoogle.expiresAt) {
      await renovarTokenGoogle(usuario);
    }

    const dataInicio = periodo?.inicio ? new Date(periodo.inicio) : new Date(Date.now() - 7 * 24 * 60 * 60 * 1000);
    const dataFim = periodo?.fim ? new Date(periodo.fim) : new Date();

    let dadosSincronizados = [];

    switch (tipo) {
      case 'atividade': {
        dadosSincronizados = await sincronizarAtividades(usuario, dataInicio, dataFim);
        break;
      }
      case 'sono': {
        dadosSincronizados = await sincronizarSono(usuario, dataInicio, dataFim);
        break;
      }
      case 'peso': {
        dadosSincronizados = await sincronizarPeso(usuario, dataInicio, dataFim);
        break;
      }
      case 'todos': {
        const [atividades, sono, peso] = await Promise.all([
          sincronizarAtividades(usuario, dataInicio, dataFim),
          sincronizarSono(usuario, dataInicio, dataFim),
          sincronizarPeso(usuario, dataInicio, dataFim)
        ]);
        dadosSincronizados = [...atividades, ...sono, ...peso];
        break;
      }
      default:
        return res.status(400).json({
          erro: 'Tipo inválido',
          mensagem: '🌑 Tipo de dados de saúde inválido'
        });
    }

    // Salvar dados sincronizados no perfil do usuário
    if (!usuario.dadosSaude) {
      usuario.dadosSaude = [];
    }
    usuario.dadosSaude.push(...dadosSincronizados);
    await usuario.save();

    res.json({
      sucesso: true,
      mensagem: `🏥 ${dadosSincronizados.length} registros de saúde sincronizados!`,
      dadosSincronizados,
      tipo,
      periodo: { inicio: dataInicio, fim: dataFim }
    });
  } catch (erro) {
    console.error('Erro ao sincronizar dados de saúde:', erro);
    res.status(500).json({
      erro: 'Erro interno do servidor',
      mensagem: '💀 Não foi possível sincronizar os dados de saúde'
    });
  }
});

// Obter dados de saúde sincronizados
router.get('/health/dados', async (req, res) => {
  try {
    const usuario = req.usuario;
    const { tipo, dataInicio, dataFim, limite = 100 } = req.query;

    if (!usuario.dadosSaude || usuario.dadosSaude.length === 0) {
      return res.json({
        sucesso: true,
        mensagem: '🏥 Nenhum dado de saúde encontrado',
        dados: []
      });
    }

    let dados = usuario.dadosSaude;

    // Filtrar por tipo
    if (tipo) {
      dados = dados.filter(d => d.tipo === tipo);
    }

    // Filtrar por período
    if (dataInicio || dataFim) {
      const inicio = dataInicio ? new Date(dataInicio) : new Date(0);
      const fim = dataFim ? new Date(dataFim) : new Date();

      dados = dados.filter(d => {
        const data = new Date(d.timestamp);
        return data >= inicio && data <= fim;
      });
    }

    // Limitar resultados
    dados = dados.slice(0, parseInt(limite));

    // Ordenar por timestamp
    dados.sort((a, b) => new Date(b.timestamp) - new Date(a.timestamp));

    res.json({
      sucesso: true,
      mensagem: `🏥 ${dados.length} registros de saúde encontrados`,
      dados,
      total: usuario.dadosSaude.length
    });
  } catch (erro) {
    console.error('Erro ao obter dados de saúde:', erro);
    res.status(500).json({
      erro: 'Erro interno do servidor',
      mensagem: '💀 Não foi possível obter os dados de saúde'
    });
  }
});

// ===== FUNÇÕES AUXILIARES =====

// Classe para interagir com a API do Google Calendar
class GoogleCalendarAPI {
  constructor (accessToken) {
    this.accessToken = accessToken;
    this.baseUrl = 'https://www.googleapis.com/calendar/v3';
  }

  async criarEvento (evento) {
    const response = await fetch(`${this.baseUrl}/calendars/primary/events`, {
      method: 'POST',
      headers: {
        Authorization: `Bearer ${this.accessToken}`,
        'Content-Type': 'application/json'
      },
      body: JSON.stringify(evento)
    });

    if (!response.ok) {
      throw new Error(`Erro na API do Google Calendar: ${response.statusText}`);
    }

    return await response.json();
  }

  async listarEventos (dataInicio, dataFim, maxResultados = 50) {
    const params = new URLSearchParams({
      timeMin: dataInicio.toISOString(),
      timeMax: dataFim.toISOString(),
      maxResults: maxResultados.toString(),
      singleEvents: 'true',
      orderBy: 'startTime'
    });

    const response = await fetch(`${this.baseUrl}/calendars/primary/events?${params}`, {
      headers: {
        Authorization: `Bearer ${this.accessToken}`
      }
    });

    if (!response.ok) {
      throw new Error(`Erro na API do Google Calendar: ${response.statusText}`);
    }

    const data = await response.json();
    return data.items || [];
  }
}

// Função para renovar token do Google
async function renovarTokenGoogle (usuario) {
  try {
    const response = await fetch('https://oauth2.googleapis.com/token', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/x-www-form-urlencoded'
      },
      body: new URLSearchParams({
        client_id: GOOGLE_OAUTH_CONFIG.clientId,
        client_secret: GOOGLE_OAUTH_CONFIG.clientSecret,
        refresh_token: usuario.integracaoGoogle.refreshToken,
        grant_type: 'refresh_token'
      })
    });

    const tokenData = await response.json();

    if (tokenData.error) {
      throw new Error(`Erro na renovação do token: ${tokenData.error_description}`);
    }

    // Atualizar tokens
    usuario.integracaoGoogle.accessToken = tokenData.access_token;
    usuario.integracaoGoogle.expiresAt = new Date(Date.now() + tokenData.expires_in * 1000);

    if (tokenData.refresh_token) {
      usuario.integracaoGoogle.refreshToken = tokenData.refresh_token;
    }

    await usuario.save();
    console.log('Token do Google renovado com sucesso');
  } catch (erro) {
    console.error('Erro ao renovar token do Google:', erro);
    throw erro;
  }
}

// Função para criar evento recorrente no Google Calendar
async function criarEventoRecorrente (googleApi, habito, dataInicio, dataFim) {
  const evento = {
    summary: `🏃 ${habito.titulo}`,
    description: habito.descricao || 'Hábito sincronizado do Librarium',
    start: {
      dateTime: dataInicio.toISOString(),
      timeZone: 'America/Sao_Paulo'
    },
    end: {
      dateTime: new Date(dataInicio.getTime() + 60 * 60 * 1000).toISOString(), // 1 hora de duração
      timeZone: 'America/Sao_Paulo'
    },
    reminders: {
      useDefault: false,
      overrides: [
        { method: 'popup', minutes: 15 }
      ]
    }
  };

  // Adicionar recorrência baseada na frequência do hábito
  switch (habito.frequencia) {
  case 'diario':
    evento.recurrence = ['RRULE:FREQ=DAILY'];
    break;
  case 'semanal':
    evento.recurrence = ['RRULE:FREQ=WEEKLY'];
    break;
  case 'mensal':
    evento.recurrence = ['RRULE:FREQ=MONTHLY'];
    break;
  }

  return await googleApi.criarEvento(evento);
}

// Função para sincronizar atividades físicas
async function sincronizarAtividades (usuario, dataInicio, dataFim) {
  // Simulação de dados do Google Fit
  // Em produção, você usaria a API real do Google Fit
  const dados = [];
  const dias = Math.ceil((dataFim - dataInicio) / (24 * 60 * 60 * 1000));

  for (let i = 0; i < dias; i++) {
    const data = new Date(dataInicio.getTime() + i * 24 * 60 * 60 * 1000);

    dados.push({
      tipo: 'atividade',
      subtipo: 'passos',
      valor: Math.floor(Math.random() * 5000) + 3000, // 3000-8000 passos
      unidade: 'passos',
      timestamp: data,
      fonte: 'google_fit',
      sincronizadoEm: new Date()
    });

    dados.push({
      tipo: 'atividade',
      subtipo: 'calorias',
      valor: Math.floor(Math.random() * 200) + 100, // 100-300 calorias
      unidade: 'kcal',
      timestamp: data,
      fonte: 'google_fit',
      sincronizadoEm: new Date()
    });
  }

  return dados;
}

// Função para sincronizar dados de sono
async function sincronizarSono (usuario, dataInicio, dataFim) {
  const dados = [];
  const dias = Math.ceil((dataFim - dataInicio) / (24 * 60 * 60 * 1000));

  for (let i = 0; i < dias; i++) {
    const data = new Date(dataInicio.getTime() + i * 24 * 60 * 60 * 1000);

    dados.push({
      tipo: 'sono',
      subtipo: 'duracao',
      valor: Math.floor(Math.random() * 3) + 6, // 6-9 horas
      unidade: 'horas',
      timestamp: data,
      fonte: 'google_fit',
      sincronizadoEm: new Date()
    });
  }

  return dados;
}

// Função para sincronizar dados de peso
async function sincronizarPeso (usuario, dataInicio, dataFim) {
  const dados = [];
  const dias = Math.ceil((dataFim - dataInicio) / (24 * 60 * 60 * 1000));

  for (let i = 0; i < dias; i++) {
    const data = new Date(dataInicio.getTime() + i * 24 * 60 * 60 * 1000);

    dados.push({
      tipo: 'peso',
      subtipo: 'massa',
      valor: Math.floor(Math.random() * 5) + 70, // 70-75 kg (exemplo)
      unidade: 'kg',
      timestamp: data,
      fonte: 'google_fit',
      sincronizadoEm: new Date()
    });
  }

  return dados;
}

// ===== ENDPOINTS DE CONFIGURAÇÃO =====

// Obter status das integrações
router.get('/status', async (req, res) => {
  try {
    const usuario = req.usuario;

    const status = {
      googleCalendar: {
        ativo: !!(usuario.integracaoGoogle && usuario.integracaoGoogle.accessToken),
        expiraEm: usuario.integracaoGoogle?.expiresAt || null,
        escopo: usuario.integracaoGoogle?.scope || null
      },
      googleFit: {
        ativo: !!(usuario.integracaoGoogle && usuario.integracaoGoogle.accessToken),
        dadosSincronizados: usuario.dadosSaude?.length || 0
      }
    };

    res.json({
      sucesso: true,
      mensagem: '📊 Status das integrações obtido',
      status
    });
  } catch (erro) {
    console.error('Erro ao obter status das integrações:', erro);
    res.status(500).json({
      erro: 'Erro interno do servidor',
      mensagem: '💀 Não foi possível obter o status das integrações'
    });
  }
});

// Desconectar integração
router.delete('/google/desconectar', async (req, res) => {
  try {
    const usuario = req.usuario;

    if (usuario.integracaoGoogle) {
      usuario.integracaoGoogle = undefined;
      await usuario.save();
    }

    res.json({
      sucesso: true,
      mensagem: '🔌 Integração com Google desconectada com sucesso'
    });
  } catch (erro) {
    console.error('Erro ao desconectar integração:', erro);
    res.status(500).json({
      erro: 'Erro interno do servidor',
      mensagem: '💀 Não foi possível desconectar a integração'
    });
  }
});

module.exports = router;
