package com.buyme.dao;

import com.buyme.model.AuctionDetail;
import com.buyme.model.AuctionSummary;
import com.buyme.model.BidSummary;
import com.buyme.util.DBUtil;

import java.math.BigDecimal;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class AuctionDAO {

    // ------------------------------------------------------------------
    // 1. Browse page – open auctions (no filters)
    // ------------------------------------------------------------------
    public List<AuctionSummary> getOpenAuctions() throws SQLException {
        List<AuctionSummary> list = new ArrayList<>();

        String sql = """
            SELECT a.auction_id,
                   i.title,
                   i.photo_url1,
                   i.brand,
                   i.size,
                   i.color,
                   c.name AS category_name,
                   a.current_high,
                   a.start_price,
                   a.end_time
            FROM auctions a
            JOIN items i      ON a.item_id = i.item_id
            JOIN categories c ON i.category_id = c.category_id
            WHERE a.status = 'open'
            ORDER BY a.end_time ASC
            """;

        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                AuctionSummary a = new AuctionSummary();
                a.setAuctionId(rs.getInt("auction_id"));
                a.setTitle(rs.getString("title"));
                a.setBrand(rs.getString("brand"));
                a.setSize(rs.getString("size"));
                a.setColor(rs.getString("color"));
                a.setPhotoUrl(rs.getString("photo_url1"));
                a.setCategoryName(rs.getString("category_name"));
                a.setCurrentHigh(rs.getBigDecimal("current_high"));
                a.setStartPrice(rs.getBigDecimal("start_price"));
                a.setEndTime(rs.getTimestamp("end_time"));
                list.add(a);
            }
        }

        return list;
    }

    // ------------------------------------------------------------------
    // 1b. Browse page – search + filters
    //      q        : text in title/brand
    //      size     : exact match
    //      color    : LIKE
    //      category : category name LIKE
    //      minPrice/maxPrice : price range on IFNULL(current_high, start_price)
    // ------------------------------------------------------------------
    public List<AuctionSummary> searchAuctions(
            String q,
            String size,
            String color,
            String category,
            String minPrice,
            String maxPrice
    ) throws SQLException {

        List<AuctionSummary> list = new ArrayList<>();

        StringBuilder sql = new StringBuilder("""
            SELECT a.auction_id,
                   i.title,
                   i.photo_url1,
                   i.brand,
                   i.size,
                   i.color,
                   c.name AS category_name,
                   a.current_high,
                   a.start_price,
                   a.end_time
            FROM auctions a
            JOIN items i      ON a.item_id = i.item_id
            JOIN categories c ON i.category_id = c.category_id
            WHERE a.status = 'open'
            """);

        List<Object> params = new ArrayList<>();

        if (q != null && !q.isBlank()) {
            sql.append(" AND (i.title LIKE ? OR i.brand LIKE ?) ");
            String pattern = "%" + q.trim() + "%";
            params.add(pattern);
            params.add(pattern);
        }

        if (size != null && !size.isBlank()) {
            sql.append(" AND i.size = ? ");
            params.add(size.trim());
        }

        if (color != null && !color.isBlank()) {
            sql.append(" AND i.color LIKE ? ");
            params.add("%" + color.trim() + "%");
        }

        if (category != null && !category.isBlank()) {
            sql.append(" AND c.name LIKE ? ");
            params.add("%" + category.trim() + "%");
        }

        // Filter on display price = current_high if present, else start_price
        if (minPrice != null && !minPrice.isBlank()) {
            try {
                Double.valueOf(minPrice.trim()); // validate
                sql.append(" AND IFNULL(a.current_high, a.start_price) >= ? ");
                params.add(new BigDecimal(minPrice.trim()));
            } catch (NumberFormatException ignore) {
                // ignore invalid input
            }
        }
        if (maxPrice != null && !maxPrice.isBlank()) {
            try {
                Double.valueOf(maxPrice.trim());
                sql.append(" AND IFNULL(a.current_high, a.start_price) <= ? ");
                params.add(new BigDecimal(maxPrice.trim()));
            } catch (NumberFormatException ignore) {
                // ignore invalid input
            }
        }

        sql.append(" ORDER BY a.end_time ASC ");

        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql.toString())) {

            for (int i = 0; i < params.size(); i++) {
                ps.setObject(i + 1, params.get(i));
            }

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    AuctionSummary a = new AuctionSummary();
                    a.setAuctionId(rs.getInt("auction_id"));
                    a.setTitle(rs.getString("title"));
                    a.setBrand(rs.getString("brand"));
                    a.setSize(rs.getString("size"));
                    a.setColor(rs.getString("color"));
                    a.setPhotoUrl(rs.getString("photo_url1"));
                    a.setCategoryName(rs.getString("category_name"));
                    a.setCurrentHigh(rs.getBigDecimal("current_high"));
                    a.setStartPrice(rs.getBigDecimal("start_price"));
                    a.setEndTime(rs.getTimestamp("end_time"));
                    list.add(a);
                }
            }
        }

        return list;
    }

    // ------------------------------------------------------------------
    // 2. Auction details page
    // ------------------------------------------------------------------
    public AuctionDetail getAuctionDetail(int auctionId) {
        String sql = """
         SELECT a.auction_id,
                a.start_time,
                a.end_time,
                a.start_price,
                a.current_high,
                a.bid_increment,
                a.reserve_price,
                i.title,
                i.description,
                i.brand,
                i.size,
                i.color,
                i.photo_url1,
                i.photo_url2,
                i.photo_url3,
                u.username AS seller_username
         FROM auctions a
         JOIN items i ON a.item_id = i.item_id
         LEFT JOIN users u ON a.seller_id = u.user_id
         WHERE a.auction_id = ?
         """;

        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, auctionId);

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    AuctionDetail d = new AuctionDetail();
                    d.setAuctionId(rs.getInt("auction_id"));
                    d.setStartTime(rs.getTimestamp("start_time"));
                    d.setEndTime(rs.getTimestamp("end_time"));
                    d.setStartPrice(rs.getBigDecimal("start_price"));
                    d.setCurrentHigh(rs.getBigDecimal("current_high"));
                    d.setBidIncrement(rs.getBigDecimal("bid_increment"));
                    d.setReservePrice(rs.getBigDecimal("reserve_price"));

                    d.setTitle(rs.getString("title"));
                    d.setDescription(rs.getString("description"));
                    d.setBrand(rs.getString("brand"));
                    d.setSize(rs.getString("size"));
                    d.setColor(rs.getString("color"));
                    d.setPhotoUrl1(rs.getString("photo_url1"));
                    d.setPhotoUrl2(rs.getString("photo_url2"));
                    d.setPhotoUrl3(rs.getString("photo_url3"));

                    String seller = rs.getString("seller_username");
                    if (seller == null || seller.isBlank()) {
                        seller = "Unknown seller";
                    }
                    d.setSellerUsername(seller);

                    return d;
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }

        return null;
    }

    // ------------------------------------------------------------------
    // 3. Full bid history for an auction (no LIMIT)
    // ------------------------------------------------------------------
    public List<BidSummary> getRecentBids(int auctionId) {
        List<BidSummary> bids = new ArrayList<>();

        String sql = """
            SELECT b.amount, b.bid_time, u.username
            FROM bids b
            JOIN users u ON b.bidder_id = u.user_id
            WHERE b.auction_id = ?
            ORDER BY b.bid_time DESC
            """;

        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, auctionId);

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    BidSummary b = new BidSummary();
                    b.setAmount(rs.getBigDecimal("amount"));
                    b.setBidTime(rs.getTimestamp("bid_time"));
                    b.setBidderUsername(rs.getString("username"));
                    bids.add(b);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }

        return bids;
    }

    // ------------------------------------------------------------------
    // 4. Auto-bid: create or update max_limit for a user
    // ------------------------------------------------------------------
    public void upsertAutoBid(int auctionId, int bidderId, BigDecimal maxLimit) throws SQLException {
        String sql = """
            INSERT INTO auto_bids (auction_id, bidder_id, max_limit, active_flag)
            VALUES (?, ?, ?, 1)
            ON DUPLICATE KEY UPDATE
                max_limit = VALUES(max_limit),
                active_flag = 1
            """;

        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, auctionId);
            ps.setInt(2, bidderId);
            ps.setBigDecimal(3, maxLimit);
            ps.executeUpdate();
        }
    }

    // ------------------------------------------------------------------
    // 5. Place a bid (manual) + run auto-bid loop
    // ------------------------------------------------------------------
    public boolean placeBid(int auctionId, int bidderId, BigDecimal bidAmount) throws SQLException {
        String checkSql = """
            SELECT status, current_high, start_price, bid_increment, end_time
            FROM auctions
            WHERE auction_id = ?
            """;

        try (Connection conn = DBUtil.getConnection()) {
            conn.setAutoCommit(false);

            try {
                // ---- 5.1 Validate auction + minimum bid ----
                String status;
                BigDecimal currentHigh;
                BigDecimal startPrice;
                BigDecimal bidIncrement;
                Timestamp endTime;

                try (PreparedStatement ps = conn.prepareStatement(checkSql)) {
                    ps.setInt(1, auctionId);
                    try (ResultSet rs = ps.executeQuery()) {
                        if (!rs.next()) {
                            conn.rollback();
                            return false;
                        }

                        status = rs.getString("status");
                        currentHigh = rs.getBigDecimal("current_high");
                        startPrice = rs.getBigDecimal("start_price");
                        bidIncrement = rs.getBigDecimal("bid_increment");
                        endTime = rs.getTimestamp("end_time");
                    }
                }

                if (!"open".equalsIgnoreCase(status)) {
                    conn.rollback();
                    return false;
                }
                if (endTime != null &&
                        endTime.before(new Timestamp(System.currentTimeMillis()))) {
                    conn.rollback();
                    return false;         // auction expired
                }

                BigDecimal base = (currentHigh != null) ? currentHigh : startPrice;
                BigDecimal minBid = base.add(bidIncrement);

                if (bidAmount.compareTo(minBid) < 0) {
                    conn.rollback();
                    return false;         // too low
                }

                // ---- 5.2 Insert the manual bid ----
                String insertBidSql =
                        "INSERT INTO bids (auction_id, bidder_id, amount, is_auto) VALUES (?, ?, ?, 0)";
                try (PreparedStatement ps = conn.prepareStatement(insertBidSql)) {
                    ps.setInt(1, auctionId);
                    ps.setInt(2, bidderId);
                    ps.setBigDecimal(3, bidAmount);
                    ps.executeUpdate();
                }

                // ---- 5.3 Update auction with this new high ----
                String updateAuctionSql =
                        "UPDATE auctions SET current_high = ?, current_high_bidder_id = ? " +
                        "WHERE auction_id = ?";
                try (PreparedStatement ps = conn.prepareStatement(updateAuctionSql)) {
                    ps.setBigDecimal(1, bidAmount);
                    ps.setInt(2, bidderId);
                    ps.setInt(3, auctionId);
                    ps.executeUpdate();
                }

                // ---- 5.4 Run auto-bid logic to see if anyone outbids ----
                applyAutoBids(conn, auctionId);

                conn.commit();
                return true;

            } catch (SQLException e) {
                conn.rollback();
                throw e;
            } finally {
                conn.setAutoCommit(true);
            }
        }
    }

    // ------------------------------------------------------------------
    // 6. Auto-bid loop (proxy bidding)
    // ------------------------------------------------------------------
    private void applyAutoBids(Connection conn, int auctionId) throws SQLException {
        while (true) {
            // Read current auction state
            String auctionSql = """
                SELECT current_high, start_price, bid_increment,
                       current_high_bidder_id, status
                FROM auctions
                WHERE auction_id = ?
                FOR UPDATE
                """;

            BigDecimal currentHigh;
            BigDecimal startPrice;
            BigDecimal bidIncrement;
            Integer currentHighBidderId;
            String status;

            try (PreparedStatement ps = conn.prepareStatement(auctionSql)) {
                ps.setInt(1, auctionId);
                try (ResultSet rs = ps.executeQuery()) {
                    if (!rs.next()) return; // no such auction
                    currentHigh = rs.getBigDecimal("current_high");
                    startPrice = rs.getBigDecimal("start_price");
                    bidIncrement = rs.getBigDecimal("bid_increment");
                    currentHighBidderId = (Integer) rs.getObject("current_high_bidder_id");
                    status = rs.getString("status");
                }
            }

            if (!"open".equalsIgnoreCase(status)) {
                return;
            }

            BigDecimal base = (currentHigh != null) ? currentHigh : startPrice;
            BigDecimal minNext = base.add(bidIncrement);

            // Find best auto-bidder who can outbid the current price
            String autoSql = """
                SELECT bidder_id, max_limit
                FROM auto_bids
                WHERE auction_id = ?
                  AND active_flag = 1
                  AND max_limit >= ?
                  AND bidder_id <> IFNULL(?, -1)
                ORDER BY max_limit DESC
                LIMIT 1
                """;

            Integer autoBidderId = null;
            BigDecimal maxLimit = null;

            try (PreparedStatement ps = conn.prepareStatement(autoSql)) {
                ps.setInt(1, auctionId);
                ps.setBigDecimal(2, minNext);
                if (currentHighBidderId == null) {
                    ps.setNull(3, Types.INTEGER);
                } else {
                    ps.setInt(3, currentHighBidderId);
                }

                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        autoBidderId = rs.getInt("bidder_id");
                        maxLimit = rs.getBigDecimal("max_limit");
                    }
                }
            }

            // No auto-bidder can beat the current price → stop.
            if (autoBidderId == null) {
                return;
            }

            // Amount that the auto-bidder will bid
            BigDecimal newAmount = minNext;
            if (newAmount.compareTo(maxLimit) > 0) {
                newAmount = maxLimit;
            }

            // Insert automatic bid
            String insertBidSql =
                    "INSERT INTO bids (auction_id, bidder_id, amount, is_auto) VALUES (?, ?, ?, 1)";
            try (PreparedStatement ps = conn.prepareStatement(insertBidSql)) {
                ps.setInt(1, auctionId);
                ps.setInt(2, autoBidderId);
                ps.setBigDecimal(3, newAmount);
                ps.executeUpdate();
            }

            // Update auction with new high
            String updateAuctionSql =
                    "UPDATE auctions SET current_high = ?, current_high_bidder_id = ? " +
                    "WHERE auction_id = ?";
            try (PreparedStatement ps = conn.prepareStatement(updateAuctionSql)) {
                ps.setBigDecimal(1, newAmount);
                ps.setInt(2, autoBidderId);
                ps.setInt(3, auctionId);
                ps.executeUpdate();
            }

            // Loop again in case another auto-bidder can now outbid this one
        }
    }

    // ------------------------------------------------------------------
    // 7. PHASE 3C: auctions a user has bid on
    // ------------------------------------------------------------------
    public List<AuctionSummary> getAuctionsUserHasBidOn(int userId) throws SQLException {
        List<AuctionSummary> list = new ArrayList<>();

        String sql = """
            SELECT DISTINCT a.auction_id,
                   i.title,
                   i.photo_url1,
                   i.brand,
                   i.size,
                   i.color,
                   c.name AS category_name,
                   a.current_high,
                   a.start_price,
                   a.end_time
            FROM bids b
            JOIN auctions a   ON b.auction_id = a.auction_id
            JOIN items i      ON a.item_id = i.item_id
            JOIN categories c ON i.category_id = c.category_id
            WHERE b.bidder_id = ?
            ORDER BY a.end_time DESC
            """;

        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, userId);

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    AuctionSummary a = new AuctionSummary();
                    a.setAuctionId(rs.getInt("auction_id"));
                    a.setTitle(rs.getString("title"));
                    a.setBrand(rs.getString("brand"));
                    a.setSize(rs.getString("size"));
                    a.setColor(rs.getString("color"));
                    a.setPhotoUrl(rs.getString("photo_url1"));
                    a.setCategoryName(rs.getString("category_name"));
                    a.setCurrentHigh(rs.getBigDecimal("current_high"));
                    a.setStartPrice(rs.getBigDecimal("start_price"));
                    a.setEndTime(rs.getTimestamp("end_time"));
                    list.add(a);
                }
            }
        }

        return list;
    }

    // ------------------------------------------------------------------
    // 8. PHASE 3C: auctions a user is selling
    // ------------------------------------------------------------------
    public List<AuctionSummary> getAuctionsUserIsSelling(int userId) throws SQLException {
        List<AuctionSummary> list = new ArrayList<>();

        String sql = """
            SELECT a.auction_id,
                   i.title,
                   i.photo_url1,
                   i.brand,
                   i.size,
                   i.color,
                   c.name AS category_name,
                   a.current_high,
                   a.start_price,
                   a.end_time
            FROM auctions a
            JOIN items i      ON a.item_id = i.item_id
            JOIN categories c ON i.category_id = c.category_id
            WHERE a.seller_id = ?
            ORDER BY a.end_time DESC
            """;

        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, userId);

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    AuctionSummary a = new AuctionSummary();
                    a.setAuctionId(rs.getInt("auction_id"));
                    a.setTitle(rs.getString("title"));
                    a.setBrand(rs.getString("brand"));
                    a.setSize(rs.getString("size"));
                    a.setColor(rs.getString("color"));
                    a.setPhotoUrl(rs.getString("photo_url1"));
                    a.setCategoryName(rs.getString("category_name"));
                    a.setCurrentHigh(rs.getBigDecimal("current_high"));
                    a.setStartPrice(rs.getBigDecimal("start_price"));
                    a.setEndTime(rs.getTimestamp("end_time"));
                    list.add(a);
                }
            }
        }

        return list;
    }

    // ------------------------------------------------------------------
    // 9. PHASE 3D: Similar auctions in the last month
    // ------------------------------------------------------------------
    public List<AuctionSummary> getSimilarAuctions(int auctionId) throws SQLException {
        List<AuctionSummary> list = new ArrayList<>();

        // 1) Get category (and optionally size/brand) for this auction's item
        String infoSql = """
            SELECT i.category_id, i.size, i.brand
            FROM auctions a
            JOIN items i ON a.item_id = i.item_id
            WHERE a.auction_id = ?
            """;

        Integer categoryId = null;

        try (Connection conn = DBUtil.getConnection();
             PreparedStatement psInfo = conn.prepareStatement(infoSql)) {

            psInfo.setInt(1, auctionId);
            try (ResultSet rs = psInfo.executeQuery()) {
                if (!rs.next()) {
                    return list; // no such auction
                }
                categoryId = rs.getInt("category_id");
            }
        }

        if (categoryId == null) {
            return list;
        }

        String similarSql = """
            SELECT a.auction_id,
                   i.title,
                   i.photo_url1,
                   i.brand,
                   i.size,
                   i.color,
                   c.name AS category_name,
                   a.current_high,
                   a.start_price,
                   a.end_time
            FROM auctions a
            JOIN items i      ON a.item_id = i.item_id
            JOIN categories c ON i.category_id = c.category_id
            WHERE a.auction_id <> ?
              AND i.category_id = ?
              AND a.end_time >= DATE_SUB(NOW(), INTERVAL 50 DAY)
            ORDER BY a.end_time DESC
            LIMIT 8
            """;

        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(similarSql)) {

            ps.setInt(1, auctionId);
            ps.setInt(2, categoryId);

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    AuctionSummary a = new AuctionSummary();
                    a.setAuctionId(rs.getInt("auction_id"));
                    a.setTitle(rs.getString("title"));
                    a.setBrand(rs.getString("brand"));
                    a.setSize(rs.getString("size"));
                    a.setColor(rs.getString("color"));
                    a.setPhotoUrl(rs.getString("photo_url1"));
                    a.setCategoryName(rs.getString("category_name"));
                    a.setCurrentHigh(rs.getBigDecimal("current_high"));
                    a.setStartPrice(rs.getBigDecimal("start_price"));
                    a.setEndTime(rs.getTimestamp("end_time"));
                    list.add(a);
                }
            }
        }

        return list;
    }

 // ------------------------------------------------------------------
 // 10. Create a new item + auction (used by SellServlet)
