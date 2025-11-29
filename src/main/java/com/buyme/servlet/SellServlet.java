package com.buyme.servlet;

import com.buyme.dao.AuctionDAO;

import javax.servlet.ServletException;
import javax.servlet.annotation.MultipartConfig;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import javax.servlet.http.Part;
import java.io.File;
import java.io.IOException;
import java.math.BigDecimal;
import java.nio.file.Files;
import java.nio.file.StandardCopyOption;
import java.sql.SQLException;
import java.sql.Timestamp;
import java.time.LocalDateTime;

@WebServlet("/sell")
@MultipartConfig(
        fileSizeThreshold = 1024 * 1024,     // 1 MB
        maxFileSize = 10 * 1024 * 1024,      // 10 MB
        maxRequestSize = 20 * 1024 * 1024    // 20 MB
)
public class SellServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request,
                         HttpServletResponse response)
            throws ServletException, IOException {

        // Just show the sell form
        request.getRequestDispatcher("sell.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request,
                          HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");
        HttpSession session = request.getSession(false);

        // Make sure user is logged in
        if (session == null || session.getAttribute("userId") == null) {
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }

        int sellerId = (Integer) session.getAttribute("userId");

        try {
            // ------------------------------------------------
            // 1. Read form fields
            // ------------------------------------------------
            String title       = request.getParameter("title");
            String description = request.getParameter("description");
            String brand       = request.getParameter("brand");
            String size        = request.getParameter("size");
            String color       = request.getParameter("color");

            String categoryStr = request.getParameter("categoryId");
            String startStr    = request.getParameter("startPrice");
            String incStr      = request.getParameter("bidIncrement");
            String reserveStr  = request.getParameter("reservePrice");
            String hoursStr    = request.getParameter("durationHours");
            String daysStr     = request.getParameter("durationDays");

            int categoryId     = Integer.parseInt(categoryStr);
            BigDecimal startPrice   = new BigDecimal(startStr);
            BigDecimal bidIncrement = new BigDecimal(incStr);

            BigDecimal reservePrice = null;
            if (reserveStr != null && !reserveStr.isBlank()) {
                reservePrice = new BigDecimal(reserveStr);
            }

            int durationHours = 0;
            if (hoursStr != null && !hoursStr.isBlank()) {
                durationHours = Integer.parseInt(hoursStr);
            }
            int durationDays = 0;
            if (daysStr != null && !daysStr.isBlank()) {
                durationDays = Integer.parseInt(daysStr);
            }

            // Compute end time: now + days + hours
            LocalDateTime endLdt = LocalDateTime.now()
                    .plusDays(durationDays)
                    .plusHours(durationHours);
            Timestamp endTime = Timestamp.valueOf(endLdt);

            // ------------------------------------------------
            // 2. Handle file upload
            // ------------------------------------------------
            Part photoPart = request.getPart("photo");
            String photoUrl = "images/default-fashion.jpg";  // fallback

            if (photoPart != null && photoPart.getSize() > 0) {
                // create /uploads if missing
                String uploadDirPath = getServletContext().getRealPath("/uploads");
                File uploadDir = new File(uploadDirPath);
                if (!uploadDir.exists()) {
                    uploadDir.mkdirs();
                }

                String originalFileName = photoPart.getSubmittedFileName();
                String fileName = System.currentTimeMillis() + "_" + originalFileName;
                File savedFile = new File(uploadDir, fileName);

                Files.copy(photoPart.getInputStream(),
                           savedFile.toPath(),
                           StandardCopyOption.REPLACE_EXISTING);

                // this becomes the src on the card: <img src="uploads/...">
                photoUrl = "uploads/" + fileName;
            }

            // ------------------------------------------------
            // 3. Insert item + auction
            // ------------------------------------------------
            AuctionDAO dao = new AuctionDAO();
            int auctionId = dao.createAuctionWithItem(
                    sellerId,
                    title,
                    description,
                    brand,
                    size,
                    color,
                    categoryId,
                    startPrice,
                    bidIncrement,
                    reservePrice,
                    photoUrl,
                    endTime
            );

            // ------------------------------------------------
            // 4. Flash success + redirect to browse
            // ------------------------------------------------
            session.setAttribute("sellSuccess",
                    "Your item has been posted for auction (ID " + auctionId + ")!");
            response.sendRedirect(request.getContextPath() + "/browse");

        } catch (NumberFormatException e) {
            e.printStackTrace();
            request.setAttribute("message",
                    "Please fill in all numeric fields correctly.");
            request.setAttribute("messageType", "danger");
            request.getRequestDispatcher("sell.jsp").forward(request, response);
        } catch (SQLException e) {
            e.printStackTrace();
            request.setAttribute("message",
                    "Database error while creating auction. Check server logs.");
            request.setAttribute("messageType", "danger");
            request.getRequestDispatcher("sell.jsp").forward(request, response);
        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("message",
                    "Unexpected error. Please try again.");
            request.setAttribute("messageType", "danger");
            request.getRequestDispatcher("sell.jsp").forward(request, response);
        }
    }
}
