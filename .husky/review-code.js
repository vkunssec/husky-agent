#!/usr/bin/env node

const { exec } = require('child_process');
const { promisify } = require('util');
const execAsync = promisify(exec);

/**
 * Obtém o diff dos arquivos staged
 * @returns {Promise<string>} O diff dos arquivos
 */
async function getStagedDiff() {
  try {
    const { stdout } = await execAsync('git diff --cached');
    return stdout;
  } catch (error) {
    console.error('Erro ao obter diff:', error.message);
    process.exit(1);
  }
}

/**
 * Obtém a lista de arquivos staged
 * @returns {Promise<string[]>} Lista de arquivos
 */
async function getStagedFiles() {
  try {
    const { stdout } = await execAsync(
      "git diff --cached --name-only --diff-filter=d | grep -E '\\.(js|jsx|ts|tsx|py|go|java|cs|php|rb|rs|html|css|scss|md)$' || true"
    );
    return stdout.trim().split('\n').filter(f => f);
  } catch (error) {
    return [];
  }
}

/**
 * Revisa o código usando a API do Claude
 * @param {string} diff - O diff do código
 * @param {string[]} files - Lista de arquivos modificados
 * @returns {Promise<{approved: boolean, feedback: string}>} Resultado da revisão
 */
async function reviewCode(diff, files) {
  // Verifica se há API key configurada
  const apiKey = process.env.ANTHROPIC_API_KEY;
  
  if (!apiKey) {
    console.log('\n⚠️  ANTHROPIC_API_KEY não configurada.');
    console.log('Pulando revisão automática. Configure a chave para habilitar a revisão.\n');
    return { approved: true, feedback: 'Revisão pulada - API key não configurada' };
  }

  try {
    const Anthropic = require('@anthropic-ai/sdk');
    const anthropic = new Anthropic({ apiKey });

    const prompt = `Você é um revisor de código expert. Analise as seguintes mudanças e determine se o código está pronto para commit.

Arquivos modificados: ${files.join(', ')}

Mudanças (git diff):
${diff}

CRITÉRIOS DE APROVAÇÃO:
- Código segue boas práticas
- Sem bugs óbvios
- Código legível e bem estruturado
- Funções têm comentários JSDoc quando apropriado
- Sem problemas de segurança
- Sem código comentado desnecessário
- Sem console.log esquecidos (exceto se forem intencionais)

Responda APENAS no seguinte formato JSON:
{
  "approved": true/false,
  "feedback": "seu feedback detalhado aqui"
}

Se aprovar, parabenize brevemente. Se reprovar, explique os problemas específicos encontrados.`;

    const message = await anthropic.messages.create({
      model: 'claude-3-5-sonnet-20241022',
      max_tokens: 1024,
      messages: [{ role: 'user', content: prompt }]
    });

    const responseText = message.content[0].text;
    const jsonMatch = responseText.match(/\{[\s\S]*\}/);
    
    if (!jsonMatch) {
      throw new Error('Resposta da API não está no formato esperado');
    }

    return JSON.parse(jsonMatch[0]);
  } catch (error) {
    console.error('\n❌ Erro ao revisar código:', error.message);
    console.log('Continuando com o commit...\n');
    return { approved: true, feedback: 'Erro na revisão - prosseguindo' };
  }
}

/**
 * Função principal
 */
async function main() {
  console.log('\n🔍 Iniciando revisão automática de código...\n');

  const files = await getStagedFiles();

  if (files.length === 0) {
    console.log('✅ Nenhum arquivo de código para revisar.\n');
    process.exit(0);
  }

  console.log('📝 Arquivos a serem revisados:');
  files.forEach(file => console.log(`   - ${file}`));
  console.log('');

  const diff = await getStagedDiff();
  
  if (!diff.trim()) {
    console.log('✅ Sem mudanças para revisar.\n');
    process.exit(0);
  }

  const { approved, feedback } = await reviewCode(diff, files);

  console.log('📋 Resultado da Revisão:\n');
  console.log(feedback);
  console.log('');

  if (approved) {
    console.log('✅ Código aprovado! Prosseguindo com o commit.\n');
    process.exit(0);
  } else {
    console.log('❌ Código reprovado. Por favor, corrija os problemas antes de commitar.\n');
    console.log('💡 Dica: Use --no-verify para pular a revisão se necessário.\n');
    process.exit(1);
  }
}

main();
