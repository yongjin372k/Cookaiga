package com.cookaiga.demo.api.repository;


import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import com.cookaiga.demo.models.Ingredients;


@Repository
public interface IngredientRepository extends JpaRepository<Ingredients, Long> {
    Ingredients findByItem(String item);
}