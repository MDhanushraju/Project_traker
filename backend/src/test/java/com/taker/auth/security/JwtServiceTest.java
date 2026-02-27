package com.taker.auth.security;

import io.jsonwebtoken.Claims;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Nested;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.test.util.ReflectionTestUtils;

import static org.assertj.core.api.Assertions.assertThat;

@ExtendWith(MockitoExtension.class)
class JwtServiceTest {

    private static final String TEST_SECRET = "test-secret-key-at-least-32-bytes-long-for-hs256";
    private static final long EXPIRATION_MS = 3600_000L;
    private static final long RESET_EXPIRATION_MS = 900_000L;

    private JwtService jwtService;

    @BeforeEach
    void setUp() {
        jwtService = new JwtService();
        ReflectionTestUtils.setField(jwtService, "secret", TEST_SECRET);
        ReflectionTestUtils.setField(jwtService, "expirationMs", EXPIRATION_MS);
        ReflectionTestUtils.setField(jwtService, "resetExpirationMs", RESET_EXPIRATION_MS);
    }

    @Nested
    @DisplayName("generateToken and extractClaims")
    class TokenGenerationTests {
        @Test
        void generatesTokenWithEmailAndRole() {
            String token = jwtService.generateToken("user@example.com", "admin");

            assertThat(token).isNotBlank();
            Claims claims = jwtService.extractClaims(token);
            assertThat(claims.getSubject()).isEqualTo("user@example.com");
            assertThat(claims.get("role")).isEqualTo("admin");
            assertThat(claims.getExpiration()).isAfter(claims.getIssuedAt());
        }

        @Test
        void extractEmailReturnsSubject() {
            String token = jwtService.generateToken("test@test.com", "member");
            assertThat(jwtService.extractEmail(token)).isEqualTo("test@test.com");
        }

        @Test
        void extractRoleReturnsRoleClaim() {
            String token = jwtService.generateToken("a@b.com", "manager");
            assertThat(jwtService.extractRole(token)).isEqualTo("manager");
        }

        @Test
        void extractRoleReturnsNullWhenNoRoleClaim() {
            String token = jwtService.generateResetToken("reset@example.com");
            assertThat(jwtService.extractRole(token)).isNull();
        }
    }

    @Nested
    @DisplayName("generateResetToken and isResetToken")
    class ResetTokenTests {
        @Test
        void generateResetTokenHasTypeReset() {
            String token = jwtService.generateResetToken("user@example.com");
            assertThat(token).isNotBlank();
            assertThat(jwtService.extractEmail(token)).isEqualTo("user@example.com");
            assertThat(jwtService.isResetToken(token)).isTrue();
        }

        @Test
        void isResetTokenReturnsFalseForNormalToken() {
            String token = jwtService.generateToken("user@example.com", "member");
            assertThat(jwtService.isResetToken(token)).isFalse();
        }

        @Test
        void isResetTokenReturnsFalseForInvalidToken() {
            assertThat(jwtService.isResetToken("invalid.jwt.token")).isFalse();
        }
    }

    @Nested
    @DisplayName("isValid")
    class IsValidTests {
        @Test
        void returnsTrueWhenTokenValidAndEmailMatches() {
            String token = jwtService.generateToken("valid@example.com", "member");
            assertThat(jwtService.isValid(token, "valid@example.com")).isTrue();
        }

        @Test
        void returnsFalseWhenEmailDoesNotMatch() {
            String token = jwtService.generateToken("user@example.com", "member");
            assertThat(jwtService.isValid(token, "other@example.com")).isFalse();
        }

        @Test
        void returnsFalseForInvalidToken() {
            assertThat(jwtService.isValid("not.a.valid.token", "user@example.com")).isFalse();
        }

        @Test
        void returnsFalseForNullToken() {
            assertThat(jwtService.isValid(null, "user@example.com")).isFalse();
        }
    }
}
