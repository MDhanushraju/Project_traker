package com.taker.auth.dto;

import io.swagger.v3.oas.annotations.media.Schema;
import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;

@Schema(description = "Verify captcha answer to get reset token")
public class VerifyCaptchaRequest {

    @Schema(description = "User email", requiredMode = Schema.RequiredMode.REQUIRED, example = "admin@taker.com")
    @NotBlank(message = "Email is required")
    @Email(message = "Invalid email format")
    private String email;

    @Schema(description = "Answer to captcha (e.g. 3+5=8)", requiredMode = Schema.RequiredMode.REQUIRED, example = "8")
    @NotBlank(message = "Captcha answer is required")
    private String captchaAnswer;

    public String getEmail() { return email; }
    public void setEmail(String email) { this.email = email; }
    public String getCaptchaAnswer() { return captchaAnswer; }
    public void setCaptchaAnswer(String captchaAnswer) { this.captchaAnswer = captchaAnswer; }
}
