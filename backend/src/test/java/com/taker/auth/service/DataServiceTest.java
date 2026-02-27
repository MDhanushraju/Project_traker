package com.taker.auth.service;

import com.taker.auth.dto.AssignRoleRequest;
import com.taker.auth.dto.CreateUserRequest;
import com.taker.auth.dto.UserSummaryDto;
import com.taker.auth.entity.Position;
import com.taker.auth.entity.Role;
import com.taker.auth.entity.User;
import com.taker.auth.exception.AuthException;
import com.taker.auth.repository.PositionRepository;
import com.taker.auth.repository.ProjectAssignmentRepository;
import com.taker.auth.repository.ProjectRepository;
import com.taker.auth.repository.TaskRepository;
import com.taker.auth.repository.UserRepository;
import com.taker.auth.util.SecurityUtils;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Nested;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.MockedStatic;
import org.mockito.Mockito;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.security.crypto.password.PasswordEncoder;

import java.util.List;
import java.util.Optional;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.argThat;
import static org.mockito.ArgumentMatchers.anyString;
import static org.mockito.Mockito.lenient;
import static org.mockito.Mockito.never;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

@ExtendWith(MockitoExtension.class)
class DataServiceTest {

    @Mock
    private UserRepository userRepository;

    @Mock
    private PositionRepository positionRepository;

    @Mock
    private ProjectRepository projectRepository;

    @Mock
    private ProjectAssignmentRepository assignmentRepository;

    @Mock
    private TaskRepository taskRepository;

    @Mock
    private PasswordEncoder passwordEncoder;

    @InjectMocks
    private DataService dataService;

    private User testUser;

    @BeforeEach
    void setUp() {
        testUser = new User("Test User", "test@example.com", null, "encoded", Role.MEMBER);
        testUser.setId(1L);
        testUser.setTitle("Developer");
        lenient().when(taskRepository.countByAssignedToIdAndStatus(any(Long.class), anyString())).thenReturn(0L);
        lenient().when(assignmentRepository.findByUserId(any(Long.class))).thenReturn(List.of());
    }

    @Nested
    @DisplayName("getAllUsers")
    class GetAllUsersTests {
        @Test
        void returnsMappedUserSummaries() {
            User u2 = new User("Other", "other@example.com", null, "hash", Role.ADMIN);
            u2.setId(2L);
            when(userRepository.findAll()).thenReturn(List.of(testUser, u2));

            List<UserSummaryDto> result = dataService.getAllUsers();

            assertThat(result).hasSize(2);
            assertThat(result.get(0).getId()).isEqualTo(1L);
            assertThat(result.get(0).getName()).isEqualTo("Test User");
            assertThat(result.get(0).getRole()).isEqualTo("member");
            assertThat(result.get(0).getTitle()).isEqualTo("Developer");
            assertThat(result.get(1).getName()).isEqualTo("Other");
            assertThat(result.get(1).getRole()).isEqualTo("admin");
        }

        @Test
        void returnsEmptyListWhenNoUsers() {
            when(userRepository.findAll()).thenReturn(List.of());
            assertThat(dataService.getAllUsers()).isEmpty();
        }
    }

    @Nested
    @DisplayName("getTeamLeaderAssignedProjects")
    class GetTeamLeaderAssignedProjectsTests {
        @Test
        void returnsEmptyListWhenNoCurrentUser() {
            try (MockedStatic<SecurityUtils> security = Mockito.mockStatic(SecurityUtils.class)) {
                security.when(SecurityUtils::currentUserEmail).thenReturn(null);
                assertThat(dataService.getTeamLeaderAssignedProjects()).isEmpty();
            }
        }
    }

    @Nested
    @DisplayName("getMemberAssignedProjects")
    class GetMemberAssignedProjectsTests {
        @Test
        void returnsEmptyListWhenNoCurrentUser() {
            try (MockedStatic<SecurityUtils> security = Mockito.mockStatic(SecurityUtils.class)) {
                security.when(SecurityUtils::currentUserEmail).thenReturn(null);
                assertThat(dataService.getMemberAssignedProjects()).isEmpty();
            }
        }
    }

    @Nested
    @DisplayName("createUser")
    class CreateUserTests {
        @Test
        void throwsWhenEmailAlreadyExists() {
            CreateUserRequest req = new CreateUserRequest();
            req.setFullName("New User");
            req.setEmail("existing@example.com");
            req.setPassword("Password@1");
            req.setRole("member");
            when(userRepository.existsByEmail("existing@example.com")).thenReturn(true);

            assertThatThrownBy(() -> dataService.createUser(req))
                    .isInstanceOf(AuthException.class)
                    .hasMessageContaining("already registered");
            verify(userRepository, never()).save(any());
        }

