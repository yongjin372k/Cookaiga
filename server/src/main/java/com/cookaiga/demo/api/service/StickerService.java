package com.cookaiga.demo.api.service;

import com.cookaiga.demo.models.Sticker;
import com.cookaiga.demo.api.repository.StickerRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Optional;

@Service
public class StickerService {

    @Autowired
    private StickerRepository stickerRepository;

    // Retrieve all stickers
    public List<Sticker> getAllStickers() {
        return stickerRepository.findAll();
    }

    // Retrieve a single sticker by ID
    public Optional<Sticker> getStickerById(int stickerID) {
        return stickerRepository.findById(stickerID);
    }

    // Add a new sticker
    public Sticker addSticker(Sticker sticker) {
        return stickerRepository.save(sticker);
    }

    // Update an existing sticker
    public Sticker updateSticker(int stickerID, Sticker stickerDetails) {
        return stickerRepository.findById(stickerID).map(sticker -> {
            sticker.setStickerName(stickerDetails.getStickerName());
            sticker.setStickerDesc(stickerDetails.getStickerDesc());
            sticker.setPointsReq(stickerDetails.getPointsReq());
            sticker.setFilePath(stickerDetails.getFilePath());
            return stickerRepository.save(sticker);
        }).orElseThrow(() -> new RuntimeException("Sticker not found with ID: " + stickerID));
    }

    // Delete a sticker by ID
    public void deleteSticker(int stickerID) {
        stickerRepository.deleteById(stickerID);
    }
}
