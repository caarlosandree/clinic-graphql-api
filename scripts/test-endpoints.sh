#!/usr/bin/env bash
set -euo pipefail

# =============================================================================
# Script de Testes - Endpoints GraphQL da API Catalogo
# =============================================================================
# Testa todas as queries e mutations do schema GraphQL.
# Requer: curl, jq, docker-compose (opcional, para subir infra)
# =============================================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"

# --- Configuração ------------------------------------------------------------
GRAPHQL_URL="${GRAPHQL_URL:-http://localhost:8080/graphql}"
TIMEOUT="${TIMEOUT:-30}"
VERBOSE="${VERBOSE:-0}"

# Cores para output (desabilitadas para evitar caracteres de controle nas queries)
RED=''
GREEN=''
YELLOW=''
BLUE=''
NC=''

PASS_COUNT=0
FAIL_COUNT=0

# IDs gerados durante os testes para reutilização
CLINIC_ID=""
PROCEDURE_ID=""
PROFESSIONAL_ID=""
APPOINTMENT_ID=""

# --- Helpers -----------------------------------------------------------------

log_info()  { echo "${BLUE}[INFO]${NC}  $*"; }
log_pass()  { echo "${GREEN}[PASS]${NC}  $*"; PASS_COUNT=$((PASS_COUNT + 1)); }
log_fail()  { echo "${RED}[FAIL]${NC}  $*"; FAIL_COUNT=$((FAIL_COUNT + 1)); }
log_warn()  { echo "${YELLOW}[WARN]${NC}  $*"; }

