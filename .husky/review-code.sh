#!/bin/bash

# ============================================================================
# REVISÃO DE CÓDIGO COM CURSOR AGENT
# ============================================================================
# Este script usa o Cursor Agent para revisar automaticamente o código
# antes de cada commit. O agente analisa as mudanças e aprova ou rejeita.
# ============================================================================

# CONFIGURAÇÕES
# ----------------------------------------------------------------------------
# Modelo a ser usado (deixe vazio para usar o padrão da conta)
# Opções: auto, gpt-5.2, opus-4.5, sonnet-4.5, gemini-3-flash, grok, etc.
# Pode ser sobrescrito pela variável de ambiente CURSOR_REVIEW_MODEL
# Exemplos:
#   REVIEW_MODEL="sonnet-4.5"        # Claude 4.5 Sonnet (rápido)
#   REVIEW_MODEL="gemini-3-flash"    # Gemini 3 Flash (econômico)
#   REVIEW_MODEL=""                  # Usa o padrão da conta
REVIEW_MODEL="${CURSOR_REVIEW_MODEL:-sonnet-4.5}"

# Timeout em segundos para a revisão
TIMEOUT_SECONDS="${CURSOR_REVIEW_TIMEOUT:-90}"

# ============================================================================

echo ""
echo "============================================"
echo "   REVISÃO DE CÓDIGO COM CURSOR AGENT"
echo "============================================"
echo ""

# Procura o agent no PATH ou em locais conhecidos
find_agent() {
  # Primeiro tenta no PATH
  if command -v agent &> /dev/null; then
    echo "agent"
    return 0
  fi
  
  # Locais conhecidos
  local KNOWN_PATHS=(
    "$HOME/.local/bin/agent"
    "/Applications/Cursor.app/Contents/Resources/app/bin/cursor"
  )
  
  for path in "${KNOWN_PATHS[@]}"; do
    if [ -x "$path" ]; then
      echo "$path"
      return 0
    fi
  done
  
  return 1
}

CURSOR_AGENT=$(find_agent)

if [ -z "$CURSOR_AGENT" ]; then
  echo "⚠️  Cursor Agent não encontrado."
  echo "   Instale via: cursor agent install-shell-integration"
  echo "   Pulando revisão automática..."
  exit 0
fi

echo "🔧 Usando: $CURSOR_AGENT"
echo ""

# Obtém a lista de arquivos staged (apenas código)
STAGED_FILES=$(git diff --cached --name-only --diff-filter=d | grep -E '\.(js|jsx|ts|tsx|py|go|java|cs|php|rb|rs|c|cpp|h|hpp|html|css|scss|json|yaml|yml|sh|sql)$')

if [ -z "$STAGED_FILES" ]; then
  echo "✅ Nenhum arquivo de código para revisar."
  echo ""
  exit 0
fi

# Mostra arquivos que serão revisados
echo "📝 Arquivos para revisão:"
for file in $STAGED_FILES; do
  echo "   - $file"
done
echo ""

# Obtém o diff das mudanças
DIFF_CONTENT=$(git diff --cached)
DIFF_LINES=$(echo "$DIFF_CONTENT" | wc -l | xargs)

# Se o diff for muito grande, trunca
MAX_LINES=300
if [ "$DIFF_LINES" -gt "$MAX_LINES" ]; then
  DIFF_CONTENT=$(echo "$DIFF_CONTENT" | head -$MAX_LINES)
  DIFF_CONTENT="$DIFF_CONTENT

[... DIFF TRUNCADO - Total: $DIFF_LINES linhas ...]"
fi

# Monta o prompt de revisão
REVIEW_PROMPT="Você é um revisor de código. Analise as mudanças e responda:

REGRAS IMPORTANTES:
1. Primeira linha da resposta DEVE ser EXATAMENTE: APPROVED ou REJECTED
2. Depois, feedback breve (máx 3 linhas)

REJEITE SE:
- Bugs óbvios ou erros de lógica
- Vulnerabilidades de segurança
- Código que vai quebrar em produção

