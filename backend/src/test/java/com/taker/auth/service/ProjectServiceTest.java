package com.taker.auth.service;

import com.taker.auth.dto.ProjectDto;
import com.taker.auth.entity.Project;
import com.taker.auth.exception.NotFoundException;
import com.taker.auth.repository.ProjectRepository;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Nested;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import java.util.List;

import static org.assertj.core.api.Assertions.assertThat;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;
import static org.mockito.Mockito.never;
import static org.mockito.Mockito.anyLong;

@ExtendWith(MockitoExtension.class)
class ProjectServiceTest {

    @Mock
    private ProjectRepository projectRepository;

    @InjectMocks
    private ProjectService projectService;

    @BeforeEach
    void setUp() {
        // no-op for now
    }

    @Nested
    @DisplayName("findAll")
    class FindAllTests {
        @Test
        void returnsEmptyListWhenNoProjects() {
            when(projectRepository.findAll()).thenReturn(List.of());

            List<ProjectDto> result = projectService.findAll();

            assertThat(result).isEmpty();
            verify(projectRepository).findAll();
        }

        @Test
        void mapsProjectsToDtos() {
            Project p1 = new Project("Alpha", "Active", 50);
            p1.setId(1L);
            Project p2 = new Project("Beta", "Completed", 100);
            p2.setId(2L);
            when(projectRepository.findAll()).thenReturn(List.of(p1, p2));

            List<ProjectDto> result = projectService.findAll();

            assertThat(result).hasSize(2);
            assertThat(result.get(0).getId()).isEqualTo(1L);
            assertThat(result.get(0).getName()).isEqualTo("Alpha");
            assertThat(result.get(0).getStatus()).isEqualTo("Active");
            assertThat(result.get(0).getProgress()).isEqualTo(50);
            assertThat(result.get(1).getId()).isEqualTo(2L);
            assertThat(result.get(1).getName()).isEqualTo("Beta");
            assertThat(result.get(1).getStatus()).isEqualTo("Completed");
            assertThat(result.get(1).getProgress()).isEqualTo(100);
            verify(projectRepository).findAll();
        }
    }

    @Nested
    @DisplayName("delete")
    class DeleteTests {
        @Test
        void deletesExistingProject() {
            when(projectRepository.existsById(1L)).thenReturn(true);

            projectService.delete(1L);

            verify(projectRepository).deleteById(1L);
        }

        @Test
        void throwsWhenProjectNotFound() {
            when(projectRepository.existsById(99L)).thenReturn(false);

            org.assertj.core.api.Assertions.assertThatThrownBy(() -> projectService.delete(99L))
                    .isInstanceOf(NotFoundException.class)
                    .hasMessageContaining("Project not found");
            verify(projectRepository, never()).deleteById(anyLong());
        }
    }
}
