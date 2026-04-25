---
trigger: always_on
description: Regras fundamentais de desenvolvimento backend: princípios, estrutura, nomenclatura, formatação e padrões básicos do Java e Spring Boot.
globs: 
---

# Regras de Desenvolvimento - Backend Core

## Stack Tecnológica

Este projeto utiliza:
- **Java 25** como linguagem de programação
- **Spring Boot** como framework principal
- **Spring Web** para HTTP server e rotas REST
- **Spring Data JPA** para acesso ao banco de dados
- **Gradle** como gerenciador de dependências e build
- **PostgreSQL 18** como banco de dados relacional
- **Flyway** para migrations
- **Bean Validation (Jakarta Validation)** para validação de dados
- **Spring Security** para autenticação e autorização (quando necessário)
- **Lombok** para reduzir boilerplate
- **SpringDoc OpenAPI (Swagger)** para documentação da API
- **MapStruct** para mapeamento performático entre Entity e DTO
- **Testcontainers** para testes de integração com banco real
- **Micrometer Tracing & OpenTelemetry** para observabilidade e tracing distribuído

## Princípios Gerais

### Código Limpo e Legível
- Sempre escreva código que seja fácil de entender para você e outros desenvolvedores
- Priorize clareza sobre concisão quando necessário
- Use nomes descritivos que expliquem o propósito do código
- Siga os princípios SOLID

### Consistência
- Mantenha estilo de codificação consistente em todo o projeto
- Siga os padrões estabelecidos no projeto
- Use as mesmas convenções de nomenclatura em arquivos relacionados
- Siga as convenções do Java (Java Code Conventions)

### Programação para Manutenção
- Escreva código pensando em quem vai mantê-lo no futuro
- Documente decisões complexas ou não óbvias
- Facilite a localização e correção de bugs
- Mantenha métodos pequenos e com responsabilidade única

## Organização e Estrutura

### Estrutura de Pastas
```
backend/
  ├── src/
  │   ├── main/
  │   │   ├── java/
  │   │   │   └── com/
  │   │   │       └── seudominio/
  │   │   │           └── aplicacao/
  │   │   │               ├── Application.java              # Classe principal Spring Boot
  │   │   │               ├── config/                      # Configurações da aplicação
  │   │   │               ├── controller/                  # Controllers REST (handlers)
  │   │   │               ├── service/                      # Lógica de negócio
  │   │   │               ├── repository/                   # Acesso ao banco de dados
  │   │   │               ├── model/                        # Entidades JPA e DTOs
  │   │   │               ├── dto/                          # Data Transfer Objects
  │   │   │               ├── exception/                    # Exceções customizadas
  │   │   │               ├── validator/                    # Validações customizadas
  │   │   │               └── util/                         # Funções utilitárias
  │   │   └── resources/
  │   │       ├── application.properties                    # Configurações (ou .yml)
  │   │       ├── application-dev.properties
  │   │       ├── application-prod.properties
  │   │       └── db/
  │   │           └── migration/                            # Scripts Flyway/Liquibase
  │   └── test/
  │       └── java/                                         # Testes
  ├── build.gradle                                          # Configuração Gradle
  ├── settings.gradle
  └── .env.example                                          # Exemplo de variáveis de ambiente
```

### Organização do Código: Package by Feature (Recomendado para ERPs)

Para projetos grandes como ERPs, prefira agrupar classes por domínio/funcionalidade ao invés de por camada técnica. Isso mantém o contexto coeso e facilita a modularização futura.

```
backend/src/main/java/com/seudominio/aplicacao/
  ├── Application.java              # Classe principal Spring Boot
  ├── config/                       # Configurações globais
  ├── shared/                       # Utilitários compartilhados
  │   ├── exception/                # Exceções customizadas
  │   ├── validator/                # Validações customizadas
  │   └── util/                     # Funções utilitárias
  └── modules/
      ├── user/                     # Módulo de Usuário
      │   ├── UserController.java
      │   ├── UserService.java
      │   ├── UserRepository.java
      │   ├── User.java             # Entidade JPA
      │   └── UserDTO.java
      ├── finance/                  # Módulo Financeiro
      │   ├── InvoiceController.java
      │   ├── InvoiceService.java
      │   ├── InvoiceRepository.java
      │   ├── Invoice.java
      │   └── InvoiceDTO.java
      └── product/                  # Módulo de Produtos
          ├── ProductController.java
          ├── ProductService.java
          ├── ProductRepository.java
          ├── Product.java
          └── ProductDTO.java
```

