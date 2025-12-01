package com.buyme.servlet;

import com.buyme.util.DBUtil;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;
import java.math.BigDecimal;
import java.sql.*;

@WebServlet("/rep/deleteBid")
public class DeleteBidServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request,
                          HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || !"cust_rep".equals(session.getAttribute("role"))) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        String bidIdParam = request.getParameter("bidId");
        String auctionIdParam = request.getParameter("auctionId");

        if (bidIdParam == null || auctionIdParam == null) {
            response.sendRedirect(request.getContextPath() + "/rep/bids");
            return;
        }

        int bidId = Integer.parseInt(bidIdParam);
        int auctionId = Integer.parseInt(auctionIdParam);

        try (Connection conn = DBUtil.getConnection()) {
            conn.setAutoCommit(false);

            // 1. Delete the bid itself
            try (PreparedStatement ps = conn.prepareStatement(
                    "DELETE FROM bids WHERE bid_id = ?")) {
                ps.setInt(1, bidId);
                ps.executeUpdate();
            }

            // 2. Recompute highest bid for this auction
            int newHighBidderId = 0;
            BigDecimal newHighAmount = null;

            String selectMaxSql =
                    "SELECT bidder_id, amount " +
                    "FROM bids " +
                    "WHERE auction_id = ? " +
                    "ORDER BY amount DESC, bid_time ASC " +
                    "LIMIT 1";

            try (PreparedStatement ps = conn.prepareStatement(selectMaxSql)) {
                ps.setInt(1, auctionId);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        newHighBidderId = rs.getInt("bidder_id");
                        newHighAmount = rs.getBigDecimal("amount");
                    }
                }
            }

            String updateAuctionSql;
            if (newHighAmount != null) {
                updateAuctionSql =
                        "UPDATE auctions " +
                        "SET current_high = ?, current_high_bidder_id = ? " +
                        "WHERE auction_id = ?";
                try (PreparedStatement ps = conn.prepareStatement(updateAuctionSql)) {
                    ps.setBigDecimal(1, newHighAmount);
                    ps.setInt(2, newHighBidderId);
                    ps.setInt(3, auctionId);
                    ps.executeUpdate();
                }
            } else {
                // No bids left
                updateAuctionSql =
                        "UPDATE auctions " +
                        "SET current_high = NULL, current_high_bidder_id = NULL " +
                        "WHERE auction_id = ?";
                try (PreparedStatement ps = conn.prepareStatement(updateAuctionSql)) {
                    ps.setInt(1, auctionId);
                    ps.executeUpdate();
                }
            }

            conn.commit();

        } catch (SQLException e) {
            throw new ServletException(e);
        }

        response.sendRedirect(
                request.getContextPath() + "/rep/auctionBids?auctionId=" + auctionId);
    }
}
