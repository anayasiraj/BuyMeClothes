package com.buyme.servlet;

import com.buyme.dao.AuctionDAO;
import com.buyme.model.AuctionSummary;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.sql.SQLException;
import java.util.List;

@WebServlet("/rep/auctions")
public class repAuctionsServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request,
                         HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);

        // Optional: restrict to reps/admins
        if (session == null) {
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }
        String role = (String) session.getAttribute("role");
        if (role == null || !(role.equals("cust_rep") || role.equals("admin"))) {
            response.sendRedirect(request.getContextPath() + "/browse");
            return;
        }

        AuctionDAO dao = new AuctionDAO();
        try {
            // Show whatever auctions you want reps to manage
            List<AuctionSummary> auctions = dao.getOpenAuctions();
            request.setAttribute("auctions", auctions);

            // IMPORTANT: JSP is at webapp/repAuctions.jsp,
            // so we forward to "/repAuctions.jsp" (NOT under WEB-INF)
            request.getRequestDispatcher("/repAuctions.jsp")
                   .forward(request, response);

        } catch (SQLException e) {
            e.printStackTrace();
            throw new ServletException("Error loading auctions for rep tools", e);
        }
    }
}
