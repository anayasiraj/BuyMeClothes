<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html>
<head>
    <title>Create Customer Rep - BuyMe</title>
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">

    <style>
        body { font-family: system-ui, -apple-system, BlinkMacSystemFont, "Segoe UI", sans-serif; background: #f6f7fb; }
        .top-bar { background: #040252; color: #fff; padding: 14px 48px; display: flex; align-items: center; justify-content: space-between; }
        .top-bar .brand { font-weight: 700; font-size: 24px; }
        .top-bar nav a { color: #fff; text-decoration: none; margin-left: 24px; font-weight: 500; font-size: 15px; }
        .top-bar nav a:hover { text-decoration: underline; }
        .page-wrap { max-width: 800px; margin: 40px auto; padding: 0 24px; }
        .headline { font-weight: 700; font-size: 26px; margin-bottom: 12px; }
        .subtitle { color: #555; margin-bottom: 24px; }
        .form-card { border-radius: 18px; box-shadow: 0 18px 45px rgba(15,23,42,.12); border: 1px solid #f0f0f5; padding: 26px 26px 22px; background: #fff; }
        .btn-main { background: #ff4a93; color: #fff; border-radius: 999px; padding: 8px 18px; font-size: 14px; border: none; }
        .btn-main:hover { background: #ff2279; }
        .badge-soft { background: #fff0f6; color: #ff4a93; border-radius: 999px; padding: 4px 12px; font-size: 11px; text-transform: uppercase; font-weight: 600; letter-spacing: .03em; }
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
    <div class="headline">Create customer representative</div>
    <div class="subtitle">
        Give trusted staff access to account-level tools. Their activity will be logged automatically.
    </div>

    <%
        Integer newUserId = (Integer) request.getAttribute("newUserId");
        if (newUserId != null && newUserId > 0) {
    %>
    <div class="alert alert-success">
        New customer representative created with ID <strong><%= newUserId %></strong>.
    </div>
    <% } %>

    <div class="form-card">
        <span class="badge-soft mb-3 d-inline-block">Staff account</span>

        <form action="${pageContext.request.contextPath}/admin/createRep" method="post">
            <div class="row g-3">
                <div class="col-md-6">
                    <label class="form-label">Full name</label>
                    <input type="text" name="full_name" class="form-control" required>
                </div>
                <div class="col-md-6">
                    <label class="form-label">Username</label>
                    <input type="text" name="username" class="form-control" required>
                </div>

                <div class="col-md-6">
                    <label class="form-label">Email</label>
                    <input type="email" name="email" class="form-control" required>
                </div>
                <div class="col-md-6">
                    <label class="form-label">Phone (optional)</label>
                    <input type="text" name="phone" class="form-control">
                </div>

                <div class="col-12">
                    <label class="form-label">Address (optional)</label>
                    <input type="text" name="address" class="form-control">
                </div>

                <div class="col-md-6">
                    <label class="form-label">Temporary password</label>
                    <input type="password" name="password" class="form-control" required>
                    <div class="form-text">They should change this after first login.</div>
                </div>

                <div class="col-12">
                    <label class="form-label">Notes (optional)</label>
                    <textarea name="notes" rows="3" class="form-control"
                              placeholder="Shift, languages, or anything useful for admins."></textarea>
                </div>
            </div>

            <div class="d-flex justify-content-between align-items-center mt-4">
                <a href="${pageContext.request.contextPath}/admin/dashboard" class="btn btn-outline-secondary">
                    Back to admin dashboard
                </a>
                <button type="submit" class="btn-main">Create representative</button>
            </div>
        </form>
    </div>
</div>

</body>
</html>
