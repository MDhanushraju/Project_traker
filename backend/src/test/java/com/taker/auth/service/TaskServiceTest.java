package com.taker.auth.service;

import com.taker.auth.dto.CreateTaskRequest;
import com.taker.auth.dto.UpdateTaskStatusRequest;
import com.taker.auth.entity.Task;
import com.taker.auth.entity.User;
import com.taker.auth.exception.NotFoundException;
import com.taker.auth.entity.Project;
import com.taker.auth.entity.ProjectAssignment;
import com.taker.auth.entity.ProjectRole;
import com.taker.auth.entity.Role;
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
import org.mockito.ArgumentCaptor;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.MockedStatic;
import org.mockito.Mockito;
import org.mockito.junit.jupiter.MockitoExtension;

import java.time.LocalDate;
import java.util.List;
import java.util.Optional;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.mockito.Mockito.*;

@ExtendWith(MockitoExtension.class)
class TaskServiceTest {

    @Mock
    private TaskRepository taskRepository;

    @Mock
    private UserRepository userRepository;

    @Mock
    private ProjectRepository projectRepository;

    @Mock
    private ProjectAssignmentRepository assignmentRepository;

    @InjectMocks
    private TaskService taskService;

    private Task testTask;
    private User testUser;

    @BeforeEach
    void setUp() {
        testUser = new User("Test User", "test@example.com", null, "hash", Role.MEMBER);
        testUser.setId(1L);

        testTask = new Task();
        testTask.setId(1L);
        testTask.setTitle("Test Task");
        testTask.setStatus("need_to_start");
        testTask.setAssignedTo(testUser);
    }

    @Nested
    @DisplayName("updateStatus")
    class UpdateStatusTests {
        @Test
        void normalizesOngoingStatus() {
            UpdateTaskStatusRequest req = new UpdateTaskStatusRequest();
            req.setStatus("ongoing");

            try (MockedStatic<SecurityUtils> security = Mockito.mockStatic(SecurityUtils.class)) {
                security.when(SecurityUtils::currentUserEmail).thenReturn("test@example.com");
                when(userRepository.findByEmail("test@example.com")).thenReturn(Optional.of(testUser));
                when(taskRepository.findById(1L)).thenReturn(Optional.of(testTask));
            when(taskRepository.save(any(Task.class))).thenAnswer(i -> i.getArgument(0));

            var result = taskService.updateStatus(1L, req);

            assertThat(result.getStatus()).isEqualTo("ongoing");
            verify(taskRepository).save(argThat(t -> "ongoing".equals(t.getStatus())));
            }
        }

        @Test
        void normalizesInProgressToOngoing() {
            UpdateTaskStatusRequest req = new UpdateTaskStatusRequest();
            req.setStatus("in_progress");

            try (MockedStatic<SecurityUtils> security = Mockito.mockStatic(SecurityUtils.class)) {
                security.when(SecurityUtils::currentUserEmail).thenReturn("test@example.com");
                when(userRepository.findByEmail("test@example.com")).thenReturn(Optional.of(testUser));
                when(taskRepository.findById(1L)).thenReturn(Optional.of(testTask));
            when(taskRepository.save(any(Task.class))).thenAnswer(i -> i.getArgument(0));

            var result = taskService.updateStatus(1L, req);

            assertThat(result.getStatus()).isEqualTo("ongoing");
            }
        }

        @Test
        void normalizesCompletedStatus() {
            UpdateTaskStatusRequest req = new UpdateTaskStatusRequest();
            req.setStatus("completed");

            try (MockedStatic<SecurityUtils> security = Mockito.mockStatic(SecurityUtils.class)) {
                security.when(SecurityUtils::currentUserEmail).thenReturn("test@example.com");
                when(userRepository.findByEmail("test@example.com")).thenReturn(Optional.of(testUser));
                when(taskRepository.findById(1L)).thenReturn(Optional.of(testTask));
            when(taskRepository.save(any(Task.class))).thenAnswer(i -> i.getArgument(0));

            var result = taskService.updateStatus(1L, req);

            assertThat(result.getStatus()).isEqualTo("completed");
            }
        }

        @Test
        void normalizesDoneToCompleted() {
            UpdateTaskStatusRequest req = new UpdateTaskStatusRequest();
            req.setStatus("done");

            try (MockedStatic<SecurityUtils> security = Mockito.mockStatic(SecurityUtils.class)) {
                security.when(SecurityUtils::currentUserEmail).thenReturn("test@example.com");
                when(userRepository.findByEmail("test@example.com")).thenReturn(Optional.of(testUser));
                when(taskRepository.findById(1L)).thenReturn(Optional.of(testTask));
            when(taskRepository.save(any(Task.class))).thenAnswer(i -> i.getArgument(0));

            var result = taskService.updateStatus(1L, req);

            assertThat(result.getStatus()).isEqualTo("completed");
            }
        }

