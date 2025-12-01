package com.buyme.servlet;

import com.buyme.model.AuctionSummary;
import com.buyme.util.DBUtil;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

@WebServlet("/rep/bids")
public class RepBidsServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request,
                         HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || !"cust_rep".equals(session.getAttribute("role"))) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        List<AuctionSummary> auctions = new ArrayList<>();

        String sql =
                "SELECT a.auction_id, a.status, a.current_high, a.end_time, " +
                "       i.title, i.brand, i.size, i.color, i.photo_url1 " +
                "FROM auctions a " +
                "JOIN items i ON a.item_id = i.item_id " +
                "ORDER BY a.end_time DESC";

        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                AuctionSummary a = new AuctionSummary();
                a.setAuctionId(rs.getInt("auction_id"));
                a.setStatus(rs.getString("status"));
                a.setCurrentHigh(rs.getBigDecimal("current_high"));
                a.setEndTime(rs.getTimestamp("end_time"));
                a.setTitle(rs.getString("title"));
                a.setBrand(rs.getString("brand"));
                a.setSize(rs.getString("size"));
                a.setColor(rs.getString("color"));
                a.setPhotoUrl(rs.getString("photo_url1"));
                auctions.add(a);
            }

        } catch (SQLException e) {
            throw new ServletException(e);
        }

        request.setAttribute("auctions", auctions);
        request.getRequestDispatcher("/repBids.jsp")
               .forward(request, response);
    }
}
