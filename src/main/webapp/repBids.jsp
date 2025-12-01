<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.List" %>
<%@ page import="com.buyme.model.AuctionSummary" %>
<!DOCTYPE html>
<html>
<head>
    <title>Manage Bids - BuyMe</title>
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">

    <style>
        body {
            font-family: system-ui, -apple-system, BlinkMacSystemFont, "Segoe UI", sans-serif;
            background: #fff5fb;
        }
        .top-bar {
            background: #06630b;
            color: #fff;
            padding: 14px 48px;
            display: flex;
            align-items: center;
            justify-content: space-between;
        }
        .top-bar .brand { font-weight: 700; font-size: 24px; }
        .top-bar nav a {
            color: #fff;
            text-decoration: none;
            margin-left: 24px;
            font-weight: 500;
            font-size: 15px;
        }
        .top-bar nav a:hover { text-decoration: underline; }

        .page-wrap { max-width: 1100px; margin: 32px auto; padding: 0 24px 40px; }
        .headline { font-weight: 700; font-size: 26px; margin-bottom: 10px; }
        .subtitle { color: #555; margin-bottom: 20px; }

        .auction-card {
            border-radius: 24px;
            background: #fff;
            box-shadow: 0 18px 45px rgba(249, 168, 212, .4);
            overflow: hidden;
            border: 1px solid #ffd4eb;
            display: flex;
            flex-direction: column;
            height: 100%;
        }
        .auction-card img {
            width: 100%;
            height: 260px;
            object-fit: cover;
        }
        .auction-body {
            padding: 16px 18px 18px;
        }
        .badge-top {
            background: #111827;
            color: #fff;
            font-size: 11px;
            padding: 4px 10px;
            border-radius: 999px;
            font-weight: 600;
            text-transform: uppercase;
            margin-right: 6px;
        }
        .badge-type {
            background: #fff;
            color: #111827;
            font-size: 11px;
            padding: 4px 10px;
            border-radius: 999px;
            font-weight: 600;
            text-transform: uppercase;
        }
        .title { font-weight: 700; font-size: 18px; margin-top: 10px; }
        .brand { color: #4b5563; font-size: 14px; }

        .pill-attr {
            display: inline-block;
            padding: 4px 10px;
            font-size: 12px;
            border-radius: 999px;
            background: #f9fafb;
            margin-right: 6px;
            margin-top: 8px;
        }
        .price {
            font-weight: 700;
            font-size: 20px;
            margin-top: 10px;
        }
        .meta {
            font-size: 13px;
            color: #4b5563;
        }
        .card-footer {
            padding: 12px 18px 16px;
            border-top: 1px solid #f3e0ff;
            display: flex;
            justify-content: flex-end;
        }
        .btn-main {
            background: #ff4a93;
            color: #fff;
            border-radius: 999px;
            padding: 7px 16px;
            font-size: 14px;
            border: none;
        }
        .btn-main:hover { background: #ff2279; }
    </style>
</head>
<body>

<div class="top-bar">
    <div class="brand">BuyMe</div>
    <nav>
        <a href="${pageContext.request.contextPath}/browse">Browse</a>
        <a href="${pageContext.request.contextPath}/myActivity">My activity</a>
        <a href="${pageContext.request.contextPath}/sell">Sell</a>
        <a href="${pageContext.request.contextPath}/alerts">Alerts</a>
        <a href="${pageContext.request.contextPath}/rep/support">Support</a>
        <a href="${pageContext.request.contextPath}/logout">Logout</a>
    </nav>
</div>

<div class="page-wrap">
    <div class="headline">Manage bids</div>
    <div class="subtitle">
        Pick an auction to review all bids placed on it and remove anything abusive or mistaken.
    </div>

    <%
        List<AuctionSummary> auctions = (List<AuctionSummary>) request.getAttribute("auctions");
        if (auctions != null && !auctions.isEmpty()) {
    %>
    <div class="row g-4">
        <%
            for (AuctionSummary a : auctions) {
        %>
        <div class="col-md-3">
            <div class="auction-card">
                <img src="<%= (a.getPhotoUrl() != null ? a.getPhotoUrl() : "images/top1.jpg") %>"
                     alt="Item photo">

                <div class="auction-body">
                    <div>
                        <span class="badge-top">Live auction</span>
                        <span class="badge-type"><%= a.getStatus() %></span>
                    </div>
                    <div class="title"><%= a.getTitle() %></div>
                    <div class="brand"><%= a.getBrand() != null ? a.getBrand() : "" %></div>

                    <div class="mt-1">
                        <span class="pill-attr">Size <%= a.getSize() != null ? a.getSize() : "-" %></span>
                        <span class="pill-attr"><%= a.getColor() != null ? a.getColor() : "-" %></span>
                    </div>

                    <div class="price">
                        <% if (a.getCurrentHigh() != null) { %>
                        $<%= a.getCurrentHigh() %>
                        <% } else { %>
                        No bids yet
                        <% } %>
                    </div>
                    <div class="meta">
                        Ends on
                        <%= a.getEndTime() != null ? a.getEndTime().toString() : "N/A" %>
                    </div>
                </div>

                <div class="card-footer">
                    <a class="btn-main"
                       href="${pageContext.request.contextPath}/rep/auctionBids?auctionId=<%= a.getAuctionId() %>">
                        Manage bids
                    </a>
                </div>
            </div>
        </div>
        <% } %>
    </div>
    <% } else { %>
        <div class="alert alert-info">No auctions found.</div>
    <% } %>

    <div class="mt-4">
        <a href="${pageContext.request.contextPath}/rep/dashboard"
           class="btn btn-outline-secondary">
            Back to rep dashboard
        </a>
    </div>
</div>

</body>
</html>