APROVE SE:
- Código funcional e razoável
- Style/formatting NÃO é motivo de rejeição
- Falta de comentários NÃO é motivo de rejeição

ARQUIVOS: $STAGED_FILES

DIFF:
$DIFF_CONTENT

Responda começando com APPROVED ou REJECTED:"

echo "🤖 Cursor Agent analisando código..."

# Mostra o modelo se configurado
if [ -n "$REVIEW_MODEL" ]; then
  echo "🧠 Modelo: $REVIEW_MODEL"
fi
echo ""

# Determina o comando correto baseado no agent encontrado
if [[ "$CURSOR_AGENT" == *"cursor"* ]] && [[ "$CURSOR_AGENT" != *"cursor-agent"* ]]; then
  # É o cursor CLI, precisa do subcomando agent
  if [ -n "$REVIEW_MODEL" ]; then
    RESPONSE=$(echo "$REVIEW_PROMPT" | timeout "${TIMEOUT_SECONDS}s" "$CURSOR_AGENT" agent --print --model "$REVIEW_MODEL" 2>&1)
  else
    RESPONSE=$(echo "$REVIEW_PROMPT" | timeout "${TIMEOUT_SECONDS}s" "$CURSOR_AGENT" agent --print 2>&1)
  fi
else
  # É o agent direto
  if [ -n "$REVIEW_MODEL" ]; then
    RESPONSE=$(echo "$REVIEW_PROMPT" | timeout "${TIMEOUT_SECONDS}s" "$CURSOR_AGENT" --print --model "$REVIEW_MODEL" 2>&1)
  else
    RESPONSE=$(echo "$REVIEW_PROMPT" | timeout "${TIMEOUT_SECONDS}s" "$CURSOR_AGENT" --print 2>&1)
  fi
fi
EXIT_CODE=$?

# Verifica timeout
if [ "${EXIT_CODE:-0}" -eq 124 ]; then
  echo "⚠️  Timeout na revisão (>${TIMEOUT_SECONDS}s)"
  echo ""
  echo "📊 Resumo das mudanças:"
  git diff --cached --stat
  echo ""
  
  read -p "Continuar com commit? (y/n) " -n 1 -r </dev/tty
  echo ""
  
  if [[ $REPLY =~ ^[Yy]$ ]]; then
    exit 0
  else
    exit 1
  fi
fi

# Verifica erros
if [ "${EXIT_CODE:-0}" -ne 0 ]; then
  echo "⚠️  Erro ao executar Cursor Agent (código: $EXIT_CODE)"
  echo ""
  if [ -n "$RESPONSE" ]; then
    echo "Detalhes: $RESPONSE"
    echo ""
  fi
  
  read -p "Continuar com commit mesmo assim? (y/n) " -n 1 -r </dev/tty
  echo ""
  
  if [[ $REPLY =~ ^[Yy]$ ]]; then
    exit 0
  else
    exit 1
  fi
fi

# Mostra a resposta do agente
echo "────────────────────────────────────────────"
echo "📋 RESPOSTA DO CURSOR AGENT:"
echo "────────────────────────────────────────────"
echo "$RESPONSE"
echo "────────────────────────────────────────────"
echo ""

# Extrai o veredito - procura APPROVED ou REJECTED em qualquer lugar
if echo "$RESPONSE" | grep -qi "APPROVED"; then
  echo "✅ CÓDIGO APROVADO!"
  echo ""
  exit 0
elif echo "$RESPONSE" | grep -qi "REJECTED"; then
  echo "❌ CÓDIGO REJEITADO"
  echo ""
  echo "💡 Dica: Corrija os problemas ou use 'git commit --no-verify' para forçar"
  echo ""
  exit 1
else
  # Resposta não clara - pede confirmação manual
  echo "🤔 Veredito não identificado na resposta."
  echo ""
  
  read -p "Aprovar commit manualmente? (y/n) " -n 1 -r </dev/tty
  echo ""
  
  if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "✅ Commit aprovado manualmente."
    exit 0
  else
    echo "❌ Commit cancelado."
    exit 1
  fi
fi
