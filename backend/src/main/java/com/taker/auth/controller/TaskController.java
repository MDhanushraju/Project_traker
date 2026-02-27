package com.taker.auth.controller;

import com.taker.auth.dto.ApiResponse;
import com.taker.auth.dto.AssignTaskRequest;
import com.taker.auth.dto.CreateTaskRequest;
import com.taker.auth.dto.TaskDto;
import com.taker.auth.dto.UpdateTaskStatusRequest;
import com.taker.auth.service.TaskService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.Parameter;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@Tag(name = "Tasks", description = "Task CRUD, status updates, assign - requires auth. Frontend expects { success, message, data }.")
@RestController
@RequestMapping("/api/tasks")
public class TaskController {

    private final TaskService taskService;

    public TaskController(TaskService taskService) {
        this.taskService = taskService;
    }

    @Operation(summary = "List tasks", description = "By default returns tasks visible to current user (role-based). Use ?userId=3 for that user's tasks only.")
    @GetMapping
    public ResponseEntity<ApiResponse<List<TaskDto>>> getTasks(
            @RequestParam(required = false) Long userId) {
        List<TaskDto> tasks = userId != null
                ? taskService.findByAssignedUser(userId)
                : taskService.findTasksForCurrentUser();
        return ResponseEntity.ok(ApiResponse.success("OK", tasks));
    }

    @Operation(summary = "Create task", description = "Create task. Frontend: title, status (default need_to_start), dueDate optional.")
    @PostMapping
    public ResponseEntity<ApiResponse<TaskDto>> createTask(@Valid @RequestBody CreateTaskRequest request) {
        return ResponseEntity.ok(ApiResponse.success("Task created", taskService.createTask(request)));
    }

    @Operation(summary = "Update task status", description = "Set status: need_to_start, ongoing, completed.")
    @PatchMapping("/{id}/status")
    public ResponseEntity<ApiResponse<TaskDto>> updateStatus(
            @Parameter(description = "Task ID", example = "1") @PathVariable Long id,
            @Valid @RequestBody UpdateTaskStatusRequest request) {
        return ResponseEntity.ok(ApiResponse.success("Status updated", taskService.updateStatus(id, request)));
    }

    @Operation(summary = "Delete task", description = "Delete task by ID. Returns 204.")
    @DeleteMapping("/{id}")
    public ResponseEntity<Void> deleteTask(@Parameter(description = "Task ID", example = "1") @PathVariable Long id) {
        taskService.deleteTask(id);
        return ResponseEntity.noContent().build();
    }

    @Operation(summary = "Assign task", description = "Create/assign task to user. Frontend: userId, taskTitle, dueDate optional, projectId optional.")
    @PostMapping("/assign")
    public ResponseEntity<ApiResponse<TaskDto>> assignTask(@Valid @RequestBody AssignTaskRequest request) {
        TaskDto task = taskService.assignTask(
                request.getUserId(),
                request.getTaskTitle(),
                request.getDueDate(),
                request.getProjectId());
        return ResponseEntity.ok(ApiResponse.success("Task assigned", task));
    }
}
