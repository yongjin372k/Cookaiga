package com.cookaiga.demo.api.repository;


import java.util.List;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import com.cookaiga.demo.models.Ingredients;


@Repository
public interface IngredientRepository extends JpaRepository<Ingredients, Long> {
    Ingredients findByItemAndUserID(String item, Long userID);
    List<Ingredients> findAllByUserID(Long userID);
}