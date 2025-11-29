package com.buyme.servlet;

import com.buyme.dao.UserDAO;
import com.buyme.model.User;

import javax.servlet.*;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;
import java.util.List;

@WebServlet(urlPatterns = {"/rep/searchUsers", "/userSearch"})
public class SearchUsersServlet extends HttpServlet {

    private UserDAO userDAO = new UserDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        String role = (session == null) ? null : (String) session.getAttribute("role");

        // Allow both admin and customer reps to use this page
        if (session == null || role == null ||
                (!"cust_rep".equals(role) && !"admin".equals(role))) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        String query = request.getParameter("query");
        List<User> results;

        if (query == null || query.trim().isEmpty()) {
            // No search query → show ALL users (for the "Open list" button)
            results = userDAO.getAllUsers();
        } else {
            results = userDAO.searchUsers(query.trim());
        }

        request.setAttribute("results", results);

        RequestDispatcher rd = request.getRequestDispatcher("/userSearch.jsp");
        rd.forward(request, response);
    }
}