//      - Sets status='open'
//      - reservePrice may be null
 // ------------------------------------------------------------------
    public int createAuctionWithItem(
            int sellerId,
            String title,
            String description,
            String brand,
            String size,
            String color,
            int categoryId,
            BigDecimal startPrice,
            BigDecimal bidIncrement,
            BigDecimal reservePrice,
            String photoUrl1,
            Timestamp endTime
    ) throws SQLException {

        String insertItemSql = """
            INSERT INTO items (
                seller_id,
                category_id,
                title,
                description,
                item_condition,
                base_price,
                brand,
                size,
                color,
                photo_url1,
                photo_url2,
                photo_url3
            )
            VALUES (?, ?, ?, ?, NULL, NULL, ?, ?, ?, ?, NULL, NULL)
            """;

        String insertAuctionSql = """
            INSERT INTO auctions (
                item_id,
                seller_id,
                status,
                start_time,
                end_time,
                start_price,
                bid_increment,
                reserve_price,
                current_high,
                current_high_bidder_id,
                winner_id,
                closing_price
            )
            VALUES (?, ?, 'open', NOW(), ?, ?, ?, ?, NULL, NULL, NULL, NULL)
            """;

        try (Connection conn = DBUtil.getConnection()) {
            conn.setAutoCommit(false);

            try {
                // Insert item
                int itemId;
                try (PreparedStatement ps = conn.prepareStatement(
                        insertItemSql, Statement.RETURN_GENERATED_KEYS)) {

                    ps.setInt(1, sellerId);
                    ps.setInt(2, categoryId);
                    ps.setString(3, title);
                    ps.setString(4, description);
                    ps.setString(5, brand);
                    ps.setString(6, size);
                    ps.setString(7, color);
                    ps.setString(8, photoUrl1);

                    ps.executeUpdate();

                    try (ResultSet rs = ps.getGeneratedKeys()) {
                        rs.next();
                        itemId = rs.getInt(1);
                    }
                }

                // Insert auction
                int auctionId;
                try (PreparedStatement ps = conn.prepareStatement(
                        insertAuctionSql, Statement.RETURN_GENERATED_KEYS)) {

                    ps.setInt(1, itemId);
                    ps.setInt(2, sellerId);
                    ps.setTimestamp(3, endTime);
                    ps.setBigDecimal(4, startPrice);
                    ps.setBigDecimal(5, bidIncrement);

                    if (reservePrice != null)
                        ps.setBigDecimal(6, reservePrice);
                    else
                        ps.setNull(6, Types.DECIMAL);

                    ps.executeUpdate();

                    try (ResultSet rs = ps.getGeneratedKeys()) {
                        rs.next();
                        auctionId = rs.getInt(1);
                    }
                }

                conn.commit();
                return auctionId;

            } catch (SQLException e) {
                conn.rollback();
                throw e;
            }
        }
    }

    
    
 // ------------------------------------------------------------
 // Delete auction + item + bids (for reps/admin)
 // ------------------------------------------------------------
 public boolean deleteAuction(int auctionId) throws SQLException {

     String deleteBidsSql = "DELETE FROM bids WHERE auction_id = ?";
     String deleteAutoSql = "DELETE FROM auto_bids WHERE auction_id = ?";
     String getItemSql    = "SELECT item_id FROM auctions WHERE auction_id = ?";
     String deleteAuctionSql = "DELETE FROM auctions WHERE auction_id = ?";
     String deleteItemSql = "DELETE FROM items WHERE item_id = ?";

     try (Connection conn = DBUtil.getConnection()) {

         conn.setAutoCommit(false);

         try {
             // 1. Get item_id (needed for deleting from items)
             int itemId = -1;
             try (PreparedStatement ps = conn.prepareStatement(getItemSql)) {
                 ps.setInt(1, auctionId);
                 try (ResultSet rs = ps.executeQuery()) {
                     if (!rs.next()) {
                         conn.rollback();
                         return false;
                     }
                     itemId = rs.getInt("item_id");
                 }
             }

             // 2. Delete all bids for auction
             try (PreparedStatement ps = conn.prepareStatement(deleteBidsSql)) {
                 ps.setInt(1, auctionId);
                 ps.executeUpdate();
             }

             // 3. Delete auto-bids
             try (PreparedStatement ps = conn.prepareStatement(deleteAutoSql)) {
                 ps.setInt(1, auctionId);
                 ps.executeUpdate();
             }

             // 4. Delete auction row
             try (PreparedStatement ps = conn.prepareStatement(deleteAuctionSql)) {
                 ps.setInt(1, auctionId);
                 ps.executeUpdate();
             }

             // 5. Delete item row
             try (PreparedStatement ps = conn.prepareStatement(deleteItemSql)) {
                 ps.setInt(1, itemId);
                 ps.executeUpdate();
             }

             conn.commit();
             return true;

         } catch (SQLException ex) {
             conn.rollback();
             throw ex;
         } finally {
             conn.setAutoCommit(true);
         }
     }
 }
 
 /**
  * Delete an auction and its related bids / auto_bids.
  * Returns true if an auction row was actually deleted.
  */
 public boolean deleteAuctionById(int auctionId) throws SQLException {
     String deleteBidsSql      = "DELETE FROM bids WHERE auction_id = ?";
     String deleteAutoBidsSql  = "DELETE FROM auto_bids WHERE auction_id = ?";
     String deleteAuctionSql   = "DELETE FROM auctions WHERE auction_id = ?";

     try (Connection conn = DBUtil.getConnection()) {
         conn.setAutoCommit(false);
         try {
             try (PreparedStatement ps = conn.prepareStatement(deleteBidsSql)) {
                 ps.setInt(1, auctionId);
                 ps.executeUpdate();
             }

             try (PreparedStatement ps = conn.prepareStatement(deleteAutoBidsSql)) {
                 ps.setInt(1, auctionId);
                 ps.executeUpdate();
             }

             int affected;
             try (PreparedStatement ps = conn.prepareStatement(deleteAuctionSql)) {
                 ps.setInt(1, auctionId);
                 affected = ps.executeUpdate();
             }

             conn.commit();
             return affected > 0;
         } catch (SQLException e) {
             conn.rollback();
             throw e;
         } finally {
             conn.setAutoCommit(true);
         }
     }
 }


}
