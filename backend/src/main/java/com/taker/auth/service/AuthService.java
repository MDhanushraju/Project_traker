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

    /**
     * Login with 5-digit loginId or email (and password). Optional: idCardNumber when using email.
     * Response includes loginId so user can use it next time.
     */
    @Transactional(readOnly = true)
    public AuthResponse login(LoginRequest req) {
        if (req == null) {
            throw new UnauthorizedException("Login ID or email and password are required");
        }
        Integer loginId = req.getLoginId();
        String email = req.getEmail() != null ? req.getEmail().trim().toLowerCase() : "";
        String password = req.getPassword() != null ? req.getPassword() : "";
        String idCard = req.getIdCardNumber() != null ? req.getIdCardNumber().trim() : "";
        if (password.isEmpty()) {
            throw new UnauthorizedException("Password is required");
        }
        if (loginId == null && email.isEmpty()) {
            throw new UnauthorizedException("Login ID or email is required");
        }
        boolean foundByLoginId = false;
        User user;
        if (loginId != null) {
            foundByLoginId = true;
            user = userRepository.findByLoginId(loginId)
                    .orElseThrow(() -> new UnauthorizedException("Invalid login ID or password"));
        } else if (!idCard.isBlank()) {
            user = userRepository.findByEmailAndIdCardNumber(email, idCard)
                    .orElseThrow(() -> new UnauthorizedException("Invalid email or ID card number"));
        } else {
            user = userRepository.findByEmail(email)
                    .orElseThrow(() -> new UnauthorizedException("Invalid email or password"));
        }
        if (user.getPassword() == null || !passwordEncoder.matches(password, user.getPassword())) {
            throw new UnauthorizedException(foundByLoginId ? "Invalid login ID or password" : "Invalid email or password");
        }
        Role role = user.getRole();
        if (role == null) {
            throw new AuthException("User role not set");
        }
        String roleName = role.name().toLowerCase();
        String userEmail = user.getEmail() != null ? user.getEmail() : email;
        String fullName = user.getFullName() != null ? user.getFullName() : email;
        String positionName = user.getPosition() != null ? user.getPosition().getName() : null;
        String token = jwtService.generateToken(userEmail, roleName);
        return new AuthResponse(user.getId(), user.getLoginId(), token, roleName, userEmail, fullName, positionName);
    }

    /**
     * Sign up: validate input, ensure email not taken, create user (plain password), save, return user info.
     */
    @Transactional
    public AuthResponse signUp(SignUpRequest req) {
        if (req == null) {
            throw new AuthException("Request body is required");
        }
        String fullName = req.getFullName() != null ? req.getFullName().trim() : "";
        String email = req.getEmail() != null ? req.getEmail().trim().toLowerCase() : "";
        String password = req.getPassword() != null ? req.getPassword() : "";
        String confirmPassword = req.getConfirmPassword() != null ? req.getConfirmPassword() : "";

        if (fullName.isEmpty()) {
            throw new AuthException("Full name is required");
        }
        if (email.isEmpty()) {
            throw new AuthException("Email is required");
        }
        if (password.isEmpty()) {
            throw new AuthException("Password is required");
        }
        if (!password.equals(confirmPassword)) {
            throw new AuthException("Passwords do not match");
        }
        if (userRepository.existsByEmail(email)) {
            throw new AuthException("Email already registered");
        }

        Role role = parseRole(req.getRole() != null ? req.getRole() : "member");
        String storedPassword = passwordEncoder.encode(password);
        String idCard = req.getIdCardNumber() != null && !req.getIdCardNumber().isBlank()
                ? req.getIdCardNumber().trim() : null;
        User user = new User(fullName, email, idCard, storedPassword, role);
        user.setLoginId(generateUniqueLoginId());

        if (req.getPosition() != null && !req.getPosition().isBlank()) {
            try {
                positionRepository.findByName(req.getPosition().trim()).ifPresent(user::setPosition);
            } catch (Exception ignored) {
                // position optional
            }
        }
        try {
            user = userRepository.save(user);
        } catch (Exception e) {
            String msg = e.getMessage() != null && (e.getMessage().toLowerCase().contains("duplicate") || e.getMessage().toLowerCase().contains("unique"))
                    ? "Email already registered"
                    : (e.getMessage() != null && e.getMessage().length() <= 200 ? e.getMessage() : "Sign up failed. Try again.");
            throw new AuthException(msg, e);
        }

        Role savedRole = user.getRole() != null ? user.getRole() : role;
        String roleName = savedRole.name().toLowerCase();
        String positionName = user.getPosition() != null ? user.getPosition().getName() : null;
        String token = jwtService.generateToken(user.getEmail(), roleName);
        return new AuthResponse(user.getId(), user.getLoginId(), token, roleName, user.getEmail(), user.getFullName(), positionName);
    }

    /** Generates a unique 5-digit login ID (10000–99999). */
    private int generateUniqueLoginId() {
        java.util.Random r = new java.util.Random();
        for (int i = 0; i < 100; i++) {
            int candidate = 10000 + r.nextInt(90000);
            if (userRepository.findByLoginId(candidate).isEmpty()) {
                return candidate;
            }
        }
        throw new AuthException("Could not generate unique login ID. Try again.");
    }

    /** Maps UI role names (Admin, Manager, Team Leader, Team Member) to Role enum. */
    public Role parseRole(String role) {
        if (role == null || role.isBlank()) return Role.MEMBER;
        String r = role.trim().toLowerCase().replace(" ", "_").replace("teamleader", "team_leader").replace("-", "_");
        return switch (r) {
            case "admin" -> Role.ADMIN;
            case "manager" -> Role.MANAGER;
            case "team_leader" -> Role.TEAM_LEADER;
            case "member", "team_member" -> Role.MEMBER;
            default -> Role.MEMBER;
        };
    }

    @Transactional(readOnly = true)
    public AuthResponse loginWithRole(String roleStr) {
        try {
            Role role = parseRole(roleStr);
            User user = userRepository.findAll().stream()
                    .filter(u -> u.getRole() == role)
                    .findFirst()
                    .orElseThrow(() -> new AuthException("No user found for role: " + roleStr));
            String roleName = user.getRole().name().toLowerCase();
            String email = user.getEmail() != null ? user.getEmail() : "";
            String fullName = user.getFullName() != null ? user.getFullName() : "";
            String positionName = user.getPosition() != null ? user.getPosition().getName() : null;
            String token = jwtService.generateToken(email, roleName);
            return new AuthResponse(user.getId(), user.getLoginId(), token, roleName, email, fullName, positionName);
        } catch (AuthException e) {
            throw e;
        } catch (Exception e) {
            throw new AuthException("No user found for role: " + roleStr, e);
        }
    }

    /** Used by DataService etc.; for now accepts any non-empty password. */
    public static boolean isValidPasswordStatic(String password) {
        return password != null && !password.isBlank();
    }

    /**
     * Forgot password: accept email or 5-digit loginId. Show a simple math question (e.g. "What is 2 + 8?").
     * Server stores the correct answer; user must enter it on reset-password along with new password.
     * Response includes email so frontend can send it on reset when user used loginId.
     */
    @Transactional
    public ForgotPasswordResponse forgotPassword(ForgotPasswordRequest req) {
        if (req == null) {
            throw new AuthException("Email or ID number is required");
        }
        Integer loginId = req.getLoginId();
        String email = req.getEmail() != null ? req.getEmail().trim() : "";
        User user;
        if (loginId != null) {
            user = userRepository.findByLoginId(loginId)
                    .orElseThrow(() -> new AuthException("No account found for this ID number"));
        } else if (!email.isEmpty()) {
            user = userRepository.findByEmail(email.toLowerCase())
                    .orElseThrow(() -> new AuthException("No account found for this email"));
        } else {
            throw new AuthException("Enter your email or ID number");
        }
        String userEmail = user.getEmail() != null ? user.getEmail() : "";
        int a = (int) (Math.random() * 9) + 1;
        int b = (int) (Math.random() * 9) + 1;
        int answer = a + b;
        String question = "What is " + a + " + " + b + "?";
        user.setPendingOtp(String.valueOf(answer));
        user.setOtpExpiresAt(Instant.now().plusSeconds(300)); // 5 minutes
        userRepository.save(user);
        return new ForgotPasswordResponse(
                "Answer the question below, then set your new password.",
                question,
                userEmail);
    }

    /**
     * Reset password: user sends email + captcha answer (e.g. "10") + new password.
     * If answer is correct, new password is stored hashed (BCrypt).
     */
    @Transactional
    public MessageResponse resetPassword(ResetPasswordRequest req) {
        if (req == null) {
            throw new AuthException("Request body is required");
        }
        String email = req.getEmail() != null ? req.getEmail().trim().toLowerCase() : "";
        String captchaAnswer = req.getCaptchaAnswer() != null ? req.getCaptchaAnswer().trim() : "";
        String newPassword = req.getNewPassword() != null ? req.getNewPassword() : "";
        String confirmPassword = req.getConfirmPassword() != null ? req.getConfirmPassword() : "";
        if (email.isEmpty()) {
            throw new AuthException("Email is required");
        }
        if (captchaAnswer.isEmpty()) {
            throw new AuthException("Please enter the answer to the question");
        }
        if (newPassword.isEmpty()) {
            throw new AuthException("New password is required");
        }
        if (!newPassword.equals(confirmPassword)) {
            throw new AuthException("Passwords do not match");
        }
        User user = userRepository.findByEmail(email)
                .orElseThrow(() -> new AuthException("Invalid or expired. Request a new question from Forgot password."));
        if (user.getPendingOtp() == null || user.getOtpExpiresAt() == null) {
            throw new AuthException("Invalid or expired. Request a new question from Forgot password.");
        }
        if (Instant.now().isAfter(user.getOtpExpiresAt())) {
            user.setPendingOtp(null);
            user.setOtpExpiresAt(null);
            userRepository.save(user);
            throw new AuthException("Question expired. Request a new one from Forgot password.");
        }
        if (!user.getPendingOtp().equals(captchaAnswer)) {
            throw new AuthException("Wrong answer. Please try again.");
        }
        user.setPassword(passwordEncoder.encode(newPassword));
        user.setPendingOtp(null);
        user.setOtpExpiresAt(null);
        userRepository.save(user);
        return new MessageResponse("Password has been reset successfully. You can log in with your new password.");
    }
}
