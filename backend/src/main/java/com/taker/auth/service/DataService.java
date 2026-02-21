package com.taker.auth.service;

import com.taker.auth.dto.*;
import com.taker.auth.entity.*;
import com.taker.auth.exception.AuthException;
import com.taker.auth.repository.*;
import com.taker.auth.util.SecurityUtils;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.*;
import java.util.stream.Collectors;

@Service
public class DataService {

    private static final String DEFAULT_PASSWORD = "Welcome@1";

    private final UserRepository userRepository;
    private final PositionRepository positionRepository;
    private final ProjectRepository projectRepository;
    private final ProjectAssignmentRepository assignmentRepository;
    private final PasswordEncoder passwordEncoder;

    public DataService(UserRepository userRepository, PositionRepository positionRepository,
                       ProjectRepository projectRepository, ProjectAssignmentRepository assignmentRepository,
                       PasswordEncoder passwordEncoder) {
        this.userRepository = userRepository;
        this.positionRepository = positionRepository;
        this.projectRepository = projectRepository;
        this.assignmentRepository = assignmentRepository;
        this.passwordEncoder = passwordEncoder;
    }

    public List<UserSummaryDto> getAllUsers() {
        return userRepository.findAll().stream().map(this::toUserSummary).collect(Collectors.toList());
    }

    public List<String> getTeamLeaderAssignedProjects() {
        String email = SecurityUtils.currentUserEmail();
        if (email == null) return List.of();
        User leader = userRepository.findByEmail(email).orElse(null);
        if (leader == null || leader.getRole() != Role.TEAM_LEADER) return List.of();
        return assignmentRepository.findByUserIdAndProjectRole(leader.getId(), ProjectRole.TEAM_LEADER).stream()
                .map(a -> a.getProject().getName())
                .distinct()
                .collect(Collectors.toList());
    }

    public Map<String, List<TeamMemberDto>> getTeamLeaderTeamMembers() {
        List<String> projectNames = getTeamLeaderAssignedProjects();
        Map<String, List<TeamMemberDto>> result = new LinkedHashMap<>();
        for (String pname : projectNames) {
            Project project = projectRepository.findAll().stream().filter(p -> p.getName().equals(pname)).findFirst().orElse(null);
            if (project == null) continue;
            List<TeamMemberDto> members = assignmentRepository.findByProjectId(project.getId()).stream()
                    .filter(a -> a.getProjectRole() == ProjectRole.TEAM_MEMBER)
                    .map(a -> {
                        TeamMemberDto dto = new TeamMemberDto();
                        dto.setId(a.getUser().getId());
                        dto.setName(a.getUser().getFullName());
                        dto.setTitle(a.getUser().getTitle() != null ? a.getUser().getTitle() : "");
                        dto.setPosition(a.getUser().getPosition() != null ? a.getUser().getPosition().getName() : "");
                        return dto;
                    })
                    .collect(Collectors.toList());
            result.put(pname, members);
        }
        return result;
    }

    public Map<String, String> getTeamManager() {
        String email = SecurityUtils.currentUserEmail();
        if (email == null) return Map.of();
        User leader = userRepository.findByEmail(email).orElse(null);
        if (leader == null) return Map.of();
        List<ProjectAssignment> leaderAssignments = assignmentRepository.findByUserIdAndProjectRole(leader.getId(), ProjectRole.TEAM_LEADER);
        for (ProjectAssignment pa : leaderAssignments) {
            Optional<ProjectAssignment> manager = assignmentRepository.findByProjectId(pa.getProject().getId()).stream()
                    .filter(a -> a.getProjectRole() == ProjectRole.MANAGER)
                    .findFirst();
            if (manager.isPresent()) {
                User m = manager.get().getUser();
                return Map.of("name", m.getFullName(), "title", m.getTitle() != null ? m.getTitle() : "Manager");
            }
        }
        return Map.of("name", "Team Manager", "title", "");
    }

    public List<String> getMemberAssignedProjects() {
        String email = SecurityUtils.currentUserEmail();
        if (email == null) return List.of();
        User member = userRepository.findByEmail(email).orElse(null);
        if (member == null) return List.of();
        return assignmentRepository.findByUserId(member.getId()).stream()
                .map(a -> a.getProject().getName())
                .distinct()
                .collect(Collectors.toList());
    }

