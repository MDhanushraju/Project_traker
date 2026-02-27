package com.taker.auth.exception;

import com.taker.auth.dto.ApiResponse;
import jakarta.servlet.http.HttpServletRequest;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Nested;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.dao.DataIntegrityViolationException;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.http.converter.HttpMessageNotReadableException;
import org.springframework.validation.BindingResult;
import org.springframework.validation.FieldError;
import org.springframework.web.bind.MethodArgumentNotValidException;

import java.util.Map;

import static org.assertj.core.api.Assertions.assertThat;
import static org.mockito.Mockito.when;

@ExtendWith(MockitoExtension.class)
class GlobalExceptionHandlerTest {

    private GlobalExceptionHandler handler;

    @Mock
    private HttpServletRequest request;

    @BeforeEach
    void setUp() {
        handler = new GlobalExceptionHandler();
    }

    @Nested
    @DisplayName("handleAuthException")
    class AuthExceptionTests {
        @Test
        void returnsBadRequestWithLoginCodeWhenPathContainsLogin() {
            when(request.getRequestURI()).thenReturn("/api/auth/login");
            AuthException ex = new AuthException("Invalid credentials");

            ResponseEntity<ApiResponse<Void>> res = handler.handleAuthException(ex, request);

            assertThat(res.getStatusCode()).isEqualTo(HttpStatus.BAD_REQUEST);
            assertThat(res.getBody()).isNotNull();
            assertThat(res.getBody().getStatusCode()).isEqualTo(400);
            assertThat(res.getBody().getErrorCode()).isEqualTo(ErrorCode.AUTH_LOGIN_FAILED.getCode());
            assertThat(res.getBody().getMessage()).isEqualTo("Invalid credentials");
        }

        @Test
        void returnsSignupEmailExistsWhenPathContainsSignupAndMessageContainsAlreadyRegistered() {
            when(request.getRequestURI()).thenReturn("/api/auth/signup");
            AuthException ex = new AuthException("Email already registered");

            ResponseEntity<ApiResponse<Void>> res = handler.handleAuthException(ex, request);

            assertThat(res.getStatusCode()).isEqualTo(HttpStatus.BAD_REQUEST);
            assertThat(res.getBody().getErrorCode()).isEqualTo(ErrorCode.AUTH_SIGNUP_EMAIL_EXISTS.getCode());
        }

        @Test
        void returnsSignupFailedWhenPathContainsSignupWithoutAlreadyRegistered() {
            when(request.getRequestURI()).thenReturn("/api/auth/signup");
            AuthException ex = new AuthException("Validation failed");

            ResponseEntity<ApiResponse<Void>> res = handler.handleAuthException(ex, request);

            assertThat(res.getBody().getErrorCode()).isEqualTo(ErrorCode.AUTH_SIGNUP_FAILED.getCode());
        }
    }

    @Nested
    @DisplayName("handleUnauthorized")
    class UnauthorizedTests {
        @Test
        void returns401WithUnauthorizedCode() {
            when(request.getRequestURI()).thenReturn("/api/projects");
            UnauthorizedException ex = new UnauthorizedException("Not authorized");

            ResponseEntity<ApiResponse<Void>> res = handler.handleUnauthorized(ex, request);

            assertThat(res.getStatusCode()).isEqualTo(HttpStatus.UNAUTHORIZED);
            assertThat(res.getBody().getStatusCode()).isEqualTo(401);
            assertThat(res.getBody().getErrorCode()).isEqualTo(ErrorCode.AUTH_UNAUTHORIZED.getCode());
        }
    }

    @Nested
    @DisplayName("handleNotFound")
    class NotFoundTests {
        @Test
        void returns404WithTaskNotFoundWhenMessageContainsTask() {
            when(request.getRequestURI()).thenReturn("/api/tasks/1");
            NotFoundException ex = new NotFoundException("Task not found");

            ResponseEntity<ApiResponse<Void>> res = handler.handleNotFound(ex, request);

            assertThat(res.getStatusCode()).isEqualTo(HttpStatus.NOT_FOUND);
            assertThat(res.getBody().getErrorCode()).isEqualTo(ErrorCode.TASK_NOT_FOUND.getCode());
        }

