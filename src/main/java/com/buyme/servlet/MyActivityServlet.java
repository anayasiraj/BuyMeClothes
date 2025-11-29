package com.buyme.servlet;

import com.buyme.dao.AuctionDAO;
import com.buyme.model.AuctionSummary;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;
import java.sql.SQLException;
import java.util.List;

@WebServlet("/myActivity")
public class MyActivityServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("userId") == null) {
            response.sendRedirect("login.jsp");
            return;
        }

        int userId = (Integer) session.getAttribute("userId");

        AuctionDAO dao = new AuctionDAO();

        try {
            List<AuctionSummary> myBids    = dao.getAuctionsUserHasBidOn(userId);
            List<AuctionSummary> mySelling = dao.getAuctionsUserIsSelling(userId);

            request.setAttribute("myBids", myBids);
            request.setAttribute("mySelling", mySelling);

        } catch (SQLException e) {
            e.printStackTrace();
            request.setAttribute("error",
                    "Could not load your activity due to a database error.");
        }

        request.getRequestDispatcher("myActivity.jsp").forward(request, response);
    }
}
