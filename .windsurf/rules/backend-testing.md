---
trigger: model_decision
description: Regras para testes: testes unitários, testes de integração e Testcontainers. Use Testcontainers ao invés de H2 para testes que dependem de funcionalidades específicas do PostgreSQL.
globs:
---
# Regras de Desenvolvimento - Testes

## Testes Unitários

- Escreva testes unitários para lógica de negócio
- Escreva testes de integração para controllers e repositories
- Use `@SpringBootTest` para testes de integração
- Mock dependências externas em testes unitários
- Use `MockMvc` para testar controllers
- Use `@DataJpaTest` para testar repositories

```java
// ✅ Bom: Teste unitário
@ExtendWith(MockitoExtension.class)
class UserServiceTest {

    @Mock
    private UserRepository userRepository;

    @InjectMocks
    private UserService userService;

    @Test
    void shouldReturnUsersWhenRepositoryHasData() {
        // Given
        List<UserDTO> expected = List.of(
            new UserDTO(1L, "João Silva", "joao@example.com")
        );
        when(userRepository.findAllUsers()).thenReturn(expected);

        // When
        List<UserDTO> result = userService.getAllUsers();

        // Then
        assertThat(result).isEqualTo(expected);
        verify(userRepository).findAllUsers();
    }
}
```

## Testes de Integração com Testcontainers

- **Evite H2** para testes que dependem de funcionalidades específicas do PostgreSQL (JSONB, Arrays, Triggers, funções customizadas)
- Use **Testcontainers** para subir instâncias descartáveis do PostgreSQL durante os testes
- Testcontainers garante que os testes rodem contra o mesmo banco de dados usado em produção
- Configure `@DynamicPropertySource` para injetar propriedades do container dinamicamente

**Configuração no build.gradle:**
```gradle
dependencies {
    testImplementation 'org.testcontainers:testcontainers:1.19.3'
    testImplementation 'org.testcontainers:postgresql:1.19.3'
    testImplementation 'org.testcontainers:junit-jupiter:1.19.3'
}
```

**Exemplo de uso:**
```java
// ✅ Bom: Teste de integração com Testcontainers
@SpringBootTest
@Testcontainers
class UserRepositoryTest {
    
    @Container
    static PostgreSQLContainer<?> postgres = new PostgreSQLContainer<>("postgres:18-alpine")
            .withDatabaseName("testdb")
            .withUsername("test")
            .withPassword("test");
    
    @DynamicPropertySource
    static void configureProperties(DynamicPropertyRegistry registry) {
        registry.add("spring.datasource.url", postgres::getJdbcUrl);
        registry.add("spring.datasource.username", postgres::getUsername);
        registry.add("spring.datasource.password", postgres::getPassword);
    }
    
    @Autowired
    private UserRepository userRepository;
    
    @Test
    @Transactional
    void shouldSaveAndRetrieveUser() {
        // Given
        User user = new User();
        user.setName("João Silva");
        user.setEmail("joao@example.com");
        
        // When
        User saved = userRepository.save(user);
        Optional<User> found = userRepository.findById(saved.getId());
        
        // Then
        assertThat(found).isPresent();
        assertThat(found.get().getName()).isEqualTo("João Silva");
    }
    
    @Test
    void shouldUsePostgreSQLSpecificFeatures() {
        // Testa funcionalidades específicas do PostgreSQL (JSONB, Arrays, etc.)
        // que não funcionariam com H2
    }
}
```

**Boas práticas:**
- Use `@Container static` para containers compartilhados entre testes (mais rápido)
- Use `@Container` não-estático para containers isolados por teste (mais lento, mas mais seguro)
- Configure `withReuse(true)` em desenvolvimento para reutilizar containers entre execuções
- Use imagens Alpine (`postgres:18-alpine`) para containers menores e mais rápidos

**Nota**: Para questões específicas do PostgreSQL em testes, consulte `postgresql.mdc`.

## Skills Recomendadas

Quando esta regra for ativada, as seguintes skills são as mais adequadas para auxiliar no desenvolvimento:

- **testing-patterns**: Para padrões de testes (unitários, integração, TDD, mocking)
- **backend-testing**: Para testes específicos de backend (Testcontainers, JPA, Spring Boot test)
- **backend-dev-guidelines**: Para padrões de testes no desenvolvimento backend

## Módulos Relacionados

Para regras relacionadas, consulte:

- **backend-core.mdc**: Princípios fundamentais e padrões básicos
- **backend-data.mdc**: Para testes de repositories e entidades JPA
- **backend-api.mdc**: Para testes de controllers e endpoints REST
- **postgresql.mdc**: Para questões específicas do PostgreSQL em testes
- **backend-checklist.mdc**: Checklist consolidado para verificação antes de commit
