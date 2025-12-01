<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html>
<head>
    <title>Customer Rep Dashboard - BuyMe</title>
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
            font-size: 26px;
            margin-bottom: 12px;
        }
        .subtitle {
            color: #555;
            margin-bottom: 24px;
        }
        .action-card {
            border-radius: 18px;
            box-shadow: 0 14px 35px rgba(15,23,42,.08);
            border: 1px solid #f0f0f5;
            padding: 20px 22px;
            background: #fff;
            height: 100%;
            transition: transform .12s, box-shadow .12s;
        }
        .action-card:hover {
            transform: translateY(-2px);
            box-shadow: 0 18px 40px rgba(15,23,42,.12);
        }
        .action-title {
            font-weight: 600;
            font-size: 18px;
            margin-bottom: 6px;
        }
        .action-desc {
            color: #666;
            font-size: 14px;
            margin-bottom: 10px;
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
        <a href="${pageContext.request.contextPath}/rep/support">Support</a>
        <a href="${pageContext.request.contextPath}/logout">Logout</a>
    </nav>
</div>

<div class="page-wrap">
    <div class="headline">Customer support tools</div>
    <div class="subtitle">
        Look up users, reset credentials, remove problematic bids and auctions, and keep things fair.
    </div>

    <div class="row g-4">
        <!-- Search users -->
        <div class="col-md-3">
            <a href="${pageContext.request.contextPath}/rep/searchUsers"
               class="text-decoration-none text-reset">
                <div class="action-card">
                    <span class="pill">Accounts</span>
                    <div class="action-title mt-2">Search users</div>
                    <div class="action-desc">
                        Find buyers and sellers by username or email before making
                        changes to their account.
                    </div>
                    <button type="button" class="btn-main">Search users</button>
                </div>
            </a>
        </div>

        <!-- Edit user profile -->
        <div class="col-md-3">
            <a href="${pageContext.request.contextPath}/rep/editUser"
               class="text-decoration-none text-reset">
                <div class="action-card">
                    <span class="pill">Profile</span>
                    <div class="action-title mt-2">Edit user profile</div>
                    <div class="action-desc">
                        Update contact details or reset a password while logging
                        all changes for auditing.
                    </div>
                    <button type="button" class="btn-main">Edit profile</button>
                </div>
            </a>
        </div>

        <!-- Delete auctions -->
        <div class="col-md-3">
            <a href="${pageContext.request.contextPath}/rep/auctions"
               class="text-decoration-none text-reset">
                <div class="action-card">
                    <span class="pill">Auctions</span>
                    <div class="action-title mt-2">Delete auctions</div>
                    <div class="action-desc">
                        Review live listings and remove illegal or abusive auctions
                        that violate marketplace rules.
                    </div>
                    <button type="button" class="btn-main">Delete auctions</button>
                </div>
            </a>
        </div>

        <!-- NEW: Manage bids -->
        <div class="col-md-3">
            <a href="${pageContext.request.contextPath}/rep/bids"
               class="text-decoration-none text-reset">
                <div class="action-card">
                    <span class="pill">Bids</span>
                    <div class="action-title mt-2">Manage bids</div>
                    <div class="action-desc">
                        View bids on any auction and remove abusive or mistaken bids
                        while keeping current prices consistent.
                    </div>
                    <button type="button" class="btn-main">Manage bids</button>
                </div>
            </a>
        </div>
    </div>
</div>

</body>
</html>
