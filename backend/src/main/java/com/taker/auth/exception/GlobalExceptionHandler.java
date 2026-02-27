package com.taker.auth.exception;

import com.taker.auth.dto.ApiResponse;
import jakarta.servlet.http.HttpServletRequest;
import org.springframework.dao.DataIntegrityViolationException;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.http.converter.HttpMessageNotReadableException;
import org.springframework.validation.FieldError;
import org.springframework.web.bind.MethodArgumentNotValidException;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.RestControllerAdvice;

import java.util.HashMap;
import java.util.Map;

@RestControllerAdvice
public class GlobalExceptionHandler {

    private static String path(HttpServletRequest request) {
        return request != null ? request.getRequestURI() : null;
    }

    @ExceptionHandler(AuthException.class)
    public ResponseEntity<ApiResponse<Void>> handleAuthException(AuthException ex, HttpServletRequest request) {
        String p = request != null ? request.getRequestURI() : "";
        ErrorCode code;
        if (p != null && p.contains("/login")) {
            code = ErrorCode.AUTH_LOGIN_FAILED;
        } else if (p != null && p.contains("/signup")) {
            code = ex.getMessage() != null && ex.getMessage().toLowerCase().contains("already registered")
                    ? ErrorCode.AUTH_SIGNUP_EMAIL_EXISTS
                    : ErrorCode.AUTH_SIGNUP_FAILED;
        } else if (p != null && (p.contains("/forgot-password") || p.contains("forgot"))) {
            code = ErrorCode.AUTH_FORGOT_PASSWORD;
        } else if (p != null && p.contains("reset-password")) {
            code = ErrorCode.AUTH_RESET_PASSWORD;
        } else {
            code = ErrorCode.AUTH_SIGNUP_FAILED;
        }
        return ResponseEntity.status(HttpStatus.BAD_REQUEST)
                .body(ApiResponse.failure(400, code, ex.getMessage(), path(request)));
    }

    @ExceptionHandler(UnauthorizedException.class)
    public ResponseEntity<ApiResponse<Void>> handleUnauthorized(UnauthorizedException ex, HttpServletRequest request) {
        return ResponseEntity.status(HttpStatus.UNAUTHORIZED)
                .body(ApiResponse.failure(401, ErrorCode.AUTH_UNAUTHORIZED, ex.getMessage(), path(request)));
    }

    @ExceptionHandler(ForbiddenException.class)
    public ResponseEntity<ApiResponse<Void>> handleForbidden(ForbiddenException ex, HttpServletRequest request) {
        return ResponseEntity.status(HttpStatus.FORBIDDEN)
                .body(ApiResponse.failure(403, ErrorCode.FORBIDDEN, ex.getMessage(), path(request)));
    }

    @ExceptionHandler(NotFoundException.class)
    public ResponseEntity<ApiResponse<Void>> handleNotFound(NotFoundException ex, HttpServletRequest request) {
        String msg = ex.getMessage();
        ErrorCode code = ErrorCode.USER_NOT_FOUND;
        if (msg != null) {
            if (msg.toLowerCase().contains("task")) code = ErrorCode.TASK_NOT_FOUND;
            else if (msg.toLowerCase().contains("project")) code = ErrorCode.PROJECT_NOT_FOUND;
        }
        return ResponseEntity.status(HttpStatus.NOT_FOUND)
                .body(ApiResponse.failure(404, code, msg != null ? msg : code.getDefaultMessage(), path(request)));
    }

    @ExceptionHandler(MethodArgumentNotValidException.class)
    public ResponseEntity<ApiResponse<Map<String, String>>> handleValidation(
            MethodArgumentNotValidException ex, HttpServletRequest request) {
        Map<String, String> errors = new HashMap<>();
        ex.getBindingResult().getAllErrors().forEach(err -> {
            String field = err instanceof FieldError ? ((FieldError) err).getField() : "error";
            String message = err.getDefaultMessage() != null ? err.getDefaultMessage() : "Invalid value";
            errors.put(field, message);
        });
        String summary = errors.isEmpty() ? ErrorCode.VALIDATION_FAILED.getDefaultMessage()
                : "Validation failed on: " + String.join(", ", errors.keySet());
        return ResponseEntity.status(HttpStatus.BAD_REQUEST)
                .body(ApiResponse.failure(400, ErrorCode.VALIDATION_FAILED, summary, path(request), errors));
    }

    @ExceptionHandler(DataIntegrityViolationException.class)
    public ResponseEntity<ApiResponse<Void>> handleDataIntegrity(DataIntegrityViolationException ex, HttpServletRequest request) {
        boolean emailConflict = ex.getMessage() != null && ex.getMessage().toLowerCase().contains("unique");
        ErrorCode code = emailConflict ? ErrorCode.DATA_EMAIL_EXISTS : ErrorCode.DATA_INVALID;
        String msg = emailConflict ? "Email already registered." : "Invalid data. Please check your input.";
        return ResponseEntity.status(HttpStatus.BAD_REQUEST)
                .body(ApiResponse.failure(400, code, msg, path(request)));
    }

    @ExceptionHandler(HttpMessageNotReadableException.class)
    public ResponseEntity<ApiResponse<Void>> handleBadRequest(HttpMessageNotReadableException ex, HttpServletRequest request) {
        String msg = "Invalid request body. Send valid JSON with required fields (e.g. fullName, email, password, role).";
        return ResponseEntity.status(HttpStatus.BAD_REQUEST)
                .body(ApiResponse.failure(400, ErrorCode.VALIDATION_REQUEST_BODY, msg, path(request)));
    }

    @ExceptionHandler(Exception.class)
    public ResponseEntity<ApiResponse<Void>> handleGeneric(Exception ex, HttpServletRequest request) {
        ex.printStackTrace();
        String p = path(request);
        int status = HttpStatus.INTERNAL_SERVER_ERROR.value();
        ErrorCode code = ErrorCode.INTERNAL_ERROR;
        String msg = "An unexpected error occurred. Please try again.";
        if (p != null && p.contains("/api/health/")) {
            status = HttpStatus.SERVICE_UNAVAILABLE.value();
            msg = "Database not connected: " + (ex.getMessage() != null && !ex.getMessage().isBlank() ? ex.getMessage() : ex.getClass().getSimpleName());
        } else if (p != null && p.contains("/signup")) {
            status = HttpStatus.BAD_REQUEST.value();
            code = ErrorCode.AUTH_SIGNUP_FAILED;
            msg = ex.getMessage() != null && !ex.getMessage().isBlank() ? ex.getMessage() : "Sign up failed. Check fullName, email, password, confirmPassword, role.";
        }
        return ResponseEntity.status(status)
                .body(ApiResponse.failure(status, code, msg, p));
    }
}
