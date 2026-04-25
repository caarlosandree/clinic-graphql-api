---
trigger: model_decision
description: Regras e padrões para desenvolvimento com PostgreSQL 18. Use esta regra quando trabalhar com banco de dados, criar migrations, escrever queries SQL, otimizar performance de banco, design de schema, ou quando precisar seguir padrões de nomenclatura e boas práticas do PostgreSQL. A regra cobre nomenclatura (snake_case para tabelas e colunas), design de schema e normalização, tipos de dados apropriados, criação de índices e constraints, otimização de queries, migrations com Flyway/Liquibase, segurança e permissões, backup e recuperação, e monitoramento.
globs: 
---

# Regras de Desenvolvimento - PostgreSQL

## Stack Tecnológica

Este projeto utiliza:
- **PostgreSQL 18** como banco de dados relacional
- **Flyway** para migrations e versionamento de schema
- **pg_stat_statements** para análise de performance de queries
- **PostGIS** para dados geoespaciais (quando necessário)
- **pgBouncer** para connection pooling (quando necessário)

## Princípios Gerais

### Código Limpo e Legível
- Sempre escreva SQL que seja fácil de entender para você e outros desenvolvedores
- Priorize clareza sobre concisão quando necessário
- Use nomes descritivos que expliquem o propósito de tabelas, colunas e funções
- Documente decisões complexas ou não óbvias
- Use comentários SQL (`COMMENT ON`) para documentar objetos do banco

### Consistência
- Mantenha estilo de SQL consistente em todo o projeto
- Siga os padrões estabelecidos no projeto
- Use as mesmas convenções de nomenclatura em objetos relacionados
- Use snake_case para tabelas e colunas (padrão PostgreSQL mais comum)

### Programação para Manutenção
- Escreva código pensando em quem vai mantê-lo no futuro
- Facilite a localização e correção de problemas
- Mantenha migrations pequenas e atômicas
- Versionamento adequado de schema através de migrations

## Organização e Estrutura

### Estrutura de Migrations
```
backend/
  └── src/
      └── main/
          └── resources/
              └── db/
                  └── migration/
                      ├── V1__Create_Users_table.sql
                      ├── V2__Create_Orders_table.sql
                      ├── V3__Add_indexes.sql
                      ├── V4__Create_functions.sql
                      └── V5__Add_constraints.sql
```

### Organização de Schema
- Use **schemas** para organizar objetos relacionados (ex: `public`, `audit`, `reporting`)
- Agrupe tabelas relacionadas no mesmo schema
- Use schemas separados para diferentes contextos (ex: `auth`, `billing`, `analytics`)

```sql
-- ✅ Bom: Uso de schemas para organização
CREATE SCHEMA IF NOT EXISTS auth;
CREATE SCHEMA IF NOT EXISTS billing;
CREATE SCHEMA IF NOT EXISTS analytics;

-- Tabelas de autenticação no schema auth
CREATE TABLE auth.users (...);
CREATE TABLE auth.sessions (...);

-- Tabelas de billing no schema billing
CREATE TABLE billing.invoices (...);
CREATE TABLE billing.payments (...);
```

## Nomenclatura

### Tabelas e Colunas
- Tabelas: **snake_case**, plural quando apropriado (ex: `users`, `order_items`, `user_profiles`)
- Colunas: **snake_case**, singular (ex: `user_id`, `created_at`, `email_address`)
- Chaves primárias: geralmente `id` ou `{table_name}_id` (ex: `user_id`)
- Chaves estrangeiras: `{referenced_table}_id` (ex: `user_id`, `order_id`)
- Timestamps: `created_at`, `updated_at`, `deleted_at`
- Booleanos: prefixo `is_`, `has_`, `can_` (ex: `is_active`, `has_permission`, `can_edit`)

**Nota**: Use snake_case sem aspas duplas (padrão PostgreSQL mais comum e compatível com a maioria das ferramentas).

