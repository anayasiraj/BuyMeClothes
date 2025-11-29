package com.buyme.servlet;

import com.buyme.util.DBUtil;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;
import java.sql.*;
import java.util.*;

@WebServlet("/support")
public class SupportServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        Integer userId = (session == null) ? null : (Integer) session.getAttribute("userId");

        if (userId == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        List<Map<String, Object>> tickets = new ArrayList<>();

        try (Connection conn = DBUtil.getConnection()) {
            String sql = "SELECT ticket_id, subject, status, open_date, close_date, notes, cust_rep_id " +
                         "FROM support_tickets WHERE user_id = ? ORDER BY open_date DESC";
            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setInt(1, userId);
                try (ResultSet rs = ps.executeQuery()) {
                    while (rs.next()) {
                        Map<String, Object> row = new HashMap<>();
                        row.put("ticket_id", rs.getInt("ticket_id"));
                        row.put("subject", rs.getString("subject"));
                        row.put("status", rs.getString("status"));
                        row.put("open_date", rs.getTimestamp("open_date"));
                        row.put("close_date", rs.getTimestamp("close_date"));
                        row.put("notes", rs.getString("notes"));
                        row.put("cust_rep_id", rs.getObject("cust_rep_id"));
                        tickets.add(row);
                    }
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
            request.setAttribute("message", "DB error: " + e.getMessage());
        }

        request.setAttribute("tickets", tickets);
        request.getRequestDispatcher("/support.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        Integer userId = (session == null) ? null : (Integer) session.getAttribute("userId");

        if (userId == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        String subject = request.getParameter("subject");
        String description = request.getParameter("description");

        if (subject == null || subject.trim().isEmpty()
                || description == null || description.trim().isEmpty()) {
            request.setAttribute("message", "Please fill in both subject and description.");
            doGet(request, response);
            return;
        }

        try (Connection conn = DBUtil.getConnection()) {
            String sql = "INSERT INTO support_tickets (user_id, subject, status, notes) " +
                         "VALUES (?, ?, 'open', ?)";
            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setInt(1, userId);
                ps.setString(2, subject.trim());
                ps.setString(3, description.trim());
                ps.executeUpdate();
            }
            request.setAttribute("message", "Your ticket has been submitted. A representative will review it soon.");
        } catch (SQLException e) {
            e.printStackTrace();
            request.setAttribute("message", "DB error: " + e.getMessage());
        }

        // Reload list with success message
        doGet(request, response);
    }
}