graphql_request() {
    local query="$1"
    local description="$2"
    local extract_path="${3:-}"

    local payload
    if command -v jq >/dev/null 2>&1; then
        payload=$(jq -n --arg q "$query" '{query: $q}')
    else
        # Fallback sem jq: escape minimal de aspas duplas
        local escaped_query
        escaped_query=${query//\\/\\\\}
        escaped_query=${escaped_query//\"/\\\"}
        payload="{\"query\": \"$escaped_query\"}"
    fi

    local response
    local http_code
    local curl_opts=(-s -w "\n%{http_code}" -m "$TIMEOUT" \
        -H "Content-Type: application/json" \
        --data-raw "$payload")

    if [[ "$VERBOSE" == "1" ]]; then
        curl_opts+=(-v)
        echo -e "\n${YELLOW}--- Request: $description ---${NC}"
        echo "Query: $query"
        echo "Payload: $payload"
    fi

    response=$(curl "${curl_opts[@]}" "$GRAPHQL_URL")
    http_code=$(echo "$response" | tail -n1)
    body=$(echo "$response" | sed '$d')

    if [[ "$VERBOSE" == "1" ]]; then
        echo "HTTP: $http_code"
        echo "Body: $body"
    fi

    if [[ "$http_code" -ne 200 ]]; then
        log_fail "$description - HTTP $http_code"
        echo "$body"
        return 1
    fi

    if echo "$body" | jq -e '.errors' >/dev/null 2>&1; then
        log_fail "$description - Erros GraphQL"
        echo "$body" | jq '.errors'
        return 1
    fi

    if [[ -n "$extract_path" ]]; then
        echo "$body" | jq -r "$extract_path"
    fi

    log_pass "$description"
    return 0
}

assert_not_empty() {
    local value="$1"
    local description="$2"
    if [[ -z "$value" || "$value" == "null" ]]; then
        log_fail "$description - valor vazio ou null"
        return 1
    fi
}

# --- Setup / Healthcheck -----------------------------------------------------

check_app_running() {
    log_info "Verificando se a aplicação está rodando em $GRAPHQL_URL ..."
    if curl -sf -m 5 "$GRAPHQL_URL" -X POST -H "Content-Type: application/json" \
         --data-raw '{"query":"{ __typename }"}' >/dev/null 2>&1; then
        log_info "Aplicação respondendo."
        return 0
    fi
    return 1
}

wait_for_app() {
    local retries=30
    log_info "Aguardando aplicação ficar disponível (max ${retries}s)..."
    for i in $(seq 1 $retries); do
        if check_app_running; then
            return 0
        fi
        sleep 1
    done
    log_fail "Aplicação não respondeu após $retries segundos"
    exit 1
}

# --- Testes: Queries ---------------------------------------------------------

test_query_clinics() {
    log_info "Testando Query: clinics"
    graphql_request '{ clinics { id name cnpj phone address createdAt updatedAt } }' \
        "Query clinics"
}

test_query_clinic_by_id() {
    log_info "Testando Query: clinicById"
    if [[ -z "$CLINIC_ID" ]]; then
        log_warn "Nenhum clinicId disponível, pulando clinicById"
        return 0
    fi
    graphql_request "{ clinicById(id: \"$CLINIC_ID\") { id name cnpj phone address createdAt updatedAt } }" \
        "Query clinicById (id=$CLINIC_ID)"
}

test_query_procedures_by_clinic() {
    log_info "Testando Query: proceduresByClinic"
    if [[ -z "$CLINIC_ID" ]]; then
        log_warn "Nenhum clinicId disponível, pulando proceduresByClinic"
        return 0
    fi
    graphql_request "{ proceduresByClinic(clinicId: \"$CLINIC_ID\") { id name description durationMinutes price createdAt updatedAt } }" \
        "Query proceduresByClinic (clinicId=$CLINIC_ID)"
}

test_query_professionals_by_clinic() {
    log_info "Testando Query: professionalsByClinic"
    if [[ -z "$CLINIC_ID" ]]; then
        log_warn "Nenhum clinicId disponível, pulando professionalsByClinic"
        return 0
    fi
    graphql_request "{ professionalsByClinic(clinicId: \"$CLINIC_ID\") { id name specialty createdAt updatedAt } }" \
        "Query professionalsByClinic (clinicId=$CLINIC_ID)"
}

test_query_appointments_by_clinic() {
    log_info "Testando Query: appointmentsByClinic"
    if [[ -z "$CLINIC_ID" ]]; then
        log_warn "Nenhum clinicId disponível, pulando appointmentsByClinic"
        return 0
    fi
    graphql_request "{ appointmentsByClinic(clinicId: \"$CLINIC_ID\") { id patientName patientPhone scheduledAt status createdAt updatedAt } }" \
        "Query appointmentsByClinic (clinicId=$CLINIC_ID)"
}

test_query_appointments_by_status() {
    log_info "Testando Query: appointmentsByStatus"
    graphql_request '{ appointmentsByStatus(status: SCHEDULED) { id patientName patientPhone scheduledAt status createdAt updatedAt } }' \
        "Query appointmentsByStatus (status=SCHEDULED)"
}

# --- Testes: Mutations -------------------------------------------------------

test_mutation_create_clinic() {
    log_info "Testando Mutation: createClinic"
    # Gera CNPJ único baseado em timestamp para evitar conflitos
    local timestamp
    timestamp=$(date +%s%N | cut -c1-14)
    local unique_cnpj="12${timestamp}00195"

    local response
    response=$(graphql_request \
        "mutation { createClinic(input: { name: \"Clinica Teste Bash\", cnpj: \"$unique_cnpj\", phone: \"11999999999\", address: \"Rua Teste, 123\" }) { id name cnpj phone address createdAt updatedAt } }" \
        "Mutation createClinic" \
        ".data.createClinic.id" || true)

    if [[ -n "$response" && "$response" != "null" ]]; then
        CLINIC_ID="$response"
        log_info "Clinic criada com ID: $CLINIC_ID"
    else
        log_fail "Não foi possível extrair ID da clinic criada"
    fi
}

test_mutation_create_procedure() {
    log_info "Testando Mutation: createProcedure"
    if [[ -z "$CLINIC_ID" ]]; then
        log_warn "Nenhum clinicId disponível, pulando createProcedure"
        return 0
    fi
    local response
    response=$(graphql_request \
        "mutation { createProcedure(input: { clinicId: \"$CLINIC_ID\", name: \"Procedimento Teste\", description: \"Descricao do procedimento\", durationMinutes: 60, price: 150.00 }) { id name description durationMinutes price createdAt updatedAt } }" \
        "Mutation createProcedure" \
        ".data.createProcedure.id" || true)

    if [[ -n "$response" && "$response" != "null" ]]; then
        PROCEDURE_ID="$response"
        log_info "Procedure criada com ID: $PROCEDURE_ID"
    else
        log_fail "Não foi possível extrair ID da procedure criada"
    fi
}

test_mutation_create_professional() {
    log_info "Testando Mutation: createProfessional"
    if [[ -z "$CLINIC_ID" ]]; then
        log_warn "Nenhum clinicId disponível, pulando createProfessional"
        return 0
    fi
    local response
    response=$(graphql_request \
        "mutation { createProfessional(input: { clinicId: \"$CLINIC_ID\", name: \"Dr. Teste\", specialty: \"Cardiologia\" }) { id name specialty createdAt updatedAt } }" \
        "Mutation createProfessional" \
        ".data.createProfessional.id" || true)

    if [[ -n "$response" && "$response" != "null" ]]; then
        PROFESSIONAL_ID="$response"
        log_info "Professional criado com ID: $PROFESSIONAL_ID"
    else
        log_fail "Não foi possível extrair ID do professional criado"
    fi
}

test_mutation_create_appointment() {
    log_info "Testando Mutation: createAppointment"
    if [[ -z "$CLINIC_ID" || -z "$PROCEDURE_ID" || -z "$PROFESSIONAL_ID" ]]; then
        log_warn "IDs dependentes ausentes, pulando createAppointment"
        return 0
    fi

    local scheduled_at
    scheduled_at=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

    local response
    response=$(graphql_request \
        "mutation { createAppointment(input: { clinicId: \"$CLINIC_ID\", procedureId: \"$PROCEDURE_ID\", professionalId: \"$PROFESSIONAL_ID\", patientName: \"Paciente Teste\", patientPhone: \"11988887777\", scheduledAt: \"$scheduled_at\" }) { id patientName patientPhone scheduledAt status createdAt updatedAt } }" \
        "Mutation createAppointment" \
        ".data.createAppointment.id" || true)

    if [[ -n "$response" && "$response" != "null" ]]; then
        APPOINTMENT_ID="$response"
        log_info "Appointment criado com ID: $APPOINTMENT_ID"
    else
        log_fail "Não foi possível extrair ID do appointment criado"
    fi
}

test_mutation_cancel_appointment() {
    log_info "Testando Mutation: cancelAppointment"
    if [[ -z "$APPOINTMENT_ID" ]]; then
        log_warn "Nenhum appointmentId disponível, pulando cancelAppointment"
        return 0
    fi
    graphql_request \
        "mutation { cancelAppointment(id: \"$APPOINTMENT_ID\") { id status } }" \
        "Mutation cancelAppointment (id=$APPOINTMENT_ID)"
}

test_mutation_finish_appointment() {
    log_info "Testando Mutation: finishAppointment"
    # Precisamos criar outro appointment para finalizar, pois o anterior foi cancelado
    if [[ -z "$CLINIC_ID" || -z "$PROCEDURE_ID" || -z "$PROFESSIONAL_ID" ]]; then
        log_warn "IDs dependentes ausentes, pulando finishAppointment"
        return 0
    fi

    local scheduled_at
    scheduled_at=$(date -u -d "+1 hour" +"%Y-%m-%dT%H:%M:%SZ" 2>/dev/null || date -u -v+1H +"%Y-%m-%dT%H:%M:%SZ" 2>/dev/null || date -u +"%Y-%m-%dT%H:%M:%SZ")

    local new_appointment_id
    new_appointment_id=$(graphql_request \
        "mutation { createAppointment(input: { clinicId: \"$CLINIC_ID\", procedureId: \"$PROCEDURE_ID\", professionalId: \"$PROFESSIONAL_ID\", patientName: \"Paciente Finalizar\", patientPhone: \"11977776666\", scheduledAt: \"$scheduled_at\" }) { id } }" \
        "Mutation createAppointment (para finish)" \
        ".data.createAppointment.id" || true)

    if [[ -z "$new_appointment_id" || "$new_appointment_id" == "null" ]]; then
        log_fail "Não foi possível criar appointment para testar finishAppointment"
        return 1
    fi

    log_info "Appointment extra criado com ID: $new_appointment_id"

    graphql_request \
        "mutation { finishAppointment(id: \"$new_appointment_id\") { id status } }" \
        "Mutation finishAppointment (id=$new_appointment_id)"
}

# --- Testes: Validações / Edge Cases -----------------------------------------

test_query_clinic_by_id_not_found() {
    log_info "Testando Query: clinicById com ID inexistente"
    local response
    response=$(curl -sf -m "$TIMEOUT" -H "Content-Type: application/json" \
        --data-raw '{"query":"{ clinicById(id: \"00000000-0000-0000-0000-000000000000\") { id } }"}' \
        "$GRAPHQL_URL" 2>/dev/null || true)

    if [[ -z "$response" ]]; then
        log_pass "clinicById com ID inexistente - resposta vazia (esperado em GraphQL com exceção)"
        return 0
    fi

    if echo "$response" | jq -e '.errors' >/dev/null 2>&1; then
        log_pass "clinicById com ID inexistente - retornou erro GraphQL (esperado)"
        return 0
    fi

    if echo "$response" | jq -e '.data.clinicById == null' >/dev/null 2>&1; then
        log_pass "clinicById com ID inexistente - retornou null (esperado)"
        return 0
    fi

    log_fail "clinicById com ID inexistente - comportamento inesperado"
    echo "$response"
}

test_mutation_create_clinic_validation_error() {
    log_info "Testando Mutation: createClinic com dados inválidos (name ausente)"
    local response
    response=$(curl -sf -m "$TIMEOUT" -H "Content-Type: application/json" \
        --data-raw '{"query":"mutation { createClinic(input: { cnpj: \"123\" }) { id } }"}' \
        "$GRAPHQL_URL" 2>/dev/null || true)

    if [[ -z "$response" ]]; then
        log_pass "createClinic inválido - resposta vazia (esperado)"
        return 0
    fi

    if echo "$response" | jq -e '.errors' >/dev/null 2>&1; then
        log_pass "createClinic inválido - retornou erro GraphQL (esperado)"
        return 0
    fi

    log_fail "createClinic inválido - comportamento inesperado"
    echo "$response"
}

# --- Execução ----------------------------------------------------------------

main() {
    echo "==================================================================="
    echo "       Testes GraphQL - API Catalogo"
    echo "       URL: $GRAPHQL_URL"
    echo "==================================================================="
    echo ""

    # Verifica dependências
    if ! command -v curl >/dev/null 2>&1; then
        echo "ERRO: curl não está instalado." >&2
        exit 1
    fi

    if ! command -v jq >/dev/null 2>&1; then
        echo "ERRO: jq é obrigatório para este script. Instale com: brew install jq (macOS) ou apt install jq (Linux)" >&2
        exit 1
    fi

    # Healthcheck
    if ! check_app_running; then
        log_warn "Aplicação não parece estar rodando."
        log_info "Dica: Inicie a aplicação com './gradlew bootRun' ou use docker-compose."
        read -r -p "Deseja aguardar a aplicação? (s/n) " answer </dev/tty || true
        if [[ "${answer:-n}" == "s" || "${answer:-n}" == "S" ]]; then
            wait_for_app
        else
            exit 1
        fi
    fi

    echo ""
    echo "--- Queries ---"
    test_query_clinics
    test_query_appointments_by_status

    echo ""
    echo "--- Mutations (criação de dados) ---"
    test_mutation_create_clinic
    test_mutation_create_procedure
    test_mutation_create_professional
    test_mutation_create_appointment

    echo ""
    echo "--- Queries com IDs gerados ---"
    test_query_clinic_by_id
    test_query_procedures_by_clinic
    test_query_professionals_by_clinic
    test_query_appointments_by_clinic

    echo ""
    echo "--- Mutations (transições de status) ---"
    test_mutation_cancel_appointment
    test_mutation_finish_appointment

    echo ""
    echo "--- Edge Cases / Validações ---"
    test_query_clinic_by_id_not_found
    test_mutation_create_clinic_validation_error

    echo ""
    echo "==================================================================="
    echo "                    RESULTADO"
    echo "==================================================================="
    echo -e "  Passaram: ${GREEN}$PASS_COUNT${NC}"
    echo -e "  Falharam: ${RED}$FAIL_COUNT${NC}"
    echo "==================================================================="

    if [[ "$FAIL_COUNT" -gt 0 ]]; then
        exit 1
    fi
    exit 0
}

main "$@"
