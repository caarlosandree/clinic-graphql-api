package com.example.catalogo.shared.logging;

import graphql.ExecutionResult;
import graphql.execution.instrumentation.Instrumentation;
import graphql.execution.instrumentation.InstrumentationContext;
import graphql.execution.instrumentation.InstrumentationState;
import graphql.execution.instrumentation.parameters.InstrumentationExecutionParameters;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.slf4j.MDC;
import org.springframework.stereotype.Component;

import java.time.Duration;
import java.time.Instant;
import java.util.concurrent.CompletableFuture;

@Component
public class GraphQLLoggingInstrumentation implements Instrumentation {

    private static final Logger log = LoggerFactory.getLogger(GraphQLLoggingInstrumentation.class);

    private final ThreadLocal<ExecutionState> stateHolder = ThreadLocal.withInitial(ExecutionState::new);

    @Override
    public InstrumentationContext<ExecutionResult> beginExecution(
            InstrumentationExecutionParameters parameters,
            InstrumentationState state) {
        ExecutionState executionState = stateHolder.get();
        executionState.startTime = Instant.now();
        executionState.operationName = parameters.getOperation();
        executionState.query = extractOperationName(parameters);

        String correlationId = MDC.get(CorrelationIdFilter.CORRELATION_ID_MDC_KEY);
        log.info("GraphQL operation started | operation={} | queryName={} | correlationId={}",
            executionState.operationName, executionState.query, correlationId);

        return new InstrumentationContext<>() {
            @Override
            public void onDispatched() {
            }

            @Override
            public void onCompleted(ExecutionResult result, Throwable t) {
                Duration duration = Duration.between(executionState.startTime, Instant.now());
                String correlationId = MDC.get(CorrelationIdFilter.CORRELATION_ID_MDC_KEY);
                stateHolder.remove();
                if (t != null) {
                    log.error("GraphQL operation failed | operation={} | queryName={} | durationMs={} | correlationId={}",
                        executionState.operationName, executionState.query, duration.toMillis(),
                        correlationId, t);
                } else if (result != null && !result.getErrors().isEmpty()) {
                    log.warn("GraphQL operation completed with errors | operation={} | queryName={} | errors={} | durationMs={} | correlationId={}",
                        executionState.operationName, executionState.query, result.getErrors().size(),
                        duration.toMillis(), correlationId);
                } else {
                    log.info("GraphQL operation completed | operation={} | queryName={} | durationMs={} | correlationId={}",
                        executionState.operationName, executionState.query, duration.toMillis(),
                        correlationId);
                }
            }
        };
    }

    @Override
    public CompletableFuture<ExecutionResult> instrumentExecutionResult(
            ExecutionResult executionResult,
            InstrumentationExecutionParameters parameters,
            InstrumentationState state) {
        return Instrumentation.super.instrumentExecutionResult(executionResult, parameters, state);
    }

    private String extractOperationName(InstrumentationExecutionParameters parameters) {
        if (parameters.getExecutionInput() != null) {
            return parameters.getExecutionInput().getOperationName() != null
                ? parameters.getExecutionInput().getOperationName()
                : "anonymous";
        }
        return "anonymous";
    }

    private static class ExecutionState implements InstrumentationState {
        Instant startTime;
        String operationName;
        String query;
    }
}
