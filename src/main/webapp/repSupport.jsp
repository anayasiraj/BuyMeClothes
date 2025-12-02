<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.*" %>
<!DOCTYPE html>
<html>
<head>
    <title>Support Tickets - BuyMe</title>
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">

    <style>
        body { font-family: system-ui, -apple-system, BlinkMacSystemFont, "Segoe UI", sans-serif; background:#f6f7fb; }
        .top-bar { background:#06630b; color:#fff; padding:14px 48px; display:flex; align-items:center; justify-content:space-between; }
        .top-bar .brand { font-weight:700; font-size:24px; }
        .top-bar nav a { color:#fff; text-decoration:none; margin-left:24px; font-weight:500; font-size:15px; }
        .top-bar nav a:hover { text-decoration:underline; }
        .page-wrap { max-width:1150px; margin:40px auto; padding:0 24px; }
        .headline { font-weight:700; font-size:26px; margin-bottom:8px; }
        .subtitle { color:#555; margin-bottom:20px; }
        .card-shell { border-radius:18px; box-shadow:0 18px 45px rgba(15,23,42,.12); border:1px solid #f0f0f5; padding:22px 24px; background:#fff; }
        .status-pill { display:inline-block; padding:3px 10px; border-radius:999px; font-size:11px; font-weight:600; text-transform:uppercase; }
        .status-open { background:#fff3cd; color:#856404; }
        .status-in_progress { background:#e3f2fd; color:#0d47a1; }
        .status-closed { background:#e8f5e9; color:#1b5e20; }
        .btn-main { background:#ff4a93; color:#fff; border-radius:999px; padding:5px 12px; font-size:13px; border:none; }
        .btn-main:hover { background:#ff2279; }
        textarea { resize:vertical; }
    </style>
</head>
<body>

<div class="top-bar">
    <div class="brand">BuyMe</div>
    <nav>
        <a href="${pageContext.request.contextPath}/browse">Browse</a>
        <a href="${pageContext.request.contextPath}/myActivity">My activity</a>
        <a href="${pageContext.request.contextPath}/sell">Sell</a>
        <a href="${pageContext.request.contextPath}/rep/support">Support</a>
        
        <%-- ADMIN-ONLY LINK --%>
        <%
            String role = (String) session.getAttribute("role");
            if ("admin".equals(role)) {
        %>
            <a href="${pageContext.request.contextPath}/admin/dashboard">Admin dashboard</a>
        <%
            }
        %>
                
        <%-- REP-ONLY LINK --%>
        <%
            String role1 = (String) session.getAttribute("role");
            if ("cust_rep".equals(role1)) {
        %>
            <a href="${pageContext.request.contextPath}/rep/dashboard">Rep dashboard</a>
        <%
            }
        %>
        
        <a href="${pageContext.request.contextPath}/logout">Logout</a>
    </nav>
</div>

<div class="page-wrap">
    <div class="headline">Support tickets</div>
    <div class="subtitle">
        Claim tickets, track their status, and leave notes for users.
    </div>

    <%
        String msg = (String) request.getAttribute("message");
        if (msg != null) {
    %>
    <div class="alert alert-info"><%= msg %></div>
    <% } %>

    <div class="card-shell">
        <%
            List<Map<String, Object>> tickets =
                    (List<Map<String, Object>>) request.getAttribute("tickets");
            if (tickets == null || tickets.isEmpty()) {
        %>
        <p class="text-muted mb-0">No tickets yet.</p>
        <%
            } else {
        %>
        <div class="table-responsive">
            <table class="table align-middle">
                <thead>
                <tr>
                    <th>ID</th>
                    <th>User</th>
                    <th>Subject</th>
                    <th>Status</th>
                    <th>Opened</th>
                    <th>Closed</th>
                    <th>Notes / Update</th>
                </tr>
                </thead>
                <tbody>
                <%
                    for (Map<String, Object> row : tickets) {
                        int ticketId = (Integer) row.get("ticket_id");
                        String status = (String) row.get("status");
                        String pillClass = "status-open";
                        if ("in_progress".equals(status)) pillClass = "status-in_progress";
                        else if ("closed".equals(status)) pillClass = "status-closed";
                        Object repIdObj = row.get("cust_rep_id");
                        boolean assigned = (repIdObj != null);
                %>
                <tr>
                    <td><%= ticketId %></td>
                    <td><strong><%= row.get("username") %></strong></td>
                    <td><%= row.get("subject") %></td>
                    <td>
                        <span class="status-pill <%= pillClass %>">
                            <%= status.replace("_", " ") %>
                        </span>
                        <br/>
                        <small class="text-muted">
                            <% if (assigned) { %>
                                Assigned (rep id: <%= repIdObj %>)
                            <% } else { %>
                                Unassigned
                            <% } %>
                        </small>
                    </td>
                    <td><%= row.get("open_date") %></td>
                    <td><%= row.get("close_date") == null ? "-" : row.get("close_date") %></td>
                    <td style="min-width:260px;">
                        <div class="mb-2" style="max-height:80px; overflow-y:auto; white-space:pre-wrap; font-size:13px;">
                            <%= row.get("notes") %>
                        </div>

                        <!-- Take ticket form (only when unassigned) -->
                        <% if (!assigned) { %>
                            <form action="${pageContext.request.contextPath}/rep/support" method="post" class="mb-2">
                                <input type="hidden" name="ticket_id" value="<%= ticketId %>">
                                <input type="hidden" name="action" value="take">
                                <button type="submit" class="btn btn-sm btn-outline-primary">
                                    Take ticket
                                </button>
                            </form>
                        <% } %>

                        <!-- Update ticket form -->
                        <form action="${pageContext.request.contextPath}/rep/support" method="post">
                            <input type="hidden" name="ticket_id" value="<%= ticketId %>">
                            <input type="hidden" name="action" value="update">

                            <div class="mb-1">
                                <select name="status" class="form-select form-select-sm">
                                    <option value="open" <%= "open".equals(status) ? "selected" : "" %>>Open</option>
                                    <option value="in_progress" <%= "in_progress".equals(status) ? "selected" : "" %>>In progress</option>
                                    <option value="closed" <%= "closed".equals(status) ? "selected" : "" %>>Closed</option>
                                </select>
                            </div>
                            <div class="mb-1">
                                <textarea name="notes" rows="2" class="form-control form-control-sm"
                                          placeholder="Add or update notes"><%= row.get("notes") == null ? "" : row.get("notes") %></textarea>
                            </div>
                            <button type="submit" class="btn-main btn-sm mt-1">Save</button>
                        </form>
                    </td>
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
