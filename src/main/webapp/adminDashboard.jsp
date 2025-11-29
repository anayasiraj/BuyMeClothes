<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html>
<head>
    <title>Admin Dashboard - BuyMe</title>
    <meta name="viewport" content="width=device-width, initial-scale=1">

    <!-- You can remove this if you already include Bootstrap globally -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">

    <style>
        body {
            font-family: system-ui, -apple-system, BlinkMacSystemFont, "Segoe UI", sans-serif;
            background: #f6f7fb;
        }
        .top-bar {
            background: #040252;
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
            font-size: 26px;
            margin-bottom: 12px;
        }
        .subtitle {
            color: #555;
            margin-bottom: 24px;
        }
        .action-card {
            border-radius: 18px;
            box-shadow: 0 14px 35px rgba(15, 23, 42, 0.08);
            border: 1px solid #f0f0f5;
            padding: 20px 22px;
            background: #fff;
            height: 100%;
            transition: transform 0.12s ease, box-shadow 0.12s ease;
        }
        .action-card:hover {
            transform: translateY(-2px);
            box-shadow: 0 18px 40px rgba(15, 23, 42, 0.12);
        }
        .action-title {
            font-weight: 600;
            font-size: 18px;
            margin-bottom: 6px;
        }
        .action-desc {
            color: #666;
            font-size: 14px;
            margin-bottom: 12px;
        }
        .pill {
            display: inline-block;
            padding: 4px 10px;
            border-radius: 999px;
            font-size: 11px;
            letter-spacing: .02em;
            background: #fff0f6;
            color: #ff4a93;
            font-weight: 600;
            text-transform: uppercase;
        }
        .btn-main {
            background: #ff4a93;
            color: #fff;
            border-radius: 999px;
            padding: 7px 16px;
            font-size: 13px;
            border: none;
        }
        .btn-main:hover {
            background: #ff2279;
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
        
        <a href="${pageContext.request.contextPath}/logout">Logout</a>
    </nav>
</div>

<div class="page-wrap">
    <div class="headline">Admin tools</div>
    <div class="subtitle">
        Manage customer representatives and keep your marketplace running smoothly.
    </div>

    <div class="row g-4">
        <div class="col-md-4">
            <a href="${pageContext.request.contextPath}/admin/createRep" class="text-decoration-none text-reset">
                <div class="action-card">
                    <span class="pill">Staff</span>
                    <div class="action-title mt-2">Create customer rep</div>
                    <div class="action-desc">
                        Add new customer representatives who can reset passwords, edit profiles, and remove bids.
                    </div>
                    <button type="button" class="btn-main">Create rep</button>
                </div>
            </a>
        </div>

        <div class="col-md-4">
            <a href="${pageContext.request.contextPath}/userSearch" class="text-decoration-none text-reset">
                <div class="action-card">
                    <span class="pill">Users</span>
                    <div class="action-title mt-2">View all users</div>
                    <div class="action-desc">
                        Browse all registered buyers and sellers, and quickly inspect their roles.
                    </div>
                    <button type="button" class="btn-main">Open list</button>
                </div>
            </a>
        </div>

        <div class="col-md-4">
    <div class="action-card">
        <span class="pill">Reports</span>
        <div class="action-title mt-2">Sales reports</div>
        <div class="action-desc">
            Summary earnings by item, seller, and category for closed auctions.
        </div>
        <a href="${pageContext.request.contextPath}/admin/reports" class="btn-main">
            View reports
        </a>
    </div>
</div>

</div>

</body>
</html>