### Índices
- Índices: `idx_{table}_{columns}` (ex: `idx_users_email`, `idx_orders_user_id_created_at`)
- Índices únicos: `uk_{table}_{columns}` (ex: `uk_users_email`)
- Índices compostos: incluir colunas na ordem de especificidade (mais específica primeiro)

### Constraints
- Primary keys: `pk_{table}` (ex: `pk_users`)
- Foreign keys: `fk_{table}_{referenced_table}` (ex: `fk_orders_users`)
- Unique constraints: `uk_{table}_{columns}` (ex: `uk_users_email`)
- Check constraints: `ck_{table}_{description}` (ex: `ck_users_age_positive`)

### Funções e Procedures
- Funções: **snake_case**, verbos descritivos (ex: `calculate_total_price`, `get_user_by_email`)
- Procedures: **snake_case**, verbos descritivos (ex: `process_payment`, `archive_old_records`)
- Triggers: `trg_{table}_{event}` (ex: `trg_users_before_insert`, `trg_orders_after_update`)

### Views e Materialized Views
- Views: **snake_case**, descritivas (ex: `user_summary`, `order_statistics`)
- Materialized views: prefixo `mv_` (ex: `mv_daily_sales`, `mv_user_activity`)

### Nomes Descritivos
- ✅ **Bom**: `user_profiles`, `order_items`, `created_at`, `is_active`, `calculate_discount`
- ❌ **Ruim**: `tbl1`, `col1`, `flag`, `x`, `data`, `temp`, `calc`

## Design de Schema

### Normalização
- **Sempre** normalize até pelo menos 3NF (Third Normal Form)
- Evite redundância de dados
- Use foreign keys para manter integridade referencial
- Considere desnormalização apenas quando há benefício real de performance

```sql
-- ✅ Bom: Schema normalizado
CREATE TABLE users (
    id BIGSERIAL PRIMARY KEY,
    email VARCHAR(255) NOT NULL UNIQUE,
    name VARCHAR(100) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE orders (
    id BIGSERIAL PRIMARY KEY,
    user_id BIGINT NOT NULL REFERENCES users(id),
    total_amount DECIMAL(10, 2) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ❌ Ruim: Dados redundantes (desnormalizado sem necessidade)
CREATE TABLE orders (
    id BIGSERIAL PRIMARY KEY,
    user_id BIGINT NOT NULL,
    user_email VARCHAR(255) NOT NULL, -- Redundante!
    user_name VARCHAR(100) NOT NULL,  -- Redundante!
    total_amount DECIMAL(10, 2) NOT NULL
);
```

### Tipos de Dados
- Use tipos apropriados para cada dado
- Prefira tipos específicos sobre genéricos quando possível
- Use `BIGSERIAL` ou `BIGINT` para IDs (suporta mais registros)
- Use `DECIMAL` ou `NUMERIC` para valores monetários (nunca `FLOAT` ou `DOUBLE`)
- Use `TIMESTAMP WITH TIME ZONE` para timestamps (não `TIMESTAMP` sem timezone)
- Use `TEXT` para strings longas, `VARCHAR(n)` apenas quando há limite real
- Use `UUID` para identificadores distribuídos quando apropriado
- Use `JSONB` para dados semi-estruturados (mais eficiente que `JSON`)
- Use `ARRAY` quando apropriado (ex: tags, categorias)

```sql
-- ✅ Bom: Tipos apropriados
CREATE TABLE products (
    id BIGSERIAL PRIMARY KEY,
    sku VARCHAR(50) NOT NULL UNIQUE,
    name TEXT NOT NULL,
    description TEXT,
    price DECIMAL(10, 2) NOT NULL CHECK (price >= 0),
    tags TEXT[],
    metadata JSONB,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- ❌ Ruim: Tipos inadequados
CREATE TABLE products (
    id INTEGER PRIMARY KEY, -- Pode estourar!
    price FLOAT, -- Impreciso para valores monetários!
    created_at TIMESTAMP, -- Sem timezone!
    description VARCHAR(255) -- Limite arbitrário!
);
```

