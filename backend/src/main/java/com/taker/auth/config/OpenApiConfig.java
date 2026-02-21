package com.taker.auth.config;

import io.swagger.v3.oas.models.Components;
import io.swagger.v3.oas.models.OpenAPI;
import io.swagger.v3.oas.models.info.Contact;
import io.swagger.v3.oas.models.info.Info;
import io.swagger.v3.oas.models.info.License;
import io.swagger.v3.oas.models.security.SecurityRequirement;
import io.swagger.v3.oas.models.security.SecurityScheme;
import io.swagger.v3.oas.models.servers.Server;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

import java.util.List;

@Configuration
public class OpenApiConfig {

    @Value("${server.port:8080}")
    private int serverPort;

    @Bean
    public OpenAPI customOpenAPI() {
        final String bearerAuth = "bearerAuth";
        return new OpenAPI()
                .addSecurityItem(new SecurityRequirement().addList(bearerAuth))
                .components(new Components()
                        .addSecuritySchemes(bearerAuth,
                                new SecurityScheme()
                                        .name("Bearer Authentication")
                                        .type(SecurityScheme.Type.HTTP)
                                        .scheme("bearer")
                                        .bearerFormat("JWT")
                                        .description("Paste JWT token from login response")))
                .info(new Info()
                        .title("Taker Project Tracker API")
                        .version("1.0.0")
                        .description("## API Overview\n" +
                                "This is the Taker project tracker backend. Use this guide to understand and test all endpoints.\n\n" +
                                "### Authentication\n" +
                                "- Login (POST /api/auth/login) or Sign Up (POST /api/auth/signup) to get a JWT token\n" +
                                "- Copy the token from the response\n" +
                                "- Click Authorize above, enter: Bearer your_token\n" +
                                "- Most endpoints (except auth) require this token\n\n" +
                                "### Test Credentials (from DataLoader)\n" +
                                "Admin: admin@taker.com / Admin@123 | Manager: manager@taker.com / Password@1\n" +
                                "Team Leader: leader@taker.com / Password@1 | Team Member: member@taker.com / Password@1\n\n" +
                                "### Quick Test Order\n" +
                                "1. Login to get token, then Authorize\n" +
                                "2. Try other endpoints using the example request bodies")
                        .contact(new Contact().name("Taker").email("support@taker.com"))
                        .license(new License().name("MIT").url("https://opensource.org/licenses/MIT")))
                .servers(List.of(
                        new Server().url("http://localhost:" + serverPort).description("Local server"),
                        new Server().url("http://localhost:8080").description("Default port")
                ));
    }
}
