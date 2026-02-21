package com.taker.auth.service;

import com.taker.auth.dto.LoginRequest;
import com.taker.auth.dto.SignUpRequest;
import com.taker.auth.entity.Role;
import com.taker.auth.entity.User;
import com.taker.auth.exception.AuthException;
import com.taker.auth.exception.UnauthorizedException;
import com.taker.auth.repository.PositionRepository;
import com.taker.auth.repository.UserRepository;
import com.taker.auth.security.JwtService;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Nested;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.security.crypto.password.PasswordEncoder;

import java.util.Optional;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.anyString;
import static org.mockito.Mockito.never;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

@ExtendWith(MockitoExtension.class)
class AuthServiceTest {

    @Mock
    private UserRepository userRepository;

    @Mock
    private PositionRepository positionRepository;

    @Mock
    private PasswordEncoder passwordEncoder;

    @Mock
    private JwtService jwtService;

    @InjectMocks
    private AuthService authService;

    private User testUser;

    @BeforeEach
    void setUp() {
        testUser = new User("Test User", "test@example.com", null, "$2a$10$hashed", Role.MEMBER);
        testUser.setId(1L);
    }

    @Nested
    @DisplayName("parseRole")
    class ParseRoleTests {
        @Test
        void parsesAdmin() {
            assertThat(authService.parseRole("admin")).isEqualTo(Role.ADMIN);
            assertThat(authService.parseRole("ADMIN")).isEqualTo(Role.ADMIN);
        }

        @Test
        void parsesManager() {
            assertThat(authService.parseRole("manager")).isEqualTo(Role.MANAGER);
        }

        @Test
        void parsesTeamLeader() {
            assertThat(authService.parseRole("team_leader")).isEqualTo(Role.TEAM_LEADER);
            assertThat(authService.parseRole("teamleader")).isEqualTo(Role.TEAM_LEADER);
        }

        @Test
        void parsesMember() {
            assertThat(authService.parseRole("member")).isEqualTo(Role.MEMBER);
        }

        @Test
        void returnsMemberForNullOrBlank() {
            assertThat(authService.parseRole(null)).isEqualTo(Role.MEMBER);
            assertThat(authService.parseRole("")).isEqualTo(Role.MEMBER);
            assertThat(authService.parseRole("   ")).isEqualTo(Role.MEMBER);
        }

        @Test
        void returnsMemberForUnknownRole() {
            assertThat(authService.parseRole("unknown")).isEqualTo(Role.MEMBER);
        }
    }

    @Nested
    @DisplayName("isValidPasswordStatic")
    class IsValidPasswordTests {
        @Test
        void acceptsValidPassword() {
            assertThat(AuthService.isValidPasswordStatic("Password@1")).isTrue();
            assertThat(AuthService.isValidPasswordStatic("Valid123!")).isTrue();
        }

        @Test
        void rejectsNull() {
            assertThat(AuthService.isValidPasswordStatic(null)).isFalse();
        }

        @Test
        void rejectsShortPassword() {
            assertThat(AuthService.isValidPasswordStatic("Short1!")).isFalse();
        }

        @Test
        void rejectsPasswordWithoutNumber() {
            assertThat(AuthService.isValidPasswordStatic("Password!!")).isFalse();
        }

        @Test
        void rejectsPasswordWithoutSpecialChar() {
            assertThat(AuthService.isValidPasswordStatic("Password123")).isFalse();
        }
    }

    @Nested
    @DisplayName("login")
    class LoginTests {
        @Test
        void returnsTokenWhenCredentialsValid() {
            LoginRequest req = new LoginRequest();
            req.setEmail("test@example.com");
            req.setPassword("Password@1");

            when(userRepository.findByEmail("test@example.com")).thenReturn(Optional.of(testUser));
            when(passwordEncoder.matches("Password@1", "$2a$10$hashed")).thenReturn(true);
            when(jwtService.generateToken("test@example.com", "member")).thenReturn("jwt-token");

            var response = authService.login(req);

            assertThat(response.getToken()).isEqualTo("jwt-token");
            assertThat(response.getEmail()).isEqualTo("test@example.com");
            assertThat(response.getRole()).isEqualTo("member");
            assertThat(response.getFullName()).isEqualTo("Test User");
        }

