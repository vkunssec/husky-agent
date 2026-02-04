#!/bin/bash

echo ""
echo "🔍 Iniciando revisão automática com IA..."
echo ""

# Obtém a lista de arquivos staged
STAGED_FILES=$(git diff --cached --name-only --diff-filter=d | grep -E '\.(js|jsx|ts|tsx|py|go|java|cs|php|rb|rs|html|css|scss|md)$')

if [ -z "$STAGED_FILES" ]; then
  echo "✅ Nenhum arquivo de código para revisar."
  exit 0
fi

echo "📝 Arquivos modificados:"
for file in $STAGED_FILES; do
  echo "   - $file"
done
echo ""

# Cria um prompt MUITO curto para não estourar o limite
PROMPT="Revise estas mudanças de código. Responda APENAS 'APPROVED' ou 'REJECTED' na primeira linha, seguido de 1-2 frases de feedback.

Arquivos: $STAGED_FILES

Diff resumido:"

# Pega apenas as primeiras 50 linhas do diff para não estourar
DIFF_SUMMARY=$(git diff --cached | head -50)

# Se o diff for muito grande, avisa
TOTAL_LINES=$(git diff --cached | wc -l | xargs)
if [ "$TOTAL_LINES" -gt 50 ]; then
  DIFF_SUMMARY="$DIFF_SUMMARY

... (diff truncado - $TOTAL_LINES linhas no total)"
fi

# Salva o prompt completo
TEMP_FILE=$(mktemp)
echo "$PROMPT" > "$TEMP_FILE"
echo "" >> "$TEMP_FILE"
echo "$DIFF_SUMMARY" >> "$TEMP_FILE"

echo "🤖 Consultando IA..."
echo ""

# Chama o agent com timeout curto
RESPONSE=$(timeout 15s agent < "$TEMP_FILE" 2>&1)
EXIT_CODE=$?

rm "$TEMP_FILE"

# Se deu timeout ou erro, mostra e pergunta
if [ $EXIT_CODE -ne 0 ] || echo "$RESPONSE" | grep -qi "error"; then
  echo "⚠️  IA não disponível ou deu erro:"
  echo "$RESPONSE"
  echo ""
  
  # Mostra diff resumido
  echo "📊 Mudanças (resumo):"
  git diff --cached --stat
  echo ""
  
  read -p "Continuar com commit mesmo assim? (y/n) " -n 1 -r
  echo ""
  
  if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "✅ Commit aprovado manualmente."
    exit 0
  else
    echo "❌ Commit cancelado."
    exit 1
  fi
fi

# Mostra resposta da IA
echo "📋 Resposta da IA:"
echo "$RESPONSE"
echo ""

# Verifica se foi aprovado
FIRST_LINE=$(echo "$RESPONSE" | head -1)
if echo "$FIRST_LINE" | grep -qi "APPROVED"; then
  echo "✅ Código aprovado pela IA!"
  exit 0
elif echo "$FIRST_LINE" | grep -qi "REJECTED"; then
  echo "❌ Código reprovado pela IA."
  echo ""
  echo "💡 Corrija os problemas ou use --no-verify para forçar"
  exit 1
else
  # Se a resposta não for clara, pede confirmação
  echo "🤔 Resposta da IA não foi clara."
  echo ""
  read -p "Continuar com commit? (y/n) " -n 1 -r
  echo ""
  
  if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "✅ Commit aprovado manualmente."
    exit 0
  else
    echo "❌ Commit cancelado."
    exit 1
  fi
fi
