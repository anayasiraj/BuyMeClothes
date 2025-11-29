package com.buyme.dao;

import com.buyme.util.DBUtil;

import java.math.BigDecimal;
import java.sql.*;

public class SellerDAO {

    /**
     * Creates a new item + auction for the given seller and returns auction_id.
     */
    public int createAuctionForSeller(
            int sellerId,
            String title,
            String description,
            String brand,
            String size,
            String color,
            String categoryName,
            String photoUrl,
            BigDecimal startPrice,
            BigDecimal bidIncrement,
            BigDecimal reservePrice,
            int durationDays
    ) throws SQLException {

        try (Connection conn = DBUtil.getConnection()) {
            conn.setAutoCommit(false);
            try {
                int catId = ensureCategory(conn, categoryName);
                int itemId = insertItem(conn, sellerId, catId, title, description,
                        brand, size, color, photoUrl);

                Timestamp startTime = new Timestamp(System.currentTimeMillis());
                long millisPerDay = 24L * 60 * 60 * 1000;
                Timestamp endTime =
                        new Timestamp(startTime.getTime() + (long) durationDays * millisPerDay);

                int auctionId = insertAuction(conn, itemId, sellerId, startTime,
                        endTime, startPrice, bidIncrement, reservePrice);

                conn.commit();
                return auctionId;

            } catch (SQLException e) {
                conn.rollback();
                throw e;
            } finally {
                conn.setAutoCommit(true);
            }
        }
    }

    // Look up or create a category by name.
    private int ensureCategory(Connection conn, String categoryName) throws SQLException {
        if (categoryName == null || categoryName.isBlank()) {
            categoryName = "Other";
        }
        categoryName = categoryName.trim();

        String selectSql = "SELECT category_id FROM categories WHERE name = ?";
        try (PreparedStatement ps = conn.prepareStatement(selectSql)) {
            ps.setString(1, categoryName);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1);
                }
            }
        }

        String insertSql = "INSERT INTO categories (name) VALUES (?)";
        try (PreparedStatement ps =
                     conn.prepareStatement(insertSql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setString(1, categoryName);
            ps.executeUpdate();
            try (ResultSet rs = ps.getGeneratedKeys()) {
                if (rs.next()) {
                    return rs.getInt(1);
                }
            }
        }

        throw new SQLException("Unable to create or find category.");
    }

    // Insert into items and return item_id.
    private int insertItem(Connection conn,
                           int sellerId,
                           int categoryId,
                           String title,
                           String description,
                           String brand,
                           String size,
                           String color,
                           String photoUrl) throws SQLException {

        String sql = """
            INSERT INTO items
              (seller_id, category_id, title, description,
               brand, size, color, photo_url1)
            VALUES (?, ?, ?, ?, ?, ?, ?, ?)
            """;

        try (PreparedStatement ps =
                     conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {

            ps.setInt(1, sellerId);
            ps.setInt(2, categoryId);
            ps.setString(3, title);
            ps.setString(4, description);
            ps.setString(5, brand);
            ps.setString(6, size);
            ps.setString(7, color);
            ps.setString(8, photoUrl);
            ps.executeUpdate();

            try (ResultSet rs = ps.getGeneratedKeys()) {
                if (rs.next()) {
                    return rs.getInt(1);
                }
            }
        }

        throw new SQLException("Unable to insert item.");
    }

    // Insert into auctions and return auction_id.
    private int insertAuction(Connection conn,
                              int itemId,
                              int sellerId,
                              Timestamp startTime,
                              Timestamp endTime,
                              BigDecimal startPrice,
                              BigDecimal bidIncrement,
                              BigDecimal reservePrice) throws SQLException {

        String sql = """
            INSERT INTO auctions
              (item_id, seller_id, status, start_time, end_time,
               start_price, bid_increment, reserve_price)
            VALUES (?, ?, 'open', ?, ?, ?, ?, ?)
            """;

        try (PreparedStatement ps =
                     conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {

            ps.setInt(1, itemId);
            ps.setInt(2, sellerId);
            ps.setTimestamp(3, startTime);
            ps.setTimestamp(4, endTime);
            ps.setBigDecimal(5, startPrice);
            ps.setBigDecimal(6, bidIncrement);

            if (reservePrice != null) {
                ps.setBigDecimal(7, reservePrice);
            } else {
                ps.setNull(7, Types.DECIMAL);
            }

            ps.executeUpdate();

            try (ResultSet rs = ps.getGeneratedKeys()) {
                if (rs.next()) {
                    return rs.getInt(1);
                }
            }
        }

        throw new SQLException("Unable to insert auction.");
    }
}
