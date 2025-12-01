package com.buyme.servlet;

import com.buyme.dao.AuctionDAO;
import com.buyme.dao.AlertDAO;
import com.buyme.model.AuctionSummary;
import com.buyme.model.Alert;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.LinkedHashSet;
import java.util.List;
import java.util.Set;

@WebServlet("/browse")
public class BrowseAuctionsServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request,
                         HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);

        // 1. Pull any one-time success message from session (for sell)
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

        AuctionDAO auctionDao = new AuctionDAO();

        try {
            // If all filters are null/blank, searchAuctions behaves like getOpenAuctions()
            List<AuctionSummary> auctions =
                    auctionDao.searchAuctions(q, size, color, category, minP, maxP);

            request.setAttribute("auctions", auctions);

            // -------------------------------------------------------------
            // 3. If user is logged in, check which auctions match their alerts
            // -------------------------------------------------------------
            if (session != null && session.getAttribute("userId") != null
                    && auctions != null && !auctions.isEmpty()) {

                int userId = (Integer) session.getAttribute("userId");
                AlertDAO alertDao = new AlertDAO();

                try {
                    List<Alert> alerts = alertDao.getAlertsForUser(userId);
                    Set<String> matchingTitles = new LinkedHashSet<>();

                    if (alerts != null && !alerts.isEmpty()) {
                        for (AuctionSummary a : auctions) {
                            for (Alert alert : alerts) {
                                if (alertDao.matchesAuction(a, alert)) {
                                    matchingTitles.add(a.getTitle());
                                    // don't break; same auction might match multiple alerts,
                                    // but we only care about listing it once
                                    break;
                                }
                            }
                        }
                    }

                    if (!matchingTitles.isEmpty()) {
                        // Build a user-friendly popup message
                        List<String> titlesPreview = new ArrayList<>(matchingTitles);
                        StringBuilder sb = new StringBuilder("Good news! These auctions match your alerts: ");

                        int limit = Math.min(3, titlesPreview.size());
                        for (int i = 0; i < limit; i++) {
                            if (i > 0) sb.append(", ");
                            sb.append(titlesPreview.get(i));
                        }
                        if (titlesPreview.size() > limit) {
                            sb.append(" and more...");
                        }

                        request.setAttribute("alertPopup", sb.toString());
                    }

                } catch (SQLException ex) {
                    // If alert loading fails, just log and continue without popup.
                    ex.printStackTrace();
                }
            }

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
