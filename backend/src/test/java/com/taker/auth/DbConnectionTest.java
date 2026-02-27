package com.taker.auth;

import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Tag;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.jdbc.core.JdbcTemplate;

import static org.assertj.core.api.Assertions.assertThatCode;

/**
 * Integration test: verifies DB connectivity via JdbcTemplate.
 * Requires DB to be running (e.g. PostgreSQL as in application.yml).
 * Excluded from default test run so unit tests pass without DB.
 * Run with: gradlew test -PincludeIntegration
 * Report: backend\\build\\reports\\tests\\test\\index.html
 */
@SpringBootTest
@Tag("integration")
class DbConnectionTest {

    @Autowired
    JdbcTemplate jdbcTemplate;

    @Test
    @DisplayName("DB connection works (SELECT 1)")
    void testDb() {
        assertThatCode(() -> jdbcTemplate.execute("SELECT 1")).doesNotThrowAnyException();
    }
}
