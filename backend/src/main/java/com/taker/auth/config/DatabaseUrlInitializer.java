package com.taker.auth.config;

import java.util.Collections;

import org.springframework.context.ApplicationContextInitializer;
import org.springframework.context.ConfigurableApplicationContext;
import org.springframework.core.env.ConfigurableEnvironment;
import org.springframework.core.env.MapPropertySource;

/**
 * Converts Render DATABASE_URL (postgresql:// or postgres://) to JDBC format (jdbc:postgresql://).
 * Credentials stay in the URL; do not set username/password in application.yml when using DATABASE_URL.
 */
public class DatabaseUrlInitializer implements ApplicationContextInitializer<ConfigurableApplicationContext> {

    @Override
    public void initialize(ConfigurableApplicationContext applicationContext) {
        var environment = applicationContext.getEnvironment();
        if (!(environment instanceof ConfigurableEnvironment configurable)) {
            return;
        }
        String databaseUrl = environment.getProperty("DATABASE_URL");
        if (databaseUrl == null || databaseUrl.isBlank()) {
            return;
        }
        if (databaseUrl.startsWith("postgresql://") || databaseUrl.startsWith("postgres://")) {
            configurable.getPropertySources().addFirst(
                new MapPropertySource("databaseUrlInitializer",
                    Collections.singletonMap("DATABASE_URL", "jdbc:" + databaseUrl))
            );
        }
    }
}
