package com.taker.auth.dto;

import io.swagger.v3.oas.annotations.media.Schema;

@Schema(description = "Request password reset - send either email or 5-digit login ID; server returns verification question")
public class ForgotPasswordRequest {

    @Schema(description = "User email (use either email or loginId)", example = "admin@taker.com")
    private String email;

    @Schema(description = "5-digit login ID (use either email or loginId)", example = "10001")
    private Integer loginId;

    public String getEmail() { return email; }
    public void setEmail(String email) { this.email = email != null ? email.trim().toLowerCase() : null; }
    public Integer getLoginId() { return loginId; }
    public void setLoginId(Integer loginId) { this.loginId = loginId; }
}
