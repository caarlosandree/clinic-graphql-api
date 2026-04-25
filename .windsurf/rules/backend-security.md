---
trigger: model_decision
description: Regras de segurança: validação de dados, SQL injection, dados sensíveis, CORS, BOLA/IDOR, autenticação/autorização e defesa em profundidade.
globs:
---
# Regras de Desenvolvimento - Segurança

## Validação de Dados de Entrada

- **Sempre** valide e sanitize dados do usuário
- Use prepared statements (JPA já faz isso automaticamente)
- Valide tipos, tamanhos e formatos de dados
- Rejeite dados malformados imediatamente
- Use **DTOs para entrada** — nunca exponha entidades JPA diretamente no controller (evita Mass Assignment e vazamento de campos)

**Nota**: Para detalhes sobre validação com Bean Validation em DTOs e controllers, consulte `backend-api.mdc`.

## Proteção contra SQL Injection

- **Nunca** construa queries concatenando strings
- **Sempre** use JPA Query Methods, `@Query` com parâmetros nomeados, ou Criteria API
- Use parâmetros nomeados (`:param`) ou posicionais (`?1`) em queries

```java
// ✅ Bom: Query parametrizada
@Query("SELECT u FROM User u WHERE u.email = :email")
Optional<User> findByEmail(@Param("email") String email);

// ❌ Perigoso: SQL Injection
@Query("SELECT u FROM User u WHERE u.email = '" + email + "'")
Optional<User> findByEmailUnsafe(String email);
```

**Nota**: Para mais detalhes sobre Spring Data JPA e repositories, consulte `backend-data.mdc`.

## Proteção de Dados Sensíveis

- **Nunca** commite credenciais, tokens ou chaves de API no código
- Use variáveis de ambiente ou `application.properties` para dados sensíveis
- Adicione `application.properties` com dados sensíveis ao `.gitignore`
- Use Spring Cloud Config ou secrets management em produção
- **Não logue** dados sensíveis (senhas, tokens, PII); em logs, mascare quando necessário (ex.: CPF, email parcial)
- Em respostas da API, exponha apenas o mínimo necessário; mascare PII quando o uso não exigir valor completo

**Nota**: Para configuração de variáveis de ambiente, consulte `backend-core.mdc`.

## CORS e Headers de Segurança

- Configure CORS de forma restritiva; liste origens permitidas explicitamente
- Com `allowCredentials(true)`, **nunca** use `allowedOrigins("*")` — use lista fixa de origens (ex.: `${app.cors.allowed-origins}`)
- Ative headers de segurança (Spring Security: X-Content-Type-Options, X-Frame-Options, Content-Security-Policy, Strict-Transport-Security)
- Implemente **rate limiting** (ex.: Bucket4j, Resilience4j ou filtro customizado) em endpoints públicos e de login
- Use HTTPS em produção e redirecione HTTP para HTTPS

```java
// ✅ Bom: CORS com origens explícitas (obrigatório se allowCredentials = true)
@Configuration
public class WebConfig implements WebMvcConfigurer {

    @Override
    public void addCorsMappings(CorsRegistry registry) {
        registry.addMapping("/api/**")
                .allowedOriginPatterns("https://seu-dominio.com", "https://*.seu-dominio.com") // ou use ${app.cors.allowed-origins}
                .allowedMethods("GET", "POST", "PUT", "DELETE", "PATCH")
                .allowedHeaders("*")
                .allowCredentials(true);
    }
}
```

## Autenticação e Autorização

- Use **Spring Security** para autenticação e autorização
- Use tokens seguros (JWT) com expiração curta; implemente refresh tokens quando necessário
- **Sempre** valide permissões no método ou endpoint (ex.: `@PreAuthorize`, `@Secured` ou checagem explícita no service)
- Proteja rotas sensíveis por padrão; permita apenas o que for necessário

### Prevenção a BOLA/IDOR (Broken Object Level Authorization)

- **Nunca** confie em IDs vindos do cliente para autorização
- Em toda operação que acessa recurso por ID, **verifique se o recurso pertence ao usuário/tenant autenticado**
- Ex.: ao buscar/atualizar documento por ID, garantir que `documento.getTenantId()` (ou equivalente) corresponda ao usuário da sessão
- Retorne 404 em vez de 403 quando o recurso não existir ou não pertencer ao usuário (evita enumeração)

## Desserialização e Entrada

- Use DTOs com Bean Validation para entrada; evite deserializar JSON diretamente em entidades JPA
- Com Jackson: evite polimorfismo sem controle; se usar `@JsonTypeInfo`, use `JsonTypeInfo.Id.NAME` com allow-list explícita de subtypes para reduzir risco de desserialização insegura

## Skills Recomendadas

Quando esta regra for ativada, as seguintes skills são as mais adequadas para auxiliar no desenvolvimento:

- **backend-security-coder**: Para implementação de segurança em código backend (validação, autenticação, proteção de dados)
- **security-audit**: Para auditoria de segurança completa (OWASP, threat modeling, análise de vulnerabilidades)
- **backend-dev-guidelines**: Para padrões específicos de segurança no desenvolvimento backend
- **security-analysis**: Para análise de segurança profunda (SAST, Threat Hunting) quando solicitar "Análise de Segurança"

## Módulos Relacionados

Para regras relacionadas, consulte:

- **backend-core.mdc**: Princípios fundamentais e padrões básicos
- **backend-api.mdc**: Validação de dados em controllers e DTOs
- **backend-data.mdc**: Proteção contra SQL injection em repositories
- **backend-checklist.mdc**: Checklist consolidado para verificação antes de commit
- **security-analysis.mdc**: Análise de segurança profunda (SAST, Threat Hunting) quando solicitar "Análise de Segurança"