        @Test
        void throwsWhenUserNotFound() {
            LoginRequest req = new LoginRequest();
            req.setEmail("nonexistent@example.com");
            req.setPassword("Password@1");

            when(userRepository.findByEmail("nonexistent@example.com")).thenReturn(Optional.empty());

            assertThatThrownBy(() -> authService.login(req))
                    .isInstanceOf(UnauthorizedException.class)
                    .hasMessageContaining("Invalid email or password");
        }

        @Test
        void throwsWhenPasswordWrong() {
            LoginRequest req = new LoginRequest();
            req.setEmail("test@example.com");
            req.setPassword("WrongPassword1!");

            when(userRepository.findByEmail("test@example.com")).thenReturn(Optional.of(testUser));
            when(passwordEncoder.matches(anyString(), anyString())).thenReturn(false);

            assertThatThrownBy(() -> authService.login(req))
                    .isInstanceOf(UnauthorizedException.class)
                    .hasMessageContaining("Invalid email or password");
        }
    }

    @Nested
    @DisplayName("signUp")
    class SignUpTests {
        @Test
        void throwsWhenPasswordsDoNotMatch() {
            SignUpRequest req = new SignUpRequest();
            req.setFullName("New User");
            req.setEmail("new@example.com");
            req.setPassword("Password@1");
            req.setConfirmPassword("Password@2");
            req.setRole("member");

            assertThatThrownBy(() -> authService.signUp(req))
                    .isInstanceOf(AuthException.class)
                    .hasMessageContaining("Passwords do not match");
            verify(userRepository, never()).save(any());
        }

        @Test
        void throwsWhenPasswordInvalid() {
            SignUpRequest req = new SignUpRequest();
            req.setFullName("New User");
            req.setEmail("new@example.com");
            req.setPassword("weak");
            req.setConfirmPassword("weak");
            req.setRole("member");

            assertThatThrownBy(() -> authService.signUp(req))
                    .isInstanceOf(AuthException.class)
                    .hasMessageContaining("8 characters");
            verify(userRepository, never()).save(any());
        }

        @Test
        void throwsWhenEmailAlreadyExists() {
            SignUpRequest req = new SignUpRequest();
            req.setFullName("New User");
            req.setEmail("existing@example.com");
            req.setPassword("Password@1");
            req.setConfirmPassword("Password@1");
            req.setRole("member");

            when(userRepository.existsByEmail("existing@example.com")).thenReturn(true);

            assertThatThrownBy(() -> authService.signUp(req))
                    .isInstanceOf(AuthException.class)
                    .hasMessageContaining("already registered");
            verify(userRepository, never()).save(any());
        }

        @Test
        void createsUserSuccessfully() {
            SignUpRequest req = new SignUpRequest();
            req.setFullName("New User");
            req.setEmail("new@example.com");
            req.setPassword("Password@1");
            req.setConfirmPassword("Password@1");
            req.setRole("member");

            User savedUser = new User("New User", "new@example.com", null, "encoded", Role.MEMBER);
            savedUser.setId(2L);

            when(userRepository.existsByEmail("new@example.com")).thenReturn(false);
            when(passwordEncoder.encode("Password@1")).thenReturn("encoded");
            when(userRepository.save(any(User.class))).thenReturn(savedUser);
            when(jwtService.generateToken("new@example.com", "member")).thenReturn("jwt-token");

            var response = authService.signUp(req);

            assertThat(response.getToken()).isEqualTo("jwt-token");
            assertThat(response.getEmail()).isEqualTo("new@example.com");
            assertThat(response.getFullName()).isEqualTo("New User");
            verify(userRepository).save(any(User.class));
        }
    }
}
