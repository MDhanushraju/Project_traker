package com.taker.auth.controller;

import com.taker.auth.dto.*;
import com.taker.auth.service.AuthService;
import jakarta.validation.Valid;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/auth")
public class AuthController {

    private final AuthService authService;

    public AuthController(AuthService authService) {
        this.authService = authService;
    }

    @PostMapping("/login")
    public ResponseEntity<ApiResponse<AuthResponse>> login(@Valid @RequestBody LoginRequest request) {
        AuthResponse data = authService.login(request);
        return ResponseEntity.ok(ApiResponse.success("Login successful", data));
    }

    @PostMapping("/signup")
    public ResponseEntity<ApiResponse<AuthResponse>> signUp(@Valid @RequestBody SignUpRequest request) {
        AuthResponse data = authService.signUp(request);
        return ResponseEntity.ok(ApiResponse.success("Sign up successful", data));
    }

    @PostMapping("/forgot-password")
    public ResponseEntity<ApiResponse<ForgotPasswordResponse>> forgotPassword(@Valid @RequestBody ForgotPasswordRequest request) {
        ForgotPasswordResponse data = authService.forgotPassword(request);
        return ResponseEntity.ok(ApiResponse.success("Done", data));
    }

    @PostMapping("/verify-captcha")
    public ResponseEntity<ApiResponse<ResetTokenResponse>> verifyCaptcha(@Valid @RequestBody VerifyCaptchaRequest request) {
        ResetTokenResponse data = authService.verifyCaptcha(request);
        return ResponseEntity.ok(ApiResponse.success("Captcha verified", data));
    }

    @PostMapping("/reset-password")
    public ResponseEntity<ApiResponse<MessageResponse>> resetPassword(
            @RequestHeader(value = "Authorization", required = false) String authHeader,
            @Valid @RequestBody ResetPasswordRequest request) {
        MessageResponse data = authService.resetPassword(authHeader != null ? authHeader : "", request);
        return ResponseEntity.ok(ApiResponse.success("Password reset done", data));
    }
}
