---
trigger: model_decision
description: Regras para acesso a dados: Spring Data JPA, repositories, lazy loading, MapStruct, batch processing e migrations. Consulte postgresql.mdc para questões específicas do PostgreSQL.
globs:
---
# Regras de Desenvolvimento - Acesso a Dados

## Estrutura de Repositories (Acesso ao Banco)

```java
package com.seudominio.aplicacao.repository;

import com.seudominio.aplicacao.dto.UserDTO;
import com.seudominio.aplicacao.model.User;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface UserRepository extends JpaRepository<User, Long> {

    @Query("SELECT new com.seudominio.aplicacao.dto.UserDTO(" +
           "u.id, u.name, u.email " +
           ") FROM User u " +
           "ORDER BY u.name")
    List<UserDTO> findAllUsers();
    
    Optional<User> findByEmail(String email);
}
```

## Spring Data JPA

- Use interfaces que estendem `JpaRepository` ou `CrudRepository`
- Use Query Methods quando possível (mais legível)
- Use `@Query` para queries complexas
- Use `@EntityGraph` para evitar N+1 queries
- Use projeções DTO para otimizar queries
- **Configure lazy loading adequadamente** - padrão é `LAZY` para `@OneToMany` e `@ManyToMany`
- Use `@Transactional` em services para manter contexto de persistência e evitar LazyInitializationException
- Prefira `@EntityGraph` ou JOIN FETCH para carregar relacionamentos específicos quando necessário
- Use `EAGER` apenas quando realmente necessário e seguro

```java
// ✅ Bom: Query Methods e Entity Graph
public interface UserRepository extends JpaRepository<User, Long> {
    
    @EntityGraph(attributePaths = {"profile"})
    List<User> findAll();
    
    @EntityGraph(attributePaths = {"orders", "addresses"})
    Optional<User> findByIdWithRelations(Long id);
    
    Optional<User> findByEmail(String email);
    
    // ✅ Bom: JOIN FETCH para evitar N+1
    @Query("SELECT u FROM User u JOIN FETCH u.orders WHERE u.id = :id")
    Optional<User> findByIdWithOrders(Long id);
}
```

## PostgreSQL 18

- **Consulte o arquivo de regras dedicado do PostgreSQL** (`postgresql.mdc`) para:
  - Design de schema e normalização
  - Nomenclatura de tabelas, colunas, índices e constraints
  - Performance e otimização de queries
  - Migrations e versionamento de schema
  - Segurança e permissões
  - Backup e recuperação
  - Monitoramento e manutenção
- Use Flyway para migrations (configurado no Spring Boot)
- Use Spring Data JPA para abstrair acesso ao banco (veja seção "Acesso ao Banco de Dados" abaixo)

## Acesso ao Banco de Dados

- Use Spring Data JPA para acesso ao banco
- Configure connection pooling (HikariCP é padrão no Spring Boot)
- Use `@Transactional` para transações
- Feche recursos adequadamente (Spring faz isso automaticamente)
- Use transações para operações múltiplas
- **Nota**: Para questões específicas do PostgreSQL (queries, índices, performance de banco), consulte o arquivo de regras dedicado (`postgresql.mdc`)

```properties
# ✅ Bom: Configuração de conexão (application.properties)
spring.datasource.url=jdbc:postgresql://localhost:5432/aplicacao
spring.datasource.username=${DB_USER}
spring.datasource.password=${DB_PASSWORD}
spring.datasource.hikari.maximum-pool-size=20
spring.datasource.hikari.minimum-idle=5
spring.datasource.hikari.connection-timeout=30000
```

## Performance - Acesso ao Banco de Dados

