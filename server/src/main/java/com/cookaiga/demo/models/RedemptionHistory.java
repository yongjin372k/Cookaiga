package com.cookaiga.demo.models;

import java.time.LocalDateTime;

import jakarta.persistence.*;
import lombok.Data;

@Entity
@Table(name = "redemption")
@Data

public class RedemptionHistory {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "redemptionID")
    private int redemptionID;

    @Column(name = "userID", nullable = false)
    private int userID;

    @Column(name = "stickerID", nullable = false)
    private int stickerID;

    @Column(name = "redeemed_at")
    private LocalDateTime redeemedAt = LocalDateTime.now();

    public RedemptionHistory () {}

    public RedemptionHistory (
        int redemptionID,
        int userID,
        int stickerID,
        LocalDateTime redeemedAt
    ) {
        this.redemptionID = redemptionID;
        this.userID = userID;
        this.stickerID = stickerID;
        this.redeemedAt = redeemedAt;
    }


    public int getRedemptionID() {
        return this.redemptionID;
    }

    public void setRedemptionID(int redemptionID) {
        this.redemptionID = redemptionID;
    }

    public int getUserID() {
        return this.userID;
    }

    public void setUserID(int userID) {
        this.userID = userID;
    }

    public int getStickerID() {
        return this.stickerID;
    }

    public void setStickerID(int stickerID) {
        this.stickerID = stickerID;
    }

    public LocalDateTime getRedeemedAt() {
        return this.redeemedAt;
    }

    public void setRedeemedAt(LocalDateTime redeemedAt) {
        this.redeemedAt = redeemedAt;
    }


    @Override
    public String toString() {
        return "{" +
            " redemptionID='" + getRedemptionID() + "'" +
            ", userID='" + getUserID() + "'" +
            ", stickerID='" + getStickerID() + "'" +
            ", redeemedAt='" + getRedeemedAt() + "'" +
            "}";
    }

}
