package com.buyme.dao;

import com.buyme.model.Alert;
import com.buyme.model.AuctionSummary;
import com.buyme.util.DBUtil;

import java.math.BigDecimal;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class AlertDAO {

    // Get all alerts for a given user (JOIN categories to show category name)
    public List<Alert> getAlertsForUser(int userId) throws SQLException {
        List<Alert> list = new ArrayList<>();

        String sql = """
            SELECT a.alert_id,
                   a.user_id,
                   a.alert_name,
                   a.color_pref,
                   a.size_pref,
                   a.keyword,
                   a.min_price,
                   a.max_price,
                   a.category_id,
                   a.created_at,
                   c.name AS category_name
            FROM alerts a
            LEFT JOIN categories c ON a.category_id = c.category_id
            WHERE a.user_id = ?
            ORDER BY a.created_at DESC
            """;

        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, userId);

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Alert alert = new Alert();
                    alert.setAlertId(rs.getInt("alert_id"));
                    alert.setUserId(rs.getInt("user_id"));
                    alert.setAlertName(rs.getString("alert_name"));
                    alert.setColorPref(rs.getString("color_pref"));
                    alert.setSizePref(rs.getString("size_pref"));
                    alert.setKeyword(rs.getString("keyword"));
                    alert.setMinPrice(rs.getBigDecimal("min_price"));
                    alert.setMaxPrice(rs.getBigDecimal("max_price"));
                    alert.setCategoryId((Integer) rs.getObject("category_id"));
                    alert.setCategoryName(rs.getString("category_name"));
                    alert.setCreatedAt(rs.getTimestamp("created_at"));
                    list.add(alert);
                }
            }
        }

        return list;
    }

    // Create a new alert
    public void createAlert(Alert alert) throws SQLException {
        String sql = """
            INSERT INTO alerts
                (user_id, alert_name, color_pref, size_pref,
                 keyword, min_price, max_price, category_id)
            VALUES (?, ?, ?, ?, ?, ?, ?, ?)
            """;

        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, alert.getUserId());
            ps.setString(2, alert.getAlertName());
            ps.setString(3, alert.getColorPref());
            ps.setString(4, alert.getSizePref());
            ps.setString(5, alert.getKeyword());

            if (alert.getMinPrice() != null) {
                ps.setBigDecimal(6, alert.getMinPrice());
            } else {
                ps.setNull(6, Types.DECIMAL);
            }

            if (alert.getMaxPrice() != null) {
                ps.setBigDecimal(7, alert.getMaxPrice());
            } else {
                ps.setNull(7, Types.DECIMAL);
            }

            if (alert.getCategoryId() != null) {
                ps.setInt(8, alert.getCategoryId());
            } else {
                ps.setNull(8, Types.INTEGER);
            }

            ps.executeUpdate();
        }
    }

    // Delete one alert (safety: ensure it belongs to this user)
    public void deleteAlert(int alertId, int userId) throws SQLException {
        String sql = "DELETE FROM alerts WHERE alert_id = ? AND user_id = ?";

        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, alertId);
            ps.setInt(2, userId);
            ps.executeUpdate();
        }
    }

    // ---------------------------------------------------------------------
    // Helper: check if a given auction matches a given alert's preferences
    // ---------------------------------------------------------------------
    public boolean matchesAuction(AuctionSummary auction, Alert alert) {
        if (auction == null || alert == null) return false;

        // 1) Price range: use display price = current_high or start_price
        BigDecimal price = (auction.getCurrentHigh() != null)
                ? auction.getCurrentHigh()
                : auction.getStartPrice();

        if (price != null) {
            BigDecimal min = alert.getMinPrice();
            BigDecimal max = alert.getMaxPrice();

            if (min != null && price.compareTo(min) < 0) {
                return false;
            }
            if (max != null && price.compareTo(max) > 0) {
                return false;
            }
        }

        // 2) Size
        String sizePref = safe(alert.getSizePref());
        if (!sizePref.isEmpty()) {
            String auctionSize = safe(auction.getSize());
            if (auctionSize.isEmpty() || !auctionSize.equalsIgnoreCase(sizePref)) {
                return false;
            }
        }

        // 3) Color (substring match, case-insensitive)
        String colorPref = safe(alert.getColorPref());
        if (!colorPref.isEmpty()) {
            String auctionColor = safe(auction.getColor());
            if (auctionColor.isEmpty()
                    || !auctionColor.toLowerCase().contains(colorPref.toLowerCase())) {
                return false;
            }
        }

        // 4) Keyword in title or brand
        String keyword = safe(alert.getKeyword());
        if (!keyword.isEmpty()) {
            String title = safe(auction.getTitle());
            String brand = safe(auction.getBrand());
            String haystack = (title + " " + brand).toLowerCase();
            if (!haystack.contains(keyword.toLowerCase())) {
                return false;
            }
        }

        // 5) Category (match by category name, since Alert has categoryName)
        Integer alertCategoryId = alert.getCategoryId();
        String alertCategoryName = safe(alert.getCategoryName());
        if (alertCategoryId != null || !alertCategoryName.isEmpty()) {
            String auctionCategory = safe(auction.getCategoryName());
            if (auctionCategory.isEmpty()
                    || !auctionCategory.equalsIgnoreCase(alertCategoryName)) {
                return false;
            }
        }

        return true;
    }

    private String safe(String s) {
        return (s == null) ? "" : s.trim();
    }
}
