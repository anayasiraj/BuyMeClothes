<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.List" %>
<%@ page import="com.buyme.model.User" %>
<!DOCTYPE html>
<html>
<head>
    <title>Search Users - BuyMe</title>
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">

    <%
        // --- figure out role from session ---
        String role = (String) session.getAttribute("role");

        // navbar color based on role
        String barColor = "#ff4a93"; // default (just in case)
        if ("admin".equals(role)) {
            barColor = "#040252";     // navy blue
        } else if ("cust_rep".equals(role)) {
            barColor = "#06630b";     // green
        }

        // back button URL + text based on role
        String ctx = request.getContextPath();
        String backUrl  = ctx + "/admin/dashboard";
        String backText = "Back to admin dashboard";

        if ("cust_rep".equals(role)) {
            backUrl  = ctx + "/rep/dashboard";
            backText = "Back to rep dashboard";
        }
    %>

    <style>
        body {
            font-family: system-ui, -apple-system, BlinkMacSystemFont, "Segoe UI", sans-serif;
            background: #f6f7fb;
        }
        .top-bar {
            background: <%= barColor %>;
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
        .page-wrap { max-width: 1000px; margin: 40px auto; padding: 0 24px; }
        .headline { font-weight: 700; font-size: 26px; margin-bottom: 12px; }
        .subtitle { color: #555; margin-bottom: 20px; }
        .search-card {
            border-radius: 18px;
            box-shadow: 0 18px 45px rgba(15,23,42,.12);
            border: 1px solid #f0f0f5;
            padding: 20px 24px;
            background: #fff;
            margin-bottom: 20px;
        }
        .results-card {
            border-radius: 18px;
            box-shadow: 0 14px 35px rgba(15,23,42,.08);
            border: 1px solid #f0f0f5;
            background: #fff;
        }
        .btn-main {
            background: #ff4a93;
            color: #fff;
            border-radius: 999px;
            padding: 8px 18px;
            font-size: 14px;
            border: none;
        }
        .btn-main:hover { background: #ff2279; }
        .badge-role {
            background: #fff0f6;
            color: #ff4a93;
            border-radius: 999px;
            padding: 4px 10px;
            font-size: 11px;
            font-weight: 600;
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
        <a href="${pageContext.request.contextPath}/support">Support</a>
        <a href="${pageContext.request.contextPath}/logout">Logout</a>
    </nav>
</div>

<div class="page-wrap">
    <div class="headline">Search users</div>
    <div class="subtitle">
        Look up a buyer or seller by username or email before editing their profile or resetting credentials.
    </div>

    <div class="search-card">
        <form action="${pageContext.request.contextPath}/rep/searchUsers" method="get">
            <div class="row g-3 align-items-end">
                <div class="col-md-8">
                    <label class="form-label">Username or email</label>
                    <input type="text" name="query" class="form-control"
                           placeholder="e.g. varshini, buyer@example.com" required>
                </div>
                <div class="col-md-4 d-grid">
                    <button type="submit" class="btn-main">Search</button>
                </div>
            </div>
        </form>
    </div>

    <%
        List<User> results = (List<User>) request.getAttribute("results");
        if (results != null) {
    %>
    <div class="results-card">
        <div class="p-3 border-bottom">
            <strong>Results (<%= results.size() %>)</strong>
        </div>
        <div class="table-responsive">
            <table class="table mb-0 align-middle">
                <thead class="table-light">
                <tr>
                    <th scope="col">User ID</th>
                    <th scope="col">Username</th>
                    <th scope="col">Email</th>
                    <th scope="col">Role</th>
                    <th scope="col" class="text-end">Actions</th>
                </tr>
                </thead>
                <tbody>
                <%
                    for (User u : results) {
                %>
                <tr>
                    <td><%= u.getUserId() %></td>
                    <td><%= u.getUsername() %></td>
                    <td><%= u.getEmail() %></td>
                    <td><span class="badge-role"><%= u.getRole() %></span></td>
                    <td class="text-end">
                        <!-- Edit profile -->
                        <a class="btn btn-sm btn-outline-primary me-2"
                           href="${pageContext.request.contextPath}/rep/editUser?user_id=<%= u.getUserId() %>">
                            Edit profile
                        </a>

                        <!-- Delete account (admin / cust_rep only) -->
                        <%
                            if ("admin".equals(role) || "cust_rep".equals(role)) {
                        %>
                        <form action="${pageContext.request.contextPath}/rep/deleteUser"
                              method="post"
                              class="d-inline">
                            <input type="hidden" name="user_id" value="<%= u.getUserId() %>">
                            <button type="submit"
                                    class="btn btn-sm btn-outline-danger"
                                    onclick="return confirm('Delete user <%= u.getUsername() %>? This cannot be undone.');">
                                Delete
                            </button>
                        </form>
                        <%
                            }
                        %>
                    </td>
                </tr>
                <%
                    }
                %>
                </tbody>
            </table>
        </div>
    </div>
    <% } %>

    <div class="mt-3">
        <a href="<%= backUrl %>" class="btn btn-outline-secondary">
            <%= backText %>
        </a>
    </div>
</div>

</body>
</html>