    public List<ContactDto> getMemberContacts() {
        String email = SecurityUtils.currentUserEmail();
        if (email == null) return List.of();
        User member = userRepository.findByEmail(email).orElse(null);
        if (member == null) return List.of();
        Set<Long> myProjectIds = assignmentRepository.findByUserId(member.getId()).stream()
                .map(a -> a.getProject().getId())
                .collect(Collectors.toSet());
        List<ContactDto> contacts = new ArrayList<>();
        Set<String> added = new HashSet<>();
        for (Long pid : myProjectIds) {
            for (ProjectAssignment a : assignmentRepository.findByProjectId(pid)) {
                User u = a.getUser();
                if (u.getId().equals(member.getId())) continue;
                String key = u.getEmail();
                if (added.contains(key)) continue;
                added.add(key);
                String type = switch (a.getProjectRole().name()) {
                    case "MANAGER" -> "Manager";
                    case "TEAM_LEADER" -> "Team Leader";
                    default -> "Team Member";
                };
                ContactDto c = new ContactDto();
                c.setName(u.getFullName());
                c.setTitle(u.getTitle() != null ? u.getTitle() : "");
                c.setType(type);
                contacts.add(c);
            }
        }
        return contacts;
    }

    public List<Long> getTeamLeaderAssignableUserIds(String projectName) {
        String email = SecurityUtils.currentUserEmail();
        if (email == null) return List.of();
        User leader = userRepository.findByEmail(email).orElse(null);
        if (leader == null || leader.getRole() != Role.TEAM_LEADER) return List.of();
        Project project = projectRepository.findAll().stream().filter(p -> p.getName().equals(projectName)).findFirst().orElse(null);
        if (project == null) return List.of();
        return assignmentRepository.findByProjectId(project.getId()).stream()
                .filter(a -> a.getProjectRole() == ProjectRole.TEAM_MEMBER)
                .map(a -> a.getUser().getId())
                .distinct()
                .collect(Collectors.toList());
    }

    @Transactional
    public UserSummaryDto createUser(CreateUserRequest req) {
        String email = req.getEmail().trim().toLowerCase();
        if (userRepository.existsByEmail(email)) {
            throw new AuthException("Email already registered");
        }
        Role role = parseRole(req.getRole());
        String pw = (req.getPassword() != null && !req.getPassword().isBlank())
                ? req.getPassword()
                : DEFAULT_PASSWORD;
        if (!AuthService.isValidPasswordStatic(pw)) {
            throw new AuthException("Password must be at least 8 characters with one number and one special character");
        }
        User user = new User(
                req.getFullName().trim(),
                email,
                null,
                passwordEncoder.encode(pw),
                role
        );
        if (req.getTitle() != null && !req.getTitle().isBlank()) {
            user.setTitle(req.getTitle().trim());
        }
        if (req.getTemporary() != null) {
            user.setTemporary(req.getTemporary());
        }
        if (req.getPosition() != null && !req.getPosition().isBlank()) {
            positionRepository.findByName(req.getPosition().trim()).ifPresent(user::setPosition);
        }
        user = userRepository.save(user);
        return toUserSummary(user);
    }

    @Transactional
    public UserSummaryDto assignRole(Long userId, AssignRoleRequest req) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new AuthException("User not found"));
        Role role = parseRole(req.getRole());
        user.setRole(role);
        if (req.getPosition() != null && !req.getPosition().isBlank()) {
            positionRepository.findByName(req.getPosition().trim()).ifPresent(user::setPosition);
        } else if (role == Role.MANAGER || role == Role.ADMIN) {
            user.setPosition(null);
        }
        user = userRepository.save(user);
        return toUserSummary(user);
    }

    private Role parseRole(String r) {
        if (r == null || r.isBlank()) return Role.MEMBER;
        String s = r.trim().toLowerCase().replace(" ", "_").replace("teamleader", "team_leader");
        return switch (s) {
            case "admin" -> Role.ADMIN;
            case "manager" -> Role.MANAGER;
            case "team_leader" -> Role.TEAM_LEADER;
            default -> Role.MEMBER;
        };
    }

    private UserSummaryDto toUserSummary(User u) {
        UserSummaryDto dto = new UserSummaryDto();
        dto.setId(u.getId());
        dto.setName(u.getFullName());
        dto.setTitle(u.getTitle() != null ? u.getTitle() : "");
        dto.setRole(u.getRole().name().toLowerCase());
        dto.setPosition(u.getPosition() != null ? u.getPosition().getName() : null);
        dto.setTemporary(u.isTemporary());
        return dto;
    }
}
