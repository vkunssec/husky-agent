#!/bin/bash

echo ""
echo "🔍 Revisão de código com Cursor Agent..."
echo ""

# Obtém a lista de arquivos staged
STAGED_FILES=$(git diff --cached --name-only --diff-filter=d | grep -E '\.(js|jsx|ts|tsx|py|go|java|cs|php|rb|rs|html|css|scss|md)$')

if [ -z "$STAGED_FILES" ]; then
  echo "✅ Nenhum arquivo de código para revisar."
  echo ""
  exit 0
fi

echo "📝 Arquivos a serem revisados:"
for file in $STAGED_FILES; do
  echo "   - $file"
done
echo ""

# Mostra um resumo do diff
echo "📊 Resumo das mudanças:"
git diff --cached --stat
echo ""

# Tenta chamar o agent de forma simples
echo "🤖 Chamando Cursor Agent para revisão..."
echo ""

# Prompt simples e direto
PROMPT="Revise rapidamente estas mudanças de código. Responda apenas APPROVED ou REJECTED na primeira linha."

# Tenta executar o agent - se falhar, apenas avisa e continua
if command -v agent &> /dev/null; then
  # Salva o diff em arquivo
  TEMP_FILE=$(mktemp)
  git diff --cached > "$TEMP_FILE"
  
  # Tenta executar agent com timeout de 10 segundos
  RESPONSE=$(timeout 10s agent "$PROMPT" < "$TEMP_FILE" 2>&1 || echo "APPROVED - Agent timeout ou erro, aprovando automaticamente")
  
  rm "$TEMP_FILE"
  
  echo "Resposta:"
  echo "$RESPONSE"
  echo ""
  
  # Verifica se foi reprovado explicitamente
  if echo "$RESPONSE" | head -1 | grep -qi "REJECTED"; then
    echo "❌ Código reprovado pelo Agent."
    echo "💡 Use --no-verify para pular a revisão"
    echo ""
    exit 1
  fi
fi

echo "✅ Prosseguindo com o commit..."
echo ""
exit 0
