package com.cookaiga.demo.api.repository;

import com.cookaiga.demo.models.Kitchen;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;
import org.springframework.transaction.annotation.Transactional;

@Repository
public interface KitchenRepository extends JpaRepository<Kitchen, Integer> {

    // Insert or Update kitchenList for a specific user
    @Transactional
    @Modifying
    @Query(value = "INSERT INTO KITCHEN (userID, kitchenList) VALUES (:userID, :kitchenList) " +
                   "ON DUPLICATE KEY UPDATE kitchenList = :kitchenList", nativeQuery = true)
    int insertOrUpdateKitchenList(@Param("userID") int userID, @Param("kitchenList") String kitchenList);

    // Find Kitchen details by user ID
    @Query(value = "SELECT * FROM KITCHEN WHERE userID = :userID", nativeQuery = true)
    Kitchen findByUserID(@Param("userID") int userID);


    // Delete Kitchen item by kitchenID
    @Transactional
    @Modifying
    @Query(value = "DELETE FROM KITCHEN WHERE kitchenID = :kitchenID", nativeQuery = true)
    void deleteByKitchenID(@Param("kitchenID") int kitchenID);
}
