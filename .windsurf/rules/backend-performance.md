---
trigger: model_decision
description: Regras de performance e otimização: gerenciamento de memória, caching, otimizações de JVM e strings. Para otimizações de banco de dados, consulte postgresql.mdc.
globs:
---
# Regras de Desenvolvimento - Performance e Otimização

## Princípios Gerais

- **Sempre** meça antes de otimizar - use profiling tools (JProfiler, VisualVM, JFR)
- Otimize apenas onde há gargalos reais identificados
- Priorize código legível sobre micro-otimizações prematuras
- Use ferramentas de monitoramento em produção (Micrometer, Prometheus)

**Nota**: Para otimizações específicas de acesso ao banco de dados (N+1 queries, paginação, projeções), consulte `backend-data.mdc`. Para otimizações de queries SQL e índices, consulte `postgresql.mdc`.

## Gerenciamento de Memória

- Use objetos imutáveis quando possível (`final`, `record` em Java 14+)
- Evite vazamentos de memória (feche recursos, limpe collections grandes)
- Use `WeakReference` ou `SoftReference` para caches quando apropriado
- Configure JVM heap adequadamente (`-Xmx`, `-Xms`)
- Monitore uso de memória com ferramentas (VisualVM, JProfiler)
- Use streaming para processar grandes volumes de dados

```java
// ✅ Bom: Uso de records (imutáveis, eficientes em memória)
public record UserDTO(Long id, String name, String email) {}

// ✅ Bom: Streaming para grandes volumes
public void processLargeDataset(List<Data> data) {
    data.stream()
        .filter(this::isValid)
        .map(this::transform)
        .forEach(this::save);
}

// ✅ Bom: Limpeza de recursos
public class ResourceManager implements AutoCloseable {
    private final List<Connection> connections = new ArrayList<>();
    
    public void addConnection(Connection conn) {
        connections.add(conn);
    }
    
    @Override
    public void close() {
        connections.forEach(conn -> {
            try {
                conn.close();
            } catch (Exception e) {
                logger.error("Erro ao fechar conexão", e);
            }
        });
        connections.clear();
    }
}
```

## Caching

- Use Spring Cache (`@Cacheable`, `@CacheEvict`) para dados frequentemente acessados
- Configure TTL (Time To Live) adequadamente
- Use cache distribuído (Redis) para aplicações em cluster
- Invalide cache quando dados são modificados
- Monitore hit rate do cache

```java
// ✅ Bom: Cache com Spring
@Service
public class UserService {
    
    @Cacheable(value = "users", key = "#id")
    public UserDTO getUserById(Long id) {
        return userRepository.findById(id)
            .map(this::toDTO)
            .orElseThrow();
    }
    
    @CacheEvict(value = "users", key = "#user.id")
    public UserDTO updateUser(User user) {
        User updated = userRepository.save(user);
        return toDTO(updated);
    }
    
    @CacheEvict(value = "users", allEntries = true)
    public void clearUserCache() {
        // Limpa todo o cache de usuários
    }
}

// ✅ Bom: Configuração de cache
@Configuration
@EnableCaching
public class CacheConfig {
    
    @Bean
    public CacheManager cacheManager() {
        RedisCacheManager.Builder builder = RedisCacheManager
            .RedisCacheManagerBuilder
            .fromConnectionFactory(redisConnectionFactory())
            .cacheDefaults(cacheConfiguration());
        return builder.build();
    }
    
    private RedisCacheConfiguration cacheConfiguration() {
        return RedisCacheConfiguration.defaultCacheConfig()
            .entryTtl(Duration.ofMinutes(10))
            .serializeKeysWith(RedisSerializationContext.SerializationPair
                .fromSerializer(new StringRedisSerializer()))
            .serializeValuesWith(RedisSerializationContext.SerializationPair
                .fromSerializer(new GenericJackson2JsonRedisSerializer()));
    }
}
```

## Otimizações de JVM

- Configure garbage collector adequadamente (G1GC para aplicações modernas)
- Use JVM flags apropriadas (`-XX:+UseG1GC`, `-XX:MaxGCPauseMillis`)
- Configure metaspace adequadamente (`-XX:MetaspaceSize`)
- Use profiling em produção (Java Flight Recorder - JFR)
- Monitore GC logs e ajuste conforme necessário

```properties
# ✅ Bom: Configuração JVM recomendada (application.properties ou variáveis de ambiente)
# JAVA_OPTS=-Xmx2g -Xms2g -XX:+UseG1GC -XX:MaxGCPauseMillis=200 -XX:MetaspaceSize=256m
```

## Otimizações de Strings

- Use `StringBuilder` ou `StringBuffer` para concatenações em loops
- Prefira `String.format()` ou template engines para strings complexas
- Use `intern()` com cuidado (pode causar vazamento de memória)

```java
// ✅ Bom: StringBuilder para concatenações
public String buildMessage(List<String> parts) {
    StringBuilder sb = new StringBuilder();
    for (String part : parts) {
        sb.append(part).append(" ");
    }
    return sb.toString().trim();
}

// ❌ Ruim: Concatenação em loop (cria muitos objetos)
public String buildMessageBad(List<String> parts) {
    String result = "";
    for (String part : parts) {
        result += part + " "; // Ineficiente
    }
    return result.trim();
}
```

## Skills Recomendadas

Quando esta regra for ativada, as seguintes skills são as mais adequadas para auxiliar no desenvolvimento:

- **performance-optimizer**: Para identificação e correção de gargalos de performance em código, banco de dados e APIs
- **backend-performance-performance-optimization**: Para otimizações específicas de backend (JVM, caching, memória)
- **backend-dev-guidelines**: Para padrões de performance no desenvolvimento backend

## Módulos Relacionados

Para regras relacionadas, consulte:

- **backend-core.mdc**: Princípios fundamentais e padrões básicos
- **backend-data.mdc**: Para otimizações específicas de acesso ao banco de dados (N+1 queries, paginação, projeções)
- **backend-concurrency.mdc**: Para otimizações relacionadas a multi-threading e concorrência
- **postgresql.mdc**: Para otimizações de queries SQL e índices
- **backend-checklist.mdc**: Checklist consolidado para verificação antes de commit
