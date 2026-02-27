package com.taker.auth.controller;

import com.taker.auth.dto.*;
import com.taker.auth.exception.AuthException;
import com.taker.auth.exception.ErrorCode;
import com.taker.auth.exception.UnauthorizedException;
import com.taker.auth.service.AuthService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.servlet.http.HttpServletRequest;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@Tag(name = "Auth", description = "Login, signup, forgot password (math captcha), reset password (hashed)")
@io.swagger.v3.oas.annotations.security.SecurityRequirements()
@RestController
@RequestMapping("/api/auth")
public class AuthController {

    private final AuthService authService;

    public AuthController(AuthService authService) {
        this.authService = authService;
    }

    private static String path(HttpServletRequest r) {
        return r != null ? r.getRequestURI() : null;
    }

    @Operation(summary = "Log In", description = "Sign in with 5-digit loginId or email and password. Body: { \"loginId\" or \"email\", \"password\" }. Returns id, loginId, role, email, fullName, position.")
    @PostMapping("/login")
    public ResponseEntity<ApiResponse<AuthResponse>> login(@RequestBody(required = false) LoginRequest request, HttpServletRequest req) {
        String requestPath = path(req);
        if (request == null) {
            return ResponseEntity.status(HttpStatus.BAD_REQUEST)
                    .body(ApiResponse.failure(400, ErrorCode.VALIDATION_REQUEST_BODY,
                            "Request body is required. Send JSON: loginId (5-digit) or email, and password. Optional: idCardNumber.", requestPath));
        }
        try {
            AuthResponse data = authService.login(request);
            return ResponseEntity.ok(ApiResponse.success("Login successful", data));
        } catch (UnauthorizedException e) {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED)
                    .body(ApiResponse.failure(401, ErrorCode.AUTH_LOGIN_FAILED, e.getMessage(), requestPath));
        } catch (AuthException e) {
            return ResponseEntity.status(HttpStatus.BAD_REQUEST)
                    .body(ApiResponse.failure(400, ErrorCode.AUTH_LOGIN_FAILED, e.getMessage(), requestPath));
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED)
                    .body(ApiResponse.failure(401, ErrorCode.AUTH_LOGIN_FAILED, "Invalid email or password.", requestPath));
        }
    }

    @Operation(summary = "Sign up (Join Taker)", description = "Register: fullName, email, password, confirmPassword, role (admin/manager/team_leader/member), position/team (Developer, Tester, Designer, Analyst). Optional: idCardNumber.")
    @PostMapping("/signup")
    public ResponseEntity<ApiResponse<AuthResponse>> signUp(@RequestBody(required = false) SignUpRequest request, HttpServletRequest req) {
        String requestPath = path(req);
        if (request == null) {
            return ResponseEntity.status(HttpStatus.BAD_REQUEST)
                    .body(ApiResponse.failure(400, ErrorCode.VALIDATION_REQUEST_BODY,
                            "Request body is required. Send JSON: fullName, email, password, confirmPassword. Optional: role, position (team).", requestPath));
        }
        try {
            AuthResponse data = authService.signUp(request);
            return ResponseEntity.ok(ApiResponse.success("Sign up successful", data));
        } catch (AuthException e) {
            ErrorCode code = e.getMessage() != null && e.getMessage().toLowerCase().contains("already registered")
                    ? ErrorCode.AUTH_SIGNUP_EMAIL_EXISTS
                    : ErrorCode.AUTH_SIGNUP_FAILED;
            return ResponseEntity.status(HttpStatus.BAD_REQUEST)
                    .body(ApiResponse.failure(400, code, e.getMessage(), requestPath));
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.BAD_REQUEST)
                    .body(ApiResponse.failure(400, ErrorCode.AUTH_SIGNUP_FAILED,
                            e.getMessage() != null ? e.getMessage() : "Sign up failed. Check fullName, email, password, confirmPassword.", requestPath));
        }
    }

    @Operation(summary = "Forgot password", description = "Submit email or 5-digit login ID; server returns a math question (e.g. What is 2 + 8?). User must answer correctly on reset-password to set new password (stored hashed).")
    @PostMapping("/forgot-password")
    public ResponseEntity<ApiResponse<ForgotPasswordResponse>> forgotPassword(@RequestBody(required = false) ForgotPasswordRequest request, HttpServletRequest req) {
        String requestPath = path(req);
        if (request == null) {
            return ResponseEntity.status(HttpStatus.BAD_REQUEST)
                    .body(ApiResponse.failure(400, ErrorCode.VALIDATION_REQUEST_BODY, "Email or ID number is required.", requestPath));
        }
        boolean hasEmail = request.getEmail() != null && !request.getEmail().isBlank();
        boolean hasLoginId = request.getLoginId() != null;
        if (!hasEmail && !hasLoginId) {
            return ResponseEntity.status(HttpStatus.BAD_REQUEST)
                    .body(ApiResponse.failure(400, ErrorCode.VALIDATION_REQUEST_BODY, "Email or ID number is required.", requestPath));
        }
        try {
            ForgotPasswordResponse data = authService.forgotPassword(request);
            return ResponseEntity.ok(ApiResponse.success("OK", data));
        } catch (AuthException e) {
            return ResponseEntity.status(HttpStatus.BAD_REQUEST)
                    .body(ApiResponse.failure(400, ErrorCode.AUTH_FORGOT_PASSWORD, e.getMessage(), requestPath));
        }
    }

    @Operation(summary = "Reset password", description = "Send email + captcha answer (e.g. 10 for \"2 + 8\") + newPassword + confirmPassword. New password is stored hashed.")
    @PostMapping("/reset-password")
    public ResponseEntity<ApiResponse<MessageResponse>> resetPassword(@RequestBody(required = false) ResetPasswordRequest request, HttpServletRequest req) {
        String requestPath = path(req);
        if (request == null) {
            return ResponseEntity.status(HttpStatus.BAD_REQUEST)
                    .body(ApiResponse.failure(400, ErrorCode.VALIDATION_REQUEST_BODY,
                            "Request body is required. Send JSON: email, captchaAnswer, newPassword, confirmPassword.", requestPath));
        }
        try {
            MessageResponse data = authService.resetPassword(request);
            return ResponseEntity.ok(ApiResponse.success("Password reset successful", data));
        } catch (AuthException e) {
            return ResponseEntity.status(HttpStatus.BAD_REQUEST)
                    .body(ApiResponse.failure(400, ErrorCode.AUTH_RESET_PASSWORD, e.getMessage(), requestPath));
        }
    }
}
