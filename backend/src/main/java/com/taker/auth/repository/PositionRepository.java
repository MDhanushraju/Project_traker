package com.taker.auth.repository;

import com.taker.auth.entity.Position;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Optional;

public interface PositionRepository extends JpaRepository<Position, Long> {

    boolean existsByName(String name);
    Optional<Position> findByName(String name);
}
