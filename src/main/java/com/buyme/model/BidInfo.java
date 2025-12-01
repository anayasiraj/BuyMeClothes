package com.buyme.model;

import java.math.BigDecimal;
import java.sql.Timestamp;

public class BidInfo {
    private int bidId;
    private int auctionId;
    private String bidderUsername;
    private BigDecimal amount;
    private Timestamp bidTime;

    public int getBidId() {
        return bidId;
    }
    public void setBidId(int bidId) {
        this.bidId = bidId;
    }
    public int getAuctionId() {
        return auctionId;
    }
    public void setAuctionId(int auctionId) {
        this.auctionId = auctionId;
    }
    public String getBidderUsername() {
        return bidderUsername;
    }
    public void setBidderUsername(String bidderUsername) {
        this.bidderUsername = bidderUsername;
    }
    public BigDecimal getAmount() {
        return amount;
    }
    public void setAmount(BigDecimal amount) {
        this.amount = amount;
    }
    public Timestamp getBidTime() {
        return bidTime;
    }
    public void setBidTime(Timestamp bidTime) {
        this.bidTime = bidTime;
    }
}
