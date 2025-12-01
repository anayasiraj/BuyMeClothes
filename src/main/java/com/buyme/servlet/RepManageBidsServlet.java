package com.buyme.servlet;

import com.buyme.model.AuctionSummary;
import com.buyme.model.BidInfo;
import com.buyme.util.DBUtil;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

@WebServlet("/rep/auctionBids")
public class RepManageBidsServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request,
                         HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || !"cust_rep".equals(session.getAttribute("role"))) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        String auctionIdParam = request.getParameter("auctionId");
        if (auctionIdParam == null) {
            response.sendRedirect(request.getContextPath() + "/rep/bids");
            return;
        }
        int auctionId = Integer.parseInt(auctionIdParam);

        AuctionSummary auction = null;
        List<BidInfo> bids = new ArrayList<>();

        try (Connection conn = DBUtil.getConnection()) {

            // Auction header info
            String auctionSql =
                    "SELECT a.auction_id, a.status, a.current_high, a.end_time, " +
                    "       i.title, i.brand, i.size, i.color, i.photo_url1 " +
                    "FROM auctions a " +
                    "JOIN items i ON a.item_id = i.item_id " +
                    "WHERE a.auction_id = ?";
            try (PreparedStatement ps = conn.prepareStatement(auctionSql)) {
                ps.setInt(1, auctionId);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        auction = new AuctionSummary();
                        auction.setAuctionId(rs.getInt("auction_id"));
                        auction.setStatus(rs.getString("status"));
                        auction.setCurrentHigh(rs.getBigDecimal("current_high"));
                        auction.setEndTime(rs.getTimestamp("end_time"));
                        auction.setTitle(rs.getString("title"));
                        auction.setBrand(rs.getString("brand"));
                        auction.setSize(rs.getString("size"));
                        auction.setColor(rs.getString("color"));
                        auction.setPhotoUrl(rs.getString("photo_url1"));
                    }
                }
            }

            // Bids list
            String bidsSql =
                    "SELECT b.bid_id, b.auction_id, b.amount, b.bid_time, u.username " +
                    "FROM bids b " +
                    "JOIN users u ON b.bidder_id = u.user_id " +
                    "WHERE b.auction_id = ? " +
                    "ORDER BY b.amount DESC, b.bid_time ASC";

            try (PreparedStatement ps = conn.prepareStatement(bidsSql)) {
                ps.setInt(1, auctionId);
                try (ResultSet rs = ps.executeQuery()) {
                    while (rs.next()) {
                        BidInfo b = new BidInfo();
                        b.setBidId(rs.getInt("bid_id"));
                        b.setAuctionId(rs.getInt("auction_id"));
                        b.setAmount(rs.getBigDecimal("amount"));
                        b.setBidTime(rs.getTimestamp("bid_time"));
                        b.setBidderUsername(rs.getString("username"));
                        bids.add(b);
                    }
                }
            }

        } catch (SQLException e) {
            throw new ServletException(e);
        }

        request.setAttribute("auction", auction);
        request.setAttribute("bids", bids);
        request.getRequestDispatcher("/repManageBids.jsp")
               .forward(request, response);
    }
}
