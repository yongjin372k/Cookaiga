package com.cookaiga.demo.api.controller;

import com.cookaiga.demo.models.RedemptionHistory;
import com.cookaiga.demo.api.service.RedemptionService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/redemptions")
public class RedemptionController {

    @Autowired
    private RedemptionService redemptionService;

    // Add a new redemption
    @PostMapping
    public ResponseEntity<RedemptionHistory> addRedemption(@RequestParam int userID, @RequestParam int stickerID) {
        return ResponseEntity.ok(redemptionService.addRedemption(userID, stickerID));
    }

    // Get all redemptions for a user
    @GetMapping("/user/{userID}")
    public ResponseEntity<List<RedemptionHistory>> getRedemptionsByUserID(@PathVariable int userID) {
        return ResponseEntity.ok(redemptionService.getRedemptionsByUserID(userID));
    }

    // Check if a user has redeemed a specific sticker
    @GetMapping("/user/{userID}/sticker/{stickerID}")
    public ResponseEntity<Boolean> hasUserRedeemedSticker(@PathVariable int userID, @PathVariable int stickerID) {
        return ResponseEntity.ok(redemptionService.hasUserRedeemedSticker(userID, stickerID));
    }

    // Get all sticker IDs redeemed by a user
    @GetMapping("/user/{userID}/stickers")
    public ResponseEntity<List<Integer>> getStickerIDsByUserID(@PathVariable int userID) {
        return ResponseEntity.ok(redemptionService.getStickerIDsByUserID(userID));
    }

    // Get redemption by ID
    @GetMapping("/{redemptionID}")
    public ResponseEntity<RedemptionHistory> getRedemptionByID(@PathVariable int redemptionID) {
        return redemptionService.getRedemptionByID(redemptionID)
                .map(ResponseEntity::ok)
                .orElse(ResponseEntity.notFound().build());
    }
}
