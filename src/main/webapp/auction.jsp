<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.buyme.model.AuctionDetail" %>
<%@ page import="com.buyme.model.BidSummary" %>
<%@ page import="com.buyme.model.AuctionSummary" %>
<%@ page import="java.util.List" %>
<%@ page import="java.math.BigDecimal" %>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>BuyMe | Auction</title>
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
        .hero-strip { padding: 2rem 1rem; }
        .hero-title { font-size: 2rem; font-weight: 700; }
        .hero-sub { color: #555; }
        .img-main {
            border-radius: 1.25rem;
            box-shadow: 0 16px 40px rgba(0,0,0,0.12);
            object-fit: cover;
            width: 100%;
            max-height: 420px;
        }
        .pill-meta {
            border-radius: 999px;
            font-size: .8rem;
            padding: .25rem .8rem;
            background: #f5f5f5;
        }
    </style>
</head>
<body>

<%
    AuctionDetail detail = (AuctionDetail) request.getAttribute("detail");
    List<BidSummary> recentBids = (List<BidSummary>) request.getAttribute("recentBids");
    List<AuctionSummary> similarAuctions =
            (List<AuctionSummary>) request.getAttribute("similarAuctions");

    if (detail == null) {
%>
    <div class="container py-5">
        <div class="alert alert-danger">Auction not found.</div>
    </div>
</body>
</html>
<%
        return;
    }

    // new: status / winner info from servlet
    String auctionStatus = (String) request.getAttribute("auctionStatus");
    if (auctionStatus == null) auctionStatus = "open";

    String winnerUsername = (String) request.getAttribute("winnerUsername");
    Boolean isWinnerViewerObj = (Boolean) request.getAttribute("isWinnerViewer");
    boolean isWinnerViewer = (isWinnerViewerObj != null && isWinnerViewerObj);

    BigDecimal current = detail.getCurrentHigh() != null
            ? detail.getCurrentHigh()
            : detail.getStartPrice();

    BigDecimal minNext = current.add(detail.getBidIncrement());

    // Flash messages (use implicit JSP session)
    String flashMessage = (String) session.getAttribute("flashMessage");
    String flashType    = (String) session.getAttribute("flashType");
    session.removeAttribute("flashMessage");
    session.removeAttribute("flashType");
%>

<nav class="navbar navbar-expand-lg navbar-buyme">
    <div class="container-fluid px-4">
        <a class="navbar-brand" href="browse">BuyMe</a>

        <button class="navbar-toggler" type="button" data-bs-toggle="collapse"
                data-bs-target="#buymeNav">
            <span class="navbar-toggler-icon" style="filter: invert(1);"></span>
        </button>

        <div class="collapse navbar-collapse" id="buymeNav">
            <ul class="navbar-nav ms-auto">
                <li class="nav-item"><a class="nav-link" href="browse">Browse</a></li>
                <li class="nav-item"><a class="nav-link" href="myActivity">My activity</a></li>
                <li class="nav-item"><a class="nav-link" href="#">Sell</a></li>
                <li class="nav-item"><a class="nav-link" href="alerts">Alerts</a></li>
                <li class="nav-item"><a href="${pageContext.request.contextPath}/support" class="nav-link">Support</a></li>

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

                <li class="nav-item"><a class="nav-link" href="logout.jsp">Logout</a></li>
            </ul>
        </div>
    </div>
</nav>

<%-- Winner banner (only if closed AND viewer is winner) --%>
<% if ("closed".equalsIgnoreCase(auctionStatus) && isWinnerViewer) { %>
<div class="container mt-3">
    <div class="alert alert-success alert-dismissible fade show" role="alert">
        🎉 Congratulations! You won this auction for
        <strong>
            $<%= detail.getCurrentHigh() != null
                    ? detail.getCurrentHigh().toPlainString()
                    : detail.getStartPrice() != null
                        ? detail.getStartPrice().toPlainString()
                        : "0.00" %>
        </strong>.
        <button type="button" class="btn-close" data-bs-dismiss="alert"
                aria-label="Close"></button>
    </div>
</div>
<% } %>

<section class="hero-strip">
    <div class="container">

        <% if (flashMessage != null) { %>
        <div class="alert alert-<%= flashType != null ? flashType : "info" %>">
            <%= flashMessage %>
        </div>
        <% } %>

        <div class="row g-4">

            <!-- LEFT: Images -->
            <div class="col-md-5">
                <img src="<%= detail.getPhotoUrl1() %>" class="img-main mb-3">

                <div class="d-flex gap-2">
                    <% if (detail.getPhotoUrl2() != null) { %>
                        <img src="<%= detail.getPhotoUrl2() %>" class="img-thumbnail" style="max-height:90px;">
                    <% } %>
                    <% if (detail.getPhotoUrl3() != null) { %>
                        <img src="<%= detail.getPhotoUrl3() %>" class="img-thumbnail" style="max-height:90px;">
                    <% } %>
                </div>
            </div>

            <!-- MIDDLE: Description -->
            <div class="col-md-4">
                <h1 class="hero-title"><%= detail.getTitle() %></h1>

                <%-- NEW: LIVE / CLOSED + winner/not-met label --%>
                <div class="mt-2 mb-2">
                    <% if ("closed".equalsIgnoreCase(auctionStatus)) { %>
                        <span class="badge rounded-pill bg-secondary me-2">
                            CLOSED
                        </span>
                        <% if (winnerUsername != null && !winnerUsername.isBlank()) { %>
                            <span class="text-muted">
                                Won by <strong><%= winnerUsername %></strong>
                            </span>
                        <% } else { %>
                            <span class="text-muted">
                                No winner (reserve not met)
                            </span>
                        <% } %>
                    <% } else { %>
                        <span class="badge rounded-pill bg-dark">
                            LIVE AUCTION
                        </span>
                    <% } %>
                </div>

                <p class="hero-sub mb-3">
                    <%= detail.getBrand() != null ? detail.getBrand() : "" %>
                    <% if (detail.getSize() != null) { %>
                        • Size <%= detail.getSize() %>
                    <% } %>
                    <% if (detail.getColor() != null) { %>
                        • <%= detail.getColor() %>
                    <% } %>
                </p>

                <p class="mb-3"><%= detail.getDescription() %></p>

                <div class="d-flex flex-wrap gap-2 mb-3">
                    <span class="pill-meta">Seller: <%= detail.getSellerUsername() %></span>
                    <span class="pill-meta">Start price $<%= detail.getStartPrice() %></span>
                    <span class="pill-meta">Bid step $<%= detail.getBidIncrement() %></span>
                </div>

                <div class="mt-3">
                    <h4>$<%= current %></h4>
                    <small class="text-muted">
                        Current highest bid<br>
                        <% if (detail.getEndTime() != null) { %>
                            Ends on <%= new java.text.SimpleDateFormat("MMM dd, yyyy HH:mm").format(detail.getEndTime()) %>
                        <% } %>
                    </small>
                </div>
            </div>

            <!-- RIGHT: Bidding -->
            <div class="col-md-3">

                <!-- Recent bids -->
                <div class="card mb-4">
                    <div class="card-header fw-semibold">Recent bids</div>
                    <div class="card-body p-0">

                        <% if (recentBids == null || recentBids.isEmpty()) { %>
                            <div class="p-3 text-muted small">No bids yet – be the first.</div>
                        <% } else { %>
                            <ul class="list-group list-group-flush">
                                <% for (BidSummary b : recentBids) { %>
                                    <li class="list-group-item d-flex justify-content-between small">
                                        <strong><%= b.getBidderUsername() %></strong>
                                        <span>$<%= b.getAmount() %></span>
                                    </li>
                                <% } %>
                            </ul>
                        <% } %>

                    </div>
                </div>

                <!-- Bid form / closed notice -->
                <div class="card">
                    <div class="card-header fw-semibold">Current highest bid</div>
                    <div class="card-body">
                        <h4>$<%= current %></h4>

                        <% if ("closed".equalsIgnoreCase(auctionStatus)) { %>
                            <p class="small text-muted mt-3">
                                This auction has ended. Bidding is no longer available.
                            </p>
                        <% } else { %>
                            <p class="small">Minimum next bid:
                                <strong>$<%= minNext %></strong></p>

                            <form action="bid" method="post">
                                <input type="hidden" name="auctionId" value="<%= detail.getAuctionId() %>">

                                <div class="mb-3">
                                    <label class="form-label">Your bid amount</label>
                                    <input type="number" name="amount" step="0.01"
                                           class="form-control" value="<%= minNext %>">
                                </div>

                                <div class="mb-3">
                                    <label class="form-label">
                                        Max auto-bid (optional)
                                        <span class="small text-muted d-block">
                                            We will auto-bid up to this limit.
                                        </span>
                                    </label>
                                    <input type="number" name="maxAutoBid" step="0.01"
                                           class="form-control" placeholder="e.g. 200.00">
                                </div>

                                <button class="btn text-white w-100" style="background: var(--buyme-pink);">
                                    Place bid
                                </button>
                            </form>
                        <% } %>

                    </div>
                </div>

            </div>

        </div>
    </div>

    <!-- Similar items section -->
    <hr class="my-5">

    <div class="row">
        <div class="col-12">
            <h3 class="mb-3">Similar items from the last month</h3>
        </div>
    </div>

    <%
        if (similarAuctions == null || similarAuctions.isEmpty()) {
    %>
        <div class="row">
            <div class="col-12">
                <p class="text-muted">No similar items from the last month.</p>
            </div>
        </div>
    <%
        } else {
    %>
        <div class="row g-3">
            <% for (AuctionSummary s : similarAuctions) { %>
                <div class="col-sm-6 col-md-4 col-lg-3">
                    <div class="card card-auction h-100">
                        <img src="<%= s.getPhotoUrl() %>" class="card-img-top" alt="<%= s.getTitle() %>">
                        <div class="card-body d-flex flex-column">
                            <h6 class="mb-1"><%= s.getTitle() %></h6>
                            <p class="text-muted mb-2">
                                <%= s.getBrand() != null ? s.getBrand() : "" %>
                            </p>
                            <div class="d-flex flex-wrap gap-2 mb-2">
                                <span class="pill-meta">
                                    Size <%= s.getSize() != null ? s.getSize() : "N/A" %>
                                </span>
                                <span class="pill-meta">
                                    <%= s.getColor() != null ? s.getColor() : "Color N/A" %>
                                </span>
                            </div>

                            <div class="mt-auto d-flex justify-content-between align-items-end">
                                <div>
                                    <div class="fw-bold">
                                        $<%= s.getCurrentHigh() != null ? s.getCurrentHigh() : s.getStartPrice() %>
                                    </div>
                                    <% if (s.getEndTime() != null) { %>
                                        <small class="text-muted">
                                            Ends <%= new java.text.SimpleDateFormat("MMM dd, yyyy HH:mm")
                                                    .format(s.getEndTime()) %>
                                        </small>
                                    <% } %>
                                </div>
                                <a href="auction?id=<%= s.getAuctionId() %>" class="btn btn-sm"
                                   style="background: var(--buyme-pink); color:#fff;">
                                    View
                                </a>
                            </div>
                        </div>
                    </div>
                </div>
            <% } %>
        </div>
    <%
        }
    %>

</section>

<!-- Bootstrap JS for dismissible alerts -->
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>

</body>
</html>
