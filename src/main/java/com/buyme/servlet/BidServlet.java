package com.buyme.servlet;

import com.buyme.dao.AuctionDAO;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;
import java.math.BigDecimal;
import java.sql.SQLException;

@WebServlet("/bid")
public class BidServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("userId") == null) {
            // must be logged in to bid
            response.sendRedirect("login.jsp");
            return;
        }

        int userId = (Integer) session.getAttribute("userId");
        String auctionIdParam = request.getParameter("auctionId");
        String amountParam    = request.getParameter("amount");
        String maxAutoParam   = request.getParameter("maxAutoBid"); // optional

        int auctionId;
        BigDecimal amount;

        try {
            auctionId = Integer.parseInt(auctionIdParam);
            amount = new BigDecimal(amountParam);
        } catch (Exception e) {
            session.setAttribute("flashMessage", "Invalid bid amount.");
            session.setAttribute("flashType", "danger");
            response.sendRedirect("auction?id=" + auctionIdParam);
            return;
        }

        AuctionDAO dao = new AuctionDAO();

        // 1) If user provided a max auto-bid, store / update it
        if (maxAutoParam != null && !maxAutoParam.isBlank()) {
            try {
                BigDecimal maxLimit = new BigDecimal(maxAutoParam);
                if (maxLimit.compareTo(amount) >= 0) {
                    dao.upsertAutoBid(auctionId, userId, maxLimit);
                } else {
                    // if they type a max smaller than their immediate bid, just ignore it
                }
            } catch (NumberFormatException | SQLException e) {
                e.printStackTrace();
                session.setAttribute("flashMessage",
                        "Could not save auto-bid setting (invalid number or DB error).");
                session.setAttribute("flashType", "warning");
            }
        }

        // 2) Place the manual bid – this will also trigger auto-bid logic
        boolean success;
        try {
            success = dao.placeBid(auctionId, userId, amount);
        } catch (SQLException e) {
            e.printStackTrace();
            session.setAttribute("flashMessage", "Database error while placing bid.");
            session.setAttribute("flashType", "danger");
            response.sendRedirect("auction?id=" + auctionId);
            return;
        }

        if (success) {
            session.setAttribute("flashMessage", "Your bid has been placed!");
            session.setAttribute("flashType", "success");
        } else {
            session.setAttribute("flashMessage",
                    "Bid too low or auction is closed/expired.");
            session.setAttribute("flashType", "danger");
        }

        response.sendRedirect("auction?id=" + auctionId);
    }
}
