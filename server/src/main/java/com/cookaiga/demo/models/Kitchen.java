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

    @Column(name = "foodID", nullable = false)
    private int foodID;

    @Column(name = "quantity", precision = 10, scale = 2)
    private BigDecimal quantity;

    @Column(name = "unit", length = 50)
    private String unit;

    @Column(name = "expiry_date")
    private LocalDate expiryDate;

    @Column(name = "added_at", updatable = false)
    private LocalDateTime addedAt = LocalDateTime.now(); // Timestamp of when the item was added

    public Kitchen() {

    }

    public Kitchen(
        int kitchenID,
        String kitchenList,
        int userID,
        int foodID,
        BigDecimal quantity,
        String unit,
        LocalDate expiryDate,
        LocalDateTime addedAt
    ) {
        this.kitchenID = kitchenID;
        this.kitchenList = kitchenList;
        this.userID = userID;
        this.foodID = foodID;
        this.quantity = quantity;
        this.unit = unit;
        this.expiryDate = expiryDate;
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

    public int getFoodID() {
        return this.foodID;
    }

    public void setFoodID(int foodID) {
        this.foodID = foodID;
    }

    public BigDecimal getQuantity() {
        return this.quantity;
    }

    public void setQuantity(BigDecimal quantity) {
        this.quantity = quantity;
    }

    public String getUnit() {
        return this.unit;
    }

    public void setUnit(String unit) {
        this.unit = unit;
    }

    public LocalDate getExpiryDate() {
        return this.expiryDate;
    }

    public void setExpiryDate(LocalDate expiryDate) {
        this.expiryDate = expiryDate;
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
            ", foodID='" + getFoodID() + "'" +
            ", quantity='" + getQuantity() + "'" +
            ", unit='" + getUnit() + "'" +
            ", expiryDate='" + getExpiryDate() + "'" +
            ", addedAt='" + getAddedAt() + "'" +
            "}";
    }

}
