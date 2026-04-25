package com.example.catalogo.exception;

import com.example.catalogo.shared.logging.CorrelationIdFilter;
import graphql.GraphQLError;
import graphql.GraphqlErrorBuilder;
import graphql.schema.DataFetchingEnvironment;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.slf4j.MDC;
import org.springframework.graphql.execution.DataFetcherExceptionResolverAdapter;
import org.springframework.stereotype.Component;

@Component
public class GraphQLExceptionHandler extends DataFetcherExceptionResolverAdapter {

    private static final Logger log = LoggerFactory.getLogger(GraphQLExceptionHandler.class);

    @Override
    protected GraphQLError resolveToSingleError(Throwable ex, DataFetchingEnvironment env) {
        String correlationId = MDC.get(CorrelationIdFilter.CORRELATION_ID_MDC_KEY);
        String fieldName = env.getField().getName();

        if (ex instanceof ResourceNotFoundException) {
            log.warn("GraphQL exception | type=ResourceNotFound | field={} | message={} | correlationId={}",
                fieldName, ex.getMessage(), correlationId);
            return GraphqlErrorBuilder.newError()
                .errorType(graphql.ErrorType.DataFetchingException)
                .message(ex.getMessage())
                .path(env.getExecutionStepInfo().getPath())
                .location(env.getField().getSourceLocation())
                .build();
        }

        if (ex instanceof BusinessException) {
            log.warn("GraphQL exception | type=Business | field={} | message={} | correlationId={}",
                fieldName, ex.getMessage(), correlationId);
            return GraphqlErrorBuilder.newError()
                .errorType(graphql.ErrorType.ValidationError)
                .message(ex.getMessage())
                .path(env.getExecutionStepInfo().getPath())
                .location(env.getField().getSourceLocation())
                .build();
        }

        if (ex instanceof DuplicateResourceException) {
            log.warn("GraphQL exception | type=DuplicateResource | field={} | message={} | correlationId={}",
                fieldName, ex.getMessage(), correlationId);
            return GraphqlErrorBuilder.newError()
                .errorType(graphql.ErrorType.ValidationError)
                .message(ex.getMessage())
                .path(env.getExecutionStepInfo().getPath())
                .location(env.getField().getSourceLocation())
                .build();
        }

        log.error("GraphQL unexpected exception | type=Internal | field={} | message={} | correlationId={}",
            fieldName, ex.getMessage(), correlationId, ex);

        return GraphqlErrorBuilder.newError()
            .errorType(graphql.ErrorType.DataFetchingException)
            .message("Erro interno do servidor")
            .path(env.getExecutionStepInfo().getPath())
            .location(env.getField().getSourceLocation())
            .build();
    }
}
