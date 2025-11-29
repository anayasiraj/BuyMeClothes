package com.buyme.servlet;

import com.buyme.dao.AlertDAO;
import com.buyme.model.Alert;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;
import java.math.BigDecimal;
import java.sql.SQLException;
import java.util.List;

@WebServlet("/alerts")
public class AlertsServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("userId") == null) {
            response.sendRedirect("login.jsp");
            return;
        }

        int userId = (Integer) session.getAttribute("userId");
        AlertDAO dao = new AlertDAO();

        try {
            List<Alert> alerts = dao.getAlertsForUser(userId);
            request.setAttribute("alerts", alerts);
        } catch (SQLException e) {
            e.printStackTrace();
            request.setAttribute("alerts", null);
            request.setAttribute("error", "Could not load alerts.");
        }

        request.getRequestDispatcher("alerts.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("userId") == null) {
            response.sendRedirect("login.jsp");
            return;
        }
        int userId = (Integer) session.getAttribute("userId");

        String action = request.getParameter("action");
        AlertDAO dao = new AlertDAO();

        if ("delete".equals(action)) {
            // delete alert
            String idParam = request.getParameter("alertId");
            try {
                int alertId = Integer.parseInt(idParam);
                dao.deleteAlert(alertId, userId);
            } catch (Exception e) {
                e.printStackTrace();
                // you could stash a flash message in session if you want
            }
            response.sendRedirect("alerts");
            return;
        }

        // otherwise treat as "create new alert"
        String alertName = request.getParameter("alertName");
        String colorPref = request.getParameter("colorPref");
        String sizePref  = request.getParameter("sizePref");
        String keyword   = request.getParameter("keyword");
        String minPriceParam = request.getParameter("minPrice");
        String maxPriceParam = request.getParameter("maxPrice");
        String categoryParam = request.getParameter("categoryId");

        Alert alert = new Alert();
        alert.setUserId(userId);
        alert.setAlertName(alertName);
        alert.setColorPref(emptyToNull(colorPref));
        alert.setSizePref(emptyToNull(sizePref));
        alert.setKeyword(emptyToNull(keyword));

        if (minPriceParam != null && !minPriceParam.isBlank()) {
            try {
                alert.setMinPrice(new BigDecimal(minPriceParam));
            } catch (NumberFormatException ignored) {}
        }
        if (maxPriceParam != null && !maxPriceParam.isBlank()) {
            try {
                alert.setMaxPrice(new BigDecimal(maxPriceParam));
            } catch (NumberFormatException ignored) {}
        }
        if (categoryParam != null && !categoryParam.isBlank()) {
            try {
                alert.setCategoryId(Integer.parseInt(categoryParam));
            } catch (NumberFormatException ignored) {}
        }

        try {
            dao.createAlert(alert);
        } catch (SQLException e) {
            e.printStackTrace();
        }

        response.sendRedirect("alerts");
    }

    private String emptyToNull(String s) {
        return (s == null || s.isBlank()) ? null : s.trim();
    }
}
