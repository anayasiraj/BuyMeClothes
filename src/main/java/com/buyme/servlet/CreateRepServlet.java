package com.buyme.servlet;

import com.buyme.dao.UserDAO;
import com.buyme.model.User;
// import your password-hash util

import javax.servlet.*;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;
import java.sql.SQLException;

@WebServlet("/admin/createRep")
public class CreateRepServlet extends HttpServlet {

    private UserDAO userDAO = new UserDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || !"admin".equals(session.getAttribute("role"))) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        RequestDispatcher rd = request.getRequestDispatcher("/createRep.jsp");
        rd.forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || !"admin".equals(session.getAttribute("role"))) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        int adminId = (Integer) session.getAttribute("userId");

        String fullName = request.getParameter("full_name");
        String username = request.getParameter("username");
        String email = request.getParameter("email");
        String phone = request.getParameter("phone");
        String address = request.getParameter("address");
        String password = request.getParameter("password");
        String notes = request.getParameter("notes");

        // TODO: use your existing hashing logic
        String passwordHash = password; // replace with PasswordUtil.hash(password);

        User rep = new User();
        rep.setFullName(fullName);
        rep.setUsername(username);
        rep.setEmail(email);
        rep.setPhone(phone);
        rep.setAddress(address);
        rep.setPasswordHash(passwordHash);

        int newUserId = 0;
		try {
			newUserId = userDAO.createCustomerRep(rep, adminId, notes);
		} catch (SQLException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}

        request.setAttribute("newUserId", newUserId);
        RequestDispatcher rd = request.getRequestDispatcher("/createRep.jsp");
        rd.forward(request, response);
    }
}
