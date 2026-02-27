package com.taker.auth.service;

import com.taker.auth.dto.*;
import com.taker.auth.entity.*;
import com.taker.auth.exception.AuthException;
import com.taker.auth.exception.ForbiddenException;
import com.taker.auth.exception.NotFoundException;
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
    private final TaskRepository taskRepository;
    private final PasswordEncoder passwordEncoder;

    public DataService(UserRepository userRepository, PositionRepository positionRepository,
                       ProjectRepository projectRepository, ProjectAssignmentRepository assignmentRepository,
                       TaskRepository taskRepository, PasswordEncoder passwordEncoder) {
        this.userRepository = userRepository;
        this.positionRepository = positionRepository;
        this.projectRepository = projectRepository;
        this.assignmentRepository = assignmentRepository;
        this.taskRepository = taskRepository;
        this.passwordEncoder = passwordEncoder;
    }

    public long getUserCount() {
        return userRepository.count();
    }

    public List<UserSummaryDto> getAllUsers() {
        try {
            return userRepository.findAll().stream()
                    .map(this::toUserSummarySafe)
                    .filter(java.util.Objects::nonNull)
                    .collect(Collectors.toList());
        } catch (Exception e) {
            org.slf4j.LoggerFactory.getLogger(DataService.class).error("getAllUsers failed", e);
            return java.util.Collections.emptyList();
        }
    }

    /**
     * Returns users visible to the given role/email. Admin: all; Manager: all except admins;
     * Team Leader: their manager + their team members; Member: their manager, team leader, and project team members.
     */
    public List<UserSummaryDto> getAllUsersFiltered(String forRole, String forEmail) {
        String email = (forEmail != null && !forEmail.isBlank()) ? forEmail.trim() : SecurityUtils.currentUserEmail();
        if (email == null || email.isBlank()) {
            return getAllUsers();
        }
        User current = userRepository.findByEmail(email).orElse(null);
        if (current == null) return getAllUsers();
        Role role = (forRole != null && !forRole.isBlank()) ? parseRole(forRole) : current.getRole();

        if (role == Role.ADMIN) {
            return userRepository.findAll().stream()
                    .map(this::toUserSummarySafe)
                    .filter(java.util.Objects::nonNull)
                    .collect(Collectors.toList());
        }
        if (role == Role.MANAGER) {
            return userRepository.findAll().stream()
                    .filter(u -> u.getRole() != Role.ADMIN)
                    .map(this::toUserSummarySafe)
                    .filter(java.util.Objects::nonNull)
                    .collect(Collectors.toList());
        }
        if (role == Role.TEAM_LEADER) {
            Set<Long> visible = new HashSet<>();
            visible.add(current.getId());
            List<ProjectAssignment> tlAssignments = assignmentRepository.findByUserIdAndProjectRole(current.getId(), ProjectRole.TEAM_LEADER);
            for (ProjectAssignment pa : tlAssignments) {
                Long projectId = pa.getProject().getId();
                assignmentRepository.findByProjectId(projectId).stream()
                        .map(a -> a.getUser().getId())
                        .forEach(visible::add);
            }
            return userRepository.findAll().stream()
                    .filter(u -> visible.contains(u.getId()))
                    .map(this::toUserSummarySafe)
                    .filter(java.util.Objects::nonNull)
                    .collect(Collectors.toList());
        }
        if (role == Role.MEMBER) {
            Set<Long> visible = new HashSet<>();
            visible.add(current.getId());
            List<ProjectAssignment> memberAssignments = assignmentRepository.findByUserId(current.getId());
            for (ProjectAssignment pa : memberAssignments) {
                Long projectId = pa.getProject().getId();
                assignmentRepository.findByProjectId(projectId).stream()
                        .map(a -> a.getUser().getId())
                        .forEach(visible::add);
            }
            return userRepository.findAll().stream()
                    .filter(u -> visible.contains(u.getId()))
                    .map(this::toUserSummarySafe)
                    .filter(java.util.Objects::nonNull)
                    .collect(Collectors.toList());
        }
        return getAllUsers();
    }

    public ProjectTeamDto getProjectTeam(Long projectId) {
        Project project = projectRepository.findById(projectId).orElse(null);
        if (project == null) return null;
        List<ProjectAssignment> assignments = assignmentRepository.findByProjectId(projectId);
        List<ProjectTeamMemberDto> members = assignments.stream()
                .map(a -> {
                    ProjectTeamMemberDto dto = new ProjectTeamMemberDto();
                    User u = a.getUser();
                    dto.setId(u.getId());
                    dto.setName(u.getFullName());
                    dto.setTitle(u.getTitle() != null ? u.getTitle() : "");
                    dto.setEmail(u.getEmail());
                    dto.setPosition(u.getPosition() != null ? u.getPosition().getName() : null);
                    dto.setProjectRole(a.getProjectRole().name().toLowerCase());
                    dto.setPhotoUrl(u.getPhotoUrl());
                    return dto;
                })
                .collect(Collectors.toList());
        ProjectTeamDto team = new ProjectTeamDto();
        team.setProjectId(project.getId());
        team.setProjectName(project.getName());
        team.setMembers(members);
        return team;
    }

    @Transactional
    public UserSummaryDto assignUserToProject(Long userId, Long projectId, String projectRoleStr) {
        User user = userRepository.findById(userId).orElseThrow(() -> new AuthException("User not found"));
        Project project = projectRepository.findById(projectId).orElseThrow(() -> new AuthException("Project not found"));
        ProjectRole projRole = parseProjectRole(projectRoleStr);
        boolean exists = assignmentRepository.findByProjectId(projectId).stream()
                .anyMatch(a -> a.getUser().getId().equals(userId));
        if (exists) {
            throw new AuthException("User is already assigned to this project");
        }
        // One manager per project; max 3 team leaders per project; members unlimited.
        if (projRole == ProjectRole.MANAGER) {
            boolean hasManager = assignmentRepository.findByProjectId(projectId).stream()
                    .anyMatch(a -> a.getProjectRole() == ProjectRole.MANAGER);
            if (hasManager) {
                throw new AuthException("This project already has a manager. Only one manager per project.");
            }
        }
        if (projRole == ProjectRole.TEAM_LEADER) {
            long leaderCount = assignmentRepository.findByProjectId(projectId).stream()
                    .filter(a -> a.getProjectRole() == ProjectRole.TEAM_LEADER)
                    .count();
            if (leaderCount >= 3) {
                throw new AuthException("This project already has the maximum of 3 team leaders.");
            }
        }
        assignmentRepository.save(new ProjectAssignment(project, user, projRole));
        return toUserSummary(user);
    }

    public Optional<UserSummaryDto> getUserById(Long id) {
        return userRepository.findById(id).map(this::toUserSummary);
    }

    @Transactional
    public UserSummaryDto updateUserProfile(Long userId, UpdateProfileRequest req) {
        User user = userRepository.findById(userId).orElseThrow(() -> new AuthException("User not found"));
        if (req.getPhotoUrl() != null) user.setPhotoUrl(req.getPhotoUrl().trim().isEmpty() ? null : req.getPhotoUrl().trim());
        if (req.getAge() != null) user.setAge(req.getAge());
        if (req.getSkills() != null) user.setSkills(req.getSkills().trim().isEmpty() ? null : req.getSkills().trim());
        if (req.getTemporary() != null) user.setTemporary(req.getTemporary());
        user = userRepository.save(user);
        return toUserSummary(user);
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

    /** Admin: can kick anyone except admin. Manager: can kick team leader and team member only. */
    @Transactional
    public void kickUser(Long targetUserId) {
        String email = SecurityUtils.currentUserEmail();
        if (email == null || email.isBlank()) {
            throw new ForbiddenException("Not authenticated");
        }
        User current = userRepository.findByEmail(email).orElseThrow(() -> new NotFoundException("User not found"));
        User target = userRepository.findById(targetUserId).orElseThrow(() -> new NotFoundException("User not found"));
        if (current.getRole() == Role.ADMIN) {
            if (target.getRole() == Role.ADMIN) {
                throw new ForbiddenException("Cannot kick an admin");
            }
        } else if (current.getRole() == Role.MANAGER) {
            if (target.getRole() != Role.TEAM_LEADER && target.getRole() != Role.MEMBER) {
                throw new ForbiddenException("Manager can only kick team leaders and team members");
            }
        } else {
            throw new ForbiddenException("Only admin or manager can kick users");
        }
        assignmentRepository.findByUserId(targetUserId).forEach(assignmentRepository::delete);
        taskRepository.findByAssignedToId(targetUserId).forEach(taskRepository::delete);
        userRepository.delete(target);
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
            throw new AuthException("Password is required");
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
        if (req.getTemporary() != null) {
            user.setTemporary(req.getTemporary());
        }
        user = userRepository.save(user);
        return toUserSummary(user);
    }

    private Role parseRole(String r) {
        if (r == null || r.isBlank()) return Role.MEMBER;
        String s = r.trim().toLowerCase().replace(" ", "_").replace("-", "_").replace("teamleader", "team_leader");
        return switch (s) {
            case "admin" -> Role.ADMIN;
            case "manager" -> Role.MANAGER;
            case "team_leader" -> Role.TEAM_LEADER;
            default -> Role.MEMBER;
        };
    }

    private ProjectRole parseProjectRole(String r) {
        if (r == null || r.isBlank()) return ProjectRole.TEAM_MEMBER;
        String s = r.trim().toLowerCase().replace(" ", "_").replace("-", "_").replace("teamleader", "team_leader");
        return switch (s) {
            case "manager" -> ProjectRole.MANAGER;
            case "team_leader" -> ProjectRole.TEAM_LEADER;
            default -> ProjectRole.TEAM_MEMBER;
        };
    }

    private void setManagerAndTeamLeader(UserSummaryDto dto, User u) {
        try {
            List<ProjectAssignment> userAssignments = assignmentRepository.findByUserId(u.getId());
            if (userAssignments == null || userAssignments.isEmpty()) return;
            ProjectAssignment first = userAssignments.get(0);
            if (first == null) return;
            Project firstProject = first.getProject();
            if (firstProject == null) return;
            List<ProjectAssignment> projectAssignments = assignmentRepository.findByProjectId(firstProject.getId());
            if (projectAssignments == null) return;
            for (ProjectAssignment a : projectAssignments) {
                if (a != null && a.getProjectRole() == ProjectRole.MANAGER) {
                    User manager = a.getUser();
                    if (manager != null && manager.getFullName() != null) {
                        dto.setManagerName(manager.getFullName());
                    }
                    break;
                }
            }
            for (ProjectAssignment a : projectAssignments) {
                if (a != null && a.getProjectRole() == ProjectRole.TEAM_LEADER) {
                    User tl = a.getUser();
                    if (tl != null && tl.getFullName() != null) {
                        dto.setTeamLeaderName(tl.getFullName());
                    }
                    break;
                }
            }
        } catch (Exception ignored) {
            // Skip manager/teamLeader if any lazy load or missing data
        }
    }

    /** Safe mapping: returns null if any field causes an exception, so one bad user does not break the whole list. */
    private UserSummaryDto toUserSummarySafe(User u) {
        try {
            return toUserSummary(u);
        } catch (Exception e) {
            org.slf4j.LoggerFactory.getLogger(DataService.class).warn("Skip user id={}: {}", u.getId(), e.getMessage());
            return null;
        }
    }

    private UserSummaryDto toUserSummary(User u) {
        if (u == null) return null;
        UserSummaryDto dto = new UserSummaryDto();
        dto.setId(u.getId());
        dto.setName(u.getFullName() != null ? u.getFullName() : "");
        dto.setTitle(u.getTitle() != null ? u.getTitle() : "");
        dto.setRole(u.getRole() != null ? u.getRole().name().toLowerCase() : "member");
        try {
            dto.setPosition(u.getPosition() != null ? u.getPosition().getName() : null);
        } catch (Exception ignored) {
            dto.setPosition(null);
        }
        dto.setTemporary(u.isTemporary());
        dto.setEmail(u.getEmail() != null ? u.getEmail() : "");
        dto.setLoginId(u.getLoginId());
        dto.setPhotoUrl(u.getPhotoUrl());
        dto.setAge(u.getAge());
        dto.setSkills(u.getSkills());
        try {
            dto.setCurrentProject(getCurrentProjectName(u.getId()));
        } catch (Exception ignored) {
            dto.setCurrentProject(null);
        }
        try {
            dto.setProjectsCompletedCount((int) taskRepository.countByAssignedToIdAndStatus(u.getId(), "completed"));
        } catch (Exception ignored) {
            dto.setProjectsCompletedCount(0);
        }
        setManagerAndTeamLeader(dto, u);
        return dto;
    }

    private String getCurrentProjectName(Long userId) {
        try {
            List<ProjectAssignment> assignments = assignmentRepository.findByUserId(userId);
            if (assignments == null || assignments.isEmpty()) return null;
            ProjectAssignment first = assignments.get(0);
            if (first == null) return null;
            Project p = first.getProject();
            return p != null ? p.getName() : null;
        } catch (Exception e) {
            return null;
        }
    }
}
