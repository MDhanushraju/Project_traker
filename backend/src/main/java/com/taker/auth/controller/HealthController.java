package com.taker.auth.controller;

import com.taker.auth.dto.ApiResponse;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.Map;

/**
 * Check if the database is connected. No auth required.
 * GET /api/health/db → { "database": "connected" } or 503 with error.
 */
@RestController
@RequestMapping("/api/health")
public class HealthController {

    private final JdbcTemplate jdbcTemplate;

    public HealthController(JdbcTemplate jdbcTemplate) {
        this.jdbcTemplate = jdbcTemplate;
    }

    @GetMapping("/db")
    public ResponseEntity<ApiResponse<?>> db() {
        try {
            jdbcTemplate.execute("SELECT 1");
            return ResponseEntity.ok(ApiResponse.success("OK", Map.of("database", "connected")));
        } catch (Throwable t) {
            String msg = t.getMessage() != null && !t.getMessage().isBlank()
                    ? t.getMessage()
                    : t.getClass().getSimpleName();
            return ResponseEntity.status(HttpStatus.SERVICE_UNAVAILABLE)
                    .body(ApiResponse.failure(503, "Database not connected: " + msg));
        }
    }
}
