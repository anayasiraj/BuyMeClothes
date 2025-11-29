package com.buyme.servlet;

import com.buyme.util.DBUtil;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;
import java.sql.*;

@WebServlet("/rep/editUser")
public class EditUserServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        String role = (session == null) ? null : (String) session.getAttribute("role");

        // Only admin + customer reps allowed
        if (session == null || role == null ||
                (!"cust_rep".equals(role) && !"admin".equals(role))) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        String userIdParam = request.getParameter("user_id");

        if (userIdParam != null && !userIdParam.isEmpty()) {
            try (Connection conn = DBUtil.getConnection()) {
                int userId = Integer.parseInt(userIdParam);

                String sql = "SELECT user_id, username, email, phone, address " +
                             "FROM users WHERE user_id = ?";
                try (PreparedStatement ps = conn.prepareStatement(sql)) {
                    ps.setInt(1, userId);
                    try (ResultSet rs = ps.executeQuery()) {
                        if (rs.next()) {
                            request.setAttribute("user_id", rs.getInt("user_id"));
                            request.setAttribute("username", rs.getString("username"));
                            request.setAttribute("email", rs.getString("email"));
                            request.setAttribute("phone", rs.getString("phone"));
                            request.setAttribute("address", rs.getString("address"));
                        } else {
                            request.setAttribute("message", "User not found.");
                        }
                    }
                }
            } catch (NumberFormatException e) {
                request.setAttribute("message", "Invalid user id.");
            } catch (SQLException e) {
                e.printStackTrace();
                request.setAttribute("message", "DB error: " + e.getMessage());
            }
        }

        // Show the edit page (either blank or with loaded data)
        request.getRequestDispatcher("/editUser.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        String role = (session == null) ? null : (String) session.getAttribute("role");

        if (session == null || role == null ||
                (!"cust_rep".equals(role) && !"admin".equals(role))) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        int repId = (session.getAttribute("userId") != null)
                ? (Integer) session.getAttribute("userId")
                : -1;

        String userIdParam = request.getParameter("user_id");
        String newUsername = request.getParameter("username");
        String newEmail = request.getParameter("email");
        String newPhone = request.getParameter("phone");
        String newAddress = request.getParameter("address");
        String newPassword = request.getParameter("new_password");

        if (userIdParam == null || userIdParam.isEmpty()) {
            request.setAttribute("message", "Missing user id.");
            request.getRequestDispatcher("/editUser.jsp").forward(request, response);
            return;
        }

        try (Connection conn = DBUtil.getConnection()) {
            conn.setAutoCommit(false);

            int userId = Integer.parseInt(userIdParam);

            // 1. Load current values
            String selectSql = "SELECT username, email, phone, address, password_hash " +
                               "FROM users WHERE user_id = ?";
            String oldUsername = null, oldEmail = null, oldPhone = null, oldAddress = null, oldPassword = null;

            try (PreparedStatement ps = conn.prepareStatement(selectSql)) {
                ps.setInt(1, userId);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        oldUsername = rs.getString("username");
                        oldEmail = rs.getString("email");
                        oldPhone = rs.getString("phone");
                        oldAddress = rs.getString("address");
                        oldPassword = rs.getString("password_hash");
                    } else {
                        request.setAttribute("message", "User not found.");
                        request.getRequestDispatcher("/editUser.jsp").forward(request, response);
                        return;
                    }
                }
            }

            // 2. Update users table
            StringBuilder updateSql = new StringBuilder(
                    "UPDATE users SET username = ?, email = ?, phone = ?, address = ?"
            );
            boolean updatePassword = newPassword != null && !newPassword.trim().isEmpty();
            if (updatePassword) {
                updateSql.append(", password_hash = ?");
            }
            updateSql.append(" WHERE user_id = ?");

            try (PreparedStatement ps = conn.prepareStatement(updateSql.toString())) {
                ps.setString(1, newUsername);
                ps.setString(2, newEmail);
                ps.setString(3, newPhone);
                ps.setString(4, newAddress);
                int idx = 5;
                if (updatePassword) {
                    // NOTE: you are currently storing plain passwords.
                    // If you switch to hashing later, hash newPassword here.
                    ps.setString(idx++, newPassword);
                }
                ps.setInt(idx, userId);
                ps.executeUpdate();
            }

            // 3. Log changes into edit_account (if that table exists)
            String logSql = "INSERT INTO edit_account " +
                            "(rep_id, edited_user_id, field_changed, old_value, new_value) " +
                            "VALUES (?, ?, ?, ?, ?)";

            try (PreparedStatement logPs = conn.prepareStatement(logSql)) {

                if (!equalsNullSafe(oldUsername, newUsername)) {
                    logPs.setInt(1, repId);
                    logPs.setInt(2, userId);
                    logPs.setString(3, "username");
                    logPs.setString(4, oldUsername);
                    logPs.setString(5, newUsername);
                    logPs.addBatch();
                }
                if (!equalsNullSafe(oldEmail, newEmail)) {
                    logPs.setInt(1, repId);
                    logPs.setInt(2, userId);
                    logPs.setString(3, "email");
                    logPs.setString(4, oldEmail);
                    logPs.setString(5, newEmail);
                    logPs.addBatch();
                }
                if (!equalsNullSafe(oldPhone, newPhone)) {
                    logPs.setInt(1, repId);
                    logPs.setInt(2, userId);
                    logPs.setString(3, "phone");
                    logPs.setString(4, oldPhone);
                    logPs.setString(5, newPhone);
                    logPs.addBatch();
                }
                if (!equalsNullSafe(oldAddress, newAddress)) {
                    logPs.setInt(1, repId);
                    logPs.setInt(2, userId);
                    logPs.setString(3, "address");
                    logPs.setString(4, oldAddress);
                    logPs.setString(5, newAddress);
                    logPs.addBatch();
                }
                if (updatePassword && !equalsNullSafe(oldPassword, newPassword)) {
                    logPs.setInt(1, repId);
                    logPs.setInt(2, userId);
                    logPs.setString(3, "password_hash");
                    logPs.setString(4, oldPassword);
                    logPs.setString(5, newPassword);
                    logPs.addBatch();
                }

                logPs.executeBatch();
            }

            conn.commit();

            // 4. Reload latest values to show on the page
            try (PreparedStatement ps = conn.prepareStatement(
                    "SELECT user_id, username, email, phone, address " +
                    "FROM users WHERE user_id = ?")) {
                ps.setInt(1, userId);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        request.setAttribute("user_id", rs.getInt("user_id"));
                        request.setAttribute("username", rs.getString("username"));
                        request.setAttribute("email", rs.getString("email"));
                        request.setAttribute("phone", rs.getString("phone"));
                        request.setAttribute("address", rs.getString("address"));
                    }
                }
            }

            request.setAttribute("message", "Changes saved successfully.");

        } catch (NumberFormatException e) {
            request.setAttribute("message", "Invalid user id.");
        } catch (SQLException e) {
            e.printStackTrace();
            request.setAttribute("message", "DB error: " + e.getMessage());
        }

        request.getRequestDispatcher("/editUser.jsp").forward(request, response);
    }

    private boolean equalsNullSafe(String a, String b) {
        if (a == null && b == null) return true;
        if (a == null || b == null) return false;
        return a.equals(b);
    }
}
