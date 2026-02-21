package com.taker.auth.config;

import com.taker.auth.entity.*;
import com.taker.auth.repository.*;
import org.springframework.boot.CommandLineRunner;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.security.crypto.password.PasswordEncoder;

import java.time.LocalDate;
import java.util.List;

@Configuration
public class DataLoader {

    @Bean
    CommandLineRunner init(UserRepository userRepository, ProjectRepository projectRepository,
                          TaskRepository taskRepository, ProjectAssignmentRepository assignmentRepository,
                          PositionRepository positionRepository, PasswordEncoder encoder) {
        return args -> {
            if (positionRepository.count() == 0) {
                for (String name : List.of("Developer", "Tester", "Designer", "Analyst")) {
                    positionRepository.save(new Position(name));
                }
            }
            String pw = encoder.encode("Password@1");
            if (userRepository.findByEmail("admin@taker.com").isEmpty()) {
                User admin = new User("Admin User", "admin@taker.com", "000-0000-001", pw, Role.ADMIN);
                admin.setTitle("Administrator");
                userRepository.save(admin);
                System.out.println("Test user: admin@taker.com / Admin@123");
            }
            if (userRepository.findByEmail("manager@taker.com").isEmpty()) {
                User m = new User("Sarah Jenkins", "manager@taker.com", "000-0000-002", pw, Role.MANAGER);
                m.setTitle("Director of Product Operations");
                userRepository.save(m);
            }
            if (userRepository.findByEmail("leader@taker.com").isEmpty()) {
                Position dev = positionRepository.findByName("Developer").orElseGet(() -> positionRepository.save(new Position("Developer")));
                User tl = new User("Marcus Thorne", "leader@taker.com", "000-0000-004", pw, Role.TEAM_LEADER);
                tl.setTitle("Tech Lead");
                tl.setPosition(dev);
                userRepository.save(tl);
            }
            if (userRepository.findByEmail("member@taker.com").isEmpty()) {
                Position dev = positionRepository.findByName("Developer").orElseGet(() -> positionRepository.save(new Position("Developer")));
                User mem = new User("Member User", "member@taker.com", "000-0000-003", pw, Role.MEMBER);
                mem.setTitle("Developer");
                mem.setPosition(dev);
                userRepository.save(mem);
            }

            if (projectRepository.count() == 0) {
                Project p1 = projectRepository.save(new Project("Website Redesign", "Active", 65));
                Project p2 = projectRepository.save(new Project("Mobile App", "Active", 30));
                Project p3 = projectRepository.save(new Project("API Integration", "On hold", 10));

                User manager = userRepository.findByEmail("manager@taker.com").orElseThrow();
                User leader = userRepository.findByEmail("leader@taker.com").orElseThrow();
                User member = userRepository.findByEmail("member@taker.com").orElseThrow();

                assignmentRepository.save(new ProjectAssignment(p1, manager, ProjectRole.MANAGER));
                assignmentRepository.save(new ProjectAssignment(p1, leader, ProjectRole.TEAM_LEADER));
                assignmentRepository.save(new ProjectAssignment(p1, member, ProjectRole.TEAM_MEMBER));
                assignmentRepository.save(new ProjectAssignment(p3, manager, ProjectRole.MANAGER));
                assignmentRepository.save(new ProjectAssignment(p3, leader, ProjectRole.TEAM_LEADER));
                assignmentRepository.save(new ProjectAssignment(p3, member, ProjectRole.TEAM_MEMBER));

                Task t1 = new Task();
                t1.setTitle("Review wireframes");
                t1.setStatus("in_progress");
                t1.setDueDate(LocalDate.of(2025, 2, 20));
                t1.setAssignedTo(member);
                taskRepository.save(t1);
                Task t2 = new Task();
                t2.setTitle("Setup dev environment");
                t2.setStatus("done");
                t2.setDueDate(LocalDate.of(2025, 2, 15));
                t2.setAssignedTo(member);
                taskRepository.save(t2);
            }
        };
    }
}
