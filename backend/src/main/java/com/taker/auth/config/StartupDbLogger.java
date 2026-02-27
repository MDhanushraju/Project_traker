package com.taker.auth.config;

import org.springframework.boot.context.event.ApplicationReadyEvent;
import org.springframework.context.event.EventListener;
import org.springframework.core.env.Environment;
import org.springframework.stereotype.Component;

/**
 * Logs the datasource URL at startup so you can verify the backend is using the same DB as pgAdmin.
 * If data isn't updating in pgAdmin, check that this URL matches the database you have open (host, port, database name).
 */
@Component
public class StartupDbLogger {

    private final Environment env;

    public StartupDbLogger(Environment env) {
        this.env = env;
    }

    @EventListener(ApplicationReadyEvent.class)
    public void logDataSourceUrl() {
        String url = env.getProperty("spring.datasource.url", "");
        String masked = url.replaceAll(":[^:@]+@", ":****@"); // mask password in URL if present
        System.out.println("[DB] Connected to: " + masked + " (ensure this is the same DB you open in pgAdmin)");
    }
}
