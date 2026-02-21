package com.taker.auth.dto;

public class TeamMemberDto {
    private Long id;
    private String name;
    private String title;
    private String position;

    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }
    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public String getTitle() {
        return title;
    }

    public void setTitle(String title) {
        this.title = title;
    }

    public String getPosition() {
        return position;
    }

    public void setPosition(String position) {
        this.position = position;
    }
}
