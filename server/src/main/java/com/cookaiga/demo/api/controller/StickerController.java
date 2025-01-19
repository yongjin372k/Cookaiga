package com.cookaiga.demo.api.controller;

import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import com.cookaiga.demo.api.service.StickerService;
import com.cookaiga.demo.models.Sticker;

@RestController
@RequestMapping("/api/sticker")
public class StickerController {
    
     @Autowired
    private StickerService stickerService;

    // Get all stickers
    @GetMapping
    public List<Sticker> getAllStickers() {
        return stickerService.getAllStickers();
    }

    // Get a sticker by ID
    @GetMapping("/{id}")
    public ResponseEntity<Sticker> getStickerById(@PathVariable int id) {
        return stickerService.getStickerById(id)
                .map(ResponseEntity::ok)
                .orElse(ResponseEntity.notFound().build());
    }

    // Get all stickers redeemed by a specific user
    @GetMapping("/user/{userID}")
    public ResponseEntity<List<Sticker>> getStickersByUserID(@PathVariable int userID) {
        List<Sticker> userStickers = stickerService.getStickersByUserID(userID);
        if (userStickers.isEmpty()) {
            return ResponseEntity.noContent().build();
        }
        return ResponseEntity.ok(userStickers);
    }

    // Get a random sticker that the user doesn't already own and add it to their redemption
    @PostMapping("/random")
    public ResponseEntity<Sticker> getRandomStickerForUser(@RequestParam int userID) {
        try {
            Sticker randomSticker = stickerService.getRandomStickerForUser(userID);
            return ResponseEntity.ok(randomSticker);
        } catch (RuntimeException e) {
            return ResponseEntity.badRequest().body(null);
        }
    }

    // Add a new sticker
    @PostMapping("/add")                                                        // Do not use database column names when testing in Postman. mb
    public ResponseEntity<Sticker> addSticker(@RequestBody Sticker sticker) {
        return ResponseEntity.ok(stickerService.addSticker(sticker));
    }

    // Update a sticker
    @PutMapping("/{id}")
    public ResponseEntity<Sticker> updateSticker(@PathVariable int id, @RequestBody Sticker stickerDetails) {
        try {
            return ResponseEntity.ok(stickerService.updateSticker(id, stickerDetails));
        } catch (RuntimeException e) {
            return ResponseEntity.notFound().build();
        }
    }

    // Delete a sticker
    @DeleteMapping("/{id}")
    public ResponseEntity<Void> deleteSticker(@PathVariable int id) {
        stickerService.deleteSticker(id);
        return ResponseEntity.noContent().build();
    }
}
