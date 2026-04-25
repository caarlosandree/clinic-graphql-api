---
trigger: model_decision
description: Regras para desenvolvimento de APIs REST: versionamento, controllers, DTOs, validação, tratamento de exceções, transações e documentação Swagger/OpenAPI.
globs:
---
# Regras de Desenvolvimento - API REST

## Versionamento de API

### Estratégia de Versionamento
- **Sempre** versionar endpoints da API usando path versioning
- Use o formato `/api/v{versao}/` (ex: `/api/v1/`, `/api/v2/`)
- A versão atual deve ser sempre a mais recente
- Mantenha versões antigas funcionando durante período de transição
- Documente breaking changes entre versões

### Implementação
```java
@RestController
@RequestMapping("/api/v1/users")
public class UserControllerV1 {
    // Implementação v1
}

@RestController
@RequestMapping("/api/v2/users")
public class UserControllerV2 {
    // Implementação v2 com melhorias
}
```

### Boas Práticas
- Use DTOs específicos por versão quando necessário
- Mantenha compatibilidade retroativa quando possível
- Deprecate versões antigas antes de removê-las
- Documente mudanças entre versões no changelog
- Use headers de versionamento como alternativa quando apropriado

## Estrutura de Controllers (REST Endpoints)

```java
package com.seudominio.aplicacao.controller;

import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import com.seudominio.aplicacao.service.UserService;
import com.seudominio.aplicacao.dto.UserDTO;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import java.util.List;

@RestController
@RequestMapping("/api/v1/users")
@CrossOrigin(origins = "${app.cors.allowed-origins}")
@Tag(name = "Users", description = "Endpoints para gerenciamento de usuários")
public class UserController {

    private final UserService userService;

    public UserController(UserService userService) {
        this.userService = userService;
    }

    /**
     * Obtém todos os usuários
     * 
     * @return Lista de usuários
     */
    @GetMapping
    @Operation(summary = "Lista todos os usuários", description = "Retorna uma lista com todos os usuários cadastrados")
    public ResponseEntity<List<UserDTO>> getAllUsers() {
        List<UserDTO> users = userService.getAllUsers();
        return ResponseEntity.ok(users);
    }
}
```

**Nota**: Para mapeamento entre Entity e DTO, consulte `backend-data.mdc` sobre MapStruct.

## Qualidade e Manutenção

### Evite Repetição (DRY)
- Identifique padrões e extraia para métodos/classes reutilizáveis
- Use interfaces para abstrair dependências
- Crie helpers e utilitários para operações comuns
- Reutilize código entre controllers quando apropriado

```java
// ✅ Bom: Método reutilizável
public static String formatDate(LocalDate date) {
    return date.format(DateTimeFormatter.ofPattern("yyyy-MM-dd"));
}

// ❌ Ruim: Repetição
String date1 = date1.format(DateTimeFormatter.ofPattern("yyyy-MM-dd"));
String date2 = date2.format(DateTimeFormatter.ofPattern("yyyy-MM-dd"));
```

### Validação de Entradas
- **Sempre** valide dados de entrada do usuário
- Use Bean Validation (`@NotNull`, `@Size`, `@Email`, etc.) para validação de DTOs
- Valide tanto no controller quanto no service quando necessário
- Forneça mensagens de erro claras e específicas
- Retorne códigos HTTP apropriados

```java
// ✅ Bom: Validação adequada
public class CreateUserRequest {
    @NotBlank(message = "Nome é obrigatório")
    @Size(min = 3, max = 100, message = "Nome deve ter entre 3 e 100 caracteres")
    private String name;

    @NotBlank(message = "Email é obrigatório")
    @Email(message = "Email deve ser válido")
    private String email;

    @NotBlank(message = "Senha é obrigatória")
    @Size(min = 8, message = "Senha deve ter no mínimo 8 caracteres")
    private String password;
}

@PostMapping
public ResponseEntity<UserDTO> createUser(
        @Valid @RequestBody CreateUserRequest request) {
    // Processar...
}
```

**Nota**: Para regras de segurança relacionadas a validação, consulte `backend-security.mdc`.

### Tratamento de Exceções
- **Sempre** trate exceções de forma adequada
- Use `@ControllerAdvice` para tratamento global de exceções
- Crie exceções customizadas para casos específicos
- Retorne erros com contexto quando apropriado
- Log erros para debugging (sem expor informações sensíveis)
- Retorne códigos HTTP apropriados baseados no tipo de exceção