### Constraints e Validação
- **Sempre** use constraints para garantir integridade dos dados
- Use `NOT NULL` para campos obrigatórios
- Use `UNIQUE` para valores que devem ser únicos
- Use `CHECK` para validações de domínio
- Use `DEFAULT` para valores padrão quando apropriado
- Use foreign keys com `ON DELETE` e `ON UPDATE` adequados

```sql
-- ✅ Bom: Constraints adequadas
CREATE TABLE users (
    id BIGSERIAL PRIMARY KEY,
    email VARCHAR(255) NOT NULL UNIQUE,
    name VARCHAR(100) NOT NULL,
    age INTEGER CHECK (age >= 0 AND age <= 150),
    status VARCHAR(20) NOT NULL DEFAULT 'active' 
        CHECK (status IN ('active', 'inactive', 'suspended')),
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE orders (
    id BIGSERIAL PRIMARY KEY,
    user_id BIGINT NOT NULL REFERENCES users(id) ON DELETE RESTRICT,
    total_amount DECIMAL(10, 2) NOT NULL CHECK (total_amount >= 0),
    status VARCHAR(20) NOT NULL DEFAULT 'pending'
        CHECK (status IN ('pending', 'processing', 'completed', 'cancelled')),
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP
);
```

### Chaves Estrangeiras
- **Sempre** defina foreign keys para relacionamentos
- Use `ON DELETE RESTRICT` ou `ON DELETE CASCADE` conforme apropriado
- Use `ON DELETE SET NULL` apenas quando faz sentido no domínio
- Evite `ON DELETE NO ACTION` (use `RESTRICT` ao invés)
- Defina índices em colunas de foreign keys para melhor performance

```sql
-- ✅ Bom: Foreign keys bem definidas
CREATE TABLE order_items (
    id BIGSERIAL PRIMARY KEY,
    order_id BIGINT NOT NULL REFERENCES orders(id) ON DELETE CASCADE,
    product_id BIGINT NOT NULL REFERENCES products(id) ON DELETE RESTRICT,
    quantity INTEGER NOT NULL CHECK (quantity > 0),
    unit_price DECIMAL(10, 2) NOT NULL CHECK (unit_price >= 0)
);

-- Criar índice na foreign key para melhor performance
CREATE INDEX idx_order_items_order_id ON order_items(order_id);
CREATE INDEX idx_order_items_product_id ON order_items(product_id);
```

## Performance e Otimização

### Índices
- **Sempre** crie índices em foreign keys
- Crie índices em colunas frequentemente usadas em `WHERE`, `JOIN` e `ORDER BY`
- Use índices compostos para queries com múltiplas condições
- Ordene colunas em índices compostos por especificidade (mais específica primeiro)
- Use índices parciais quando apropriado (`WHERE` clause no índice)
- Monitore uso de índices e remova índices não utilizados
- Use `EXPLAIN ANALYZE` para analisar performance de queries

```sql
-- ✅ Bom: Índices adequados
CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_orders_user_id_created_at ON orders(user_id, created_at DESC);
CREATE INDEX idx_orders_status_created_at ON orders(status, created_at DESC) 
    WHERE status = 'pending'; -- Índice parcial

-- ✅ Bom: Índice único para constraint
CREATE UNIQUE INDEX uk_users_email ON users(email);

-- ❌ Ruim: Índice desnecessário
CREATE INDEX idx_users_name ON users(name); -- Se name nunca é usado em WHERE/JOIN
```

### Queries Otimizadas
- **Sempre** use `EXPLAIN ANALYZE` antes de otimizar queries
- Use `SELECT` específico (não `SELECT *`) quando possível
- Use `LIMIT` para limitar resultados quando apropriado
- Evite funções em colunas de `WHERE` (use índices funcionais se necessário)
- Use `EXISTS` ao invés de `IN` para subqueries quando apropriado
- Use `JOIN` ao invés de subqueries quando possível
- Evite `DISTINCT` desnecessário
- Use `UNION ALL` ao invés de `UNION` quando duplicatas não importam

