package com.taker.auth.dto;

public class ForgotPasswordResponse {

    private String message;
    private String captchaQuestion;

    public ForgotPasswordResponse() {}

    public ForgotPasswordResponse(String message, String captchaQuestion) {
        this.message = message;
        this.captchaQuestion = captchaQuestion;
    }

    public String getMessage() { return message; }
    public void setMessage(String message) { this.message = message; }
    public String getCaptchaQuestion() { return captchaQuestion; }
    public void setCaptchaQuestion(String captchaQuestion) { this.captchaQuestion = captchaQuestion; }
}
