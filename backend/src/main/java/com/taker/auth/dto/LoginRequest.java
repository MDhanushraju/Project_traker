package com.taker.auth.dto;

import io.swagger.v3.oas.annotations.media.Schema;
import jakarta.validation.constraints.NotBlank;

@Schema(description = "Login with email and password")
public class LoginRequest {

    @Schema(description = "Optional ID card number (when provided, used with email for 2FA-style auth)", example = "000-0000-001")
    private String idCardNumber;

    @Schema(description = "User email", requiredMode = Schema.RequiredMode.REQUIRED, example = "admin@taker.com")
    @NotBlank(message = "Email is required")
    private String email;

    @Schema(description = "User password", requiredMode = Schema.RequiredMode.REQUIRED, example = "Admin@123")
    @NotBlank(message = "Password is required")
    private String password;

    @Schema(description = "Optional role hint", example = "admin")
    private String role;

    public String getIdCardNumber() { return idCardNumber; }
    public void setIdCardNumber(String idCardNumber) { this.idCardNumber = idCardNumber; }
    public String getEmail() { return email; }
    public void setEmail(String email) { this.email = email; }
    public String getPassword() { return password; }
    public void setPassword(String password) { this.password = password; }
    public String getRole() { return role; }
    public void setRole(String role) { this.role = role; }
}