```sql
-- ✅ Bom: Query otimizada
SELECT u.id, u.name, u.email
FROM users u
WHERE u.email = :email
LIMIT 1;

-- ✅ Bom: JOIN ao invés de subquery
SELECT o.id, o.total_amount, u.name
FROM orders o
JOIN users u ON o.user_id = u.id
WHERE u.email = :email;

-- ❌ Ruim: SELECT * e subquery desnecessária
SELECT *
FROM orders
WHERE user_id IN (
    SELECT id FROM users WHERE email = :email
);
```

### Paginação Eficiente
- Use `LIMIT` e `OFFSET` para paginação simples
- Para grandes datasets, considere cursor-based pagination (usando `WHERE id > :last_id`)
- Use `OFFSET` apenas para pequenos offsets (não escalável para grandes offsets)

```sql
-- ✅ Bom: Paginação simples (para pequenos offsets)
SELECT id, name, email
FROM users
ORDER BY created_at DESC
LIMIT 20 OFFSET 0;

-- ✅ Bom: Cursor-based pagination (escalável)
SELECT id, name, email
FROM users
WHERE id > :last_id
ORDER BY id
LIMIT 20;
```

### Vacuum e Analyze
- Execute `VACUUM` regularmente para recuperar espaço e atualizar estatísticas
- Execute `VACUUM ANALYZE` após mudanças significativas nos dados
- Configure `autovacuum` adequadamente no `postgresql.conf`
- Use `VACUUM FULL` apenas quando necessário (bloqueia tabela)

```sql
-- ✅ Bom: Manutenção regular
VACUUM ANALYZE users;
VACUUM ANALYZE orders;

-- Para tabelas grandes, use VACUUM sem bloquear
VACUUM VERBOSE users;
```

### Connection Pooling
- Configure connection pooling adequadamente (pgBouncer, Pgpool-II, ou HikariCP no aplicativo)
- Não mantenha conexões abertas desnecessariamente
- Use pool de conexões com tamanho adequado (não muito grande nem muito pequeno)
- Monitore número de conexões ativas

### Particionamento
- Considere particionamento para tabelas muito grandes (>10GB)
- Use particionamento por range ou por hash conforme apropriado
- Particione por coluna frequentemente usada em queries (ex: `createdAt`, `userId`)

```sql
-- ✅ Bom: Tabela particionada por data
CREATE TABLE orders (
    id BIGSERIAL,
    user_id BIGINT NOT NULL,
    total_amount DECIMAL(10, 2) NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id, created_at)
) PARTITION BY RANGE (created_at);

CREATE TABLE orders_2024_q1 PARTITION OF orders
    FOR VALUES FROM ('2024-01-01') TO ('2024-04-01');
    
CREATE TABLE orders_2024_q2 PARTITION OF orders
    FOR VALUES FROM ('2024-04-01') TO ('2024-07-01');
```

## Segurança

### Permissões e Roles
- Use roles para gerenciar permissões (não conceda permissões diretamente a usuários)
- Siga o princípio do menor privilégio
- Crie roles específicos para diferentes contextos (ex: `app_readonly`, `app_readwrite`, `migration_user`)
- Revogue permissões desnecessárias

```sql
-- ✅ Bom: Roles e permissões adequadas
CREATE ROLE app_readonly;
CREATE ROLE app_readwrite;
CREATE ROLE migration_user;

-- Conceder permissões
GRANT CONNECT ON DATABASE mydb TO app_readonly, app_readwrite, migration_user;
GRANT USAGE ON SCHEMA public TO app_readonly, app_readwrite, migration_user;
GRANT SELECT ON ALL TABLES IN SCHEMA public TO app_readonly;
GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA public TO app_readwrite;
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO migration_user;

-- Atribuir roles a usuários
CREATE USER app_user WITH PASSWORD 'secure_password';
GRANT app_readwrite TO app_user;
```

