#!/usr/bin/env node

/**
 * 🔄 Script de Migração de Avatares - Librarium
 * 
 * Este script migra todos os usuários existentes do formato antigo
 * de avatar (string) para o novo formato (objeto).
 */

const mongoose = require('mongoose');

// Configuração do MongoDB
const MONGODB_URI = process.env.MONGODB_URI || 'mongodb://127.0.0.1:27017/librarium';

async function migrarAvatares() {
  try {
    console.log('🔄 Iniciando migração de avatares...\n');

    // Conectar ao banco
    await mongoose.connect(MONGODB_URI);
    console.log('✅ Conectado ao MongoDB\n');

    // Acessar a coleção diretamente
    const db = mongoose.connection.db;
    const collection = db.collection('usuarios');

    // ETAPA 1: Converter avatares de string para objeto
    console.log('📋 ETAPA 1: Convertendo avatares antigos...');
    
    const resultadoAvatar = await collection.updateMany(
      { avatar: { $type: "string" } },
      {
        $set: {
          avatar: {
            tipo: "$avatar",
            nivel: 1,
            evolucao: "inicial",
            desbloqueadoEm: new Date()
          }
        }
      }
    );

    console.log(`   ✅ ${resultadoAvatar.modifiedCount} avatares convertidos\n`);

    // ETAPA 2: Atualizar personalização do avatar
    console.log('📋 ETAPA 2: Atualizando personalização do avatar...');
    
    // Primeiro, vamos verificar quais campos precisam ser migrados
    const usuariosComPersonalizacaoAntiga = await collection.find({
      $or: [
        { "personalizacaoAvatar.arma": { $type: "string" } },
        { "personalizacaoAvatar.armadura": { $type: "string" } },
        { "personalizacaoAvatar.acessorio": { $type: "string" } }
      ]
    }).toArray();

    console.log(`   🔍 Encontrados ${usuariosComPersonalizacaoAntiga.length} usuários com personalização antiga`);

    let personalizacoesMigradas = 0;

    for (const usuario of usuariosComPersonalizacaoAntiga) {
      console.log(`   🔄 Migrando usuário: ${usuario.nomeUsuario || usuario.email}`);
      
      const atualizacoes = {};
      
      // Migrar arma se for string
      if (typeof usuario.personalizacaoAvatar?.arma === 'string') {
        atualizacoes['personalizacaoAvatar.arma'] = {
          tipo: usuario.personalizacaoAvatar.arma,
          nivel: 1,
          desbloqueadaEm: new Date()
        };
        console.log(`      Arma: '${usuario.personalizacaoAvatar.arma}' → objeto`);
      }
      
      // Migrar armadura se for string
      if (typeof usuario.personalizacaoAvatar?.armadura === 'string') {
        atualizacoes['personalizacaoAvatar.armadura'] = {
          tipo: usuario.personalizacaoAvatar.armadura,
          nivel: 1,
          desbloqueadaEm: new Date()
        };
        console.log(`      Armadura: '${usuario.personalizacaoAvatar.armadura}' → objeto`);
      }
      
      // Migrar acessório se for string
      if (typeof usuario.personalizacaoAvatar?.acessorio === 'string') {
        atualizacoes['personalizacaoAvatar.acessorio'] = {
          tipo: usuario.personalizacaoAvatar.acessorio,
          nivel: 1,
          desbloqueadaEm: new Date()
        };
        console.log(`      Acessório: '${usuario.personalizacaoAvatar.acessorio}' → objeto`);
      }
      
      // Adicionar campos de aura e partículas se não existirem
      if (!usuario.personalizacaoAvatar?.aura) {
        atualizacoes['personalizacaoAvatar.aura'] = {
          tipo: 'nenhuma',
          nivel: 1,
          desbloqueadaEm: new Date()
        };
        console.log(`      Aura: criada`);
      }
      
      if (!usuario.personalizacaoAvatar?.particulas) {
        atualizacoes['personalizacaoAvatar.particulas'] = {
          tipo: 'nenhuma',
          nivel: 1,
          desbloqueadaEm: new Date()
        };
        console.log(`      Partículas: criadas`);
      }
      
      // Aplicar atualizações
      if (Object.keys(atualizacoes).length > 0) {
        await collection.updateOne(
          { _id: usuario._id },
          { $set: atualizacoes }
        );
        personalizacoesMigradas++;
      }
    }

    console.log(`   ✅ ${personalizacoesMigradas} personalizações migradas\n`);

    // ETAPA 3: Verificar resultado final
    console.log('📋 ETAPA 3: Verificando resultado...');
    
    const totalUsuarios = await collection.countDocuments({});
    const usuariosComAvatarObjeto = await collection.countDocuments({
      avatar: { $type: "object" }
    });

    console.log(`   📊 Total de usuários: ${totalUsuarios}`);
    console.log(`   ✅ Usuários com avatar objeto: ${usuariosComAvatarObjeto}`);
    console.log(`   🔄 Usuários migrados: ${resultadoAvatar.modifiedCount}`);

    if (resultadoAvatar.modifiedCount > 0) {
      console.log('\n🎉 Migração concluída com sucesso!');
      console.log('   Todos os usuários agora usam o novo sistema de avatar.');
      console.log('\n💡 Próximo passo: Execute "npm run test:avatar" para testar!');
    } else {
      console.log('\nℹ️ Nenhuma migração necessária.');
      console.log('   Todos os usuários já estão no formato correto.');
    }

  } catch (erro) {
    console.error('❌ Erro durante a migração:', erro);
  } finally {
    // Fechar conexão
    await mongoose.connection.close();
    console.log('\n🔌 Conexão com MongoDB fechada');
  }
}

// Executar migração se chamado diretamente
if (require.main === module) {
  migrarAvatares().catch(console.error);
}

module.exports = { migrarAvatares };
