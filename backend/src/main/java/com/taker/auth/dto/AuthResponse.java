package com.taker.auth.dto;

import io.swagger.v3.oas.annotations.media.Schema;

@Schema(description = "Auth response: user info returned after login or signup")
public class AuthResponse {

    @Schema(description = "Database user ID", example = "1")
    private Long id;

    @Schema(description = "5-digit login ID (use this or email to log in next time)", example = "10001")
    private Integer loginId;

    @Schema(description = "Token (empty for now)", example = "")
    private String token;

    @Schema(description = "User role", example = "admin")
    private String role;

    @Schema(description = "User email", example = "admin@taker.com")
    private String email;

    @Schema(description = "User full name", example = "Admin User")
    private String fullName;

    @Schema(description = "Team/position name (Developer, Tester, Designer, Analyst)", example = "Developer")
    private String position;

    public AuthResponse() {}

    public AuthResponse(String token, String role, String email, String fullName) {
        this(null, token, role, email, fullName, null);
    }

    public AuthResponse(Long id, String token, String role, String email, String fullName) {
        this(id, null, token, role, email, fullName, null);
    }

    public AuthResponse(Long id, String token, String role, String email, String fullName, String position) {
        this(id, null, token, role, email, fullName, position);
    }

    public AuthResponse(Long id, Integer loginId, String token, String role, String email, String fullName, String position) {
        this.id = id;
        this.loginId = loginId;
        this.token = token != null ? token : "";
        this.role = role;
        this.email = email;
        this.fullName = fullName;
        this.position = position;
    }

    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }
    public Integer getLoginId() { return loginId; }
    public void setLoginId(Integer loginId) { this.loginId = loginId; }
    public String getToken() { return token; }
    public void setToken(String token) { this.token = token; }
    public String getRole() { return role; }
    public void setRole(String role) { this.role = role; }
    public String getEmail() { return email; }
    public void setEmail(String email) { this.email = email; }
    public String getFullName() { return fullName; }
    public void setFullName(String fullName) { this.fullName = fullName; }
    public String getPosition() { return position; }
    public void setPosition(String position) { this.position = position; }
}