        @Test
        void throwsWhenPasswordBlankAndDefaultPasswordInvalid() {
            CreateUserRequest req = new CreateUserRequest();
            req.setFullName("New User");
            req.setEmail("new@example.com");
            req.setPassword("");
            req.setRole("member");
            when(userRepository.existsByEmail("new@example.com")).thenReturn(false);
            try (MockedStatic<AuthService> auth = Mockito.mockStatic(AuthService.class)) {
                auth.when(() -> AuthService.isValidPasswordStatic("Welcome@1")).thenReturn(false);
                assertThatThrownBy(() -> dataService.createUser(req))
                        .isInstanceOf(AuthException.class)
                        .hasMessageContaining("Password is required");
                verify(userRepository, never()).save(any());
            }
        }

        @Test
        void createsUserWithDefaultPasswordWhenPasswordBlank() {
            CreateUserRequest req = new CreateUserRequest();
            req.setFullName("New User");
            req.setEmail("new@example.com");
            req.setPassword("");
            req.setRole("member");
            when(userRepository.existsByEmail("new@example.com")).thenReturn(false);
            when(passwordEncoder.encode("Welcome@1")).thenReturn("encoded");
            when(userRepository.save(any(User.class))).thenAnswer(inv -> {
                User u = inv.getArgument(0);
                u.setId(2L);
                return u;
            });
            try (MockedStatic<AuthService> auth = Mockito.mockStatic(AuthService.class)) {
                auth.when(() -> AuthService.isValidPasswordStatic("Welcome@1")).thenReturn(true);

                UserSummaryDto result = dataService.createUser(req);

                assertThat(result.getId()).isEqualTo(2L);
                assertThat(result.getName()).isEqualTo("New User");
                assertThat(result.getRole()).isEqualTo("member");
                verify(userRepository).save(any(User.class));
            }
        }

        @Test
        void createsUserWithProvidedPasswordAndRole() {
            CreateUserRequest req = new CreateUserRequest();
            req.setFullName("Manager One");
            req.setEmail("manager@example.com");
            req.setPassword("SecurePass@1");
            req.setRole("manager");
            req.setTitle("Project Manager");
            when(userRepository.existsByEmail("manager@example.com")).thenReturn(false);
            when(passwordEncoder.encode("SecurePass@1")).thenReturn("encoded");
            when(userRepository.save(any(User.class))).thenAnswer(inv -> {
                User u = inv.getArgument(0);
                u.setId(3L);
                return u;
            });
            try (MockedStatic<AuthService> auth = Mockito.mockStatic(AuthService.class)) {
                auth.when(() -> AuthService.isValidPasswordStatic("SecurePass@1")).thenReturn(true);

                UserSummaryDto result = dataService.createUser(req);

                assertThat(result.getName()).isEqualTo("Manager One");
                assertThat(result.getRole()).isEqualTo("manager");
                assertThat(result.getTitle()).isEqualTo("Project Manager");
                verify(userRepository).save(any(User.class));
            }
        }
    }

    @Nested
    @DisplayName("assignRole")
    class AssignRoleTests {
        @Test
        void throwsWhenUserNotFound() {
            when(userRepository.findById(999L)).thenReturn(Optional.empty());
            AssignRoleRequest req = new AssignRoleRequest();
            req.setRole("admin");

            assertThatThrownBy(() -> dataService.assignRole(999L, req))
                    .isInstanceOf(AuthException.class)
                    .hasMessageContaining("User not found");
            verify(userRepository, never()).save(any());
        }

        @Test
        void updatesRoleAndSaves() {
            when(userRepository.findById(1L)).thenReturn(Optional.of(testUser));
            when(userRepository.save(any(User.class))).thenAnswer(inv -> inv.getArgument(0));
            AssignRoleRequest req = new AssignRoleRequest();
            req.setRole("team_leader");

            UserSummaryDto result = dataService.assignRole(1L, req);

            assertThat(result.getRole()).isEqualTo("team_leader");
            verify(userRepository).save(argThat(u -> u.getRole() == Role.TEAM_LEADER));
        }

        @Test
        void setsPositionWhenProvided() {
            Position pos = new Position();
            pos.setName("Developer");
            when(userRepository.findById(1L)).thenReturn(Optional.of(testUser));
            when(userRepository.save(any(User.class))).thenAnswer(inv -> inv.getArgument(0));
            when(positionRepository.findByName("Developer")).thenReturn(Optional.of(pos));
            AssignRoleRequest req = new AssignRoleRequest();
            req.setRole("member");
            req.setPosition("Developer");

            dataService.assignRole(1L, req);

            verify(userRepository).save(argThat(u -> u.getPosition() != null && "Developer".equals(u.getPosition().getName())));
        }
    }
}
