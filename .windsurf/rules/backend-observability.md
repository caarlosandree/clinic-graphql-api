---
trigger: model_decision
description: Regras de observabilidade: logging estruturado, Micrometer Tracing e OpenTelemetry para rastreamento distribuído e identificação de gargalos.
globs:
---
# Regras de Desenvolvimento - Observabilidade

## Logging

- Use SLF4J com Logback (padrão do Spring Boot)
- Log informações relevantes (sem dados sensíveis)
- Use níveis apropriados (DEBUG, INFO, WARN, ERROR)
- Inclua contexto nos logs (request ID, user ID, etc.)

```java
// ✅ Bom: Logging estruturado
private static final Logger logger = LoggerFactory.getLogger(UserController.class);

@GetMapping
public ResponseEntity<List<UserDTO>> getAllUsers() {
    logger.info("Buscando todos os usuários");
    List<UserDTO> users = userService.getAllUsers();
    logger.debug("Encontrados {} usuários", users.size());
    return ResponseEntity.ok(users);
}
```

**Nota**: Para proteção de dados sensíveis em logs, consulte `backend-security.mdc`.

## Observabilidade e Tracing

- Use **Micrometer Tracing** com **OpenTelemetry** para rastreamento distribuído e identificação de gargalos
- Tracing permite rastrear requisições através de múltiplos serviços e identificar onde ocorrem latências
- Configure spans customizados para operações críticas de negócio
- Integre com sistemas de observabilidade (Jaeger, Zipkin, Grafana Tempo) para visualização

**Configuração no build.gradle:**
```gradle
dependencies {
    implementation 'io.micrometer:micrometer-tracing-bridge-otel'
    implementation 'io.opentelemetry:opentelemetry-exporter-zipkin'
    // ou
    implementation 'io.opentelemetry:opentelemetry-exporter-jaeger'
}
```

**Configuração no application.properties:**
```properties
# ✅ Bom: Configuração de Tracing
management.tracing.sampling.probability=1.0
management.zipkin.tracing.endpoint=http://localhost:9411/api/v2/spans
# ou para Jaeger
management.jaeger.tracing.endpoint=http://localhost:14250
```

**Exemplo de uso com spans customizados:**
```java
// ✅ Bom: Tracing customizado em services
@Service
public class UserService {
    
    private final Tracer tracer;
    private final UserRepository userRepository;
    
    public UserService(Tracer tracer, UserRepository userRepository) {
        this.tracer = tracer;
        this.userRepository = userRepository;
    }
    
    public UserDTO getUserById(Long id) {
        Span span = tracer.nextSpan()
            .name("user-service.get-user")
            .tag("user.id", String.valueOf(id))
            .start();
        
        try (Tracer.SpanInScope ws = tracer.withSpanInScope(span)) {
            User user = userRepository.findById(id).orElseThrow();
            span.tag("user.found", "true");
            return userMapper.toDTO(user);
        } catch (Exception e) {
            span.tag("error", true);
            span.tag("error.message", e.getMessage());
            throw e;
        } finally {
            span.end();
        }
    }
}
```

**Benefícios do Tracing:**
- **Rastreamento distribuído**: Veja o caminho completo de uma requisição através de múltiplos serviços
- **Identificação de gargalos**: Identifique rapidamente onde ocorrem latências
- **Debugging**: Correlacione logs com traces usando trace IDs
- **Monitoramento**: Monitore performance de endpoints e operações críticas
- **Análise de dependências**: Entenda como serviços se relacionam

**Integração com Logging:**
```java
// ✅ Bom: Correlação de logs com traces
@GetMapping
public ResponseEntity<List<UserDTO>> getAllUsers() {
    String traceId = tracer.currentSpan().context().traceId();
    logger.info("Buscando todos os usuários [traceId={}]", traceId);
    List<UserDTO> users = userService.getAllUsers();
    return ResponseEntity.ok(users);
}
```

**Nota**: Para aplicações simples, o Spring Boot já configura tracing básico automaticamente. Use spans customizados apenas para operações críticas que precisam de rastreamento detalhado.

## Skills Recomendadas

Quando esta regra for ativada, as seguintes skills são as mais adequadas para auxiliar no desenvolvimento:

- **observability-engineer**: Para implementação de sistemas de observabilidade (logging, tracing, métricas)
- **backend-observability**: Para logging estruturado, Micrometer Tracing e OpenTelemetry
- **backend-dev-guidelines**: Para padrões de observabilidade no desenvolvimento backend

## Módulos Relacionados

Para regras relacionadas, consulte:

- **backend-core.mdc**: Princípios fundamentais e padrões básicos
- **backend-concurrency.mdc**: Para logging e tracing de operações assíncronas
- **backend-security.mdc**: Para proteção de dados sensíveis em logs
- **backend-checklist.mdc**: Checklist consolidado para verificação antes de commit
