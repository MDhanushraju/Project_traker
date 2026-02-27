package com.taker.auth.entity;

import jakarta.persistence.*;
import java.time.Instant;

@Entity
@Table(name = "users")
public class User {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false)
    private String fullName;

    @Column(nullable = false, unique = true)
    private String email;

    @Column(name = "login_id", unique = true)
    private Integer loginId;

    @Column(name = "id_card_number")
    private String idCardNumber;

    @Column(nullable = false)
    private String password;

    @Column(nullable = false, name = "role")
    private Role role;

    private String title;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "position_id")
    private Position position;

    @Column(name = "is_temporary")
    private boolean isTemporary = false;

    @Column(name = "photo_url", length = 512)
    private String photoUrl;

    @Column(name = "age")
    private Integer age;

    @Column(name = "skills", length = 1000)
    private String skills;

    @Column(name = "created_at")
    private Instant createdAt = Instant.now();

    @Column(name = "pending_otp")
    private String pendingOtp;

    @Column(name = "otp_expires_at")
    private Instant otpExpiresAt;

    public User() {}

    public User(String fullName, String email, String idCardNumber, String password, Role role) {
        this.fullName = fullName;
        this.email = email;
        this.idCardNumber = idCardNumber;
        this.password = password;
        this.role = role;
    }

    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }
    public String getFullName() { return fullName; }
    public void setFullName(String fullName) { this.fullName = fullName; }
    public String getEmail() { return email; }
    public void setEmail(String email) { this.email = email; }
    public Integer getLoginId() { return loginId; }
    public void setLoginId(Integer loginId) { this.loginId = loginId; }
    public String getIdCardNumber() { return idCardNumber; }
    public void setIdCardNumber(String idCardNumber) { this.idCardNumber = idCardNumber; }
    public String getPassword() { return password; }
    public void setPassword(String password) { this.password = password; }
    public Role getRole() { return role; }
    public void setRole(Role role) { this.role = role; }
    public String getTitle() { return title; }
    public void setTitle(String title) { this.title = title; }
    public Position getPosition() { return position; }
    public void setPosition(Position position) { this.position = position; }
    public boolean isTemporary() { return isTemporary; }
    public void setTemporary(boolean temporary) { isTemporary = temporary; }
    public Instant getCreatedAt() { return createdAt; }
    public String getPendingOtp() { return pendingOtp; }
    public void setPendingOtp(String pendingOtp) { this.pendingOtp = pendingOtp; }
    public Instant getOtpExpiresAt() { return otpExpiresAt; }
    public void setOtpExpiresAt(Instant otpExpiresAt) { this.otpExpiresAt = otpExpiresAt; }
    public String getPhotoUrl() { return photoUrl; }
    public void setPhotoUrl(String photoUrl) { this.photoUrl = photoUrl; }
    public Integer getAge() { return age; }
    public void setAge(Integer age) { this.age = age; }
    public String getSkills() { return skills; }
    public void setSkills(String skills) { this.skills = skills; }
}
