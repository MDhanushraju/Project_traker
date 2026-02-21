package com.taker.auth.dto;

import io.swagger.v3.oas.annotations.media.Schema;

@Schema(description = "Auth response with JWT token and user info")
public class AuthResponse {

    @Schema(description = "JWT token - use in Authorization: Bearer <token>", example = "eyJhbGciOiJIUzI1NiJ9...")
    private String token;

    @Schema(description = "User role", example = "admin")
    private String role;

    @Schema(description = "User email", example = "admin@taker.com")
    private String email;

    @Schema(description = "User full name", example = "Admin User")
    private String fullName;

    public AuthResponse() {}

    public AuthResponse(String token, String role) {
        this.token = token;
        this.role = role;
    }

    public AuthResponse(String token, String role, String email, String fullName) {
        this.token = token;
        this.role = role;
        this.email = email;
        this.fullName = fullName;
    }

    public String getToken() { return token; }
    public void setToken(String token) { this.token = token; }
    public String getRole() { return role; }
    public void setRole(String role) { this.role = role; }
    public String getEmail() { return email; }
    public void setEmail(String email) { this.email = email; }
    public String getFullName() { return fullName; }
    public void setFullName(String fullName) { this.fullName = fullName; }
}
