package com.taker.auth.dto;

public class ForgotPasswordResponse {

    private String message;
    private String captchaQuestion;
    /** User email (for use on reset-password step when user identified by loginId) */
    private String email;

    public ForgotPasswordResponse() {}

    public ForgotPasswordResponse(String message, String captchaQuestion) {
        this.message = message;
        this.captchaQuestion = captchaQuestion;
        this.email = null;
    }

    public ForgotPasswordResponse(String message, String captchaQuestion, String email) {
        this.message = message;
        this.captchaQuestion = captchaQuestion;
        this.email = email;
    }

    public String getMessage() { return message; }
    public void setMessage(String message) { this.message = message; }
    public String getCaptchaQuestion() { return captchaQuestion; }
    public void setCaptchaQuestion(String captchaQuestion) { this.captchaQuestion = captchaQuestion; }
    public String getEmail() { return email; }
    public void setEmail(String email) { this.email = email; }
}
