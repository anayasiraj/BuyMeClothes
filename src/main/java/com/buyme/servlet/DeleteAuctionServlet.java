package com.buyme.servlet;

import com.buyme.dao.AuctionDAO;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.sql.SQLException;

@WebServlet("/rep/deleteAuction")
public class DeleteAuctionServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request,
                          HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null ||
            session.getAttribute("userId") == null ||
            !"cust_rep".equals(session.getAttribute("role"))) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        String idStr = request.getParameter("auctionId");
        AuctionDAO dao = new AuctionDAO();

        String msg;
        if (idStr == null || idStr.isBlank()) {
            msg = "No auction id specified.";
        } else {
            try {
                int auctionId = Integer.parseInt(idStr);
                boolean ok = dao.deleteAuctionById(auctionId);
                if (ok) {
                    msg = "Auction #" + auctionId + " was deleted.";
                } else {
                    msg = "Auction #" + auctionId + " could not be deleted (it may not exist).";
                }
            } catch (NumberFormatException e) {
                msg = "Invalid auction id: " + idStr;
            } catch (SQLException e) {
                e.printStackTrace();
                msg = "Database error while deleting auction.";
            }
        }

        session.setAttribute("repMessage", msg);
        response.sendRedirect(request.getContextPath() + "/rep/auctions");
    }
}