        @Test
        void returns404WithProjectNotFoundWhenMessageContainsProject() {
            NotFoundException ex = new NotFoundException("Project not found");

            ResponseEntity<ApiResponse<Void>> res = handler.handleNotFound(ex, request);

            assertThat(res.getBody().getErrorCode()).isEqualTo(ErrorCode.PROJECT_NOT_FOUND.getCode());
        }

        @Test
        void returns404WithUserNotFoundByDefault() {
            NotFoundException ex = new NotFoundException("User not found");

            ResponseEntity<ApiResponse<Void>> res = handler.handleNotFound(ex, request);

            assertThat(res.getBody().getErrorCode()).isEqualTo(ErrorCode.USER_NOT_FOUND.getCode());
        }
    }

    @Nested
    @DisplayName("handleValidation")
    class ValidationTests {
        @Test
        void returnsBadRequestWithFieldErrors() {
            when(request.getRequestURI()).thenReturn("/api/auth/signup");
            BindingResult bindingResult = org.mockito.Mockito.mock(BindingResult.class);
            when(bindingResult.getAllErrors()).thenReturn(
                    java.util.List.of(new FieldError("signUpRequest", "email", "must be valid email"))
            );
            MethodArgumentNotValidException ex = org.mockito.Mockito.mock(MethodArgumentNotValidException.class);
            when(ex.getBindingResult()).thenReturn(bindingResult);

            ResponseEntity<ApiResponse<Map<String, String>>> res = handler.handleValidation(ex, request);

            assertThat(res.getStatusCode()).isEqualTo(HttpStatus.BAD_REQUEST);
            assertThat(res.getBody().getErrorCode()).isEqualTo(ErrorCode.VALIDATION_FAILED.getCode());
            assertThat(res.getBody().getData()).containsKey("email");
        }
    }

    @Nested
    @DisplayName("handleDataIntegrity")
    class DataIntegrityTests {
        @Test
        void returnsEmailExistsWhenMessageContainsUnique() {
            when(request.getRequestURI()).thenReturn("/api/users");
            DataIntegrityViolationException ex = new DataIntegrityViolationException("unique constraint violation on email");

            ResponseEntity<ApiResponse<Void>> res = handler.handleDataIntegrity(ex, request);

            assertThat(res.getStatusCode()).isEqualTo(HttpStatus.BAD_REQUEST);
            assertThat(res.getBody().getErrorCode()).isEqualTo(ErrorCode.DATA_EMAIL_EXISTS.getCode());
        }

        @Test
        void returnsDataInvalidWhenMessageDoesNotContainUnique() {
            DataIntegrityViolationException ex = new DataIntegrityViolationException("constraint violation");

            ResponseEntity<ApiResponse<Void>> res = handler.handleDataIntegrity(ex, request);

            assertThat(res.getBody().getErrorCode()).isEqualTo(ErrorCode.DATA_INVALID.getCode());
        }
    }

    @Nested
    @DisplayName("handleBadRequest")
    class BadRequestTests {
        @Test
        void returns400WithRequestBodyMessage() {
            when(request.getRequestURI()).thenReturn("/api/auth/signup");
            HttpMessageNotReadableException ex = new HttpMessageNotReadableException("Malformed JSON", new RuntimeException(), null);

            ResponseEntity<ApiResponse<Void>> res = handler.handleBadRequest(ex, request);

            assertThat(res.getStatusCode()).isEqualTo(HttpStatus.BAD_REQUEST);
            assertThat(res.getBody().getErrorCode()).isEqualTo(ErrorCode.VALIDATION_REQUEST_BODY.getCode());
            assertThat(res.getBody().getMessage()).contains("Invalid request body");
        }
    }

    @Nested
    @DisplayName("handleGeneric")
    class GenericExceptionTests {
        @Test
        void returns500WithInternalErrorCode() {
            when(request.getRequestURI()).thenReturn("/api/projects");
            Exception ex = new RuntimeException("Unexpected");

            ResponseEntity<ApiResponse<Void>> res = handler.handleGeneric(ex, request);

            assertThat(res.getStatusCode()).isEqualTo(HttpStatus.INTERNAL_SERVER_ERROR);
            assertThat(res.getBody().getStatusCode()).isEqualTo(500);
            assertThat(res.getBody().getErrorCode()).isEqualTo(ErrorCode.INTERNAL_ERROR.getCode());
        }
    }
}
