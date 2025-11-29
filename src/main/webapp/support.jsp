<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.*" %>
<!DOCTYPE html>
<html>
<head>
    <title>Support - BuyMe</title>
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">

    <style>
        body { font-family: system-ui, -apple-system, BlinkMacSystemFont, "Segoe UI", sans-serif; background:#f6f7fb; }
        .top-bar { background:#ff4a93; color:#fff; padding:14px 48px; display:flex; align-items:center; justify-content:space-between; }
        .top-bar .brand { font-weight:700; font-size:24px; }
        .top-bar nav a { color:#fff; text-decoration:none; margin-left:24px; font-weight:500; font-size:15px; }
        .top-bar nav a:hover { text-decoration:underline; }
        .page-wrap { max-width:1000px; margin:40px auto; padding:0 24px; }
        .headline { font-weight:700; font-size:26px; margin-bottom:8px; }
        .subtitle { color:#555; margin-bottom:20px; }
        .card-shell { border-radius:18px; box-shadow:0 18px 45px rgba(15,23,42,.12); border:1px solid #f0f0f5; padding:22px 24px; background:#fff; margin-bottom:24px; }
        .btn-main { background:#ff4a93; color:#fff; border-radius:999px; padding:8px 18px; font-size:14px; border:none; }
        .btn-main:hover { background:#ff2279; }
        .status-pill { display:inline-block; padding:3px 10px; border-radius:999px; font-size:11px; font-weight:600; text-transform:uppercase; }
        .status-open { background:#fff3cd; color:#856404; }
        .status-in_progress { background:#e3f2fd; color:#0d47a1; }
        .status-closed { background:#e8f5e9; color:#1b5e20; }
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
                
                <%-- ADMIN-ONLY LINK --%>
                <%
                    String role = (String) session.getAttribute("role");
                    if ("admin".equals(role)) {
                %>
                    <a href="admin/dashboard">Admin dashboard</a>
                <%
                    }
                %>
                
                <%-- REP-ONLY LINK --%>
                <%
                    String role1 = (String) session.getAttribute("role");
                    if ("cust_rep".equals(role1)) {
                %>
                    <a href="rep/dashboard">Rep dashboard</a>
                <%
                    }
                %>
                
                
                <a href="logout.jsp">Logout</a>
    </nav>
</div>

<div class="page-wrap">
    <div class="headline">Need help?</div>
    <div class="subtitle">
        Open a support ticket and a customer representative will get back to you.
    </div>

    <%
        String msg = (String) request.getAttribute("message");
        if (msg != null) {
    %>
    <div class="alert alert-info"><%= msg %></div>
    <% } %>

    <!-- New ticket form -->
    <div class="card-shell mb-4">
        <h2 class="h5 mb-3">Open a new ticket</h2>
        <form action="${pageContext.request.contextPath}/support" method="post">
            <div class="mb-3">
                <label class="form-label">Subject</label>
                <input type="text" name="subject" class="form-control" required
                       placeholder="Example: Problem with my recent bid">
            </div>
            <div class="mb-3">
                <label class="form-label">Describe the issue</label>
                <textarea name="description" class="form-control" rows="4" required
                          placeholder="Tell us what happened, including item title, seller, and any error messages."></textarea>
            </div>
            <button type="submit" class="btn-main">Submit ticket</button>
        </form>
    </div>

    <!-- My tickets -->
    <div class="card-shell">
        <h2 class="h5 mb-3">My tickets</h2>

        <%
            List<Map<String, Object>> tickets =
                    (List<Map<String, Object>>) request.getAttribute("tickets");
            if (tickets == null || tickets.isEmpty()) {
        %>
            <p class="text-muted mb-0">You haven’t opened any tickets yet.</p>
        <%
            } else {
        %>
        <div class="table-responsive">
            <table class="table align-middle">
                <thead>
                <tr>
                    <th>ID</th>
                    <th>Subject</th>
                    <th>Status</th>
                    <th>Opened</th>
                    <th>Closed</th>
                    <th>Rep notes</th>
                </tr>
                </thead>
                <tbody>
                <%
                    for (Map<String, Object> row : tickets) {
                        String status = (String) row.get("status");
                        String pillClass = "status-open";
                        if ("in_progress".equals(status)) pillClass = "status-in_progress";
                        else if ("closed".equals(status)) pillClass = "status-closed";
                %>
                <tr>
                    <td><%= row.get("ticket_id") %></td>
                    <td><strong><%= row.get("subject") %></strong></td>
                    <td>
                        <span class="status-pill <%= pillClass %>">
                            <%= status.replace("_", " ") %>
                        </span>
                    </td>
                    <td><%= row.get("open_date") %></td>
                    <td><%= row.get("close_date") == null ? "-" : row.get("close_date") %></td>
                    <td style="max-width:300px; white-space:pre-wrap;"><%= row.get("notes") %></td>
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