### Proteção contra SQL Injection
- **Nunca** construa queries concatenando strings
- **Sempre** use prepared statements ou parâmetros nomeados
- Valide e sanitize inputs antes de usar em queries
- Use ORM ou query builders que protegem contra SQL injection

```sql
-- ✅ Bom: Prepared statement (do aplicativo)
-- Java/JPA já faz isso automaticamente com @Query e parâmetros

-- ❌ Perigoso: SQL Injection
-- SELECT * FROM users WHERE email = '" + email + "'
```

### Dados Sensíveis
- **Nunca** armazene senhas em texto plano - use hash (bcrypt, argon2)
- Use criptografia para dados sensíveis quando necessário (`pgcrypto`)
- Não logue dados sensíveis
- Use variáveis de ambiente para credenciais de conexão

```sql
-- ✅ Bom: Hash de senha (do aplicativo, não do banco)
-- Senhas devem ser hasheadas no aplicativo antes de inserir

-- ✅ Bom: Criptografia de dados sensíveis
CREATE EXTENSION IF NOT EXISTS pgcrypto;

CREATE TABLE users (
    id BIGSERIAL PRIMARY KEY,
    email VARCHAR(255) NOT NULL UNIQUE,
    encrypted_ssn BYTEA -- Criptografado
);
```

### Auditoria
- Considere criar tabelas de auditoria para mudanças críticas
- Use triggers para registrar mudanças automaticamente
- Mantenha histórico de alterações quando necessário

```sql
-- ✅ Bom: Tabela de auditoria
CREATE TABLE audit_logs (
    id BIGSERIAL PRIMARY KEY,
    table_name VARCHAR(100) NOT NULL,
    record_id BIGINT NOT NULL,
    action VARCHAR(20) NOT NULL CHECK (action IN ('INSERT', 'UPDATE', 'DELETE')),
    old_values JSONB,
    new_values JSONB,
    changed_by VARCHAR(100),
    changed_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- Trigger de exemplo (simplificado)
CREATE OR REPLACE FUNCTION audit_trigger()
RETURNS TRIGGER AS $$
BEGIN
    IF TG_OP = 'DELETE' THEN
        INSERT INTO audit_logs (table_name, record_id, action, old_values)
        VALUES (TG_TABLE_NAME, OLD.id, TG_OP, row_to_json(OLD));
        RETURN OLD;
    ELSIF TG_OP = 'UPDATE' THEN
        INSERT INTO audit_logs (table_name, record_id, action, old_values, new_values)
        VALUES (TG_TABLE_NAME, NEW.id, TG_OP, row_to_json(OLD), row_to_json(NEW));
        RETURN NEW;
    ELSIF TG_OP = 'INSERT' THEN
        INSERT INTO audit_logs (table_name, record_id, action, new_values)
        VALUES (TG_TABLE_NAME, NEW.id, TG_OP, row_to_json(NEW));
        RETURN NEW;
    END IF;
END;
$$ LANGUAGE plpgsql;
```

## Migrations

### Versionamento
- **Sempre** use migrations versionadas (Flyway ou Liquibase)
- Nunca modifique migrations já aplicadas em produção
- Crie novas migrations para mudanças
- Teste migrations em ambiente de desenvolvimento primeiro
- Use nomenclatura consistente (ex: `V1__Create_Users_table.sql`)

### Boas Práticas de Migrations
- Mantenha migrations pequenas e atômicas
- Uma migration = uma mudança lógica
- Use transações para migrations (Flyway faz isso automaticamente)
- Inclua rollback quando possível (Liquibase suporta)
- Documente migrations complexas