```java
// ✅ Bom: Tratamento adequado
@ControllerAdvice
public class GlobalExceptionHandler {

    @ExceptionHandler(EntityNotFoundException.class)
    public ResponseEntity<ErrorResponse> handleEntityNotFound(EntityNotFoundException ex) {
        ErrorResponse error = new ErrorResponse(
            HttpStatus.NOT_FOUND.value(),
            "Recurso não encontrado",
            ex.getMessage()
        );
        return ResponseEntity.status(HttpStatus.NOT_FOUND).body(error);
    }

    @ExceptionHandler(MethodArgumentNotValidException.class)
    public ResponseEntity<ErrorResponse> handleValidationErrors(MethodArgumentNotValidException ex) {
        // Processar erros de validação...
    }
}

// ❌ Ruim: Ignorando exceção
try {
    result = repository.findById(id);
} catch (Exception e) {
    // Ignorado
}
```

### Transações
- Use `@Transactional` para operações que modificam dados
- Use `@Transactional(readOnly = true)` para operações de leitura
- Configure isolamento e propagação adequadamente
- Evite transações longas
- Use `@Transactional` em métodos de service, não em controllers

```java
// ✅ Bom: Uso adequado de transações
@Service
@Transactional(readOnly = true)
public class UserService {

    @Transactional
    public User createUser(User user) {
        return userRepository.save(user);
    }

    public List<User> getAllUsers() {
        return userRepository.findAll();
    }
}
```

## Documentação da API com Swagger/OpenAPI

### Configuração
- Use **SpringDoc OpenAPI** para documentação automática da API
- Configure no `application.properties` ou via `@Configuration`
- Acesse a documentação em `/swagger-ui.html` e `/api-docs`

### Configuração Básica
```java
@Configuration
public class OpenApiConfig {

    @Bean
    public OpenAPI customOpenAPI() {
        return new OpenAPI()
                .info(new Info()
                        .title("API Documentation")
                        .version("1.0.0")
                        .description("Documentação da API REST")
                        .contact(new Contact()
                                .name("Equipe de Desenvolvimento")
                                .email("dev@example.com")))
                .servers(List.of(
                        new Server().url("http://localhost:8080").description("Servidor Local"),
                        new Server().url("https://api.example.com").description("Servidor Produção")
                ));
    }
}
```

### Anotações Swagger em Controllers
```java
@RestController
@RequestMapping("/api/v1/users")
@Tag(name = "Users", description = "Endpoints para gerenciamento de usuários")
public class UserController {

    @GetMapping("/{id}")
    @Operation(
        summary = "Busca usuário por ID",
        description = "Retorna os dados de um usuário específico pelo seu ID",
        responses = {
            @ApiResponse(responseCode = "200", description = "Usuário encontrado"),
            @ApiResponse(responseCode = "404", description = "Usuário não encontrado")
        }
    )
    public ResponseEntity<UserDTO> getUserById(@PathVariable Long id) {
        // ...
    }
}
```

### Boas Práticas
- **Sempre** documente endpoints públicos com anotações Swagger
- Use `@Tag` para agrupar endpoints relacionados
- Use `@Operation` para descrever cada endpoint
- Use `@ApiResponse` para documentar possíveis respostas
- Use `@Schema` em DTOs para documentar campos
- Mantenha a documentação atualizada com o código
- Configure diferentes servidores para dev/prod

### Configuração no application.properties
```properties
# Swagger/OpenAPI
springdoc.api-docs.path=/api-docs
springdoc.swagger-ui.path=/swagger-ui.html
springdoc.swagger-ui.operationsSorter=method
springdoc.swagger-ui.tagsSorter=alpha
```

## Skills Recomendadas

Quando esta regra for ativada, as seguintes skills são as mais adequadas para auxiliar no desenvolvimento:

- **api-design-principles**: Para design de APIs REST, versionamento, escolha entre REST/GraphQL/tRPC e padrões de resposta
- **api-endpoint-builder**: Para construção de endpoints REST com validação, error handling e segurança
- **backend-dev-guidelines**: Para padrões específicos de desenvolvimento backend (controllers, DTOs, validação)
- **api-documentation-generator**: Para geração automática de documentação OpenAPI a partir do código

## Módulos Relacionados

Para regras relacionadas, consulte:

- **backend-core.mdc**: Princípios fundamentais, estrutura, nomenclatura e padrões básicos
- **backend-data.mdc**: Para uso de DTOs e MapStruct em controllers
- **backend-security.mdc**: Para validação de dados e proteção de segurança
- **backend-checklist.mdc**: Checklist consolidado para verificação antes de commit
