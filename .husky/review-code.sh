#!/bin/bash

# Obtém a lista de arquivos staged
STAGED_FILES=$(git diff --cached --name-only --diff-filter=d | grep -E '\.(js|jsx|ts|tsx|py|go|java|cs|php|rb|rs|html|css|scss|md)$')

if [ -z "$STAGED_FILES" ]; then
  exit 0
fi

echo ""
echo "📝 Arquivos modificados:"
for file in $STAGED_FILES; do
  echo "   - $file"
done
echo ""

# Mostra o diff de forma resumida
echo "📊 Mudanças:"
git diff --cached --stat
echo ""

# Mostra o diff completo (colorido se possível)
git diff --cached --color=always

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
read -p "✅ Revisar e continuar com o commit? (y/n) " -n 1 -r
echo ""

if [[ $REPLY =~ ^[Yy]$ ]]; then
  echo "✅ Commit aprovado!"
  exit 0
else
  echo "❌ Commit cancelado. Use --no-verify para pular."
  exit 1
fi
