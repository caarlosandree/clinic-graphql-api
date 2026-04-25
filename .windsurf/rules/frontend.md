---
trigger: always_on
description: Regras e padrões para desenvolvimento frontend com Next.js, React 19, TypeScript e shadcn/ui. Esta regra é sempre aplicada (alwaysApply: true) e deve ser seguida em todo desenvolvimento frontend. As regras foram modularizadas em arquivos especializados - consulte os módulos específicos abaixo.
globs: 
---

# Regras de Desenvolvimento Frontend

As regras de desenvolvimento frontend foram organizadas em módulos especializados para facilitar consulta e manutenção. Consulte os módulos específicos conforme necessário.

## Módulos de Regras Frontend

### Módulos Fundamentais (alwaysApply: true)

- **frontend-core.mdc**: Regras fundamentais de desenvolvimento frontend: stack tecnológica, princípios, estrutura, nomenclatura, formatação e padrões básicos do Next.js, React 19 e TypeScript.
- **frontend-checklist.mdc**: Checklist consolidado para verificação antes de fazer commit. Consolida verificações de todos os módulos de regras frontend.

### Módulos Especializados (alwaysApply: false)

- **frontend-forms.mdc**: Formulários com React Hook Form e Zod, **Server Actions**, **`useActionState`**, **`useFormStatus`**, shadcn/ui e erros.
- **frontend-state.mdc**: TanStack Query (cache, queries, mutations), combinação com Server Actions, **`useOptimistic`** (React 19) e atualizações otimistas.
- **frontend-ui.mdc**: Regras para interface e componentes: shadcn/ui, Tailwind CSS, configuração de tema, componentes, estilização, dark mode e @uidotdev/usehooks.
- **frontend-charts.mdc**: Regras para visualização de dados: bibliotecas compatíveis com shadcn/ui para dashboards e gráficos.
- **frontend-security.mdc**: Regras de segurança frontend: validação de dados de entrada, proteção contra XSS, proteção de dados sensíveis e autenticação/autorização.
- **frontend-performance.mdc**: Regras de performance frontend: React.memo, useMemo, useCallback, lazy loading, otimização de imagens, Server Components e code splitting.
- **frontend-quality.mdc**: Regras de qualidade de código frontend: DRY, validação de entradas, tipagem forte TypeScript e tratamento de exceções.

## Como Usar

1. **Para desenvolvimento geral**: Consulte `frontend-core.mdc` para princípios fundamentais e padrões básicos.
2. **Para formulários**: Consulte `frontend-forms.mdc` (RHF, Zod, Server Actions, `useActionState`, `useFormStatus`).
3. **Para estado servidor**: Consulte `frontend-state.mdc` (TanStack Query, invalidação, `useOptimistic`, integração com actions).
4. **Para UI**: Consulte `frontend-ui.mdc` quando trabalhar com shadcn/ui e Tailwind CSS.
5. **Para gráficos**: Consulte `frontend-charts.mdc` quando criar dashboards e visualizações de dados.
6. **Para segurança**: Consulte `frontend-security.mdc` para questões de segurança e validação.
7. **Para performance**: Consulte `frontend-performance.mdc` para otimizações de performance.
8. **Para qualidade**: Consulte `frontend-quality.mdc` para qualidade de código e boas práticas.
9. **Antes de commitar**: Consulte `frontend-checklist.mdc` para verificação completa.

## Stack Tecnológica

Este projeto utiliza:
- **Next.js 16** como framework React full-stack
- **React 19** como framework UI
- **TypeScript** para tipagem estática
- **Turbopack** como bundler padrão (Next.js 16)
- **React Compiler** para memoização automática (Next.js 16)
- **shadcn/ui** como biblioteca de componentes
- **React Hook Form** para formulários com campos controlados complexos
- **Zod** para validação de schemas e tipos (cliente e servidor)
- **TanStack Query** (React Query) para leituras remotas, cache e mutations HTTP quando aplicável
- **Server Actions** + **`useActionState`** / **`useFormStatus`** para mutações e formulários com progressive enhancement
- **`useOptimistic`** (React 19) para feedback imediato alinhado a `frontend-state.mdc`
- **@uidotdev/usehooks** para hooks customizados
- **lucide-react** para ícones
- **Tailwind CSS** para estilização
- **ESLint** para linting
- **Path alias `@/`** apontando para `./src` ou raiz do projeto

Para detalhes sobre cada tecnologia, consulte os módulos específicos acima.