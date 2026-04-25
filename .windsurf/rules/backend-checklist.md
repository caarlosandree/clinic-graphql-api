---
trigger: always_on
description: Checklist consolidado para verificação antes de fazer commit. Consolida verificações de todos os módulos de regras backend.
globs:
---
# Checklist Antes de Commitar

Antes de fazer commit, verifique:

## Compilação e Testes
- [ ] Código compila sem erros (`./gradlew build`)
- [ ] Passa no lint (`./gradlew checkstyleMain` ou similar)
- [ ] Passa nos testes (`./gradlew test`)
- [ ] Sem warnings desnecessários

## Qualidade de Código
- [ ] Código está formatado
- [ ] Nomes descritivos para variáveis e métodos
- [ ] Comentários onde necessário

## API e Validação
- [ ] Validação de inputs implementada (consulte `backend-api.mdc`)
- [ ] Tratamento de exceções adequado (consulte `backend-api.mdc`)
- [ ] Endpoints versionados corretamente (consulte `backend-api.mdc`)

## Transações e Banco de Dados
- [ ] Transações configuradas corretamente (consulte `backend-api.mdc`)
- [ ] Queries parametrizadas (sem SQL injection) (consulte `backend-security.mdc` e `backend-data.mdc`)
- [ ] Lazy loading configurado adequadamente (evitar LazyInitializationException) (consulte `backend-data.mdc`)
- [ ] N+1 queries evitadas (usando @EntityGraph ou JOIN FETCH quando necessário) (consulte `backend-data.mdc`)
- [ ] Paginação implementada para listas grandes (consulte `backend-data.mdc`)

## Migrations
- [ ] Migrations criadas se necessário (seguindo regras do `postgresql.mdc`)

## Segurança
- [ ] Sem dados sensíveis no código (consulte `backend-security.mdc`)
- [ ] Validação de dados implementada (consulte `backend-security.mdc`)

## Performance e Concorrência
- [ ] Virtual Threads habilitadas para operações I/O bound (`spring.threads.virtual.enabled=true`) (consulte `backend-concurrency.mdc`)
- [ ] Thread pools configurados adequadamente apenas para casos CPU-bound (se necessário) (consulte `backend-concurrency.mdc`)
- [ ] Recursos assíncronos fechados corretamente (executorService.shutdown() quando usando ExecutorService) (consulte `backend-concurrency.mdc`)
- [ ] Cache configurado e invalidado adequadamente quando dados são modificados (consulte `backend-performance.mdc`)

## Mapeamento
- [ ] MapStruct usado para mapeamentos Entity <-> DTO (evitar mapeamento manual) (consulte `backend-data.mdc`)

## Testes
- [ ] Testcontainers usado em testes de integração que dependem de funcionalidades PostgreSQL específicas (consulte `backend-testing.mdc`)

## Skills Recomendadas

Quando esta regra for ativada, as seguintes skills são as mais adequadas para auxiliar na verificação:

- **rule-backend-checklist**: Para verificação consolidada antes de commit no backend
- **backend-dev-guidelines**: Para padrões de verificação de qualidade de código backend
- **rule-commit**: Para verificação de mensagens de commit seguindo Conventional Commits

## Referências aos Módulos de Regras

Este checklist consolida verificações de todos os módulos de regras backend:
- **backend-core.mdc**: Princípios, estrutura, nomenclatura e padrões básicos
- **backend-api.mdc**: Versionamento, controllers, DTOs, validação e Swagger
- **backend-data.mdc**: JPA, repositories, lazy loading, MapStruct e batch processing
- **backend-performance.mdc**: Otimizações de memória, caching e JVM
- **backend-concurrency.mdc**: Multi-threading, Virtual Threads e @Async
- **backend-security.mdc**: Validação, proteção de dados e autenticação
- **backend-testing.mdc**: Testes unitários, integração e Testcontainers
- **backend-observability.mdc**: Logging, tracing e observabilidade
- **postgresql.mdc**: Regras específicas do PostgreSQL (migrations, queries, índices)
