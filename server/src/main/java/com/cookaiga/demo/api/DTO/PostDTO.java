package com.cookaiga.demo.api.DTO;

import java.time.LocalDateTime;

public class PostDTO {
    private Long postID;
    private Long userID;
    private String imagePath;
    private String caption;
    private LocalDateTime postDate;
    private String username;

    public PostDTO() {}

    // Constructor (must match order in SELECT)
    public PostDTO(Long postID, Long userID, String imagePath,
                               String caption, LocalDateTime postDate, String username) {
        this.postID = postID;
        this.userID = userID;
        this.imagePath = imagePath;
        this.caption = caption;
        this.postDate = postDate;
        this.username = username;
    }


    public Long getPostID() {
        return this.postID;
    }

    public void setPostID(Long postID) {
        this.postID = postID;
    }

    public Long getUserID() {
        return this.userID;
    }

    public void setUserID(Long userID) {
        this.userID = userID;
    }

    public String getImagePath() {
        return this.imagePath;
    }

    public void setImagePath(String imagePath) {
        this.imagePath = imagePath;
    }

    public String getCaption() {
        return this.caption;
    }

    public void setCaption(String caption) {
        this.caption = caption;
    }

    public LocalDateTime getPostDate() {
        return this.postDate;
    }

    public void setPostDate(LocalDateTime postDate) {
        this.postDate = postDate;
    }

    public String getUsername() {
        return this.username;
    }

    public void setUsername(String username) {
        this.username = username;
    }


    @Override
    public String toString() {
        return "{" +
            " postID='" + getPostID() + "'" +
            ", userID='" + getUserID() + "'" +
            ", imagePath='" + getImagePath() + "'" +
            ", caption='" + getCaption() + "'" +
            ", postDate='" + getPostDate() + "'" +
            ", username='" + getUsername() + "'" +
            "}";
    }

}