        @Test
        void normalizesNeedToStart() {
            testTask.setStatus("ongoing");
            UpdateTaskStatusRequest req = new UpdateTaskStatusRequest();
            req.setStatus("need_to_start");

            try (MockedStatic<SecurityUtils> security = Mockito.mockStatic(SecurityUtils.class)) {
                security.when(SecurityUtils::currentUserEmail).thenReturn("test@example.com");
                when(userRepository.findByEmail("test@example.com")).thenReturn(Optional.of(testUser));
                when(taskRepository.findById(1L)).thenReturn(Optional.of(testTask));
            when(taskRepository.save(any(Task.class))).thenAnswer(i -> i.getArgument(0));

            var result = taskService.updateStatus(1L, req);

            assertThat(result.getStatus()).isEqualTo("need_to_start");
            }
        }

        @Test
        void throwsWhenTaskNotFound() {
            UpdateTaskStatusRequest req = new UpdateTaskStatusRequest();
            req.setStatus("ongoing");

            try (MockedStatic<SecurityUtils> security = Mockito.mockStatic(SecurityUtils.class)) {
                security.when(SecurityUtils::currentUserEmail).thenReturn("test@example.com");
                when(userRepository.findByEmail("test@example.com")).thenReturn(Optional.of(testUser));
                when(taskRepository.findById(999L)).thenReturn(Optional.empty());

                assertThatThrownBy(() -> taskService.updateStatus(999L, req))
                        .isInstanceOf(NotFoundException.class)
                        .hasMessageContaining("Task not found");
                verify(taskRepository, never()).save(any());
            }
        }
    }

    @Nested
    @DisplayName("deleteTask")
    class DeleteTaskTests {
        @Test
        void deletesExistingTask() {
            when(taskRepository.existsById(1L)).thenReturn(true);
            doNothing().when(taskRepository).deleteById(1L);

            taskService.deleteTask(1L);

            verify(taskRepository).deleteById(1L);
        }

        @Test
        void throwsWhenTaskNotFound() {
            when(taskRepository.existsById(999L)).thenReturn(false);

            assertThatThrownBy(() -> taskService.deleteTask(999L))
                    .isInstanceOf(NotFoundException.class)
                    .hasMessageContaining("Task not found");
            verify(taskRepository, never()).deleteById(any());
        }
    }

    @Nested
    @DisplayName("assignTask")
    class AssignTaskTests {
        @Test
        void createsAndAssignsTask() {
            when(userRepository.findById(1L)).thenReturn(Optional.of(testUser));
            when(taskRepository.save(any(Task.class))).thenAnswer(inv -> {
                Task t = inv.getArgument(0);
                t.setId(2L);
                return t;
            });

            var result = taskService.assignTask(1L, "New Task", "2025-03-15", null);

            assertThat(result.getTitle()).isEqualTo("New Task");
            assertThat(result.getStatus()).isEqualTo("need_to_start");
            ArgumentCaptor<Task> captor = ArgumentCaptor.forClass(Task.class);
            verify(taskRepository).save(captor.capture());
            assertThat(captor.getValue().getAssignedTo()).isEqualTo(testUser);
            assertThat(captor.getValue().getDueDate()).isEqualTo(LocalDate.of(2025, 3, 15));
        }

        @Test
        void throwsWhenUserNotFound() {
            when(userRepository.findById(999L)).thenReturn(Optional.empty());

            assertThatThrownBy(() -> taskService.assignTask(999L, "Task", null, null))
                    .isInstanceOf(NotFoundException.class)
                    .hasMessageContaining("User not found");
            verify(taskRepository, never()).save(any());
        }
    }

    @Nested
    @DisplayName("findAll")
    class FindAllTests {
        @Test
        void returnsAllTasksAsDtos() {
            Task t2 = new Task();
            t2.setId(2L);
            t2.setTitle("Second Task");
            t2.setStatus("ongoing");
            when(taskRepository.findAll()).thenReturn(List.of(testTask, t2));

            var result = taskService.findAll();

            assertThat(result).hasSize(2);
            assertThat(result.get(0).getId()).isEqualTo(1L);
            assertThat(result.get(0).getTitle()).isEqualTo("Test Task");
            assertThat(result.get(0).getStatus()).isEqualTo("need_to_start");
            assertThat(result.get(1).getId()).isEqualTo(2L);
            assertThat(result.get(1).getTitle()).isEqualTo("Second Task");
            assertThat(result.get(1).getStatus()).isEqualTo("ongoing");
            verify(taskRepository).findAll();
        }

        @Test
        void returnsEmptyListWhenNoTasks() {
            when(taskRepository.findAll()).thenReturn(List.of());
            assertThat(taskService.findAll()).isEmpty();
        }
    }

