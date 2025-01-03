package com.cookaiga.demo.api.repository;

import com.cookaiga.demo.models.Kitchen;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface KitchenRepository extends JpaRepository<Kitchen, Integer> {

    List<Kitchen> findByUserIDAndFoodID(int userID, Long foodID);
}