**Benefícios do Package by Feature:**
- **Coesão**: Classes relacionadas ficam juntas, facilitando navegação
- **Modularização**: Facilita extração futura para microsserviços
- **Escalabilidade**: Projetos grandes não viram "gavetas de bagunça"
- **Manutenibilidade**: Desenvolvedores encontram código relacionado mais rapidamente

**Nota**: A estrutura "Package by Layer" (controller/, service/, repository/) ainda é válida para projetos pequenos, mas para ERPs e sistemas complexos, Package by Feature é recomendado.

### Nomenclatura

#### Arquivos e Pacotes
- Pacotes: **lowercase**, palavras separadas por ponto (ex: `com.seudominio.aplicacao.controller`)
- Classes: **PascalCase** (ex: `UserController.java`, `UserService.java`)
- Testes: sufixo `Test` (ex: `UserControllerTest.java`)

#### Variáveis e Métodos
- Variáveis e métodos: **camelCase** (ex: `userName`, `getUserData()`)
- Constantes: **UPPER_SNAKE_CASE** (ex: `MAX_RETRY_ATTEMPTS`, `API_BASE_URL`)
- Classes e Interfaces: **PascalCase** (ex: `User`, `UserDTO`)
- Interfaces: **PascalCase**, geralmente terminando com o nome do serviço (ex: `UserService`, `UserRepository`)

#### Nomes Descritivos
- ✅ **Bom**: `getUserById()`, `calculateTotalPrice()`, `isUserAuthenticated()`
- ❌ **Ruim**: `get()`, `calc()`, `flag()`, `x`, `data`, `temp`

### Organização do Código

#### Estrutura de Services (Lógica de Negócio)
```java
package com.seudominio.aplicacao.service;

import com.seudominio.aplicacao.dto.UserDTO;
import com.seudominio.aplicacao.repository.UserRepository;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Service
@Transactional(readOnly = true)
public class UserService {

    private final UserRepository userRepository;

    public UserService(UserRepository userRepository) {
        this.userRepository = userRepository;
    }

    public List<UserDTO> getAllUsers() {
        return userRepository.findAllUsers();
    }
}
```

#### Funções e Métodos
- Mantenha métodos pequenos e com responsabilidade única
- Máximo de ~50 linhas por método quando possível
- Se um método faz mais de uma coisa, divida-o
- Use métodos auxiliares para lógica complexa
- Trate exceções explicitamente (não ignore exceções)

### Indentação e Formatação
- Use **4 espaços** para indentação (padrão do Java)
- Use `google-java-format` ou formatação do IDE para formatação automática
- Use `checkstyle` ou `spotbugs` para análise de código
- Mantenha linhas com máximo de 120 caracteres
- Use aspas duplas para strings

### Comentários

#### Comentários de Arquivo
```java
/**
 * Package: com.seudominio.aplicacao.controller
 * 
 * Contém os controllers REST para as rotas da API.
 * Este pacote é responsável por receber requisições HTTP, validar
 * dados de entrada e delegar a lógica de negócio para os services.
 */
package com.seudominio.aplicacao.controller;
```

#### Comentários no Código
- Comente apenas o **porquê**, não o **o quê**
- Comente lógica complexa ou não óbvia
- Evite comentários redundantes
- Use JavaDoc para métodos públicos

```java
// ✅ Bom: Explica o porquê
// Usamos transação para garantir atomicidade na criação de usuário e perfil
@Transactional
public void createUserWithProfile(User user, Profile profile) {
    // ...
}

// ❌ Ruim: Redundante
// Incrementa o contador
count++;
```

## Padrões Específicos do Stack

### Java
- Siga as convenções do Java (Java Code Conventions)
- Use `google-java-format` para formatação
- Use `checkstyle` ou `spotbugs` para análise de código
- Use interfaces para desacoplar dependências
- Prefira composição sobre herança
- Use enums para constantes relacionadas
- Use `Optional` para valores que podem ser nulos

### Spring Boot
- Use dependency injection (construtor preferido sobre `@Autowired` em campos)
- Use `@Configuration` para configurações
- Use profiles para diferentes ambientes (`application-dev.properties`, `application-prod.properties`)
- Aproveite auto-configuração do Spring Boot
- Use `@ConditionalOnProperty` quando apropriado
- Retorne DTOs, não entidades JPA diretamente