```sql
-- ✅ Bom: Migration bem estruturada
-- V1__Create_Users_table.sql
CREATE TABLE users (
    id BIGSERIAL PRIMARY KEY,
    email VARCHAR(255) NOT NULL UNIQUE,
    name VARCHAR(100) NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_users_email ON users(email);

COMMENT ON TABLE users IS 'Tabela de usuários do sistema';
COMMENT ON COLUMN users.email IS 'Email único do usuário';
```

### Migrations Destrutivas
- **Sempre** faça backup antes de migrations destrutivas
- Documente claramente migrations que removem dados
- Considere criar migrations em duas etapas (adicionar nova coluna, migrar dados, remover antiga)
- Use `IF EXISTS` para evitar erros em objetos que podem não existir

```sql
-- ✅ Bom: Migration segura (duas etapas)
-- V10__Add_new_column.sql
ALTER TABLE users ADD COLUMN new_email VARCHAR(255);
CREATE INDEX idx_users_new_email ON users(new_email);

-- V11__Migrate_data.sql
UPDATE users SET new_email = email WHERE new_email IS NULL;

-- V12__Remove_old_column.sql (após validação)
-- ALTER TABLE users DROP COLUMN email; -- Apenas após validação completa
```

## Queries e Funções

### Funções SQL
- Use funções para lógica reutilizável
- Documente funções com comentários
- Use `IMMUTABLE`, `STABLE`, ou `VOLATILE` adequadamente
- Prefira funções simples sobre funções complexas

```sql
-- ✅ Bom: Função bem documentada
CREATE OR REPLACE FUNCTION calculate_discount(
    price DECIMAL,
    discount_percent DECIMAL
) RETURNS DECIMAL AS $$
    /**
     * Calcula o preço com desconto aplicado
     * @param price Preço original
     * @param discount_percent Percentual de desconto (0-100)
     * @return Preço com desconto aplicado
     */
BEGIN
    RETURN price * (1 - discount_percent / 100);
END;
$$ LANGUAGE plpgsql IMMUTABLE;

COMMENT ON FUNCTION calculate_discount IS 'Calcula preço com desconto aplicado';
```

### Views
- Use views para simplificar queries complexas
- Use materialized views para dados que não mudam frequentemente
- Atualize materialized views regularmente (`REFRESH MATERIALIZED VIEW`)

```sql
-- ✅ Bom: View para simplificar query complexa
CREATE OR REPLACE VIEW user_order_summary AS
SELECT 
    u.id AS user_id,
    u.name,
    u.email,
    COUNT(o.id) AS total_orders,
    SUM(o.total_amount) AS total_spent,
    MAX(o.created_at) AS last_order_date
FROM users u
LEFT JOIN orders o ON u.id = o.user_id
GROUP BY u.id, u.name, u.email;

-- ✅ Bom: Materialized view para dados agregados
CREATE MATERIALIZED VIEW mv_daily_sales AS
SELECT 
    DATE(created_at) AS sale_date,
    COUNT(*) AS order_count,
    SUM(total_amount) AS total_revenue
FROM orders
GROUP BY DATE(created_at);

CREATE UNIQUE INDEX ON mv_daily_sales(sale_date);

-- Atualizar materialized view
REFRESH MATERIALIZED VIEW CONCURRENTLY mv_daily_sales;
```

## Backup e Recuperação

### Estratégia de Backup
- Configure backups automáticos regulares
- Use `pg_dump` para backups lógicos
- Use `pg_basebackup` para backups físicos (WAL archiving)
- Teste restauração de backups regularmente
- Mantenha múltiplos backups (diário, semanal, mensal)

### Backup Lógico
```bash
# ✅ Bom: Backup completo
pg_dump -h localhost -U postgres -d mydb -F c -f backup_$(date +%Y%m%d).dump

# ✅ Bom: Backup apenas schema
pg_dump -h localhost -U postgres -d mydb --schema-only -f schema_backup.sql

# ✅ Bom: Backup apenas dados
pg_dump -h localhost -U postgres -d mydb --data-only -f data_backup.sql
```

