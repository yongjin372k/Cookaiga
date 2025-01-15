package com.cookaiga.demo.models;


import java.math.BigDecimal;
import java.text.DecimalFormat;
import java.time.LocalDate;
import java.time.LocalDateTime;

import jakarta.persistence.*;
import lombok.Data;

@Entity
@Table(name = "post")
@Data

public class Post {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "postID")
    private int postID;

    @Column(name = "userID", nullable = false)
    private int userID;
    
    @Column(name = "imagePath")
    private String imagePath;

    @Column(name = "caption")
    private String caption;

    @Column(name = "postDate")
    private LocalDateTime postDate = LocalDateTime.now();

    public Post() {}

    public Post(
        int postID,
        String imagePath,
        String caption,
        LocalDateTime postDate
    ) {
        this.postID = postID;
        this.imagePath = imagePath;
        this.caption = caption;
        this.postDate = postDate;
    }


    public int getPostID() {
        return this.postID;
    }

    public void setPostID(int postID) {
        this.postID = postID;
    }

    public int getUserID() {
        return this.userID;
    }

    public void setUserID(int userID) {
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

    @Override
    public String toString() {
        return "{" +
            " postID='" + getPostID() + "'" +
            ", userID='" + getUserID() + "'" +
            ", imagePath='" + getImagePath() + "'" +
            ", caption='" + getCaption() + "'" +
            ", postDate='" + getPostDate() + "'" +
            "}";
    }

}
