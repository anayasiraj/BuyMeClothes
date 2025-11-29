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

@WebServlet("/browse")
public class BrowseAuctionsServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request,
                         HttpServletResponse response)
            throws ServletException, IOException {

        // 1. Pull any one-time success message from session (for sell)
        HttpSession session = request.getSession(false);
        if (session != null) {
            String sellSuccess = (String) session.getAttribute("sellSuccess");
            if (sellSuccess != null) {
                request.setAttribute("sellSuccess", sellSuccess);
                session.removeAttribute("sellSuccess");
            }
        }

        // 2. Read search/filter parameters (names match browse.jsp)
        String q        = request.getParameter("q");         // text search
        String size     = request.getParameter("size");
        String color    = request.getParameter("color");
        String category = request.getParameter("category");
        String minP     = request.getParameter("minPrice");
        String maxP     = request.getParameter("maxPrice");

        AuctionDAO dao = new AuctionDAO();

        try {
            // If all filters are null/blank, searchAuctions behaves like getOpenAuctions()
            List<AuctionSummary> auctions =
                    dao.searchAuctions(q, size, color, category, minP, maxP);

            request.setAttribute("auctions", auctions);
            request.getRequestDispatcher("browse.jsp")
                   .forward(request, response);

        } catch (SQLException e) {
            e.printStackTrace();
            request.setAttribute("error",
                    "Error loading auctions. Please try again later.");
            request.getRequestDispatcher("browse.jsp")
                   .forward(request, response);
        }
    }
}
