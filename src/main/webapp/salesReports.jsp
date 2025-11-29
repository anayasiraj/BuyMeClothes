<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.*, java.math.BigDecimal" %>
<!DOCTYPE html>
<html>
<head>
    <title>Sales Reports - BuyMe</title>
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">

    <style>
        body { font-family: system-ui, -apple-system, BlinkMacSystemFont, "Segoe UI", sans-serif; background:#f6f7fb; }
        .top-bar { background:#040252; color:#fff; padding:14px 48px; display:flex; align-items:center; justify-content:space-between; }
        .top-bar .brand { font-weight:700; font-size:24px; }
        .top-bar nav a { color:#fff; text-decoration:none; margin-left:24px; font-weight:500; font-size:15px; }
        .top-bar nav a:hover { text-decoration:underline; }

        .page-wrap { max-width:1200px; margin:40px auto; padding:0 24px; }
        .headline { font-weight:700; font-size:26px; margin-bottom:6px; }
        .subtitle { color:#555; margin-bottom:18px; }
        .metric-card { border-radius:18px; box-shadow:0 18px 45px rgba(15,23,42,.12); border:1px solid #f0f0f5; padding:18px 22px; background:#fff; }
        .metric-label { font-size:13px; text-transform:uppercase; letter-spacing:.08em; color:#888; font-weight:600; }
        .metric-value { font-size:28px; font-weight:700; margin-top:4px; }

        .section-card { border-radius:18px; box-shadow:0 18px 45px rgba(15,23,42,.12); border:1px solid #f0f0f5; padding:18px 22px; background:#fff; margin-top:24px; }
        .section-title { font-size:18px; font-weight:600; margin-bottom:10px; }
        .badge-best { background:#ff4a93; }
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
    <%
        BigDecimal totalEarnings = (BigDecimal) request.getAttribute("totalEarnings");
        if (totalEarnings == null) { totalEarnings = BigDecimal.ZERO; }

        List<Map<String,Object>> itemEarnings =
                (List<Map<String,Object>>) request.getAttribute("itemEarnings");
        List<Map<String,Object>> categoryEarnings =
                (List<Map<String,Object>>) request.getAttribute("categoryEarnings");
        List<Map<String,Object>> sellerEarnings =
                (List<Map<String,Object>>) request.getAttribute("sellerEarnings");
    %>

    <div class="d-flex justify-content-between align-items-center mb-3">
        <div>
            <div class="headline">Sales reports</div>
            <div class="subtitle">
                Summary of closed auctions: total earnings, earnings by item, category, and seller.
            </div>
        </div>
        <div>
            <a href="${pageContext.request.contextPath}/adminDashboard.jsp" class="btn btn-outline-secondary btn-sm">
                ← Back to admin dashboard
            </a>
        </div>
    </div>

    <!-- Top metric: total earnings -->
    <div class="row g-3 mb-3">
        <div class="col-md-4">
            <div class="metric-card">
                <div class="metric-label">Total earnings</div>
                <div class="metric-value">$<%= totalEarnings.setScale(2, BigDecimal.ROUND_HALF_UP) %></div>
                <div class="text-muted" style="font-size:13px;">
                    Sum of closing prices for all closed auctions.
                </div>
            </div>
        </div>

        <%
            // precompute "best-selling" item and user by revenue
            Map<String,Object> bestItem = null;
            Map<String,Object> bestSeller = null;
            if (itemEarnings != null && !itemEarnings.isEmpty()) {
                bestItem = itemEarnings.get(0);
            }
            if (sellerEarnings != null && !sellerEarnings.isEmpty()) {
                bestSeller = sellerEarnings.get(0);
            }
        %>

        <div class="col-md-4">
            <div class="metric-card">
                <div class="metric-label">Best-selling item</div>
                <% if (bestItem != null) { %>
                    <div class="metric-value" style="font-size:20px;">
                        <%= bestItem.get("title") %>
                    </div>
                    <div class="text-muted" style="font-size:13px;">
                        <span class="badge rounded-pill badge-best text-white me-1">Top</span>
                        Revenue: $
                        <%= ((BigDecimal) bestItem.get("total_revenue")).setScale(2, BigDecimal.ROUND_HALF_UP) %>,
                        Sales: <%= bestItem.get("num_sales") %>
                    </div>
                <% } else { %>
                    <div class="text-muted">No closed auctions yet.</div>
                <% } %>
            </div>
        </div>

        <div class="col-md-4">
            <div class="metric-card">
                <div class="metric-label">Top seller</div>
                <% if (bestSeller != null) { %>
                    <div class="metric-value" style="font-size:20px;">
                        <%= bestSeller.get("username") %>
                    </div>
                    <div class="text-muted" style="font-size:13px;">
                        <span class="badge rounded-pill badge-best text-white me-1">Top</span>
                        Revenue: $
                        <%= ((BigDecimal) bestSeller.get("total_revenue")).setScale(2, BigDecimal.ROUND_HALF_UP) %>,
                        Sales: <%= bestSeller.get("num_sales") %>
                    </div>
                <% } else { %>
                    <div class="text-muted">No sellers with closed auctions yet.</div>
                <% } %>
            </div>
        </div>
    </div>

    <!-- Earnings per item -->
    <div class="section-card">
        <div class="section-title">Earnings by item</div>
        <%
            if (itemEarnings == null || itemEarnings.isEmpty()) {
        %>
        <p class="text-muted mb-0">No closed auctions yet.</p>
        <%
            } else {
        %>
        <div class="table-responsive">
            <table class="table align-middle">
                <thead>
                <tr>
                    <th>#</th>
                    <th>Item</th>
                    <th>Item ID</th>
                    <th>Sales</th>
                    <th>Total revenue</th>
                </tr>
                </thead>
                <tbody>
                <%
                    int rank = 1;
                    for (Map<String,Object> row : itemEarnings) {
                        BigDecimal rev = (BigDecimal) row.get("total_revenue");
                %>
                <tr>
                    <td><%= rank++ %></td>
                    <td><strong><%= row.get("title") %></strong></td>
                    <td><%= row.get("item_id") %></td>
                    <td><%= row.get("num_sales") %></td>
                    <td>$<%= rev.setScale(2, BigDecimal.ROUND_HALF_UP) %></td>
                </tr>
                <%
                    }
                %>
                </tbody>
            </table>
        </div>
        <%
            }
        %>
    </div>

    <!-- Earnings per category -->
    <div class="section-card">
        <div class="section-title">Earnings by category</div>
        <%
            if (categoryEarnings == null || categoryEarnings.isEmpty()) {
        %>
        <p class="text-muted mb-0">No closed auctions with categories yet.</p>
        <%
            } else {
        %>
        <div class="table-responsive">
            <table class="table align-middle">
                <thead>
                <tr>
                    <th>#</th>
                    <th>Category</th>
                    <th>Category ID</th>
                    <th>Sales</th>
                    <th>Total revenue</th>
                </tr>
                </thead>
                <tbody>
                <%
                    int rankC = 1;
                    for (Map<String,Object> row : categoryEarnings) {
                        BigDecimal rev = (BigDecimal) row.get("total_revenue");
                %>
                <tr>
                    <td><%= rankC++ %></td>
                    <td><strong><%= row.get("category_name") %></strong></td>
                    <td><%= row.get("category_id") %></td>
                    <td><%= row.get("num_sales") %></td>
                    <td>$<%= rev.setScale(2, BigDecimal.ROUND_HALF_UP) %></td>
                </tr>
                <%
                    }
                %>
                </tbody>
            </table>
        </div>
        <%
            }
        %>
    </div>

    <!-- Earnings per seller -->
    <div class="section-card mb-4">
        <div class="section-title">Earnings by seller</div>
        <%
            if (sellerEarnings == null || sellerEarnings.isEmpty()) {
        %>
        <p class="text-muted mb-0">No sellers with closed auctions yet.</p>
        <%
            } else {
        %>
        <div class="table-responsive">
            <table class="table align-middle">
                <thead>
                <tr>
                    <th>#</th>
                    <th>Seller</th>
                    <th>User ID</th>
                    <th>Sales</th>
                    <th>Total revenue</th>
                </tr>
                </thead>
                <tbody>
                <%
                    int rankS = 1;
                    for (Map<String,Object> row : sellerEarnings) {
                        BigDecimal rev = (BigDecimal) row.get("total_revenue");
                %>
                <tr>
                    <td><%= rankS++ %></td>
                    <td><strong><%= row.get("username") %></strong></td>
                    <td><%= row.get("user_id") %></td>
                    <td><%= row.get("num_sales") %></td>
                    <td>$<%= rev.setScale(2, BigDecimal.ROUND_HALF_UP) %></td>
                </tr>
                <%
                    }
                %>
                </tbody>
            </table>
        </div>
        <%
            }
        %>
    </div>
</div>

</body>
</html>
