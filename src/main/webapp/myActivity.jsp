<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.List" %>
<%@ page import="com.buyme.model.AuctionSummary" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>BuyMe | My Activity</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <style>
        :root { --buyme-pink: #ff4f87; }
        body {
            min-height: 100vh;
            background: linear-gradient(180deg, #ffe3ef 0%, #ffffff 40%, #f7f7f7 100%);
        }
        .navbar-buyme {
            background: var(--buyme-pink);
        }
        .navbar-buyme .navbar-brand,
        .navbar-buyme .nav-link {
            color: #fff !important;
            font-weight: 500;
        }
        .section-title {
            font-size: 1.4rem;
            font-weight: 700;
        }
        .card-auction {
            border-radius: 1.1rem;
            box-shadow: 0 10px 30px rgba(0,0,0,0.06);
            overflow: hidden;
            transition: transform .18s ease, box-shadow .18s ease;
            background-color: #fff;
        }
        .card-auction:hover {
            transform: translateY(-3px);
            box-shadow: 0 16px 40px rgba(0,0,0,0.12);
        }
        .card-auction img {
            height: 200px;
            object-fit: cover;
        }
        .pill-meta {
            border-radius: 999px;
            font-size: .8rem;
            padding: .25rem .7rem;
            background: #f5f5f5;
        }
    </style>
</head>
<body>

<nav class="navbar navbar-expand-lg navbar-buyme">
    <div class="container-fluid px-4">
        <a class="navbar-brand" href="browse">BuyMe</a>
        <button class="navbar-toggler" type="button" data-bs-toggle="collapse"
                data-bs-target="#buymeNav" aria-controls="buymeNav"
                aria-expanded="false" aria-label="Toggle navigation">
            <span class="navbar-toggler-icon" style="filter: invert(1);"></span>
        </button>
        <div class="collapse navbar-collapse" id="buymeNav">
            <ul class="navbar-nav ms-auto mb-2 mb-lg-0">
                <li class="nav-item"><a class="nav-link" href="browse">Browse</a></li>
                <li class="nav-item"><a class="nav-link" href="myActivity">My activity</a></li>
                <li class="nav-item"><a class="nav-link" href="sell">Sell</a></li>
                <li class="nav-item"><a class="nav-link" href="alerts">Alerts</a></li>
                <li class="nav-item"><a class="nav-link" href="${pageContext.request.contextPath}/support">Support</a></li>
                
                <%-- ADMIN-ONLY LINK --%>
                <%
                    String role = (String) session.getAttribute("role");
                    if ("admin".equals(role)) {
                %>
                    <li class="nav-item">
                        <a class="nav-link fw-semibold" href="admin/dashboard">
                            Admin dashboard
                        </a>
                    </li>
                <%
                    }
                %>
                
                <%-- REP-ONLY LINK --%>
                <%
                    String role1 = (String) session.getAttribute("role");
                    if ("cust_rep".equals(role1)) {
                %>
                    <li class="nav-item">
                        <a class="nav-link fw-semibold" href="rep/dashboard">
                            Rep dashboard
                        </a>
                    </li>
                <%
                    }
                %>
                
                
                <li class="nav-item"><a class="nav-link" href="logout.jsp">Logout</a></li>
            </ul>
        </div>
    </div>
</nav>

<%
    List<AuctionSummary> myBids =
            (List<AuctionSummary>) request.getAttribute("myBids");
    List<AuctionSummary> mySelling =
            (List<AuctionSummary>) request.getAttribute("mySelling");
    String error = (String) request.getAttribute("error");
%>

<div class="container my-4 my-md-5">
    <% if (error != null) { %>
        <div class="alert alert-danger"><%= error %></div>
    <% } %>

    <!-- Section: auctions I've bid on -->
    <div class="mb-4">
        <div class="d-flex justify-content-between align-items-center mb-2">
            <h2 class="section-title mb-0">Auctions I’ve bid on</h2>
            <% if (myBids == null || myBids.isEmpty()) { %>
                <span class="text-muted small">No bids yet.</span>
            <% } %>
        </div>

        <% if (myBids != null && !myBids.isEmpty()) { %>
            <div class="row g-3">
                <% for (AuctionSummary a : myBids) { %>
                    <div class="col-sm-6 col-md-4 col-lg-3">
                        <div class="card card-auction h-100">
                            <img src="<%= a.getPhotoUrl() %>" class="card-img-top" alt="<%= a.getTitle() %>">
                            <div class="card-body d-flex flex-column">
                                <h6 class="mb-1"><%= a.getTitle() %></h6>
                                <p class="text-muted mb-2">
                                    <%= a.getBrand() != null ? a.getBrand() : "" %>
                                </p>
                                <div class="d-flex flex-wrap gap-2 mb-2">
                                    <span class="pill-meta">
                                        Size <%= a.getSize() != null ? a.getSize() : "N/A" %>
                                    </span>
                                    <span class="pill-meta">
                                        <%= a.getColor() != null ? a.getColor() : "Color N/A" %>
                                    </span>
                                </div>

                                <div class="mt-auto d-flex justify-content-between align-items-end">
                                    <div>
                                        <div class="fw-bold">
                                            $<%= a.getCurrentHigh() != null ? a.getCurrentHigh() : a.getStartPrice() %>
                                        </div>
                                        <% if (a.getEndTime() != null) { %>
                                            <small class="text-muted">
                                                Ends <%= new java.text.SimpleDateFormat("MMM dd, yyyy HH:mm")
                                                        .format(a.getEndTime()) %>
                                            </small>
                                        <% } %>
                                    </div>
                                    <a href="auction?id=<%= a.getAuctionId() %>" class="btn btn-sm"
                                       style="background: var(--buyme-pink); color:#fff;">
                                        View
                                    </a>
                                </div>
                            </div>
                        </div>
                    </div>
                <% } %>
            </div>
        <% } %>
    </div>

    <hr class="my-4">

    <!-- Section: auctions I'm selling -->
    <div class="mb-4">
        <div class="d-flex justify-content-between align-items-center mb-2">
            <h2 class="section-title mb-0">Auctions I’m selling</h2>
            <% if (mySelling == null || mySelling.isEmpty()) { %>
                <span class="text-muted small">You’re not selling anything yet.</span>
            <% } %>
        </div>

        <% if (mySelling != null && !mySelling.isEmpty()) { %>
            <div class="row g-3">
                <% for (AuctionSummary a : mySelling) { %>
                    <div class="col-sm-6 col-md-4 col-lg-3">
                        <div class="card card-auction h-100">
                            <img src="<%= a.getPhotoUrl() %>" class="card-img-top" alt="<%= a.getTitle() %>">
                            <div class="card-body d-flex flex-column">
                                <h6 class="mb-1"><%= a.getTitle() %></h6>
                                <p class="text-muted mb-2">
                                    <%= a.getBrand() != null ? a.getBrand() : "" %>
                                </p>
                                <div class="d-flex flex-wrap gap-2 mb-2">
                                    <span class="pill-meta">
                                        Size <%= a.getSize() != null ? a.getSize() : "N/A" %>
                                    </span>
                                    <span class="pill-meta">
                                        <%= a.getColor() != null ? a.getColor() : "Color N/A" %>
                                    </span>
                                </div>

                                <div class="mt-auto d-flex justify-content-between align-items-end">
                                    <div>
                                        <div class="fw-bold">
                                            $<%= a.getCurrentHigh() != null ? a.getCurrentHigh() : a.getStartPrice() %>
                                        </div>
                                        <% if (a.getEndTime() != null) { %>
                                            <small class="text-muted">
                                                Ends <%= new java.text.SimpleDateFormat("MMM dd, yyyy HH:mm")
                                                        .format(a.getEndTime()) %>
                                            </small>
                                        <% } %>
                                    </div>
                                    <a href="auction?id=<%= a.getAuctionId() %>" class="btn btn-sm"
                                       style="background: var(--buyme-pink); color:#fff;">
                                        View
                                    </a>
                                </div>
                            </div>
                        </div>
                    </div>
                <% } %>
            </div>
        <% } %>
    </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
