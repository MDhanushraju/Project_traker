package com.taker.auth.controller;

import com.taker.auth.dto.*;
import com.taker.auth.service.AuthService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@Tag(name = "Auth", description = "Login, signup, password reset - no token required")
@io.swagger.v3.oas.annotations.security.SecurityRequirements()
@RestController
@RequestMapping("/api/auth")
public class AuthController {

    private final AuthService authService;

    public AuthController(AuthService authService) {
        this.authService = authService;
    }

    @Operation(summary = "Login", description = "Login with email and password. Returns JWT token. Example: email=admin@taker.com, password=Admin@123")
    @PostMapping("/login")
    public ResponseEntity<ApiResponse<AuthResponse>> login(@Valid @RequestBody LoginRequest request) {
        AuthResponse data = authService.login(request);
        return ResponseEntity.ok(ApiResponse.success("Login successful", data));
    }

    @Operation(summary = "Sign up", description = "Register new user. For team_leader/member, position (Developer, Tester, etc.) is required.")
    @PostMapping("/signup")
    public ResponseEntity<ApiResponse<AuthResponse>> signUp(@Valid @RequestBody SignUpRequest request) {
        AuthResponse data = authService.signUp(request);
        return ResponseEntity.ok(ApiResponse.success("Sign up successful", data));
    }

    @Operation(summary = "Forgot password", description = "Request password reset. Returns captcha question.")
    @PostMapping("/forgot-password")
    public ResponseEntity<ApiResponse<ForgotPasswordResponse>> forgotPassword(@Valid @RequestBody ForgotPasswordRequest request) {
        ForgotPasswordResponse data = authService.forgotPassword(request);
        return ResponseEntity.ok(ApiResponse.success("Done", data));
    }

    @Operation(summary = "Verify captcha", description = "Solve captcha from forgot-password. Returns reset token.")
    @PostMapping("/verify-captcha")
    public ResponseEntity<ApiResponse<ResetTokenResponse>> verifyCaptcha(@Valid @RequestBody VerifyCaptchaRequest request) {
        ResetTokenResponse data = authService.verifyCaptcha(request);
        return ResponseEntity.ok(ApiResponse.success("Captcha verified", data));
    }

    @Operation(summary = "Demo login by role", description = "Get token for first user with given role. For testing: role=admin returns admin@taker.com token.")
    @PostMapping("/login-with-role")
    public ResponseEntity<ApiResponse<AuthResponse>> loginWithRole(@Valid @RequestBody LoginWithRoleRequest request) {
        AuthResponse data = authService.loginWithRole(request.getRole());
        return ResponseEntity.ok(ApiResponse.success("Login successful", data));
    }

    @Operation(summary = "Reset password", description = "Reset password using token from verify-captcha. Header: Authorization: Bearer <reset_token>")
    @PostMapping("/reset-password")
    public ResponseEntity<ApiResponse<MessageResponse>> resetPassword(
            @RequestHeader(value = "Authorization", required = false) String authHeader,
            @Valid @RequestBody ResetPasswordRequest request) {
        MessageResponse data = authService.resetPassword(authHeader != null ? authHeader : "", request);
        return ResponseEntity.ok(ApiResponse.success("Password reset done", data));
    }
}
