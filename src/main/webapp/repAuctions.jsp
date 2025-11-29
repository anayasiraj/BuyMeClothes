<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.List" %>
<%@ page import="com.buyme.model.AuctionSummary" %>
<!DOCTYPE html>
<html>
<head>
    <title>Manage auctions - BuyMe</title>
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
        .top-bar .brand {
            font-weight: 700;
            font-size: 24px;
        }
        .top-bar nav a {
            color: #fff;
            text-decoration: none;
            margin-left: 24px;
            font-weight: 500;
            font-size: 15px;
        }
        .top-bar nav a:hover {
            text-decoration: underline;
        }
        .page-wrap {
            max-width: 1100px;
            margin: 40px auto;
            padding: 0 24px;
        }
        .headline {
            font-weight: 700;
            font-size: 24px;
            margin-bottom: 8px;
        }
        .subtitle {
            color: #555;
            margin-bottom: 20px;
        }
        .badge-soft {
            background: #f1f1f6;
            border-radius: 999px;
            padding: 2px 8px;
            font-size: 11px;
        }
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
        <a href="${pageContext.request.contextPath}/rep/dashboard">Support</a>
        <a href="${pageContext.request.contextPath}/logout">Logout</a>
    </nav>
</div>

<div class="page-wrap">
    <div class="headline">Delete auctions</div>
    <div class="subtitle">
        Customer representatives can remove auctions that are fraudulent, unsafe,
        or violate marketplace rules. Deletions are permanent.
    </div>

    <%
        String flash = (String) session.getAttribute("repMessage");
        if (flash != null) {
    %>
        <div class="alert alert-info"><%= flash %></div>
    <%
            session.removeAttribute("repMessage");
        }

        List<AuctionSummary> auctions =
                (List<AuctionSummary>) request.getAttribute("auctions");
        if (auctions == null || auctions.isEmpty()) {
    %>
        <div class="alert alert-secondary">
            There are no open auctions to moderate right now.
        </div>
    <%
        } else {
    %>

    <div class="table-responsive">
        <table class="table table-sm align-middle">
            <thead>
            <tr>
                <th>ID</th>
                <th>Item</th>
                <th>Brand</th>
                <th>Size / Color</th>
                <th>Category</th>
                <th>Current / Start</th>
                <th>Ends</th>
                <th class="text-end">Actions</th>
            </tr>
            </thead>
            <tbody>
            <%
                for (AuctionSummary a : auctions) {
            %>
            <tr>
                <td>#<%= a.getAuctionId() %></td>
                <td><strong><%= a.getTitle() %></strong></td>
                <td><%= a.getBrand() != null ? a.getBrand() : "-" %></td>
                <td>
                    <span class="badge-soft">
                        <%= a.getSize() != null ? a.getSize() : "-" %>
                    </span>
                    &nbsp;
                    <span class="badge-soft">
                        <%= a.getColor() != null ? a.getColor() : "-" %>
                    </span>
                </td>
                <td><%= a.getCategoryName() %></td>
                <td>
                    <% if (a.getCurrentHigh() != null) { %>
                        $<%= a.getCurrentHigh() %>
                        <span class="text-muted">(start $<%= a.getStartPrice() %>)</span>
                    <% } else { %>
                        $<%= a.getStartPrice() %>
                    <% } %>
                </td>
                <td><%= a.getEndTime() %></td>
                <td class="text-end">
                    <form method="post"
                          action="${pageContext.request.contextPath}/rep/deleteAuction"
                          class="d-inline"
                          onsubmit="return confirm('Delete auction #<%= a.getAuctionId() %> (\\'<%= a.getTitle() %>\\')? This cannot be undone.');">
                        <input type="hidden" name="auctionId"
                               value="<%= a.getAuctionId() %>">
                        <button type="submit"
                                class="btn btn-sm btn-outline-danger">
                            Delete
                        </button>
                    </form>
                </td>
            </tr>
            <%
                }
            %>
            </tbody>
        </table>
    </div>
    
    <div class="mt-3">
        <a href="${pageContext.request.contextPath}/rep/dashboard" class="btn btn-outline-secondary">
            Back to rep dashboard
        </a>
    </div>

    <%
        }
    %>
</div>

</body>
</html>
