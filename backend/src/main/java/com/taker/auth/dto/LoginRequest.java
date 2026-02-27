package com.taker.auth.dto;

import io.swagger.v3.oas.annotations.media.Schema;
import jakarta.validation.constraints.NotBlank;

@Schema(description = "Login with 5-digit loginId or email, and password")
public class LoginRequest {

    @Schema(description = "5-digit login ID (use either loginId or email)", example = "10001")
    private Integer loginId;

    @Schema(description = "Optional ID card number (when provided with email for 2FA-style auth)", example = "000-0000-001")
    private String idCardNumber;

    @Schema(description = "User email (use either loginId or email)", example = "admin@taker.com")
    private String email;

    @Schema(description = "User password", requiredMode = Schema.RequiredMode.REQUIRED, example = "Dhanush@03")
    @NotBlank(message = "Password is required")
    private String password;

    @Schema(description = "Optional role hint", example = "admin")
    private String role;

    public Integer getLoginId() { return loginId; }
    public void setLoginId(Integer loginId) { this.loginId = loginId; }
    public String getIdCardNumber() { return idCardNumber; }
    public void setIdCardNumber(String idCardNumber) { this.idCardNumber = idCardNumber != null ? idCardNumber.trim() : null; }
    public String getEmail() { return email; }
    public void setEmail(String email) { this.email = email != null ? email.trim() : null; }
    public String getPassword() { return password; }
    public void setPassword(String password) { this.password = password; }
    public String getRole() { return role; }
    public void setRole(String role) { this.role = role; }
}
