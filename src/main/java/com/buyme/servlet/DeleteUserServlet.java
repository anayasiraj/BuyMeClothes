package com.buyme.servlet;

import com.buyme.util.DBUtil;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.SQLException;

@WebServlet("/rep/deleteUser")
public class DeleteUserServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        String role = (String) session.getAttribute("role");
        if (role == null || !(role.equals("admin") || role.equals("cust_rep"))) {
            // only admin and customer reps can delete users
            response.sendError(HttpServletResponse.SC_FORBIDDEN, "Not authorized.");
            return;
        }

        String userIdParam = request.getParameter("user_id");
        if (userIdParam == null || userIdParam.trim().isEmpty()) {
            // no id provided – back to edit screen
            request.setAttribute("errorMessage", "No user id provided to delete.");
            request.getRequestDispatcher("/editUser.jsp").forward(request, response);
            return;
        }

        int userId;
        try {
            userId = Integer.parseInt(userIdParam.trim());
        } catch (NumberFormatException e) {
            request.setAttribute("errorMessage", "Invalid user id: " + userIdParam);
            request.getRequestDispatcher("/editUser.jsp").forward(request, response);
            return;
        }

        try (Connection conn = DBUtil.getConnection()) {
            String sql = "DELETE FROM users WHERE user_id = ?";
            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setInt(1, userId);
                int rows = ps.executeUpdate();

                if (rows == 0) {
                    request.setAttribute("errorMessage", "User not found or could not be deleted.");
                    request.getRequestDispatcher("/editUser.jsp").forward(request, response);
                    return;
                }
            }
        } catch (SQLException e) {
            // Most likely foreign-key constraints if the user has bids / auctions etc.
            e.printStackTrace();
            request.setAttribute("errorMessage",
                    "Unable to delete user. They may have existing activity in the system.");
            request.getRequestDispatcher("/editUser.jsp").forward(request, response);
            return;
        }

        // Success – send them back to the appropriate dashboard
        String ctx = request.getContextPath();
        if ("admin".equals(role)) {
            response.sendRedirect(ctx + "/admin/dashboard");
        } else {
            response.sendRedirect(ctx + "/rep/dashboard");
        }
    }
}
