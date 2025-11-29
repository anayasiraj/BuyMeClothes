package com.buyme.servlet;

import com.buyme.dao.AuctionDAO;
import com.buyme.model.AuctionDetail;
import com.buyme.model.BidSummary;
import com.buyme.model.AuctionSummary;
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

        AuctionDAO dao = new AuctionDAO();
        AuctionDetail detail = dao.getAuctionDetail(auctionId);
        List<BidSummary> recentBids = dao.getRecentBids(auctionId);

        List<AuctionSummary> similarAuctions = null;
        try {
            similarAuctions = dao.getSimilarAuctions(auctionId);
        } catch (Exception e) {
            e.printStackTrace();
        }

        request.setAttribute("detail", detail);
        request.setAttribute("recentBids", recentBids);
        request.setAttribute("similarAuctions", similarAuctions);

        request.getRequestDispatcher("auction.jsp").forward(request, response);
    }

}