### Restauração
```bash
# ✅ Bom: Restaurar backup
pg_restore -h localhost -U postgres -d mydb -c backup_20240101.dump
```

## Monitoramento

### Queries Lentas
- Use `pg_stat_statements` para identificar queries lentas
- Monitore `pg_stat_activity` para queries ativas
- Configure alertas para queries que excedem threshold de tempo

```sql
-- ✅ Bom: Habilitar pg_stat_statements
CREATE EXTENSION IF NOT EXISTS pg_stat_statements;

-- Ver queries mais lentas
SELECT 
    query,
    calls,
    total_exec_time,
    mean_exec_time,
    max_exec_time
FROM pg_stat_statements
ORDER BY mean_exec_time DESC
LIMIT 10;
```

### Estatísticas
- Monitore tamanho de tabelas e índices
- Monitore uso de conexões
- Monitore locks e deadlocks
- Configure alertas para problemas comuns

```sql
-- ✅ Bom: Ver tamanho de tabelas
SELECT 
    schemaname,
    tablename,
    pg_size_pretty(pg_total_relation_size(schemaname||'.'||tablename)) AS size
FROM pg_tables
WHERE schemaname = 'public'
ORDER BY pg_total_relation_size(schemaname||'.'||tablename) DESC;

-- ✅ Bom: Ver conexões ativas
SELECT 
    pid,
    usename,
    application_name,
    client_addr,
    state,
    query_start,
    state_change
FROM pg_stat_activity
WHERE datname = current_database();
```

## Boas Práticas Adicionais

### Comentários e Documentação
- Use `COMMENT ON` para documentar tabelas, colunas e funções
- Mantenha documentação atualizada
- Documente decisões arquiteturais importantes

```sql
-- ✅ Bom: Documentação adequada
COMMENT ON TABLE users IS 'Tabela principal de usuários do sistema';
COMMENT ON COLUMN users.email IS 'Email único do usuário, usado para login';
COMMENT ON COLUMN users.created_at IS 'Timestamp de criação do registro';
```

### Variáveis de Ambiente
- Use variáveis de ambiente para configurações de conexão
- Não hardcode credenciais em código
- Use diferentes credenciais para diferentes ambientes

### Git e Versionamento
- Commite migrations junto com código relacionado
- Use mensagens de commit descritivas
- Um commit = uma migration lógica
- Siga o padrão: `tipo: descrição curta` (ex: `feat: adiciona tabela de produtos`)

## Skills Recomendadas

Quando esta regra for ativada, as seguintes skills são as mais adequadas para auxiliar no desenvolvimento:

- **postgresql**: Para regras específicas do PostgreSQL 18 (nomenclatura, design de schema, tipos de dados, migrations)
- **database**: Para design de schema, normalização, índices e otimização de queries
- **database-architect**: Para arquitetura de camada de dados, tecnologia de banco e escalabilidade
- **rule-postgresql**: Para padrões específicos de desenvolvimento com PostgreSQL (nomenclatura snake_case, migrations Flyway)

## Checklist Antes de Commitar

Antes de fazer commit, verifique:
- [ ] Migration testada em ambiente de desenvolvimento
- [ ] Nomenclatura consistente (snake_case para tabelas e colunas, sem aspas)
- [ ] Constraints adequadas (NOT NULL, UNIQUE, CHECK, FOREIGN KEY)
- [ ] Índices criados em foreign keys e colunas frequentemente consultadas
- [ ] Tipos de dados apropriados
- [ ] Comentários em objetos complexos
- [ ] Queries otimizadas (usar EXPLAIN ANALYZE)
- [ ] Sem dados sensíveis em texto plano
- [ ] Permissões configuradas adequadamente
- [ ] Backup realizado antes de migrations destrutivas
- [ ] Rollback testado quando possível

## Documentação

- Documente decisões arquiteturais importantes
- Mantenha documentação de schema atualizada
- Documente migrations complexas
- Inclua exemplos de uso de funções e views complexas
- Documente estratégia de backup e recuperação