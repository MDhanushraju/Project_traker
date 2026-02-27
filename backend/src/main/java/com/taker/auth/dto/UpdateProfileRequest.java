package com.taker.auth.dto;

import io.swagger.v3.oas.annotations.media.Schema;

@Schema(description = "Update user profile: photo URL, age, skills (all optional)")
public class UpdateProfileRequest {

    @Schema(example = "https://example.com/photo.jpg")
    private String photoUrl;

    @Schema(example = "28")
    private Integer age;

    @Schema(example = "Java, React, SQL")
    private String skills;

    @Schema(description = "Mark role as temporary or permanent", example = "false")
    private Boolean temporary;

    public String getPhotoUrl() { return photoUrl; }
    public void setPhotoUrl(String photoUrl) { this.photoUrl = photoUrl; }
    public Integer getAge() { return age; }
    public void setAge(Integer age) { this.age = age; }
    public String getSkills() { return skills; }
    public void setSkills(String skills) { this.skills = skills != null && skills.length() > 1000 ? skills.substring(0, 1000) : skills; }
    public Boolean getTemporary() { return temporary; }
    public void setTemporary(Boolean temporary) { this.temporary = temporary; }
}
