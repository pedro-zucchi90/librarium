const express = require('express');
const { gerarToken } = require('../config/jwt');
const { autenticarUsuario } = require('../middleware/auth');
const Usuario = require('../models/User');

const router = express.Router();

// Registrar novo usuário
router.post('/registrar', async (req, res) => {
  try {
    const { nomeUsuario, email, senha } = req.body;

    // Verificar se o usuário já existe
    const usuarioExistente = await Usuario.findOne({
      $or: [{ email }, { nomeUsuario }]
    });

    if (usuarioExistente) {
      return res.status(400).json({
        erro: 'Usuário já existe',
        mensagem: '👻 Este caçador já foi invocado no Librarium'
      });
    }

    // Criar novo usuário
    const novoUsuario = new Usuario({
      nomeUsuario,
      email,
      senha
    });

    await novoUsuario.save();

    // Gerar token
    const token = gerarToken(novoUsuario._id);

    res.status(201).json({
      sucesso: true,
      mensagem: '🎮 Bem-vindo ao Librarium, jovem Aspirante!',
      token,
      usuario: {
        id: novoUsuario._id,
        nomeUsuario: novoUsuario.nomeUsuario,
        email: novoUsuario.email,
        nivel: novoUsuario.nivel,
        experiencia: novoUsuario.experiencia,
        titulo: novoUsuario.titulo,
        avatar: novoUsuario.avatar
      }
    });

  } catch (erro) {
    console.error('Erro no registro:', erro);
    res.status(500).json({
      erro: 'Erro interno do servidor',
      mensagem: '💀 Algo deu errado durante a invocação...'
    });
  }
});

// Login do usuário
router.post('/login', async (req, res) => {
  try {
    const { email, senha } = req.body;

    // Buscar usuário
    const usuario = await Usuario.findOne({ email });
    if (!usuario) {
      return res.status(401).json({
        erro: 'Credenciais inválidas',
        mensagem: '🌑 Este caçador não foi encontrado no Librarium'
      });
    }

    // Verificar senha
    const senhaCorreta = await usuario.compararSenha(senha);
    if (!senhaCorreta) {
      return res.status(401).json({
        erro: 'Credenciais inválidas',
        mensagem: '⚔️ Senha incorreta, tente novamente'
      });
    }

    // Atualizar última atividade
    await usuario.atualizarUltimaAtividade();

    // Gerar token
    const token = gerarToken(usuario._id);

    res.json({
      sucesso: true,
      mensagem: `🗡️ Bem-vindo de volta, ${usuario.titulo} ${usuario.nomeUsuario}!`,
      token,
      usuario: {
        id: usuario._id,
        nomeUsuario: usuario.nomeUsuario,
        email: usuario.email,
        nivel: usuario.nivel,
        experiencia: usuario.experiencia,
        titulo: usuario.titulo,
        avatar: usuario.avatar,
        sequencia: usuario.sequencia,
        ultimaAtividade: usuario.ultimaAtividade
      }
    });

  } catch (erro) {
    console.error('Erro no login:', erro);
    res.status(500).json({
      erro: 'Erro interno do servidor',
      mensagem: '💀 Algo deu errado durante o acesso...'
    });
  }
});

// Obter perfil do usuário autenticado
router.get('/perfil', autenticarUsuario, async (req, res) => {
  try {
    const usuario = req.usuario;

    res.json({
      sucesso: true,
      usuario: {
        id: usuario._id,
        nomeUsuario: usuario.nomeUsuario,
        email: usuario.email,
        nivel: usuario.nivel,
        experiencia: usuario.experiencia,
        titulo: usuario.titulo,
        avatar: usuario.avatar,
        personalizacaoAvatar: usuario.personalizacaoAvatar,
        sequencia: usuario.sequencia,
        preferencias: usuario.preferencias,
        dataEntrada: usuario.dataEntrada,
        ultimaAtividade: usuario.ultimaAtividade
      }
    });

  } catch (erro) {
    console.error('Erro ao obter perfil:', erro);
    res.status(500).json({
      erro: 'Erro interno do servidor',
      mensagem: '💀 Não foi possível acessar o perfil...'
    });
  }
});

// Atualizar perfil do usuário
router.put('/perfil', autenticarUsuario, async (req, res) => {
  try {
    const { nomeUsuario, preferencias, personalizacaoAvatar } = req.body;
    const usuario = req.usuario;

    // Verificar se o novo nome de usuário já existe (se fornecido)
    if (nomeUsuario && nomeUsuario !== usuario.nomeUsuario) {
      const nomeExistente = await Usuario.findOne({ nomeUsuario });
      if (nomeExistente) {
        return res.status(400).json({
          erro: 'Nome já existe',
          mensagem: '👻 Este nome de caçador já está em uso'
        });
      }
      usuario.nomeUsuario = nomeUsuario;
    }

    // Atualizar preferências se fornecidas
    if (preferencias) {
      usuario.preferencias = { ...usuario.preferencias, ...preferencias };
    }

    // Atualizar personalização do avatar se fornecida
    if (personalizacaoAvatar) {
      usuario.personalizacaoAvatar = { ...usuario.personalizacaoAvatar, ...personalizacaoAvatar };
    }

    await usuario.save();

    res.json({
      sucesso: true,
      mensagem: '⚔️ Perfil atualizado com sucesso!',
      usuario: {
        id: usuario._id,
        nomeUsuario: usuario.nomeUsuario,
        email: usuario.email,
        nivel: usuario.nivel,
        experiencia: usuario.experiencia,
        titulo: usuario.titulo,
        avatar: usuario.avatar,
        personalizacaoAvatar: usuario.personalizacaoAvatar,
        preferencias: usuario.preferencias
      }
    });

  } catch (erro) {
    console.error('Erro ao atualizar perfil:', erro);
    res.status(500).json({
      erro: 'Erro interno do servidor',
      mensagem: '💀 Não foi possível atualizar o perfil...'
    });
  }
});

// Verificar se o token é válido
router.get('/verificar', autenticarUsuario, (req, res) => {
  res.json({
    sucesso: true,
    mensagem: '🗡️ Token válido',
    usuario: {
      id: req.usuario._id,
      nomeUsuario: req.usuario.nomeUsuario,
      nivel: req.usuario.nivel,
      titulo: req.usuario.titulo
    }
  });
});

module.exports = router;
