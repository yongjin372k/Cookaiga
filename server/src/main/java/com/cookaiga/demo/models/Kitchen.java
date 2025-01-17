package com.cookaiga.demo.models;

import java.math.BigDecimal;
import java.text.DecimalFormat;
import java.time.LocalDate;
import java.time.LocalDateTime;

import jakarta.persistence.*;
import lombok.Data;

@Entity
@Table(name = "kitchen")
@Data

public class Kitchen {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "kitchenID")
    private int kitchenID;

    @Column(name = "kitchenList", columnDefinition = "TEXT")
    private String kitchenList;

    @Column(name = "userID", nullable = false)
    private int userID;

    @Column(name = "added_at", updatable = false)
    private LocalDateTime addedAt = LocalDateTime.now(); // Timestamp of when the item was added

    public Kitchen() {

    }

    public Kitchen(
        int kitchenID,
        String kitchenList,
        int userID,
        LocalDateTime addedAt
    ) {
        this.kitchenID = kitchenID;
        this.kitchenList = kitchenList;
        this.userID = userID;
        this.addedAt = addedAt;
    }

    public int getKitchenID() {
        return this.kitchenID;
    }

    public void setKitchenID(int kitchenID) {
        this.kitchenID = kitchenID;
    }

    public String getKitchenList() {
        return this.kitchenList;
    }

    public void setKitchenList(String kitchenList) {
        this.kitchenList = kitchenList;
    }

    public int getUserID() {
        return this.userID;
    }

    public void setUserID(int userID) {
        this.userID = userID;
    }

    public LocalDateTime getAddedAt() {
        return this.addedAt;
    }

    public void setAddedAt(LocalDateTime addedAt) {
        this.addedAt = addedAt;
    }

    @Override
    public String toString() {
        return "{" +
            " kitchenID='" + getKitchenID() + "'" +
            ", kitchenList='" + getKitchenList() + "'" +
            ", userID='" + getUserID() + "'" +
            ", addedAt='" + getAddedAt() + "'" +
            "}";
    }

}
