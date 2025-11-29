package com.buyme.servlet;

import com.buyme.util.DBUtil;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;
import java.sql.*;
import java.util.*;

@WebServlet("/rep/support")
public class RepSupportServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        String role = (session == null) ? null : (String) session.getAttribute("role");

        if (session == null || role == null ||
                (!"cust_rep".equals(role) && !"admin".equals(role))) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        List<Map<String, Object>> tickets = new ArrayList<>();

        try (Connection conn = DBUtil.getConnection()) {
            String sql = "SELECT t.ticket_id, u.username, t.subject, t.status, " +
                         "t.open_date, t.close_date, t.notes, t.cust_rep_id " +
                         "FROM support_tickets t " +
                         "JOIN users u ON t.user_id = u.user_id " +
                         "ORDER BY FIELD(t.status, 'open','in_progress','closed'), t.open_date DESC";
            try (PreparedStatement ps = conn.prepareStatement(sql);
                 ResultSet rs = ps.executeQuery()) {

                while (rs.next()) {
                    Map<String, Object> row = new HashMap<>();
                    row.put("ticket_id", rs.getInt("ticket_id"));
                    row.put("username", rs.getString("username"));
                    row.put("subject", rs.getString("subject"));
                    row.put("status", rs.getString("status"));
                    row.put("open_date", rs.getTimestamp("open_date"));
                    row.put("close_date", rs.getTimestamp("close_date"));
                    row.put("notes", rs.getString("notes"));
                    row.put("cust_rep_id", rs.getObject("cust_rep_id"));
                    tickets.add(row);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
            request.setAttribute("message", "DB error: " + e.getMessage());
        }

        request.setAttribute("tickets", tickets);
        request.getRequestDispatcher("/repSupport.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        String role = (session == null) ? null : (String) session.getAttribute("role");
        Integer repId = (session == null) ? null : (Integer) session.getAttribute("userId");

        if (session == null || role == null ||
                (!"cust_rep".equals(role) && !"admin".equals(role)) || repId == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        String action = request.getParameter("action");
        String ticketIdParam = request.getParameter("ticket_id");

        if (ticketIdParam == null || ticketIdParam.isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/rep/support");
            return;
        }

        int ticketId = Integer.parseInt(ticketIdParam);

        try (Connection conn = DBUtil.getConnection()) {
            if ("take".equals(action)) {
                String takeSql = "UPDATE support_tickets " +
                                 "SET cust_rep_id = ?, status = 'in_progress' " +
                                 "WHERE ticket_id = ?";
                try (PreparedStatement ps = conn.prepareStatement(takeSql)) {
                    ps.setInt(1, repId);
                    ps.setInt(2, ticketId);
                    ps.executeUpdate();
                }
            } else if ("update".equals(action)) {
                String newStatus = request.getParameter("status");
                String notes = request.getParameter("notes");

                if (newStatus == null || newStatus.isEmpty()) {
                    newStatus = "in_progress";
                }

                String updateSql;
                if ("closed".equals(newStatus)) {
                    updateSql = "UPDATE support_tickets " +
                                "SET status = ?, notes = ?, cust_rep_id = ?, close_date = NOW() " +
                                "WHERE ticket_id = ?";
                } else {
                    updateSql = "UPDATE support_tickets " +
                                "SET status = ?, notes = ?, cust_rep_id = ?, close_date = NULL " +
                                "WHERE ticket_id = ?";
                }

                try (PreparedStatement ps = conn.prepareStatement(updateSql)) {
                    ps.setString(1, newStatus);
                    ps.setString(2, notes);
                    ps.setInt(3, repId);
                    ps.setInt(4, ticketId);
                    ps.executeUpdate();
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
            // you could stash an error in session here if you want
        }

        // PRG pattern – reload list
        response.sendRedirect(request.getContextPath() + "/rep/support");
    }
}
