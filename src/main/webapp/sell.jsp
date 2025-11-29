<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>BuyMe | Sell an item</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">

    <style>
        :root {
            --buyme-pink: #ff4f87;
        }
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
        .page-header {
            padding: 2.5rem 1rem 1rem;
        }
        .page-title {
            font-size: 2rem;
            font-weight: 700;
        }
        .page-sub {
            color: #555;
        }
        .card-sell {
            border-radius: 1.25rem;
            box-shadow: 0 18px 45px rgba(0,0,0,0.08);
            border: none;
        }
        .form-label {
            font-weight: 500;
        }
        .btn-buyme {
            background: var(--buyme-pink);
            border-color: var(--buyme-pink);
            color: #fff;
            font-weight: 500;
        }
        .btn-buyme:hover {
            background: #ff3374;
            border-color: #ff3374;
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
                <li class="nav-item"><a class="nav-link fw-semibold" href="sell">Sell</a></li>
                <li class="nav-item"><a class="nav-link" href="alerts">Alerts</a></li>
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

<section class="page-header">
    <div class="container">
        <h1 class="page-title mb-2">List a new fashion item</h1>
        <p class="page-sub mb-0">
            Upload photos, set your starting price, and let other students bid on your piece.
        </p>
    </div>
</section>

<div class="container mb-5">
    <div class="row justify-content-center">
        <div class="col-lg-8 col-xl-7">
            <div class="card card-sell p-4 p-md-5 bg-white">

                <%-- FLASH SUCCESS (from SellServlet, disappears after one view) --%>
                <%
                    String sellSuccess = (String) session.getAttribute("sellSuccess");
                    if (sellSuccess != null) {
                %>
                    <div class="alert alert-success mb-4">
                        <%= sellSuccess %>
                    </div>
                <%
                        // remove so it only shows once
                        session.removeAttribute("sellSuccess");
                    }

                    // Error from SellServlet when validation/DB fails
                    String errorMessage = (String) request.getAttribute("errorMessage");
                    if (errorMessage != null) {
                %>
                    <div class="alert alert-danger mb-4">
                        <%= errorMessage %>
                    </div>
                <%
                    }
                %>

                <!-- IMPORTANT: multipart/form-data for file upload -->
                <form method="post" action="sell" enctype="multipart/form-data">
                    <div class="mb-3">
                        <label class="form-label" for="title">Title</label>
                        <input type="text" class="form-control" id="title" name="title"
                               placeholder="e.g., Ribbed crop top" required>
                    </div>

                    <div class="mb-3">
                        <label class="form-label" for="description">Description</label>
                        <textarea class="form-control" id="description" name="description" rows="3"
                                  placeholder="Add details about fabric, fit, condition, etc." required></textarea>
                    </div>

                    <div class="row g-3">
                        <div class="col-md-4">
                            <label class="form-label" for="brand">Brand</label>
                            <input type="text" class="form-control" id="brand" name="brand"
                                   placeholder="e.g., Zara">
                        </div>
                        <div class="col-md-4">
                            <label class="form-label" for="size">Size</label>
                            <input type="text" class="form-control" id="size" name="size"
                                   placeholder="e.g., S, M, 28">
                        </div>
                        <div class="col-md-4">
                            <label class="form-label" for="color">Color</label>
                            <input type="text" class="form-control" id="color" name="color"
                                   placeholder="e.g., Black">
                        </div>
                    </div>

                    <div class="row g-3 mt-1">
                        <div class="col-md-6">
                            <label class="form-label" for="categoryId">Category</label>
                            <select class="form-select" id="categoryId" name="categoryId" required>
                                <option value="">Choose a category…</option>
                                <option value="1">Tops</option>
                                <option value="2">Bottoms</option>
                                <option value="3">Outerwear</option>
                                <option value="4">Dresses</option>
                                <!-- add / adjust IDs to match your categories table -->
                            </select>
                        </div>
                        <div class="col-md-3">
                            <label class="form-label" for="startPrice">Starting price ($)</label>
                            <input type="number" step="0.01" min="0" class="form-control"
                                   id="startPrice" name="startPrice" required>
                        </div>
                        <div class="col-md-3">
                            <label class="form-label" for="bidIncrement">Bid increment ($)</label>
                            <input type="number" step="0.01" min="0.01" class="form-control"
                                   id="bidIncrement" name="bidIncrement" required>
                        </div>
                    </div>

                    <div class="row g-3 mt-1">
                        <div class="col-md-4">
                            <label class="form-label" for="reservePrice">Reserve price ($)</label>
                            <input type="number" step="0.01" min="0" class="form-control"
                                   id="reservePrice" name="reservePrice"
                                   placeholder="Optional">
                        </div>
                        <div class="col-md-4">
                            <label class="form-label" for="durationHours">Duration (hours)</label>
                            <input type="number" min="1" max="168" class="form-control"
                                   id="durationHours" name="durationHours" value="72">
                        </div>
                        <div class="col-md-4">
                            <label class="form-label" for="durationDays">Duration (days)</label>
                            <input type="number" min="1" max="14" class="form-control"
                                   id="durationDays" name="durationDays" value="3">
                        </div>
                    </div>

                    <hr class="my-4">

                    <!-- File upload -->
                    <div class="mb-3">
                        <label class="form-label" for="photo">Upload photo</label>
                        <input type="file" class="form-control" id="photo" name="photo"
                               accept="image/*" required>
                        <div class="form-text">
                            Choose a clear photo of your item (JPG or PNG).
                        </div>
                    </div>

                    <div class="mt-4 d-flex justify-content-end">
                        <button type="submit" class="btn btn-buyme px-4">
                            Post auction
                        </button>
                    </div>
                </form>
            </div>
        </div>
    </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
