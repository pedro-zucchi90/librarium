const express = require('express');
const { autenticarUsuario } = require('../middleware/auth');
const Usuario = require('../models/User');

const router = express.Router();

// Loja de skins e itens cosméticos
const lojaItens = [
  { id: 'skin1', nome: 'Manto Sombrio', tipo: 'armadura', precoXP: 100 },
  { id: 'skin2', nome: 'Espada Fantasma', tipo: 'arma', precoXP: 150 },
  { id: 'skin3', nome: 'Amuleto Abissal', tipo: 'acessorio', precoXP: 80 },
  { id: 'skin4', nome: 'Manto Lendário', tipo: 'armadura', precoXP: 300 },
];

// Listar itens disponíveis na loja
router.get('/', autenticarUsuario, (req, res) => {
  res.json({
    sucesso: true,
    itens: lojaItens
  });
});

// Comprar item da loja
router.post('/comprar', autenticarUsuario, async (req, res) => {
  try {
    const usuario = req.usuario;
    const { itemId } = req.body;
    const item = lojaItens.find(i => i.id === itemId);
    if (!item) {
      return res.status(404).json({
        erro: 'Item não encontrado',
        mensagem: '💀 Este item não existe na loja.'
      });
    }
    if (usuario.experiencia < item.precoXP) {
      return res.status(400).json({
        erro: 'XP insuficiente',
        mensagem: '⚠️ Você não tem XP suficiente para comprar este item.'
      });
    }
    // Deduzir XP e adicionar item à personalização
    usuario.experiencia -= item.precoXP;
    if (item.tipo === 'armadura') usuario.personalizacaoAvatar.armadura = item.nome;
    if (item.tipo === 'arma') usuario.personalizacaoAvatar.arma = item.nome;
    if (item.tipo === 'acessorio') usuario.personalizacaoAvatar.acessorio = item.nome;
    await usuario.save();
    res.json({
      sucesso: true,
      mensagem: `Item ${item.nome} comprado e equipado!`,
      experienciaRestante: usuario.experiencia,
      personalizacaoAvatar: usuario.personalizacaoAvatar
    });
  } catch (erro) {
    console.error('Erro ao comprar item:', erro);
    res.status(500).json({
      erro: 'Erro interno do servidor',
      mensagem: '💀 Não foi possível comprar o item...'
    });
  }
});

module.exports = router;
