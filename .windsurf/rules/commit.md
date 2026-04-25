---
trigger: model_decision
description: Regras e padrões para criação de mensagens de commit seguindo Conventional Commits. Commits sempre separados por área (backend, frontend, mobile). Tipos de commit, estrutura de mensagens, e boas práticas.
globs:
---
# Regras de Commit

## Regra absoluta: sem Co-authored-by

**Nunca** adicione linhas `Co-authored-by:` (ou qualquer variação, ex.: `Co-authored-by: Cursor <cursoragent@cursor.com>`) nas mensagens de commit. Commits deste repositório não devem conter co-autoria em rodapé. Esta regra é obrigatória para todos os commits.

## Commits por área (obrigatório)

**Sempre** faça commits **individualmente** por área do monorepo, sem misturar alterações de mais de uma área no mesmo commit:

| Área | Caminho no repositório | Inclui |
|------|------------------------|--------|
| **Backend** | `backend/` | Código Java/Spring Boot, testes de backend, recursos e **migrations Flyway** em `backend/.../db/migration/` |
| **Frontend** | `frontend/` | Next.js/React, tipos e serviços só do web |
| **Mobile** | `mobile/` | React Native e artefatos só do app mobile |

**Como aplicar:**

1. Após mudanças em mais de uma área, use **um commit por área** (ex.: primeiro `git add` apenas arquivos sob `backend/` e commit; depois `frontend/`; depois `mobile/`).
2. **Não** inclua no mesmo commit arquivos de `backend/` e `frontend/`, nem `frontend/` e `mobile/`, etc.
3. Alterações em arquivos na **raiz** do repo (CI, README, configs globais) ou fora dessas três pastas: prefira um **commit dedicado** (`chore:` ou `ci:`), **sem** misturar com mudanças de `backend/`, `frontend/` ou `mobile/` na mesma mensagem.

Assim o histórico fica reversível por stack, cherry-pick e revisão por time fica mais simples.

## Formato de Mensagem de Commit

Siga o padrão **Conventional Commits** com mensagens em português brasileiro:

```
<tipo>: <descrição curta>

<corpo detalhado (opcional)>

<rodapé (opcional)>
```

## Tipos de Commit

Use os seguintes tipos de commit:

- **feat**: Nova funcionalidade
- **fix**: Correção de bug
- **refactor**: Refatoração de código (sem mudança de funcionalidade)
- **style**: Mudanças de formatação (espaços, indentação, etc.)
- **docs**: Mudanças na documentação
- **test**: Adição ou correção de testes
- **chore**: Tarefas de manutenção (dependências, build, etc.)
- **perf**: Melhorias de performance
- **ci**: Mudanças em CI/CD
- **build**: Mudanças no sistema de build

## Estrutura da Mensagem

### Descrição Curta (Obrigatória)
- Máximo de 72 caracteres
- Use imperativo ("adiciona", "corrige", "melhora")
- Sem ponto final
- Primeira letra minúscula

### Corpo Detalhado (Recomendado para mudanças complexas **dentro da mesma área**)
- Explique **o quê** e **por quê**, não **como**
- Dentro de um único commit (uma área), pode listar subáreas, por exemplo:
  - **Backend**: vários serviços ou pacotes em `backend/`
  - **Database**: detalhar migrations no corpo quando o commit for só de `backend/` (migrations ficam no backend)
  - **Config**: configs da mesma área
- Use bullet points para listar mudanças principais
- Seja específico sobre arquivos/componentes afetados
- **Não** use o corpo para justificar misturar backend + frontend + mobile; use commits separados (ver seção anterior)

## Exemplos

### Commit Simples
```
feat: adiciona validação de email no formulário de cadastro
```

### Várias áreas alteradas = vários commits (correto)

Não agrupe. Exemplo de sequência após uma feature que tocou backend e frontend:

```
# Commit 1 — apenas backend/
feat: adiciona clearLoginRateLimit e ajusta RateLimitingFilter

- Adiciona método clearLoginRateLimit() em RateLimitingConfig
- Melhora tratamento de rate limiting no RateLimitingFilter
```

```
# Commit 2 — apenas frontend/
feat: melhora login e tratamento de erro 429

- Melhora tratamento de erros na página de login
- Ajusta busca de contabilidades para só ocorrer quando autenticado
- Refatora Sidebar e componentes de dashboard
```

### Commit detalhado em uma única área
```
feat: reorganiza módulo de faturamento no backend

- Move DTOs para pacote dto/faturamento
- Extrai FaturamentoValidationService
```

### Commit de Correção
```
fix: corrige erro de validação no schema de email

- Ajusta emailConfigSchema para usar transform do Zod
- Garante valores padrão corretos para sslEnabled, tlsEnabled e authRequired
- Corrige tipo TypeScript EmailConfigFormData
```

### Commit de Refatoração
```
refactor: reorganiza estrutura de componentes do dashboard

- Move componentes específicos para pasta dashboard/
- Separa lógica de apresentação de lógica de negócio
- Melhora legibilidade e manutenibilidade do código
```

## Boas Práticas

1. **Seja Descritivo**: A mensagem deve deixar claro o que foi alterado e por quê
2. **Um commit = uma área** (`backend/`, `frontend/` ou `mobile/`), salvo arquivos de infra/docs na raiz em commit `chore`/`ci` separado
3. **Seja Específico**: Mencione arquivos, componentes ou funcionalidades principais afetadas
4. **Use Imperativo**: "adiciona" ao invés de "adicionado" ou "adicionando"
5. **Uma Mudança Lógica por Commit**: Dentro da área, evite misturar funcionalidades não relacionadas
6. **Mencione Breaking Changes**: Se houver, indique claramente no corpo do commit

## Quando Usar Corpo Detalhado

Use corpo detalhado quando:
- O commit afeta múltiplos arquivos/componentes **na mesma área**
- A mudança é complexa e precisa de contexto
- A descrição curta não é suficiente para entender o escopo

Se a mudança envolve **várias áreas** (backend e frontend, etc.), use **vários commits** (um por área), cada um com corpo quando necessário — não um único commit com todas as camadas.

## Skills Recomendadas

Quando esta regra for ativada, as seguintes skills são as mais adequadas para auxiliar no desenvolvimento:

- **commit**: Para criação de mensagens de commit seguindo Conventional Commits e padrões do projeto
- **rule-commit**: Para regras específicas de commits (separação por área, tipos de commit, estrutura de mensagens)

## Checklist Antes de Commitar

- [ ] Mensagem segue o padrão Conventional Commits
- [ ] **O commit contém arquivos de apenas uma área** (`backend/`, `frontend/` ou `mobile/`), ou apenas raiz/CI/docs em commit `chore`/`ci` isolado
- [ ] Descrição curta é clara e objetiva (máx. 72 caracteres)
- [ ] Corpo detalhado está presente quando necessário
- [ ] Arquivos/componentes principais estão mencionados
- [ ] Breaking changes estão documentados (se houver)
- [ ] Código compila e testes passam (quando aplicável)
