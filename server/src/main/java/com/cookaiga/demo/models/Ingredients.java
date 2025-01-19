package com.cookaiga.demo.models;

import java.time.LocalDate;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Entity
@Data
@NoArgsConstructor
@AllArgsConstructor
public class Ingredients {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "id") // Map to the 'id' column in the database
    private Long id;

    @Column(name = "item") // Map to the 'item' column in the database
    private String item;

    @Column(name = "quantity_with_unit") // Map to the 'quantity_with_unit' column in the database
    private String quantityWithUnit;

    @Column(name = "expiry") // Map to the 'expiry' column in the database
    private LocalDate expiry;

    @Column(name = "userID") // Add this column to track the user
    private Long userID;
}