- Use connection pooling adequado (HikariCP configurado pelo Spring Boot)
- Implemente cache quando apropriado (Spring Cache, Redis)
- **Para criação de índices e otimização de queries SQL**, consulte o arquivo de regras do PostgreSQL (`postgresql.mdc`)
- Evite N+1 queries - use `@EntityGraph` ou JOIN FETCH
- Use paginação para listas grandes (`Pageable`)
- Use projeções DTO quando não precisar de entidades completas
- Configure batch processing para operações em lote
- Use `@QueryHints` para otimizar queries específicas

```java
// ✅ Bom: Paginação e projeção
@Query("SELECT new com.seudominio.aplicacao.dto.UserSummaryDTO(" +
       "u.id, u.name) FROM User u")
Page<UserSummaryDTO> findAllUserSummaries(Pageable pageable);

// ✅ Bom: Entity Graph para evitar N+1
@EntityGraph(attributePaths = {"profile", "addresses"})
List<User> findAllWithRelations();

// ✅ Bom: Query hints para otimização
@QueryHints({
    @QueryHint(name = "org.hibernate.fetchSize", value = "50"),
    @QueryHint(name = "org.hibernate.cacheable", value = "true")
})
List<User> findAllCached();
```

**Nota**: Para otimizações de performance mais amplas, consulte `backend-performance.mdc`.

## Lazy Loading e Eager Loading

- **Configure lazy loading adequadamente** - padrão do JPA é `LAZY` para `@OneToMany` e `@ManyToMany`
- Use `EAGER` apenas quando necessário e seguro (evite em relacionamentos grandes)
- Prefira `@EntityGraph` ou JOIN FETCH para carregar relacionamentos específicos quando necessário
- Evite lazy loading fora de contexto transacional (LazyInitializationException)
- Use `@Transactional` em services para manter contexto de persistência
- Considere usar DTOs com projeções ao invés de entidades completas

```java
// ✅ Bom: Lazy loading configurado corretamente
@Entity
public class User {
    @OneToMany(fetch = FetchType.LAZY) // Padrão, mas explícito
    private List<Order> orders;
    
    @ManyToOne(fetch = FetchType.EAGER) // Apenas se sempre necessário
    private Profile profile;
}

// ✅ Bom: Carregamento sob demanda com Entity Graph
@EntityGraph(attributePaths = {"orders"})
Optional<User> findByIdWithOrders(Long id);

// ✅ Bom: JOIN FETCH em queries customizadas
@Query("SELECT u FROM User u JOIN FETCH u.orders WHERE u.id = :id")
Optional<User> findByIdWithOrdersFetch(Long id);

// ❌ Ruim: Lazy loading fora de transação
public UserDTO getUser(Long id) {
    User user = repository.findById(id).orElseThrow();
    // LazyInitializationException se orders não foram carregados
    return new UserDTO(user.getId(), user.getOrders().size());
}

// ✅ Bom: Lazy loading dentro de transação
@Transactional(readOnly = true)
public UserDTO getUser(Long id) {
    User user = repository.findByIdWithOrders(id).orElseThrow();
    return new UserDTO(user.getId(), user.getOrders().size());
}
```

## Mapeamento Entity <-> DTO com MapStruct

- **Sempre** use **MapStruct** para mapeamento entre Entity e DTO em projetos grandes
- MapStruct gera código de mapeamento em tempo de compilação (type-safe, sem reflection, super rápido)
- Evite mapeamento manual ou bibliotecas baseadas em reflection (BeanUtils, ModelMapper) para melhor performance
- Configure MapStruct no `build.gradle` e crie interfaces de mapper

**Configuração no build.gradle:**
```gradle
plugins {
    id 'org.mapstruct' version '1.5.5.Final'
}

dependencies {
    implementation 'org.mapstruct:mapstruct:1.5.5.Final'
    annotationProcessor 'org.mapstruct:mapstruct-processor:1.5.5.Final'
}
```

