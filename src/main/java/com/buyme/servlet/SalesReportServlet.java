package com.buyme.servlet;

import com.buyme.util.DBUtil;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import javax.servlet.RequestDispatcher;
import java.io.IOException;
import java.math.BigDecimal;
import java.sql.*;
import java.util.*;

@WebServlet("/admin/reports")
public class SalesReportServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        String role = (session == null) ? null : (String) session.getAttribute("role");

        // Only allow admin (you can add "cust_rep" here too if you want them to see reports)
        if (session == null || role == null || !"admin".equals(role)) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        BigDecimal totalEarnings = BigDecimal.ZERO;
        List<Map<String, Object>> itemEarnings = new ArrayList<>();
        List<Map<String, Object>> categoryEarnings = new ArrayList<>();
        List<Map<String, Object>> sellerEarnings = new ArrayList<>();

        try (Connection conn = DBUtil.getConnection()) {

            // 1) Total earnings across all closed auctions
            String totalSql =
                    "SELECT COALESCE(SUM(closing_price), 0) AS total_earnings " +
                    "FROM auctions " +
                    "WHERE status = 'closed' AND closing_price IS NOT NULL";
            try (PreparedStatement ps = conn.prepareStatement(totalSql);
                 ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    totalEarnings = rs.getBigDecimal("total_earnings");
                    if (totalEarnings == null) {
                        totalEarnings = BigDecimal.ZERO;
                    }
                }
            }

            // 2) Earnings per item (group by item)
            String itemSql =
                    "SELECT i.item_id, i.title, " +
                    "       COUNT(*) AS num_sales, " +
                    "       SUM(a.closing_price) AS total_revenue " +
                    "FROM auctions a " +
                    "JOIN items i ON a.item_id = i.item_id " +
                    "WHERE a.status = 'closed' AND a.closing_price IS NOT NULL " +
                    "GROUP BY i.item_id, i.title " +
                    "ORDER BY total_revenue DESC";
            try (PreparedStatement ps = conn.prepareStatement(itemSql);
                 ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Map<String, Object> row = new HashMap<>();
                    row.put("item_id", rs.getInt("item_id"));
                    row.put("title", rs.getString("title"));
                    row.put("num_sales", rs.getInt("num_sales"));
                    row.put("total_revenue", rs.getBigDecimal("total_revenue"));
                    itemEarnings.add(row);
                }
            }

            // 3) Earnings per category
            String categorySql =
                    "SELECT c.category_id, c.name AS category_name, " +
                    "       COUNT(*) AS num_sales, " +
                    "       SUM(a.closing_price) AS total_revenue " +
                    "FROM auctions a " +
                    "JOIN items i ON a.item_id = i.item_id " +
                    "JOIN categories c ON i.category_id = c.category_id " +
                    "WHERE a.status = 'closed' AND a.closing_price IS NOT NULL " +
                    "GROUP BY c.category_id, c.name " +
                    "ORDER BY total_revenue DESC";
            try (PreparedStatement ps = conn.prepareStatement(categorySql);
                 ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Map<String, Object> row = new HashMap<>();
                    row.put("category_id", rs.getInt("category_id"));
                    row.put("category_name", rs.getString("category_name"));
                    row.put("num_sales", rs.getInt("num_sales"));
                    row.put("total_revenue", rs.getBigDecimal("total_revenue"));
                    categoryEarnings.add(row);
                }
            }

            // 4) Earnings per seller
            String sellerSql =
                    "SELECT u.user_id, u.username, " +
                    "       COUNT(*) AS num_sales, " +
                    "       SUM(a.closing_price) AS total_revenue " +
                    "FROM auctions a " +
                    "JOIN users u ON a.seller_id = u.user_id " +
                    "WHERE a.status = 'closed' AND a.closing_price IS NOT NULL " +
                    "GROUP BY u.user_id, u.username " +
                    "ORDER BY total_revenue DESC";
            try (PreparedStatement ps = conn.prepareStatement(sellerSql);
                 ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Map<String, Object> row = new HashMap<>();
                    row.put("user_id", rs.getInt("user_id"));
                    row.put("username", rs.getString("username"));
                    row.put("num_sales", rs.getInt("num_sales"));
                    row.put("total_revenue", rs.getBigDecimal("total_revenue"));
                    sellerEarnings.add(row);
                }
            }

        } catch (SQLException e) {
            e.printStackTrace();
            request.setAttribute("message", "DB error: " + e.getMessage());
        }

        request.setAttribute("totalEarnings", totalEarnings);
        request.setAttribute("itemEarnings", itemEarnings);
        request.setAttribute("categoryEarnings", categoryEarnings);
        request.setAttribute("sellerEarnings", sellerEarnings);

        RequestDispatcher rd = request.getRequestDispatcher("/salesReports.jsp");
        rd.forward(request, response);
    }
}
