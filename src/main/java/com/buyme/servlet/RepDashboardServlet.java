package com.buyme.servlet;

import javax.servlet.RequestDispatcher;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;

@WebServlet("/rep/dashboard")
public class RepDashboardServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        String role = (session == null) ? null : (String) session.getAttribute("role");

        // Only allow customer reps (and admins) to see this page
        if (session == null || role == null ||
                (!"cust_rep".equals(role) && !"admin".equals(role))) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        // NOTE: leading "/" → path is relative to the app root, NOT /rep/
        RequestDispatcher rd = request.getRequestDispatcher("/repDashboard.jsp");
        rd.forward(request, response);
    }
}
