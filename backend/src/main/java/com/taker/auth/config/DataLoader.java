package com.taker.auth.config;

import com.taker.auth.entity.Role;
import com.taker.auth.entity.User;
import com.taker.auth.repository.UserRepository;
import org.springframework.boot.CommandLineRunner;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.security.crypto.password.PasswordEncoder;

@Configuration
public class DataLoader {

    @Bean
    CommandLineRunner init(UserRepository userRepository, PasswordEncoder encoder) {
        return args -> {
            if (userRepository.findByEmail("admin@taker.com").isEmpty()) {
                userRepository.save(new User(
                        "Admin User",
                        "admin@taker.com",
                        "000-0000-001",
                        encoder.encode("Admin@123"),
                        Role.ADMIN
                ));
                System.out.println("Test user: admin@taker.com / 000-0000-001 / Admin@123");
            }
            if (userRepository.findByEmail("member@taker.com").isEmpty()) {
                userRepository.save(new User(
                        "Member User",
                        "member@taker.com",
                        "000-0000-003",
                        encoder.encode("Member@123"),
                        Role.MEMBER
                ));
                System.out.println("Test user: member@taker.com / 000-0000-003 / Member@123");
            }
        };
    }
}
