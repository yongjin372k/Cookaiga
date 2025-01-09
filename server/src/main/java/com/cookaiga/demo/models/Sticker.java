package com.cookaiga.demo.models;

import jakarta.persistence.*;
import lombok.Data;


@Entity
@Table(name = "sticker")
@Data

public class Sticker {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "stickerID")
    private int stickerID;

    @Column(name = "stickerName", nullable = false)
    private String stickerName;

    @Column(name = "stickerDesc", nullable = false, columnDefinition = "TEXT")
    private String stickerDesc;

    @Column(name = "points_required", nullable = false)
    private int pointsReq;

    @Column(name = "file_path", nullable = false)
    private String filePath;

    public Sticker() {}

    public Sticker(
        int stickerID,
        String stickerName,
        String stickerDesc,
        int pointsReq,
        String filePath
    ) {
        this.stickerID = stickerID;
        this.stickerName = stickerName;
        this.stickerDesc = stickerDesc;
        this.pointsReq = pointsReq;
        this.filePath = filePath;
    }


    public int getStickerID() {
        return this.stickerID;
    }

    public void setStickerID(int stickerID) {
        this.stickerID = stickerID;
    }

    public String getStickerName() {
        return this.stickerName;
    }

    public void setStickerName(String stickerName) {
        this.stickerName = stickerName;
    }

    public String getStickerDesc() {
        return this.stickerDesc;
    }

    public void setStickerDesc(String stickerDesc) {
        this.stickerDesc = stickerDesc;
    }

    public int getPointsReq() {
        return this.pointsReq;
    }

    public void setPointsReq(int pointsReq) {
        this.pointsReq = pointsReq;
    }

    public String getFilePath() {
        return this.filePath;
    }

    public void setFilePath(String filePath) {
        this.filePath = filePath;
    }


    @Override
    public String toString() {
        return "{" +
            " stickerID='" + getStickerID() + "'" +
            ", stickerName='" + getStickerName() + "'" +
            ", stickerDesc='" + getStickerDesc() + "'" +
            ", pointsReq='" + getPointsReq() + "'" +
            ", filePath='" + getFilePath() + "'" +
            "}";
    }

}
