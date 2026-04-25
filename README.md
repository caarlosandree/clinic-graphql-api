# Catalogo - API GraphQL para Gestão de Clínicas Médicas

API GraphQL desenvolvida com Spring Boot para gestão de clínicas médicas, permitindo o gerenciamento de clínicas, procedimentos, profissionais e agendamentos.

## 📋 Índice

- [Visão Geral](#visão-geral)
- [Stack Tecnológica](#stack-tecnológica)
- [Arquitetura](#arquitetura)
- [Modelo de Dados](#modelo-de-dados)
- [API GraphQL](#api-graphql)
- [Configuração e Setup](#configuração-e-setup)
- [Execução](#execução)
- [Desenvolvimento](#desenvolvimento)
- [Testes](#testes)
- [Migrations](#migrations)
- [Variáveis de Ambiente](#variáveis-de-ambiente)
- [Contribuição](#contribuição)
- [Licença](#licença)

## 🎯 Visão Geral

O **Catalogo** é uma API RESTful/GraphQL para gestão de clínicas médicas que permite:

- Cadastro e gerenciamento de clínicas
- Registro de procedimentos médicos com preços e duração
- Gestão de profissionais de saúde e especialidades
- Sistema de agendamentos com controle de status
- Relacionamentos entre todas as entidades do domínio

### Funcionalidades Principais

- **Queries**: Busca de clínicas, procedimentos, profissionais e agendamentos
- **Mutations**: Criação e atualização de entidades do sistema
- **Filtros**: Agendamentos por clínica e status
- **Validação**: Validação de dados de entrada com Bean Validation
- **Migrations**: Versionamento automático do schema do banco com Flyway

## 🛠 Stack Tecnológica

### Backend

- **Java 25**: Linguagem de programação
- **Spring Boot 4.0.6**: Framework principal
- **Spring GraphQL**: Implementação de GraphQL no Spring
- **Spring Data JPA**: Acesso ao banco de dados
- **Spring Validation**: Validação de dados
- **PostgreSQL 18**: Banco de dados relacional
- **Flyway**: Migrations de banco de dados
- **Lombok**: Redução de código boilerplate
- **spring-dotenv**: Suporte a variáveis de ambiente

### Ferramentas de Build

- **Gradle 9.x**: Gerenciador de build e dependências
- **JUnit 5**: Framework de testes
- **Spring Test**: Suporte a testes com Spring

## 🏗 Arquitetura

O projeto segue uma arquitetura organizada por domínio (Package by Feature):

```
src/main/java/com/example/catalogo/
├── CatalogoApplication.java          # Classe principal Spring Boot
├── config/                            # Configurações da aplicação
├── domain/                            # Domínios do negócio
│   ├── clinic/                       # Módulo de Clínicas
│   │   ├── Clinic.java              # Entidade JPA
│   │   ├── ClinicRepository.java    # Repository Spring Data JPA
│   │   ├── ClinicService.java       # Lógica de negócio
│   │   └── ClinicDTO.java           # Data Transfer Object
│   ├── procedure/                    # Módulo de Procedimentos
│   ├── professional/                 # Módulo de Profissionais
│   └── appointment/                  # Módulo de Agendamentos
├── graphql/                           # Camada GraphQL
│   ├── query/                        # Resolvers de Query
│   ├── mutation/                     # Resolvers de Mutation
│   └── input/                        # DTOs de Input GraphQL
├── exception/                         # Exceções customizadas
└── shared/                            # Utilitários compartilhados
```

### Princípios Arquiteturais

- **Package by Feature**: Agrupamento por domínio de negócio
- **Separation of Concerns**: Separação clara entre camadas
- **Dependency Injection**: Injeção de dependências via construtor
- **Transaction Management**: Transações declarativas com Spring
- **Validation**: Validação em múltiplas camadas

## 📊 Modelo de Dados

### Entidades

#### Clinic (Clínica)
- `id`: UUID (primary key)
- `name`: Nome da clínica
- `cnpj`: CNPJ (único)
- `phone`: Telefone
- `address`: Endereço
- `createdAt`: Timestamp de criação
- `updatedAt`: Timestamp de atualização

#### Procedure (Procedimento)
- `id`: UUID (primary key)
- `name`: Nome do procedimento
- `description`: Descrição
- `durationMinutes`: Duração em minutos
- `price`: Preço (NUMERIC 10,2)
- `clinicId`: FK para Clinic
- `createdAt`: Timestamp de criação
- `updatedAt`: Timestamp de atualização

#### Professional (Profissional)
- `id`: UUID (primary key)
- `name`: Nome do profissional
- `specialty`: Especialidade
- `clinicId`: FK para Clinic
- `createdAt`: Timestamp de criação
- `updatedAt`: Timestamp de atualização

#### Appointment (Agendamento)
- `id`: UUID (primary key)
- `patientName`: Nome do paciente
- `patientPhone`: Telefone do paciente
- `scheduledAt`: Data/hora agendada
- `status`: Status (SCHEDULED, CANCELLED, FINISHED)
- `clinicId`: FK para Clinic
- `procedureId`: FK para Procedure
- `professionalId`: FK para Professional
- `createdAt`: Timestamp de criação
- `updatedAt`: Timestamp de atualização

### Índices

- `idx_clinics_cnpj`: Índice único no CNPJ
- `idx_procedures_clinic_id`: Índice para busca por clínica
- `idx_professionals_clinic_id`: Índice para busca por clínica
- `idx_appointments_status`: Índice para busca por status
- `idx_appointments_clinic_id`: Índice para busca por clínica
- `idx_appointments_scheduled_at`: Índice para busca por data

## 🔌 API GraphQL

### Schema GraphQL

O schema GraphQL está disponível em `src/main/resources/graphql/schema.graphqls`.

### Queries

```graphql
type Query {
    clinics: [Clinic!]!
    clinicById(id: ID!): Clinic!
    proceduresByClinic(clinicId: ID!): [Procedure!]!
    professionalsByClinic(clinicId: ID!): [Professional!]!
    appointmentsByClinic(clinicId: ID!): [Appointment!]!
    appointmentsByStatus(status: AppointmentStatus!): [Appointment!]!
}
```

### Mutations

```graphql
type Mutation {
    createClinic(input: CreateClinicInput!): Clinic!
    createProcedure(input: CreateProcedureInput!): Procedure!
    createProfessional(input: CreateProfessionalInput!): Professional!
    createAppointment(input: CreateAppointmentInput!): Appointment!
    cancelAppointment(id: ID!): Appointment!
    finishAppointment(id: ID!): Appointment!
}
```

### Tipos

```graphql
enum AppointmentStatus {
    SCHEDULED
    CANCELLED
    FINISHED
}
```

### Exemplos de Uso

#### Criar Clínica

```graphql
mutation {
  createClinic(input: {
    name: "Clínica Saúde"
    cnpj: "12345678000190"
    phone: "11999999999"
    address: "Rua Example, 123"
  }) {
    id
    name
    cnpj
  }
}
```

#### Buscar Procedimentos por Clínica

```graphql
query {
  proceduresByClinic(clinicId: "uuid-da-clinica") {
    id
    name
    price
    durationMinutes
    clinic {
      name
    }
  }
}
```

#### Criar Agendamento

```graphql
mutation {
  createAppointment(input: {
    clinicId: "uuid-da-clinica"
    procedureId: "uuid-do-procedimento"
    professionalId: "uuid-do-profissional"
    patientName: "João Silva"
    patientPhone: "11988888888"
    scheduledAt: "2026-04-25T10:00:00"
  }) {
    id
    patientName
    status
    scheduledAt
  }
}
```

## ⚙️ Configuração e Setup

### Pré-requisitos

- **Java 25**: [Download JDK 25](https://openjdk.org/projects/jdk/25/)
- **Gradle 9.x**: [Download Gradle](https://gradle.org/install/)
- **PostgreSQL 18**: [Download PostgreSQL](https://www.postgresql.org/download/)
- **Docker** (opcional): Para containerização do banco de dados

### Instalação

1. **Clone o repositório**

```bash
git clone <repository-url>
cd catalogo
```

2. **Configure as variáveis de ambiente**

```bash
cp .env.example .env
```

Edite o arquivo `.env` com suas configurações:

```env
DB_HOST=localhost
DB_PORT=5432
DB_NAME=catalogo
DB_USER=postgres
DB_PASSWORD=sua-senha
```

3. **Configure o banco de dados PostgreSQL**

Crie o banco de dados:

```sql
CREATE DATABASE catalogo;
```

4. **Execute as migrations**

As migrations serão executadas automaticamente ao iniciar a aplicação via Flyway.

## 🚀 Execução

### Via Gradle

```bash
./gradlew bootRun
```

### Via Docker Compose

```bash
docker-compose up -d
```

A aplicação estará disponível em:
- **GraphQL Playground**: http://localhost:8080/graphiql
- **GraphQL Endpoint**: http://localhost:8080/graphql

## 💻 Desenvolvimento

### Estrutura de Código

O código segue as convenções do Java e Spring Boot:

- **Nomenclatura**: PascalCase para classes, camelCase para métodos/variáveis
- **Package by Feature**: Agrupamento por domínio de negócio
- **Dependency Injection**: Via construtor (sem `@Autowired` em campos)
- **Lombok**: Redução de código boilerplate
- **Validação**: Bean Validation (Jakarta Validation)

### Padrões de Código

- Services com `@Transactional(readOnly = true)` para operações de leitura
- Repositories Spring Data JPA para acesso a dados
- DTOs para transferência de dados entre camadas
- Exceções customizadas para tratamento de erros
- Logging estruturado para observabilidade

### Formatação e Lint

```bash
# Formatar código
./gradlew spotlessApply

# Executar checkstyle
./gradlew checkstyleMain
```

## 🧪 Testes

### Executar Testes

```bash
./gradlew test
```

### Testes de Integração

O projeto utiliza Spring Boot Test para testes de integração. Para testes que dependem de funcionalidades específicas do PostgreSQL, recomenda-se o uso de Testcontainers.

## 📦 Migrations

As migrations do banco de dados são gerenciadas pelo Flyway e estão localizadas em `src/main/resources/db/migration/`.

### Convenções de Nomenclatura

- `V{version}__{description}.sql`
- Exemplo: `V1__create_clinics_table.sql`

### Lista de Migrations

- `V1__create_clinics_table.sql`: Criação da tabela de clínicas
- `V2__create_procedures_table.sql`: Criação da tabela de procedimentos
- `V3__create_professionals_table.sql`: Criação da tabela de profissionais
- `V4__create_appointments_table.sql`: Criação da tabela de agendamentos

### Criar Nova Migration

1. Crie um novo arquivo SQL em `src/main/resources/db/migration/`
2. Siga a convenção de nomenclatura `V{version}__{description}.sql`
3. Execute a aplicação para aplicar a migration automaticamente

## 🔐 Variáveis de Ambiente

| Variável | Descrição | Padrão |
|----------|-----------|--------|
| `DB_HOST` | Host do PostgreSQL | `localhost` |
| `DB_PORT` | Porta do PostgreSQL | `5432` |
| `DB_NAME` | Nome do banco de dados | `catalogo` |
| `DB_USER` | Usuário do PostgreSQL | `catalogo` |
| `DB_PASSWORD` | Senha do PostgreSQL | `catalogo` |

## 🤝 Contribuição

1. Fork o repositório
2. Crie uma branch para sua feature (`git checkout -b feature/nova-feature`)
3. Faça commit das suas mudanças (`git commit -m 'feat: adiciona nova feature'`)
4. Push para a branch (`git push origin feature/nova-feature`)
5. Abra um Pull Request

### Padrões de Commit

Siga o padrão Conventional Commits:

- `feat`: Nova funcionalidade
- `fix`: Correção de bug
- `docs`: Mudanças na documentação
- `style`: Formatação, ponto e vírgula, etc.
- `refactor`: Refatoração de código
- `test`: Adição ou modificação de testes
- `chore`: Mudanças em build, configuração, etc.

## 📝 Licença

Este projeto está sob a licença MIT. Consulte o arquivo LICENSE para mais detalhes.

## 🔗 Links Úteis

- [Spring Boot Documentation](https://docs.spring.io/spring-boot/documentation.html)
- [Spring GraphQL Documentation](https://docs.spring.io/spring-graphql/reference/)
- [PostgreSQL Documentation](https://www.postgresql.org/docs/)
- [Flyway Documentation](https://flywaydb.org/documentation/)
- [GraphQL Specification](https://graphql.org/learn/)
- [Java 25 Documentation](https://openjdk.org/projects/jdk/25/)

---

Desenvolvido com ❤️ usando Spring Boot e GraphQL
