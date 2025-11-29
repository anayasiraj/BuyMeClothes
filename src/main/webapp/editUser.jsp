<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html>
<head>
    <title>Edit User - BuyMe</title>
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">

    <style>
        body { font-family: system-ui, -apple-system, BlinkMacSystemFont, "Segoe UI", sans-serif; background: #f6f7fb; }
        .top-bar { background:#06630b; color:#fff; padding:14px 48px; display:flex; align-items:center; justify-content:space-between; }
        .top-bar .brand { font-weight:700; font-size:24px; }
        .top-bar nav a { color:#fff; text-decoration:none; margin-left:24px; font-weight:500; font-size:15px; }
        .top-bar nav a:hover { text-decoration:underline; }
        .page-wrap { max-width:900px; margin:40px auto; padding:0 24px; }
        .headline { font-weight:700; font-size:26px; margin-bottom:12px; }
        .subtitle { color:#555; margin-bottom:20px; }
        .lookup-card, .edit-card { border-radius:18px; box-shadow:0 18px 45px rgba(15,23,42,.12); border:1px solid #f0f0f5; padding:22px 24px; background:#fff; margin-bottom:20px; }
        .btn-main { background:#ff4a93; color:#fff; border-radius:999px; padding:8px 18px; font-size:14px; border:none; }
        .btn-main:hover { background:#ff2279; }
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
    <div class="headline">Edit user profile</div>
    <div class="subtitle">
        Load a user by ID, then adjust contact information or reset their password. All changes are logged.
    </div>

    <%
        String msg = (String) request.getAttribute("message");
        if (msg != null) {
    %>
    <div class="alert alert-info"><%= msg %></div>
    <% } %>

    <div class="lookup-card">
        <form action="${pageContext.request.contextPath}/rep/editUser" method="get">
            <div class="row g-3 align-items-end">
                <div class="col-md-4">
                    <label class="form-label">User ID</label>
                    <input type="number" name="user_id" class="form-control" required>
                </div>
                <div class="col-md-3 d-grid">
                    <button type="submit" class="btn-main">Load user</button>
                </div>
            </div>
        </form>
    </div>

    <%
        Integer userId = (Integer) request.getAttribute("user_id");
        String username = (String) request.getAttribute("username");
        String email = (String) request.getAttribute("email");
        String phone = (String) request.getAttribute("phone");
        String address = (String) request.getAttribute("address");

        if (userId != null) {
    %>
    <div class="edit-card">
        <h2 class="h5 mb-3">
            Editing user #<%= userId %>
            <% if (username != null) { %> – <strong><%= username %></strong><% } %>
        </h2>

        <form action="${pageContext.request.contextPath}/rep/editUser" method="post">
            <input type="hidden" name="user_id" value="<%= userId %>">

            <div class="row g-3">
                <div class="col-md-6">
                    <label class="form-label">Username</label>
                    <input type="text" name="username" class="form-control"
                           value="<%= username != null ? username : "" %>" required>
                </div>
                <div class="col-md-6">
                    <label class="form-label">Email</label>
                    <input type="email" name="email" class="form-control"
                           value="<%= email != null ? email : "" %>" required>
                </div>

                <div class="col-md-6">
                    <label class="form-label">Phone</label>
                    <input type="text" name="phone" class="form-control"
                           value="<%= phone != null ? phone : "" %>">
                </div>
                <div class="col-md-6">
                    <label class="form-label">Address</label>
                    <input type="text" name="address" class="form-control"
                           value="<%= address != null ? address : "" %>">
                </div>

                <div class="col-12">
                    <label class="form-label">New password</label>
                    <input type="password" name="new_password" class="form-control"
                           placeholder="Leave blank to keep current password">
                    <div class="form-text">Use only if you are actively resetting their login.</div>
                </div>
            </div>

            <div class="d-flex justify-content-between align-items-center mt-4">
                <a href="${pageContext.request.contextPath}/rep/dashboard" class="btn btn-outline-secondary">
                    Back to rep dashboard
                </a>
                <button type="submit" class="btn-main">Save changes</button>
            </div>
        </form>
        
      
    </div>
    <% } %>
</div>

</body>
</html>
