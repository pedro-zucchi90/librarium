#!/usr/bin/env node

/**
 * 🔧 Script para Corrigir Tipos de Avatar - Librarium
 * 
 * Este script corrige os tipos de avatar que ficaram como "$avatar"
 * após a migração inicial.
 */

const mongoose = require('mongoose');

// Configuração do MongoDB
const MONGODB_URI = process.env.MONGODB_URI || 'mongodb://127.0.0.1:27017/librarium';

async function corrigirTiposAvatar() {
  try {
    console.log('🔧 Corrigindo tipos de avatar...\n');

    // Conectar ao banco
    await mongoose.connect(MONGODB_URI);
    console.log('✅ Conectado ao MongoDB\n');

    // Acessar a coleção diretamente
    const db = mongoose.connection.db;
    const collection = db.collection('usuarios');

    // Buscar usuários com tipo "$avatar"
    const usuariosComTipoIncorreto = await collection.find({
      "avatar.tipo": "$avatar"
    }).toArray();

    console.log(`🔍 Encontrados ${usuariosComTipoIncorreto.length} usuários com tipo incorreto\n`);

    if (usuariosComTipoIncorreto.length === 0) {
      console.log('ℹ️ Nenhum usuário precisa ser corrigido.');
      return;
    }

    let corrigidos = 0;

    for (const usuario of usuariosComTipoIncorreto) {
      console.log(`🔧 Corrigindo usuário: ${usuario.nomeUsuario || usuario.email}`);
      
      // Determinar o tipo correto baseado no contexto
      // Como não temos o valor original, vamos usar "aspirante" como padrão
      const tipoCorreto = "aspirante";
      
      await collection.updateOne(
        { _id: usuario._id },
        { 
          $set: { 
            "avatar.tipo": tipoCorreto
          }
        }
      );

      console.log(`   ✅ Tipo corrigido: "$avatar" → "${tipoCorreto}"`);
      corrigidos++;
    }

    console.log(`\n📊 Resumo da Correção:`);
    console.log(`   🔧 Usuários corrigidos: ${corrigidos}`);

    console.log('\n🎉 Correção concluída com sucesso!');

  } catch (erro) {
    console.error('❌ Erro durante a correção:', erro);
  } finally {
    // Fechar conexão
    await mongoose.connection.close();
    console.log('\n🔌 Conexão com MongoDB fechada');
  }
}

// Executar correção se chamado diretamente
if (require.main === module) {
  corrigirTiposAvatar().catch(console.error);
}

module.exports = { corrigirTiposAvatar };
