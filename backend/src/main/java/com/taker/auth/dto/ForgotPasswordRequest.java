package com.taker.auth.dto;

import io.swagger.v3.oas.annotations.media.Schema;
import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;

@Schema(description = "Request password reset - sends captcha")
public class ForgotPasswordRequest {

    @Schema(description = "User email", requiredMode = Schema.RequiredMode.REQUIRED, example = "admin@taker.com")
    @NotBlank(message = "Email is required")
    @Email(message = "Invalid email format")
    private String email;

    public String getEmail() { return email; }
    public void setEmail(String email) { this.email = email; }
}
