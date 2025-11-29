<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.List" %>
<%@ page import="com.buyme.model.Alert" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>BuyMe | Alerts</title>
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
                <li class="nav-item"><a class="nav-link fw-semibold" href="alerts">Alerts</a></li>
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

<div class="container py-4 py-md-5">
    <h2 class="mb-4">Your alerts</h2>

    <%
        String error = (String) request.getAttribute("error");
        List<Alert> alerts = (List<Alert>) request.getAttribute("alerts");
    %>

    <% if (error != null) { %>
        <div class="alert alert-danger"><%= error %></div>
    <% } %>

    <!-- Create alert form -->
    <div class="card mb-4">
        <div class="card-header fw-semibold">Create a new alert</div>
        <div class="card-body">
            <form action="alerts" method="post" class="row g-3">
                <div class="col-md-4">
                    <label class="form-label">Alert name</label>
                    <input type="text" name="alertName" class="form-control" placeholder="e.g. Black jeans under $50" required>
                </div>
                <div class="col-md-2">
                    <label class="form-label">Size</label>
                    <input type="text" name="sizePref" class="form-control" placeholder="e.g. M">
                </div>
                <div class="col-md-2">
                    <label class="form-label">Color</label>
                    <input type="text" name="colorPref" class="form-control" placeholder="e.g. black">
                </div>
                <div class="col-md-4">
                    <label class="form-label">Keyword</label>
                    <input type="text" name="keyword" class="form-control" placeholder="e.g. blazer, Zara">
                </div>
                <div class="col-md-2">
                    <label class="form-label">Min price</label>
                    <input type="number" step="0.01" name="minPrice" class="form-control">
                </div>
                <div class="col-md-2">
                    <label class="form-label">Max price</label>
                    <input type="number" step="0.01" name="maxPrice" class="form-control">
                </div>
                <div class="col-md-2">
                    <label class="form-label">Category ID</label>
                    <input type="number" name="categoryId" class="form-control" placeholder="optional">
                </div>
                <div class="col-md-12">
                    <button type="submit" class="btn text-white" style="background: var(--buyme-pink);">
                        Save alert
                    </button>
                </div>
            </form>
        </div>
    </div>

    <!-- List alerts -->
    <% if (alerts == null || alerts.isEmpty()) { %>
        <div class="alert alert-light border text-muted">
            You don't have any alerts yet. Create one above and we’ll use it to match future listings.
        </div>
    <% } else { %>
        <div class="card">
            <div class="card-header fw-semibold">Saved alerts</div>
            <div class="card-body p-0">
                <table class="table mb-0">
                    <thead>
                    <tr>
                        <th>Name</th>
                        <th>Size</th>
                        <th>Color</th>
                        <th>Keyword</th>
                        <th>Price range</th>
                        <th>Category</th>
                        <th>Created</th>
                        <th></th>
                    </tr>
                    </thead>
                    <tbody>
                    <% for (Alert a : alerts) { %>
                        <tr>
                            <td><%= a.getAlertName() %></td>
                            <td><%= a.getSizePref() != null ? a.getSizePref() : "-" %></td>
                            <td><%= a.getColorPref() != null ? a.getColorPref() : "-" %></td>
                            <td><%= a.getKeyword() != null ? a.getKeyword() : "-" %></td>
                            <td>
                                <%
                                    String range = "";
                                    if (a.getMinPrice() != null) range += "$" + a.getMinPrice();
                                    if (a.getMaxPrice() != null) {
                                        if (!range.isEmpty()) range += " - ";
                                        range += "$" + a.getMaxPrice();
                                    }
                                    if (range.isEmpty()) range = "-";
                                %>
                                <%= range %>
                            </td>
                            <td><%= a.getCategoryName() != null ? a.getCategoryName() : (a.getCategoryId() != null ? a.getCategoryId() : "-") %></td>
                            <td><%= a.getCreatedAt() %></td>
                            <td>
                                <form action="alerts" method="post" class="d-inline">
                                    <input type="hidden" name="action" value="delete">
                                    <input type="hidden" name="alertId" value="<%= a.getAlertId() %>">
                                    <button type="submit"
                                            class="btn btn-sm btn-outline-danger">
                                        Delete
                                    </button>
                                </form>
                            </td>
                        </tr>
                    <% } %>
                    </tbody>
                </table>
            </div>
        </div>
    <% } %>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
