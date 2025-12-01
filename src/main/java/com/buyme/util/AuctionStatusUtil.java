package com.buyme.util;

import java.math.BigDecimal;
import java.sql.*;
import com.buyme.util.DBUtil;

public class AuctionStatusUtil {

    /**
     * If the auction has passed its end_time and is still open,
     * this will close it and, if appropriate, set winner_id + closing_price.
     */
    public static void closeAuctionIfEnded(int auctionId) throws SQLException {
        try (Connection conn = DBUtil.getConnection()) {
            conn.setAutoCommit(false);

            // 1. Load auction row
            String selectSql =
                    "SELECT status, end_time, reserve_price, current_high, current_high_bidder_id " +
                    "FROM auctions WHERE auction_id = ? FOR UPDATE";

            String status;
            Timestamp endTime;
            BigDecimal reservePrice;
            BigDecimal currentHigh;
            Integer currentHighBidderId;

            try (PreparedStatement ps = conn.prepareStatement(selectSql)) {
                ps.setInt(1, auctionId);
                try (ResultSet rs = ps.executeQuery()) {
                    if (!rs.next()) {
                        conn.rollback();
                        return; // no such auction
                    }
                    status = rs.getString("status");
                    endTime = rs.getTimestamp("end_time");
                    reservePrice = rs.getBigDecimal("reserve_price");
                    currentHigh = rs.getBigDecimal("current_high");
                    int bidder = rs.getInt("current_high_bidder_id");
                    currentHighBidderId = rs.wasNull() ? null : bidder;
                }
            }

            // 2. Only act on open auctions whose end time is in the past
            Timestamp now = new Timestamp(System.currentTimeMillis());
            if (!"open".equals(status) || endTime == null || endTime.after(now)) {
                conn.rollback();
                return;
            }

            Integer winnerId = null;
            BigDecimal closingPrice = null;

            // 3. Decide winner according to spec
            if (currentHigh != null && currentHighBidderId != null) {
                boolean reserveMet = (reservePrice == null) ||
                        (currentHigh.compareTo(reservePrice) >= 0);

                if (reserveMet) {
                    winnerId = currentHighBidderId;
                    closingPrice = currentHigh;
                }
            }

            // 4. Update auction row
            String updateSql =
                    "UPDATE auctions " +
                    "SET status = 'closed', winner_id = ?, closing_price = ? " +
                    "WHERE auction_id = ?";

            try (PreparedStatement ps = conn.prepareStatement(updateSql)) {
                if (winnerId == null) {
                    ps.setNull(1, Types.INTEGER);
                    ps.setNull(2, Types.DECIMAL);
                } else {
                    ps.setInt(1, winnerId);
                    ps.setBigDecimal(2, closingPrice);
                }
                ps.setInt(3, auctionId);
                ps.executeUpdate();
            }

            conn.commit();
        }
    }
}