```java
// ✅ Bom: Dependency Injection por construtor
@Service
public class UserService {
    private final UserRepository userRepository;

    public UserService(UserRepository userRepository) {
        this.userRepository = userRepository;
    }
}
```

### Gradle
- Use `build.gradle.kts` (Kotlin DSL) ou `build.gradle` (Groovy)
- Organize dependências por escopo (implementation, testImplementation, etc.)
- Use version catalogs para gerenciar versões
- Configure tasks de build adequadamente
- Use plugins do Spring Boot

```gradle
// ✅ Bom: build.gradle
plugins {
    id 'org.springframework.boot' version '3.2.0'
    id 'io.spring.dependency-management' version '1.1.4'
    id 'java'
}

dependencies {
    implementation 'org.springframework.boot:spring-boot-starter-web'
    implementation 'org.springframework.boot:spring-boot-starter-data-jpa'
    implementation 'org.postgresql:postgresql'
    implementation 'org.springdoc:springdoc-openapi-starter-webmvc-ui:2.3.0'
    testImplementation 'org.springframework.boot:spring-boot-starter-test'
}
```

## Variáveis de Ambiente
- Use `application.properties` ou `application.yml` para configurações
- Use profiles para diferentes ambientes
- Documente todas as variáveis em `application.properties.example`
- Valide variáveis obrigatórias na inicialização
- Use tipos apropriados para variáveis

```java
// ✅ Bom: Configuração
@Configuration
@ConfigurationProperties(prefix = "app")
public class AppConfig {
    private String dbHost;
    private int dbPort;
    private String dbUser;
    private String dbPassword;
    private String dbName;
    
    // Getters e setters
}
```

## Git e Commits
- Faça commits frequentes e atômicos
- Use mensagens de commit descritivas
- Um commit = uma mudança lógica
- Siga o padrão: `tipo: descrição curta` (ex: `feat: adiciona endpoint de skills`)

**Nota**: Para padrões detalhados de commits, consulte o arquivo de regras `commit.mdc`.

## Documentação

- Documente apenas quando necessário no `README.md`
- Mantenha README atualizado
- Documente decisões arquiteturais importantes
- Inclua instruções de setup e desenvolvimento
- Documente endpoints da API usando Swagger/OpenAPI
- Documente versionamento da API e breaking changes

## Docs Oficiais
- Java Gradle - https://docs.gradle.org/9.2.1/javadoc/
- OpenJDK 25 - https://openjdk.org/projects/jdk/25/
- SpringBoot - https://docs.spring.io/spring-boot/documentation.html
- Spring Releases - https://spring.io/projects/spring-boot#learn

## Skills Recomendadas

Quando esta regra for ativada, as seguintes skills são as mais adequadas para auxiliar no desenvolvimento:

- **java-pro**: Para desenvolvimento Java moderno com Java 25, incluindo patterns de linguagem, enums, Optional e boas práticas
- **spring-boot**: Para configuração e uso específico do Spring Boot (auto-configuração, profiles, dependency injection)
- **backend-dev-guidelines**: Para padrões de desenvolvimento backend (arquitetura, estrutura, boas práticas)

## Módulos Relacionados

Este arquivo contém as regras fundamentais do backend. Para regras específicas, consulte:

- **backend-api.mdc**: Versionamento de API, controllers, DTOs, validação, tratamento de exceções, transações e Swagger/OpenAPI
- **backend-data.mdc**: Spring Data JPA, repositories, lazy loading, MapStruct, batch processing e migrations
- **backend-performance.mdc**: Otimizações de memória, caching, JVM e strings
- **backend-concurrency.mdc**: Multi-threading, Virtual Threads, @Async, CompletableFuture e thread safety
- **backend-security.mdc**: Validação de dados, proteção contra SQL injection, proteção de dados sensíveis, CORS e autenticação
- **backend-testing.mdc**: Testes unitários, testes de integração e Testcontainers
- **backend-observability.mdc**: Logging estruturado, Micrometer Tracing e OpenTelemetry
- **backend-checklist.mdc**: Checklist consolidado para verificação antes de commit
- **postgresql.mdc**: Regras específicas do PostgreSQL (design de schema, nomenclatura, performance, migrations)