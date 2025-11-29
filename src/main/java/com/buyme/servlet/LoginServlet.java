package com.buyme.servlet;

import com.buyme.util.DBUtil;
import com.buyme.util.PasswordUtil;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

@WebServlet("/login")
public class LoginServlet extends HttpServlet {

    // Handle GET /login → just show the login page
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.getRequestDispatcher("/login.jsp").forward(request, response);
    }

    // Handle POST /login → actually log in
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String username = request.getParameter("username");
        String password = request.getParameter("password");

        try (Connection conn = DBUtil.getConnection()) {

            // 1) Look up the user by username only
            String sql = "SELECT user_id, role, password_hash FROM users WHERE username = ?";
            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setString(1, username);

                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        int userId = rs.getInt("user_id");
                        String role = rs.getString("role");
                        String storedHash = rs.getString("password_hash");

                        // 2) Check raw password against stored hash
                        boolean ok = PasswordUtil.checkPassword(password, storedHash);

                        if (ok) {
                            // ---- store info in the session for navbars / role checks ----
                            HttpSession session = request.getSession();
                            session.setAttribute("username", username);
                            session.setAttribute("userId", userId);
                            session.setAttribute("role", role);

                            String ctx = request.getContextPath();

                            // ---- route based on role ----
                            if ("admin".equals(role)) {
                                response.sendRedirect(ctx + "/admin/dashboard");
                            } else if ("cust_rep".equals(role)) {
                                response.sendRedirect(ctx + "/rep/dashboard");
                            } else {
                                // Normal buyer/seller → main browse page servlet
                                response.sendRedirect(ctx + "/browse");
                            }
                        } else {
                            // password mismatch
                            request.setAttribute("message", "Invalid username or password.");
                            request.getRequestDispatcher("/login.jsp").forward(request, response);
                        }
                    } else {
                        // no such username
                        request.setAttribute("message", "Invalid username or password.");
                        request.getRequestDispatcher("/login.jsp").forward(request, response);
                    }
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
            request.setAttribute("message", "DB error: " + e.getMessage());
            request.getRequestDispatcher("/login.jsp").forward(request, response);
        }
    }
}
