package com.taker.auth.service;

import com.taker.auth.dto.UpdateTaskStatusRequest;
import com.taker.auth.entity.Task;
import com.taker.auth.entity.User;
import com.taker.auth.exception.NotFoundException;
import com.taker.auth.repository.TaskRepository;
import com.taker.auth.repository.UserRepository;
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

    @InjectMocks
    private TaskService taskService;

    private Task testTask;
    private User testUser;

    @BeforeEach
    void setUp() {
        testUser = new User("Test User", "test@example.com", null, "hash", com.taker.auth.entity.Role.MEMBER);
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

            when(taskRepository.findById(1L)).thenReturn(Optional.of(testTask));
            when(taskRepository.save(any(Task.class))).thenAnswer(i -> i.getArgument(0));

            var result = taskService.updateStatus(1L, req);

            assertThat(result.getStatus()).isEqualTo("ongoing");
            verify(taskRepository).save(argThat(t -> "ongoing".equals(t.getStatus())));
        }

        @Test
        void normalizesInProgressToOngoing() {
            UpdateTaskStatusRequest req = new UpdateTaskStatusRequest();
            req.setStatus("in_progress");

            when(taskRepository.findById(1L)).thenReturn(Optional.of(testTask));
            when(taskRepository.save(any(Task.class))).thenAnswer(i -> i.getArgument(0));

            var result = taskService.updateStatus(1L, req);

            assertThat(result.getStatus()).isEqualTo("ongoing");
        }

        @Test
        void normalizesCompletedStatus() {
            UpdateTaskStatusRequest req = new UpdateTaskStatusRequest();
            req.setStatus("completed");

            when(taskRepository.findById(1L)).thenReturn(Optional.of(testTask));
            when(taskRepository.save(any(Task.class))).thenAnswer(i -> i.getArgument(0));

            var result = taskService.updateStatus(1L, req);

            assertThat(result.getStatus()).isEqualTo("completed");
        }

        @Test
        void normalizesDoneToCompleted() {
            UpdateTaskStatusRequest req = new UpdateTaskStatusRequest();
            req.setStatus("done");

            when(taskRepository.findById(1L)).thenReturn(Optional.of(testTask));
            when(taskRepository.save(any(Task.class))).thenAnswer(i -> i.getArgument(0));

            var result = taskService.updateStatus(1L, req);

            assertThat(result.getStatus()).isEqualTo("completed");
        }

        @Test
        void normalizesNeedToStart() {
            testTask.setStatus("ongoing");
            UpdateTaskStatusRequest req = new UpdateTaskStatusRequest();
            req.setStatus("need_to_start");

            when(taskRepository.findById(1L)).thenReturn(Optional.of(testTask));
            when(taskRepository.save(any(Task.class))).thenAnswer(i -> i.getArgument(0));

            var result = taskService.updateStatus(1L, req);

            assertThat(result.getStatus()).isEqualTo("need_to_start");
        }

        @Test
        void throwsWhenTaskNotFound() {
            UpdateTaskStatusRequest req = new UpdateTaskStatusRequest();
            req.setStatus("ongoing");

            when(taskRepository.findById(999L)).thenReturn(Optional.empty());

            assertThatThrownBy(() -> taskService.updateStatus(999L, req))
                    .isInstanceOf(NotFoundException.class)
                    .hasMessageContaining("Task not found");
            verify(taskRepository, never()).save(any());
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
}