    @Nested
    @DisplayName("findByAssignedUser")
    class FindByAssignedUserTests {
        @Test
        void returnsTasksForUser() {
            when(taskRepository.findByAssignedToId(1L)).thenReturn(List.of(testTask));

            var result = taskService.findByAssignedUser(1L);

            assertThat(result).hasSize(1);
            assertThat(result.get(0).getTitle()).isEqualTo("Test Task");
            verify(taskRepository).findByAssignedToId(1L);
        }

        @Test
        void returnsEmptyListWhenUserHasNoTasks() {
            when(taskRepository.findByAssignedToId(2L)).thenReturn(List.of());
            assertThat(taskService.findByAssignedUser(2L)).isEmpty();
        }
    }

    @Nested
    @DisplayName("findTasksForCurrentUser")
    class FindTasksForCurrentUserTests {

        @Test
        void returnsAllTasksWhenNotAuthenticated() {
            when(taskRepository.findAll()).thenReturn(List.of(testTask));

            try (MockedStatic<SecurityUtils> security = Mockito.mockStatic(SecurityUtils.class)) {
                security.when(SecurityUtils::currentUserEmail).thenReturn(null);

                var result = taskService.findTasksForCurrentUser();

                assertThat(result).hasSize(1);
                assertThat(result.get(0).getTitle()).isEqualTo("Test Task");
                verify(taskRepository).findAll();
            }
        }

        @Test
        void returnsAllTasksWhenCurrentUserNotFound() {
            when(taskRepository.findAll()).thenReturn(List.of(testTask));

            try (MockedStatic<SecurityUtils> security = Mockito.mockStatic(SecurityUtils.class)) {
                security.when(SecurityUtils::currentUserEmail).thenReturn("missing@example.com");
                when(userRepository.findByEmail("missing@example.com")).thenReturn(Optional.empty());

                var result = taskService.findTasksForCurrentUser();

                assertThat(result).hasSize(1);
                verify(taskRepository).findAll();
            }
        }
    }

    @Nested
    @DisplayName("createTask")
    class CreateTaskTests {
        @Test
        void fallsBackToFirstUserWhenNotAuthenticated() {
            CreateTaskRequest req = new CreateTaskRequest();
            req.setTitle("New Task");
            req.setStatus("need_to_start");
            try (MockedStatic<SecurityUtils> security = Mockito.mockStatic(SecurityUtils.class)) {
                security.when(SecurityUtils::currentUserEmail).thenReturn(null);
                when(userRepository.findAll()).thenReturn(List.of(testUser));
                when(taskRepository.save(any(Task.class))).thenAnswer(inv -> {
                    Task t = inv.getArgument(0);
                    t.setId(5L);
                    return t;
                });

                var result = taskService.createTask(req);

                assertThat(result.getId()).isEqualTo(5L);
                assertThat(result.getTitle()).isEqualTo("New Task");
                ArgumentCaptor<Task> captor = ArgumentCaptor.forClass(Task.class);
                verify(taskRepository).save(captor.capture());
                assertThat(captor.getValue().getAssignedTo()).isEqualTo(testUser);
            }
        }

        @Test
        void createsTaskAssignedToCurrentUser() {
            CreateTaskRequest req = new CreateTaskRequest();
            req.setTitle("  New Task  ");
            req.setStatus("ongoing");
            req.setDueDate("2025-06-01");
            when(taskRepository.save(any(Task.class))).thenAnswer(inv -> {
                Task t = inv.getArgument(0);
                t.setId(10L);
                return t;
            });
            try (MockedStatic<SecurityUtils> security = Mockito.mockStatic(SecurityUtils.class)) {
                security.when(SecurityUtils::currentUserEmail).thenReturn("test@example.com");
                when(userRepository.findByEmail("test@example.com")).thenReturn(Optional.of(testUser));

                var result = taskService.createTask(req);

                assertThat(result.getId()).isEqualTo(10L);
                assertThat(result.getTitle()).isEqualTo("New Task");
                assertThat(result.getStatus()).isEqualTo("ongoing");
                assertThat(result.getDueDate()).isEqualTo(LocalDate.of(2025, 6, 1));
                ArgumentCaptor<Task> captor = ArgumentCaptor.forClass(Task.class);
                verify(taskRepository).save(captor.capture());
                assertThat(captor.getValue().getAssignedTo()).isEqualTo(testUser);
            }
        }

        @Test
        void throwsWhenCurrentUserNotFound() {
            CreateTaskRequest req = new CreateTaskRequest();
            req.setTitle("Task");
            try (MockedStatic<SecurityUtils> security = Mockito.mockStatic(SecurityUtils.class)) {
                security.when(SecurityUtils::currentUserEmail).thenReturn("unknown@example.com");
                when(userRepository.findByEmail("unknown@example.com")).thenReturn(Optional.empty());
                assertThatThrownBy(() -> taskService.createTask(req))
                        .isInstanceOf(NotFoundException.class)
                        .hasMessageContaining("User not found");
                verify(taskRepository, never()).save(any());
            }
        }
    }
}
