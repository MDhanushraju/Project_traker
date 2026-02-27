package com.taker.auth.repository;

import com.taker.auth.entity.Role;
import com.taker.auth.entity.User;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Optional;

public interface UserRepository extends JpaRepository<User, Long> {

    Optional<User> findByEmail(String email);

    Optional<User> findByLoginId(Integer loginId);

    boolean existsByEmail(String email);

    Optional<User> findByEmailAndIdCardNumber(String email, String idCardNumber);
}
