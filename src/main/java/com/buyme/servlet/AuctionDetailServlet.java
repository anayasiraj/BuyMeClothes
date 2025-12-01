package com.buyme.servlet;

import com.buyme.dao.AuctionDAO;
import com.buyme.model.AuctionDetail;
import com.buyme.model.BidSummary;
import com.buyme.model.AuctionSummary;
import com.buyme.util.AuctionStatusUtil;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;
import java.sql.SQLException;
import java.util.List;

@WebServlet("/auction")
public class AuctionDetailServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String idParam = request.getParameter("id");   // matches ?id= in browse.jsp

        // No id → just render empty page
        if (idParam == null) {
            request.setAttribute("detail", null);
            request.setAttribute("recentBids", null);
            request.setAttribute("similarAuctions", null);
            request.getRequestDispatcher("auction.jsp").forward(request, response);
            return;
        }

        int auctionId;
        try {
            auctionId = Integer.parseInt(idParam);
        } catch (NumberFormatException e) {
            request.setAttribute("detail", null);
            request.setAttribute("recentBids", null);
            request.setAttribute("similarAuctions", null);
            request.getRequestDispatcher("auction.jsp").forward(request, response);
            return;
        }

        // NEW: lazily close the auction if its end_time has passed
        try {
            AuctionStatusUtil.closeAuctionIfEnded(auctionId);
        } catch (SQLException e) {
            e.printStackTrace(); // log but don't block the page
        }

        AuctionDAO dao = new AuctionDAO();
        AuctionDetail detail = dao.getAuctionDetail(auctionId);
        List<BidSummary> recentBids = dao.getRecentBids(auctionId);

        List<AuctionSummary> similarAuctions = null;
        try {
            similarAuctions = dao.getSimilarAuctions(auctionId);
        } catch (Exception e) {
            e.printStackTrace();
        }

        // Winner banner + status for JSP (if these fields exist on AuctionDetail)
        String auctionStatus = null;
        String winnerUsername = null;
        boolean isWinnerViewer = false;

        if (detail != null) {
            try {
                auctionStatus = detail.getStatus();            // you may already have this
            } catch (Exception ignored) {}

            try {
                winnerUsername = detail.getWinnerUsername();  // optional, if present
            } catch (Exception ignored) {}

            try {
                HttpSession session = request.getSession(false);
                Integer viewerId = (session != null)
                        ? (Integer) session.getAttribute("userId")
                        : null;

                Integer winnerId = detail.getWinnerId();       // optional, if present

                if (viewerId != null && winnerId != null && viewerId.equals(winnerId)) {
                    isWinnerViewer = true;
                }
            } catch (Exception ignored) {}
        }

        request.setAttribute("detail", detail);
        request.setAttribute("recentBids", recentBids);
        request.setAttribute("similarAuctions", similarAuctions);

        // extra attributes used by auction.jsp (if you wire them in)
        request.setAttribute("auctionStatus", auctionStatus);
        request.setAttribute("winnerUsername", winnerUsername);
        request.setAttribute("isWinnerViewer", isWinnerViewer);

        request.getRequestDispatcher("auction.jsp").forward(request, response);
    }
}
