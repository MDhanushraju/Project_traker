package com.taker.auth.service;

import com.taker.auth.dto.*;
import java.time.Instant;
import com.taker.auth.entity.Role;
import com.taker.auth.entity.User;
import com.taker.auth.exception.AuthException;
import com.taker.auth.exception.UnauthorizedException;
import com.taker.auth.repository.PositionRepository;
import com.taker.auth.repository.UserRepository;
import com.taker.auth.security.JwtService;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
public class AuthService {

    private final UserRepository userRepository;
    private final PositionRepository positionRepository;
    private final PasswordEncoder passwordEncoder;
    private final JwtService jwtService;

    public AuthService(UserRepository userRepository,
                       PositionRepository positionRepository,
                       PasswordEncoder passwordEncoder,
                       JwtService jwtService) {
        this.userRepository = userRepository;
        this.positionRepository = positionRepository;
        this.passwordEncoder = passwordEncoder;
        this.jwtService = jwtService;
    }

    public AuthResponse login(LoginRequest req) {
        User user;
        String email = req.getEmail().trim();
        String idCard = req.getIdCardNumber() != null ? req.getIdCardNumber().trim() : "";
        if (!idCard.isBlank()) {
            user = userRepository.findByEmailAndIdCardNumber(email, idCard)
                    .orElseThrow(() -> new UnauthorizedException("Invalid email or ID Card Number"));
        } else {
            user = userRepository.findByEmail(email)
                    .orElseThrow(() -> new UnauthorizedException("Invalid email or password"));
        }
        if (!passwordEncoder.matches(req.getPassword(), user.getPassword())) {
            throw new UnauthorizedException("Invalid email or password");
        }

        String roleName = user.getRole().name().toLowerCase();
        String token = jwtService.generateToken(user.getEmail(), roleName);
        return new AuthResponse(token, roleName, user.getEmail(), user.getFullName());
    }

    @Transactional
    public AuthResponse signUp(SignUpRequest req) {
        if (!req.getPassword().equals(req.getConfirmPassword())) {
            throw new AuthException("Passwords do not match");
        }
        if (!isValidPassword(req.getPassword())) {
            throw new AuthException("Password must be at least 8 characters with one number and one special character");
        }
        if (userRepository.existsByEmail(req.getEmail().trim().toLowerCase())) {
            throw new AuthException("Email already registered");
        }

        Role role = parseRole(req.getRole() != null ? req.getRole() : "member");
        User user = new User(
                req.getFullName().trim(),
                req.getEmail().trim().toLowerCase(),
                req.getIdCardNumber() != null ? req.getIdCardNumber().trim() : null,
                passwordEncoder.encode(req.getPassword()),
                role
        );
        if (req.getPosition() != null && !req.getPosition().isBlank()) {
            positionRepository.findByName(req.getPosition().trim())
                    .ifPresent(user::setPosition);
        }
        user = userRepository.save(user);

        String roleName = user.getRole().name().toLowerCase();
        String token = jwtService.generateToken(user.getEmail(), roleName);
        return new AuthResponse(token, roleName, user.getEmail(), user.getFullName());
    }

    public Role parseRole(String role) {
        if (role == null || role.isBlank()) return Role.MEMBER;
        String r = role.trim().toLowerCase().replace(" ", "_").replace("teamleader", "team_leader");
        return switch (r) {
            case "admin" -> Role.ADMIN;
            case "manager" -> Role.MANAGER;
            case "team_leader" -> Role.TEAM_LEADER;
            default -> Role.MEMBER;
        };
    }

    public AuthResponse loginWithRole(String roleStr) {
        Role role = parseRole(roleStr);
        User user = userRepository.findAll().stream()
                .filter(u -> u.getRole() == role)
                .findFirst()
                .orElseThrow(() -> new AuthException("No user found for role: " + roleStr));
        String roleName = user.getRole().name().toLowerCase();
        String token = jwtService.generateToken(user.getEmail(), roleName);
        return new AuthResponse(token, roleName, user.getEmail(), user.getFullName());
    }

    private boolean isValidPassword(String password) {
        return isValidPasswordStatic(password);
    }

    public static boolean isValidPasswordStatic(String password) {
        return password != null
                && password.length() >= 8
                && password.matches(".*[0-9].*")
                && password.matches(".*[!@#$%^&*(),.?\":{}|<>].*");
    }

    public ForgotPasswordResponse forgotPassword(ForgotPasswordRequest req) {
        String email = req.getEmail().trim().toLowerCase();
        User user = userRepository.findByEmail(email).orElse(null);
        if (user == null) {
            return new ForgotPasswordResponse("If the email exists, a captcha has been generated.", null);
        }
        int a = (int) (Math.random() * 9) + 1;
        int b = (int) (Math.random() * 9) + 1;
        String captchaQuestion = "What is " + a + " + " + b + "?";
        String answer = String.valueOf(a + b);
        user.setPendingOtp(answer);
        user.setOtpExpiresAt(Instant.now().plusSeconds(300));
        userRepository.save(user);
        return new ForgotPasswordResponse("Solve the captcha to continue.", captchaQuestion);
    }

    @Transactional
    public ResetTokenResponse verifyCaptcha(VerifyCaptchaRequest req) {
        String email = req.getEmail() != null ? req.getEmail().trim().toLowerCase() : "";
        String captchaAnswer = req.getCaptchaAnswer() != null ? req.getCaptchaAnswer().trim() : "";
        User user = userRepository.findByEmail(email)
                .orElseThrow(() -> new AuthException("Invalid or expired captcha"));
        if (user.getPendingOtp() == null || user.getOtpExpiresAt() == null) {
            throw new AuthException("Invalid or expired captcha");
        }
        if (!user.getPendingOtp().equals(captchaAnswer)) {
            throw new AuthException("Invalid captcha answer");
        }
        if (Instant.now().isAfter(user.getOtpExpiresAt())) {
            user.setPendingOtp(null);
            user.setOtpExpiresAt(null);
            userRepository.save(user);
            throw new AuthException("Invalid or expired captcha");
        }
        user.setPendingOtp(null);
        user.setOtpExpiresAt(null);
        userRepository.save(user);
        String resetToken = jwtService.generateResetToken(email);
        return new ResetTokenResponse(resetToken);
    }

    @Transactional
    public MessageResponse resetPassword(String bearerToken, ResetPasswordRequest req) {
        if (bearerToken == null || !bearerToken.startsWith("Bearer ")) {
            throw new UnauthorizedException("Invalid reset token");
        }
        String token = bearerToken.substring(7);
        if (!jwtService.isResetToken(token)) {
            throw new UnauthorizedException("Invalid reset token");
        }
        if (!req.getNewPassword().equals(req.getConfirmPassword())) {
            throw new AuthException("Passwords do not match");
        }
        if (!isValidPassword(req.getNewPassword())) {
            throw new AuthException("Password must be at least 8 characters with one number and one special character");
        }
        String email = jwtService.extractEmail(token);
        User user = userRepository.findByEmail(email)
                .orElseThrow(() -> new UnauthorizedException("Invalid reset token"));
        user.setPassword(passwordEncoder.encode(req.getNewPassword()));
        userRepository.save(user);
        return new MessageResponse("Password has been reset successfully.");
    }
}
