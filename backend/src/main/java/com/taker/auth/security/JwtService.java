package com.taker.auth.security;

import io.jsonwebtoken.Claims;
import io.jsonwebtoken.Jwts;
import io.jsonwebtoken.security.Keys;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;

import javax.crypto.SecretKey;
import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import java.util.Date;

@Service
public class JwtService {

    @Value("${jwt.secret}")
    private String secret;

    @Value("${jwt.expiration-ms:86400000}")
    private long expirationMs;

    @Value("${jwt.reset-expiration-ms:900000}")
    private long resetExpirationMs;

    /**
     * Builds an HMAC-SHA256 key with at least 256 bits as required by RFC 7518.
     * Derives 32 bytes from the configured secret via SHA-256 so any secret length is safe.
     */
    private SecretKey getSigningKey() {
        byte[] secretBytes = secret.getBytes(StandardCharsets.UTF_8);
        byte[] keyBytes;
        try {
            keyBytes = MessageDigest.getInstance("SHA-256").digest(secretBytes);
        } catch (NoSuchAlgorithmException e) {
            throw new IllegalStateException("SHA-256 not available", e);
        }
        return Keys.hmacShaKeyFor(keyBytes);
    }

    public String generateToken(String email, String role) {
        return Jwts.builder()
                .subject(email)
                .claim("role", role)
                .issuedAt(new Date())
                .expiration(new Date(System.currentTimeMillis() + expirationMs))
                .signWith(getSigningKey())
                .compact();
    }

    public Claims extractClaims(String token) {
        return Jwts.parser()
                .verifyWith(getSigningKey())
                .build()
                .parseSignedClaims(token)
                .getPayload();
    }

    public String extractEmail(String token) {
        return extractClaims(token).getSubject();
    }

    public String extractRole(String token) {
        Object role = extractClaims(token).get("role");
        return role != null ? role.toString() : null;
    }

    public String generateResetToken(String email) {
        return Jwts.builder()
                .subject(email)
                .claim("type", "reset")
                .issuedAt(new Date())
                .expiration(new Date(System.currentTimeMillis() + resetExpirationMs))
                .signWith(getSigningKey())
                .compact();
    }

    public boolean isResetToken(String token) {
        try {
            return "reset".equals(extractClaims(token).get("type"));
        } catch (Exception e) {
            return false;
        }
    }

    public boolean isValid(String token, String email) {
        try {
            String subject = extractClaims(token).getSubject();
            return subject.equals(email) && !isExpired(token);
        } catch (Exception e) {
            return false;
        }
    }

    private boolean isExpired(String token) {
        return extractClaims(token).getExpiration().before(new Date());
    }
}
