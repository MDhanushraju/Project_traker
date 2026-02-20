package com.taker.auth.service;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.mail.SimpleMailMessage;
import org.springframework.mail.javamail.JavaMailSender;
import org.springframework.stereotype.Service;
import org.springframework.beans.factory.ObjectProvider;

@Service
public class EmailService {

    private final JavaMailSender mailSender;

    @Value("${spring.mail.username:}")
    private String fromEmail;

    @Value("${app.mail.enabled:false}")
    private boolean mailEnabled;

    public EmailService(ObjectProvider<JavaMailSender> mailSenderProvider) {
        this.mailSender = mailSenderProvider.getIfAvailable();
    }

    public boolean isMailConfigured() {
        return mailSender != null && mailEnabled && fromEmail != null && !fromEmail.isBlank();
    }

    public void sendOtp(String toEmail, String otp) {
        if (!isMailConfigured()) {
            return;
        }
        SimpleMailMessage message = new SimpleMailMessage();
        message.setFrom(fromEmail);
        message.setTo(toEmail);
        message.setSubject("Your Taker Password Reset Code");
        message.setText(
                "Your 4-digit verification code is: " + otp + "\n\n" +
                "This code expires in 10 minutes.\n\n" +
                "If you did not request this, please ignore this email."
        );
        mailSender.send(message);
    }
}