**Exemplo de uso:**
```java
// ✅ Bom: Mapper com MapStruct
@Mapper(componentModel = "spring")
public interface UserMapper {
    
    UserDTO toDTO(User user);
    
    List<UserDTO> toDTOList(List<User> users);
    
    User toEntity(UserDTO dto);
    
    @Mapping(target = "id", ignore = true)
    @Mapping(target = "createdAt", ignore = true)
    User updateEntityFromDTO(UserDTO dto, @MappingTarget User user);
}

// ✅ Bom: Uso no Service
@Service
public class UserService {
    
    private final UserRepository userRepository;
    private final UserMapper userMapper;
    
    public UserService(UserRepository userRepository, UserMapper userMapper) {
        this.userRepository = userRepository;
        this.userMapper = userMapper;
    }
    
    public UserDTO getUserById(Long id) {
        User user = userRepository.findById(id).orElseThrow();
        return userMapper.toDTO(user);
    }
    
    public List<UserDTO> getAllUsers() {
        List<User> users = userRepository.findAll();
        return userMapper.toDTOList(users);
    }
}
```

**Benefícios do MapStruct:**
- **Type-safe**: Erros de compilação ao invés de runtime
- **Performance**: Código gerado é tão rápido quanto mapeamento manual
- **Sem reflection**: Zero overhead de runtime
- **Manutenibilidade**: Mudanças em Entity/DTO são detectadas em compile-time

**Nota**: Para DTOs simples, você pode usar `record` com MapStruct. O MapStruct suporta records nativamente.

## Batch Processing

- Use `@Transactional` com batch size para operações em lote
- Configure `hibernate.jdbc.batch_size` para inserções/atualizações em lote
- Use `saveAll()` com cuidado - pode ser ineficiente para grandes volumes
- Considere usar `EntityManager.flush()` e `clear()` para grandes batches

```java
// ✅ Bom: Batch processing eficiente
@Service
public class BatchService {
    
    @Transactional
    public void saveUsersInBatch(List<User> users) {
        int batchSize = 50;
        for (int i = 0; i < users.size(); i++) {
            userRepository.save(users.get(i));
            if (i % batchSize == 0 && i > 0) {
                entityManager.flush();
                entityManager.clear();
            }
        }
    }
}

// ✅ Bom: Configuração de batch no application.properties
# spring.jpa.properties.hibernate.jdbc.batch_size=50
# spring.jpa.properties.hibernate.order_inserts=true
# spring.jpa.properties.hibernate.order_updates=true
```

## Migrations

- **Consulte o arquivo de regras dedicado do PostgreSQL** (`postgresql.mdc`) para boas práticas de migrations
- Use Flyway para versionamento de migrations no Spring Boot
- Mantenha migrations pequenas e atômicas
- Teste migrations em ambiente de desenvolvimento primeiro
- Use nomenclatura consistente do Flyway (ex: `V1__Create_categorias_table.sql`)

## Skills Recomendadas

Quando esta regra for ativada, as seguintes skills são as mais adequadas para auxiliar no desenvolvimento:

- **database**: Para design de schema, otimização de queries, índices e boas práticas de banco de dados
- **database-architect**: Para arquitetura de camada de dados, tecnologia de banco, schema modeling e escalabilidade
- **backend-dev-guidelines**: Para padrões específicos de Spring Data JPA, repositories e MapStruct
- **postgresql**: Para regras específicas do PostgreSQL 18 (nomenclatura, migrations, performance)

## Módulos Relacionados

Para regras relacionadas, consulte:

- **backend-core.mdc**: Princípios fundamentais, estrutura e padrões básicos
- **backend-api.mdc**: Para uso de DTOs e MapStruct em controllers e services
- **backend-performance.mdc**: Para otimizações de performance relacionadas a acesso a dados
- **backend-security.mdc**: Para proteção contra SQL injection e segurança de dados
- **backend-testing.mdc**: Para testes de repositories e entidades JPA
- **postgresql.mdc**: Para questões específicas do PostgreSQL (queries, índices, performance de banco)
- **backend-checklist.mdc**: Checklist consolidado para verificação antes de commit
