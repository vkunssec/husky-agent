# Husky + Cursor Agent - Revisão Automática de Código

Sistema automático de revisão de código que utiliza o Cursor Agent CLI (`agent`) para analisar mudanças antes de cada commit.

## 🚀 Características

- ✅ Revisão automática de código antes de commits
- 🤖 Usa o Cursor Agent CLI que você já tem instalado
- 📝 Feedback detalhado sobre qualidade do código
- 🔒 Detecta problemas de segurança e bugs
- 📋 Verifica boas práticas e padrões de código
- ⚡ Totalmente automatizado
- 🆓 Sem necessidade de API keys externas

## 📦 Instalação

### Pré-requisitos

- Cursor Agent CLI instalado e funcionando (comando `agent` disponível no terminal)
- Node.js instalado

### Passos

1. Clone o repositório e instale as dependências:

```bash
npm install
```

2. Pronto! O sistema já está configurado e funcionando.

O hook vai usar o comando `agent` que você já tem configurado no seu sistema.

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
│   └── review-code.sh      # Script de revisão usando Cursor Agent
├── .gitignore             # Ignora node_modules
├── package.json           # Dependências do projeto
└── README.md             # Este arquivo
```

## 🛠️ Configuração Avançada

### Personalizar Critérios

Edite `.husky/review-code.sh` e modifique a seção `CRITÉRIOS DE APROVAÇÃO` no prompt para ajustar o que a IA deve verificar.

### Suportar Mais Extensões

No arquivo `.husky/review-code.sh`, adicione extensões ao regex na linha que define `STAGED_FILES`:

```bash
grep -E '\.(js|jsx|ts|tsx|py|go|java|cs|php|rb|rs|html|css|scss|md|sua_extensao)$'
```

## 🐛 Troubleshooting

### Comando `agent` não encontrado

Certifique-se de ter o Cursor Agent CLI instalado e disponível no PATH. Teste no terminal:

```bash
agent --version
```

### Hook não está executando

Verifique se o Husky está instalado corretamente:

```bash
npm run prepare
```

### Erro de permissão

Torne os scripts executáveis:

```bash
chmod +x .husky/review-code.sh
chmod +x .husky/pre-commit
```

### Cursor Agent não responde

Se o Cursor Agent travar ou demorar muito, você pode interromper com Ctrl+C e usar `--no-verify` para pular a revisão:

```bash
git commit --no-verify -m "sua mensagem"
```

## 📝 Exemplo de Uso

```bash
$ git add index.js
$ git commit -m "Adiciona função de validação"

🔍 Iniciando revisão automática de código com Cursor Agent...

📝 Arquivos a serem revisados:
   - index.js

🤖 Consultando Cursor Agent...

📋 Resultado da Revisão:
APPROVED

O código está bem estruturado! A função de validação está clara,
tem JSDoc adequado e segue as boas práticas. Pronto para commit!

✅ Código aprovado! Prosseguindo com o commit.

[main abc1234] Adiciona função de validação
 1 file changed, 15 insertions(+)
```

## 🤝 Contribuindo

Sinta-se à vontade para abrir issues ou pull requests com melhorias!

## 📄 Licença

ISC
