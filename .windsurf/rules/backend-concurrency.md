---
trigger: model_decision
description: Regras para programação concorrente: Virtual Threads, ExecutorService, @Async, CompletableFuture e thread safety. Use Virtual Threads para I/O bound e ExecutorService apenas para CPU-bound.
globs:
---
# Regras de Desenvolvimento - Concorrência e Multi-threading

## Princípios

- **Use multi-threading apenas quando há benefício real** (I/O bloqueante, processamento paralelo)
- Prefira `CompletableFuture` e `@Async` do Spring para operações assíncronas
- **Para operações I/O bound, use Virtual Threads (Java 21+)** - mais eficiente que thread pools tradicionais
- Use `ExecutorService` apenas para casos CPU-bound ou quando precisar de controle fino de threads
- Configure thread pools adequadamente (não criar threads ilimitadas)
- Use estruturas thread-safe quando necessário (`ConcurrentHashMap`, `CopyOnWriteArrayList`)
- Evite compartilhar estado mutável entre threads

## Virtual Threads (Java 21+)

- **Habilite Virtual Threads** no `application.properties`: `spring.threads.virtual.enabled=true`
- Com Virtual Threads, não é necessário configurar `ThreadPoolTaskExecutor` customizados para tarefas I/O bound
- O Spring Boot adaptará automaticamente o Tomcat e métodos `@Async` para usar threads virtuais
- Virtual Threads permitem milhões de conexões simultâneas sem overhead de OS threads
- Use `synchronized` com cautela em Virtual Threads; prefira `ReentrantLock` se necessário para evitar pinning

**Configuração:**
```properties
# ✅ Bom: Habilitar Virtual Threads (application.properties)
spring.threads.virtual.enabled=true
```

**Exemplo de uso:**
```java
// ✅ Bom: Virtual Threads habilitadas simplificam o código assíncrono
@Service
public class ReportService {
    
    // Com spring.threads.virtual.enabled=true, isso roda em uma thread virtual leve
    @Async
    public CompletableFuture<Report> generateReport(Long id) {
        // Operação bloqueante (ex: chamada HTTP ou DB) não bloqueia thread do SO
        var data = externalClient.fetchData(id); 
        return CompletableFuture.completedFuture(new Report(data));
    }
}

// ✅ Bom: Uso em controllers
@RestController
public class ReportController {
    
    @PostMapping("/reports/generate")
    public ResponseEntity<Map<String, String>> generateReports(@RequestBody List<Long> ids) {
        CompletableFuture<List<Report>> future = reportService.generateReportsAsync(ids);
        
        // Retorna imediatamente, processamento continua em background
        return ResponseEntity.accepted()
            .body(Map.of("status", "processing", "jobId", UUID.randomUUID().toString()));
    }
}
```

**Avisos importantes:**
- **Pinning**: Evite `synchronized` em blocos que executam por muito tempo, pois pode causar "pinning" da virtual thread à OS thread
- **CPU-bound**: Para operações CPU-intensivas, continue usando `ExecutorService` com pool limitado
- **Thread pools**: Virtual Threads não substituem a necessidade de thread pools para processamento CPU-bound

## ExecutorService e Thread Pools

**Nota**: Use ExecutorService apenas para casos CPU-bound ou quando precisar de controle específico. Para I/O bound, prefira Virtual Threads.

```java
// ✅ Bom: Configuração de Thread Pool
@Configuration
public class AsyncConfig implements AsyncConfigurer {

    @Override
    @Bean(name = "taskExecutor")
    public Executor getAsyncExecutor() {
        ThreadPoolTaskExecutor executor = new ThreadPoolTaskExecutor();
        executor.setCorePoolSize(5);
        executor.setMaxPoolSize(10);
        executor.setQueueCapacity(100);
        executor.setThreadNamePrefix("async-");
        executor.setRejectedExecutionHandler(new ThreadPoolExecutor.CallerRunsPolicy());
        executor.initialize();
        return executor;
    }
}

// ✅ Bom: Uso de ExecutorService
@Service
public class DataProcessingService {
    
    private final ExecutorService executorService = Executors.newFixedThreadPool(10);
    
    public CompletableFuture<List<Result>> processData(List<Data> dataList) {
        List<CompletableFuture<Result>> futures = dataList.stream()
            .map(data -> CompletableFuture.supplyAsync(
                () -> processSingleData(data), executorService))
            .toList();
            
        return CompletableFuture.allOf(futures.toArray(new CompletableFuture[0]))
            .thenApply(v -> futures.stream()
                .map(CompletableFuture::join)
                .toList());
    }
    
    @PreDestroy
    public void shutdown() {
        executorService.shutdown();
        try {
            if (!executorService.awaitTermination(60, TimeUnit.SECONDS)) {
                executorService.shutdownNow();
            }
        } catch (InterruptedException e) {
            executorService.shutdownNow();
            Thread.currentThread().interrupt();
        }
    }
}
```

