<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.List" %>
<%@ page import="com.buyme.model.AuctionSummary" %>
<%@ page import="com.buyme.model.BidInfo" %>
<!DOCTYPE html>
<html>
<head>
    <title>Manage Bids - BuyMe</title>
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">

    <style>
        body {
            font-family: system-ui, -apple-system, BlinkMacSystemFont, "Segoe UI", sans-serif;
            background: #f6f7fb;
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

        .page-wrap { max-width: 1000px; margin: 32px auto; padding: 0 24px 40px; }
        .headline { font-weight: 700; font-size: 24px; margin-bottom: 6px; }
        .subtitle { color: #555; margin-bottom: 18px; }

        .auction-summary {
            border-radius: 18px;
            background: #fff;
            box-shadow: 0 14px 35px rgba(15,23,42,.08);
            border: 1px solid #f0f0f5;
            padding: 20px 22px;
            margin-bottom: 20px;
        }
        .badge-status {
            background: #111827;
            color: #fff;
            font-size: 11px;
            padding: 4px 10px;
            border-radius: 999px;
            text-transform: uppercase;
            font-weight: 600;
        }
        .btn-delete {
            border-radius: 999px;
        }
    </style>

    <script>
        function confirmDelete() {
            return confirm("Are you sure you want to delete this bid? This will recompute the auction's current price.");
        }
    </script>
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
    <%
        AuctionSummary auction = (AuctionSummary) request.getAttribute("auction");
        List<BidInfo> bids = (List<BidInfo>) request.getAttribute("bids");
    %>

    <div class="auction-summary">
        <div class="d-flex justify-content-between align-items-center mb-1">
            <div class="headline">
                Manage bids – Auction #<%= (auction != null ? auction.getAuctionId() : 0) %>
            </div>
            <span class="badge-status"><%= auction != null ? auction.getStatus() : "" %></span>
        </div>
        <div class="subtitle mb-0">
            <strong><%= auction != null ? auction.getTitle() : "" %></strong>
            <% if (auction != null && auction.getBrand() != null) { %>
                · <%= auction.getBrand() %>
            <% } %>
            <br>
            Current highest bid:
            <% if (auction != null && auction.getCurrentHigh() != null) { %>
                $<%= auction.getCurrentHigh() %>
            <% } else { %>
                No bids yet
            <% } %>
            <br>
            Ends on:
            <%= (auction != null && auction.getEndTime() != null)
                    ? auction.getEndTime().toString()
                    : "N/A" %>
        </div>
    </div>

    <div class="card">
        <div class="card-header">
            Bids on this auction
        </div>
        <div class="table-responsive">
            <table class="table mb-0 align-middle">
                <thead class="table-light">
                <tr>
                    <th scope="col">Bid ID</th>
                    <th scope="col">Bidder</th>
                    <th scope="col">Amount</th>
                    <th scope="col">Time</th>
                    <th scope="col" class="text-end">Action</th>
                </tr>
                </thead>
                <tbody>
                <% if (bids != null && !bids.isEmpty()) {
                       for (BidInfo b : bids) { %>
                    <tr>
                        <td><%= b.getBidId() %></td>
                        <td><%= b.getBidderUsername() %></td>
                        <td>$<%= b.getAmount() %></td>
                        <td><%= b.getBidTime() %></td>
                        <td class="text-end">
                            <form action="${pageContext.request.contextPath}/rep/deleteBid"
                                  method="post"
                                  class="d-inline"
                                  onsubmit="return confirmDelete();">
                                <input type="hidden" name="bidId" value="<%= b.getBidId() %>">
                                <input type="hidden" name="auctionId" value="<%= b.getAuctionId() %>">
                                <button type="submit" class="btn btn-sm btn-outline-danger btn-delete">
                                    Delete bid
                                </button>
                            </form>
                        </td>
                    </tr>
                <%   }
                   } else { %>
                    <tr>
                        <td colspan="5" class="text-center text-muted py-3">
                            No bids on this auction yet.
                        </td>
                    </tr>
                <% } %>
                </tbody>
            </table>
        </div>
    </div>

    <div class="mt-3">
        <a href="${pageContext.request.contextPath}/rep/bids"
           class="btn btn-outline-secondary">
            Back to auctions list
        </a>
    </div>
</div>

</body>
</html>
