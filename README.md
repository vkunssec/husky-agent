# Husky + Claude AI - Revisão Automática de Código

Sistema automático de revisão de código que utiliza Claude AI (Anthropic) para analisar mudanças antes de cada commit.

## 🚀 Características

- ✅ Revisão automática de código antes de commits
- 🤖 Análise inteligente usando Claude AI
- 📝 Feedback detalhado sobre qualidade do código
- 🔒 Detecta problemas de segurança e bugs
- 📋 Verifica boas práticas e padrões de código
- ⚡ Não-interativo e totalmente automatizado

## 📦 Instalação

1. Clone o repositório e instale as dependências:

```bash
npm install
```

2. Configure sua chave da API Anthropic:

```bash
# Copie o arquivo de exemplo
cp .env.example .env

# Edite o arquivo .env e adicione sua chave
# ANTHROPIC_API_KEY=sua_chave_aqui
```

3. Obtenha sua chave da API:
   - Acesse: https://console.anthropic.com/
   - Crie uma conta ou faça login
   - Vá para API Keys e gere uma nova chave
   - Cole a chave no arquivo `.env`

## 🎯 Como Usar

### Uso Normal

Simplesmente faça commits normalmente. O hook pre-commit será executado automaticamente:

```bash
git add .
git commit -m "sua mensagem de commit"
```

Se o código passar na revisão, o commit será concluído. Se houver problemas, você verá o feedback e o commit será bloqueado.

### Pular a Revisão

Se precisar fazer um commit sem revisão (não recomendado):

```bash
git commit --no-verify -m "sua mensagem"
```

## 🔍 O Que é Analisado

O revisor de código verifica:

- ✅ **Boas práticas**: Código segue padrões e convenções
- 🐛 **Bugs óbvios**: Detecta erros comuns
- 📖 **Legibilidade**: Código claro e bem estruturado
- 📝 **Documentação**: Funções têm comentários JSDoc
- 🔒 **Segurança**: Identifica possíveis vulnerabilidades
- 🧹 **Código limpo**: Sem código comentado ou console.logs esquecidos

## 📄 Arquivos do Projeto

```
.
├── .husky/
│   ├── pre-commit          # Hook do Git
│   └── review-code.js      # Script de revisão
├── .env.example            # Template de configuração
├── .gitignore             # Ignora node_modules e .env
├── package.json           # Dependências do projeto
└── README.md             # Este arquivo
```

## 🛠️ Configuração Avançada

### Modo Sem API Key

Se não houver `ANTHROPIC_API_KEY` configurada, o hook permitirá commits sem revisão, mas mostrará um aviso.

### Personalizar Critérios

Edite `.husky/review-code.js` e modifique a seção `CRITÉRIOS DE APROVAÇÃO` no prompt para ajustar o que a IA deve verificar.

### Suportar Mais Extensões

No arquivo `.husky/review-code.js`, na função `getStagedFiles()`, adicione extensões ao regex:

```javascript
grep -E '\\.(js|jsx|ts|tsx|py|go|java|cs|php|rb|rs|html|css|scss|md|sua_extensao)$'
```

## 🐛 Troubleshooting

### "ANTHROPIC_API_KEY não configurada"

Certifique-se de ter criado o arquivo `.env` e adicionado sua chave:

```bash
ANTHROPIC_API_KEY=sk-ant-...
```

### Hook não está executando

Verifique se o Husky está instalado corretamente:

```bash
npm run prepare
```

### Erro de permissão

Torne o script executável:

```bash
chmod +x .husky/review-code.js
chmod +x .husky/pre-commit
```

## 📝 Exemplo de Uso

```bash
$ git add index.js
$ git commit -m "Adiciona função de validação"

🔍 Iniciando revisão automática de código...

📝 Arquivos a serem revisados:
   - index.js

📋 Resultado da Revisão:

✅ Código está bem estruturado! A função de validação está clara,
tem JSDoc adequado e segue as boas práticas. Pronto para commit!

✅ Código aprovado! Prosseguindo com o commit.

[main abc1234] Adiciona função de validação
 1 file changed, 15 insertions(+)
```

## 🤝 Contribuindo

Sinta-se à vontade para abrir issues ou pull requests com melhorias!

## 📄 Licença

ISC