## Spring @Async

```java
// ✅ Bom: Métodos assíncronos com Spring
@Service
public class NotificationService {
    
    @Async("taskExecutor")
    public CompletableFuture<Void> sendEmailAsync(String email, String message) {
        // Operação I/O bloqueante
        emailService.send(email, message);
        return CompletableFuture.completedFuture(null);
    }
    
    @Async
    public CompletableFuture<List<Report>> generateReportsAsync(List<Long> ids) {
        return CompletableFuture.supplyAsync(() -> {
            return ids.stream()
                .map(this::generateReport)
                .toList();
        });
    }
}

// ✅ Bom: Uso em controllers
@RestController
public class ReportController {
    
    @PostMapping("/reports/generate")
    public ResponseEntity<Map<String, String>> generateReports(@RequestBody List<Long> ids) {
        CompletableFuture<List<Report>> future = reportService.generateReportsAsync(ids);
        
        // Retorna imediatamente, processamento continua em background
        return ResponseEntity.accepted()
            .body(Map.of("status", "processing", "jobId", UUID.randomUUID().toString()));
    }
}
```

## CompletableFuture

```java
// ✅ Bom: Composição de operações assíncronas
@Service
public class UserDataService {
    
    public CompletableFuture<UserDashboardDTO> getUserDashboard(Long userId) {
        CompletableFuture<User> userFuture = CompletableFuture
            .supplyAsync(() -> userRepository.findById(userId).orElseThrow());
            
        CompletableFuture<List<Order>> ordersFuture = CompletableFuture
            .supplyAsync(() -> orderRepository.findByUserId(userId));
            
        CompletableFuture<List<Notification>> notificationsFuture = CompletableFuture
            .supplyAsync(() -> notificationRepository.findByUserId(userId));
        
        return CompletableFuture.allOf(userFuture, ordersFuture, notificationsFuture)
            .thenApply(v -> {
                User user = userFuture.join();
                List<Order> orders = ordersFuture.join();
                List<Notification> notifications = notificationsFuture.join();
                
                return new UserDashboardDTO(user, orders, notifications);
            })
            .exceptionally(ex -> {
                logger.error("Erro ao carregar dashboard", ex);
                throw new RuntimeException("Erro ao carregar dashboard", ex);
            });
    }
    
    // ✅ Bom: Pipeline assíncrono com tratamento de erros
    public CompletableFuture<String> processDataPipeline(String input) {
        return CompletableFuture
            .supplyAsync(() -> validateInput(input))
            .thenApplyAsync(this::transformData)
            .thenApplyAsync(this::enrichData)
            .thenApplyAsync(this::saveData)
            .handle((result, throwable) -> {
                if (throwable != null) {
                    logger.error("Erro no pipeline", throwable);
                    return "Erro no processamento";
                }
                return result;
            });
    }
}
```

## Thread Safety

```java
// ✅ Bom: Uso de estruturas thread-safe
@Service
public class CacheService {
    
    // ConcurrentHashMap é thread-safe
    private final ConcurrentHashMap<String, Object> cache = new ConcurrentHashMap<>();
    
    public void put(String key, Object value) {
        cache.put(key, value);
    }
    
    public Object get(String key) {
        return cache.get(key);
    }
    
    // ✅ Bom: Operações atômicas
    private final AtomicLong counter = new AtomicLong(0);
    
    public long increment() {
        return counter.incrementAndGet();
    }
}

// ✅ Bom: Sincronização quando necessário
public class SharedResource {
    private final Object lock = new Object();
    private int count = 0;
    
    public void increment() {
        synchronized (lock) {
            count++;
        }
    }
    
    // Prefira ReentrantLock para controle mais fino
    private final ReentrantLock lock2 = new ReentrantLock();
    
    public void incrementWithLock() {
        lock2.lock();
        try {
            count++;
        } finally {
            lock2.unlock();
        }
    }
}
```

## Skills Recomendadas

Quando esta regra for ativada, as seguintes skills são as mais adequadas para auxiliar no desenvolvimento:

- **backend-concurrency**: Para padrões específicos de concorrência (Virtual Threads, ExecutorService, @Async, CompletableFuture)
- **java-pro**: Para patterns de concorrência em Java (threads, locks, atomic operations)
- **backend-dev-guidelines**: Para padrões de programação concorrente no Spring Boot

## Módulos Relacionados

Para regras relacionadas, consulte:

- **backend-core.mdc**: Princípios fundamentais e padrões básicos
- **backend-performance.mdc**: Para otimizações de performance relacionadas
- **backend-observability.mdc**: Para logging e tracing de operações assíncronas
- **backend-checklist.mdc**: Checklist consolidado para verificação antes de commit
