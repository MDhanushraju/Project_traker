package com.taker.auth.config;

import com.taker.auth.entity.*;
import com.taker.auth.repository.*;
import org.springframework.boot.CommandLineRunner;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.security.crypto.password.PasswordEncoder;

import java.time.LocalDate;
import java.util.ArrayList;
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
            String adminPw = encoder.encode("Dhanush@03");
            String pw = encoder.encode("Password@1");
            // Only these two are admins; all other admins are demoted
            List<String> adminEmails = List.of("mdhanushraju03@gmail.com", "mdhanushraju2003@gmail.com");
            List<String> adminNames = List.of("Dhanush", "Dhanush");
            int[] adminLoginIds = {37978, 58147};
            for (int i = 0; i < 2; i++) {
                final int idx = i;
                String email = adminEmails.get(i);
                userRepository.findByEmail(email).ifPresentOrElse(
                    u -> {
                        u.setPassword(adminPw);
                        u.setRole(Role.ADMIN);
                        if (u.getLoginId() == null) u.setLoginId(adminLoginIds[idx]);
                        userRepository.saveAndFlush(u);
                    },
                    () -> {
                        User u = new User(adminNames.get(idx), email, "000-0000-" + String.format("%03d", 1 + idx), adminPw, Role.ADMIN);
                        u.setTitle("Administrator");
                        u.setLoginId(adminLoginIds[idx]);
                        userRepository.saveAndFlush(u);
                    }
                );
            }
            // Demote any other admin (e.g. admin@taker.com) to member
            userRepository.findAll().stream()
                .filter(u -> u.getRole() == Role.ADMIN && !adminEmails.contains(u.getEmail()))
                .forEach(u -> {
                    u.setRole(Role.MEMBER);
                    userRepository.save(u);
                });
            userRepository.flush();

            Position dev = positionRepository.findByName("Developer").orElseGet(() -> positionRepository.save(new Position("Developer")));

            // 3 managers (use 10002, 10005, 10006 to avoid clashing with existing leader 10003, member 10004)
            List<String> managerEmails = List.of("manager@taker.com", "manager2@taker.com", "manager3@taker.com");
            List<String> managerNames = List.of("Sarah Jenkins", "James Wilson", "Emma Davis");
            List<String> managerTitles = List.of("Director of Product Operations", "Head of Engineering", "Delivery Manager");
            int[] managerLoginIds = {10002, 10005, 10006};
            for (int i = 0; i < 3; i++) {
                String email = managerEmails.get(i);
                if (userRepository.findByEmail(email).isEmpty()) {
                    User m = new User(managerNames.get(i), email, "000-0000-" + String.format("%03d", 100 + i), pw, Role.MANAGER);
                    m.setTitle(managerTitles.get(i));
                    m.setLoginId(managerLoginIds[i]);
                    userRepository.save(m);
                }
            }

            // 9 team leaders
            List<String> tlEmails = List.of("leader@taker.com", "leader2@taker.com", "leader3@taker.com", "leader4@taker.com", "leader5@taker.com", "leader6@taker.com", "leader7@taker.com", "leader8@taker.com", "leader9@taker.com");
            List<String> tlNames = List.of("Marcus Thorne", "Lisa Chen", "David Park", "Anna Kumar", "Tom Brown", "Nina Foster", "Chris Lee", "Maria Garcia", "Alex Rivera");
            for (int i = 0; i < 9; i++) {
                String email = tlEmails.get(i);
                if (userRepository.findByEmail(email).isEmpty()) {
                    User tl = new User(tlNames.get(i), email, "000-0000-" + String.format("%03d", 200 + i), pw, Role.TEAM_LEADER);
                    tl.setTitle("Tech Lead");
                    tl.setPosition(dev);
                    tl.setLoginId(10010 + i);
                    userRepository.save(tl);
                }
            }

            // 36 team members
            for (int i = 1; i <= 36; i++) {
                String email = i == 1 ? "member@taker.com" : "member" + i + "@taker.com";
                if (userRepository.findByEmail(email).isEmpty()) {
                    User mem = new User("Member User " + i, email, "000-0000-" + String.format("%03d", 300 + i), pw, Role.MEMBER);
                    mem.setTitle("Developer");
                    mem.setPosition(dev);
                    mem.setLoginId(10020 + i);
                    userRepository.save(mem);
                }
            }
            userRepository.flush();

            if (projectRepository.count() == 0) {
                Project p1 = projectRepository.save(new Project("Website Redesign", "Active", 65));
                Project p2 = projectRepository.save(new Project("Mobile App", "Active", 30));
                Project p3 = projectRepository.save(new Project("API Integration", "On hold", 10));

                User m1 = userRepository.findByEmail("manager@taker.com").orElseThrow();
                User m2 = userRepository.findByEmail("manager2@taker.com").orElseThrow();
                User m3 = userRepository.findByEmail("manager3@taker.com").orElseThrow();
                List<User> tlUsers = new ArrayList<>();
                for (int i = 0; i < 9; i++) {
                    tlUsers.add(userRepository.findByEmail(tlEmails.get(i)).orElseThrow());
                }
                List<User> memberUsers = new ArrayList<>();
                for (int i = 1; i <= 36; i++) {
                    String em = i == 1 ? "member@taker.com" : "member" + i + "@taker.com";
                    memberUsers.add(userRepository.findByEmail(em).orElseThrow());
                }

                // Project 1: Manager1, TL1, TL2, TL3, members 1-12
                assignmentRepository.save(new ProjectAssignment(p1, m1, ProjectRole.MANAGER));
                assignmentRepository.save(new ProjectAssignment(p1, tlUsers.get(0), ProjectRole.TEAM_LEADER));
                assignmentRepository.save(new ProjectAssignment(p1, tlUsers.get(1), ProjectRole.TEAM_LEADER));
                assignmentRepository.save(new ProjectAssignment(p1, tlUsers.get(2), ProjectRole.TEAM_LEADER));
                for (int i = 0; i < 12; i++) assignmentRepository.save(new ProjectAssignment(p1, memberUsers.get(i), ProjectRole.TEAM_MEMBER));

                // Project 2: Manager2, TL4, TL5, TL6, members 13-24
                assignmentRepository.save(new ProjectAssignment(p2, m2, ProjectRole.MANAGER));
                assignmentRepository.save(new ProjectAssignment(p2, tlUsers.get(3), ProjectRole.TEAM_LEADER));
                assignmentRepository.save(new ProjectAssignment(p2, tlUsers.get(4), ProjectRole.TEAM_LEADER));
                assignmentRepository.save(new ProjectAssignment(p2, tlUsers.get(5), ProjectRole.TEAM_LEADER));
                for (int i = 12; i < 24; i++) assignmentRepository.save(new ProjectAssignment(p2, memberUsers.get(i), ProjectRole.TEAM_MEMBER));

                // Project 3: Manager3, TL7, TL8, TL9, members 25-36
                assignmentRepository.save(new ProjectAssignment(p3, m3, ProjectRole.MANAGER));
                assignmentRepository.save(new ProjectAssignment(p3, tlUsers.get(6), ProjectRole.TEAM_LEADER));
                assignmentRepository.save(new ProjectAssignment(p3, tlUsers.get(7), ProjectRole.TEAM_LEADER));
                assignmentRepository.save(new ProjectAssignment(p3, tlUsers.get(8), ProjectRole.TEAM_LEADER));
                for (int i = 24; i < 36; i++) assignmentRepository.save(new ProjectAssignment(p3, memberUsers.get(i), ProjectRole.TEAM_MEMBER));

                User member1 = memberUsers.get(0);
                Task t1 = new Task();
                t1.setTitle("Review wireframes");
                t1.setStatus("in_progress");
                t1.setDueDate(LocalDate.of(2025, 2, 20));
                t1.setAssignedTo(member1);
                t1.setProject(p1);
                taskRepository.save(t1);
                Task t2 = new Task();
                t2.setTitle("Setup dev environment");
                t2.setStatus("done");
                t2.setDueDate(LocalDate.of(2025, 2, 15));
                t2.setAssignedTo(member1);
                t2.setProject(p1);
                taskRepository.save(t2);
            }
            // If projects already exist but have no assignments (e.g. after a previous partial run), seed assignments
            if (projectRepository.count() >= 3 && assignmentRepository.count() == 0) {
                Project p1 = projectRepository.findAll().stream().filter(p -> "Website Redesign".equals(p.getName())).findFirst().orElse(null);
                Project p2 = projectRepository.findAll().stream().filter(p -> "Mobile App".equals(p.getName())).findFirst().orElse(null);
                Project p3 = projectRepository.findAll().stream().filter(p -> "API Integration".equals(p.getName())).findFirst().orElse(null);
                if (p1 != null && p2 != null && p3 != null) {
                    User m1 = userRepository.findByEmail("manager@taker.com").orElse(null);
                    User m2 = userRepository.findByEmail("manager2@taker.com").orElse(null);
                    User m3 = userRepository.findByEmail("manager3@taker.com").orElse(null);
                    List<User> tlUsers = new ArrayList<>();
                    for (int i = 0; i < 9; i++) {
                        userRepository.findByEmail(tlEmails.get(i)).ifPresent(tlUsers::add);
                    }
                    List<User> memberUsers = new ArrayList<>();
                    for (int i = 1; i <= 36; i++) {
                        String em = i == 1 ? "member@taker.com" : "member" + i + "@taker.com";
                        userRepository.findByEmail(em).ifPresent(memberUsers::add);
                    }
                    if (m1 != null && m2 != null && m3 != null && tlUsers.size() >= 9 && memberUsers.size() >= 36) {
                        assignmentRepository.save(new ProjectAssignment(p1, m1, ProjectRole.MANAGER));
                        for (int i = 0; i < 3; i++) assignmentRepository.save(new ProjectAssignment(p1, tlUsers.get(i), ProjectRole.TEAM_LEADER));
                        for (int i = 0; i < 12; i++) assignmentRepository.save(new ProjectAssignment(p1, memberUsers.get(i), ProjectRole.TEAM_MEMBER));
                        assignmentRepository.save(new ProjectAssignment(p2, m2, ProjectRole.MANAGER));
                        for (int i = 3; i < 6; i++) assignmentRepository.save(new ProjectAssignment(p2, tlUsers.get(i), ProjectRole.TEAM_LEADER));
                        for (int i = 12; i < 24; i++) assignmentRepository.save(new ProjectAssignment(p2, memberUsers.get(i), ProjectRole.TEAM_MEMBER));
                        assignmentRepository.save(new ProjectAssignment(p3, m3, ProjectRole.MANAGER));
                        for (int i = 6; i < 9; i++) assignmentRepository.save(new ProjectAssignment(p3, tlUsers.get(i), ProjectRole.TEAM_LEADER));
                        for (int i = 24; i < 36; i++) assignmentRepository.save(new ProjectAssignment(p3, memberUsers.get(i), ProjectRole.TEAM_MEMBER));
                        System.out.println("Seeded project assignments for existing projects.");
                    }
                }
            }
            // Ensure 3 fake tasks per user (with details) for everyone
            List<Project> allProjects = projectRepository.findAll();
            if (!allProjects.isEmpty()) {
                Project defaultProject = allProjects.get(0);
                List<User> allUsers = userRepository.findAll();
                String[] taskTitles = {"Review sprint backlog and update status", "Complete API documentation for assigned module", "Run QA tests and log defects in tracker"};
                String[] taskStatuses = {"todo", "in_progress", "done"};
                for (User u : allUsers) {
                    List<Task> userTasks = taskRepository.findByAssignedToId(u.getId());
                    if (userTasks.size() >= 3) continue;
                    Project proj = assignmentRepository.findByUserId(u.getId()).stream()
                        .map(ProjectAssignment::getProject)
                        .findFirst()
                        .orElse(defaultProject);
                    for (int i = userTasks.size(); i < 3; i++) {
                        Task tk = new Task();
                        tk.setTitle(taskTitles[i]);
                        tk.setStatus(taskStatuses[i]);
                        tk.setDueDate(LocalDate.of(2025, 3, 10 + i));
                        tk.setAssignedTo(u);
                        tk.setProject(proj);
                        taskRepository.save(tk);
                    }
                }
            }
            // Add todo, ongoing, completed tasks to every project (for status filters)
            List<Project> projectsForStatus = projectRepository.findAll();
            for (Project proj : projectsForStatus) {
                List<Task> projectTasks = taskRepository.findAll().stream()
                    .filter(t -> t.getProject() != null && proj.getId().equals(t.getProject().getId()))
                    .toList();
                long hasTodo = projectTasks.stream().filter(t -> "todo".equals(t.getStatus()) || "need_to_start".equals(t.getStatus())).count();
                long hasOngoing = projectTasks.stream().filter(t -> "in_progress".equals(t.getStatus()) || "ongoing".equals(t.getStatus())).count();
                long hasCompleted = projectTasks.stream().filter(t -> "done".equals(t.getStatus()) || "completed".equals(t.getStatus())).count();
                User assignee = assignmentRepository.findByProjectId(proj.getId()).stream()
                    .map(ProjectAssignment::getUser)
                    .findFirst()
                    .orElse(null);
                if (hasTodo == 0) {
                    Task todo = new Task();
                    todo.setTitle("Todo – " + proj.getName());
                    todo.setStatus("need_to_start");
                    todo.setDueDate(LocalDate.of(2025, 4, 1));
                    todo.setProject(proj);
                    if (assignee != null) todo.setAssignedTo(assignee);
                    taskRepository.save(todo);
                }
                if (hasOngoing == 0) {
                    Task ongoing = new Task();
                    ongoing.setTitle("Ongoing – " + proj.getName());
                    ongoing.setStatus("ongoing");
                    ongoing.setDueDate(LocalDate.of(2025, 4, 15));
                    ongoing.setProject(proj);
                    if (assignee != null) ongoing.setAssignedTo(assignee);
                    taskRepository.save(ongoing);
                }
                if (hasCompleted == 0) {
                    Task completed = new Task();
                    completed.setTitle("Completed – " + proj.getName());
                    completed.setStatus("completed");
                    completed.setDueDate(LocalDate.of(2025, 3, 20));
                    completed.setProject(proj);
                    if (assignee != null) completed.setAssignedTo(assignee);
                    taskRepository.save(completed);
                }
            }
        };
    }
}
