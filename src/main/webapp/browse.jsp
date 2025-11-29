<%@ page import="java.util.List" %>
<%@ page import="com.buyme.model.AuctionSummary" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>BuyMe | Browse</title>
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
        .hero-strip {
            padding: 2rem 1rem;
            background: radial-gradient(circle at top, #ffe7f2 0%, #ffffff 50%, #f3f3f3 100%);
        }
        .hero-title {
            font-size: 2.1rem;
            font-weight: 700;
        }
        .hero-sub {
            color: #555;
        }
        .card-auction {
            border-radius: 1.2rem;
            box-shadow: 0 14px 35px rgba(0,0,0,0.08);
            overflow: hidden;
            transition: transform .18s ease, box-shadow .18s ease;
            background-color: #fff;
        }
        .card-auction:hover {
            transform: translateY(-4px);
            box-shadow: 0 18px 45px rgba(0,0,0,0.12);
        }
        .card-auction img {
            height: 260px;
            object-fit: cover;
        }
        .badge-tag {
            background: rgba(0,0,0,0.75);
            font-size: .7rem;
            letter-spacing: .08em;
        }
        .price-main {
            font-size: 1.25rem;
            font-weight: 700;
        }
        .pill-meta {
            border-radius: 999px;
            font-size: .8rem;
            padding: .25rem .7rem;
            background: #f5f5f5;
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

                <!-- normal user links -->
                <li class="nav-item"><a class="nav-link" href="browse">Browse</a></li>
                <li class="nav-item"><a class="nav-link" href="myActivity">My activity</a></li>
                <li class="nav-item"><a class="nav-link" href="sell">Sell</a></li>
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


<%
    // Current filters (so we can pre-fill the search + modal)
    String q        = request.getParameter("q");
    String size     = request.getParameter("size");
    String color    = request.getParameter("color");
    String category = request.getParameter("category");
    String minPrice = request.getParameter("minPrice");
    String maxPrice = request.getParameter("maxPrice");
%>

<section class="hero-strip">
    <div class="container">
        <div class="row align-items-center gy-3">
            <div class="col-md-7">
                <h1 class="hero-title mb-2">Curated, bid-only fashion drops.</h1>
                <p class="hero-sub mb-0">
                    Scroll through live auctions for dresses, tops, denim, and outerwear — all from trusted student sellers.
                </p>
            </div>

            <div class="col-md-5">
                <!-- Search bar + Filters button -->
                <form class="d-flex gap-2 justify-content-md-end mt-3 mt-md-0" method="get" action="browse">
                    <input type="text"
                           class="form-control"
                           name="q"
                           placeholder="Search auctions (title, brand, color...)"
                           value="<%= q != null ? q : "" %>">

                    <!-- Preserve existing filters when searching -->
                    <input type="hidden" name="size"     value="<%= size     != null ? size     : "" %>">
                    <input type="hidden" name="color"    value="<%= color    != null ? color    : "" %>">
                    <input type="hidden" name="category" value="<%= category != null ? category : "" %>">
                    <input type="hidden" name="minPrice" value="<%= minPrice != null ? minPrice : "" %>">
                    <input type="hidden" name="maxPrice" value="<%= maxPrice != null ? maxPrice : "" %>">

                    <button type="submit" class="btn btn-light border px-3">
                        Search
                    </button>

                    <button type="button" class="btn btn-light border px-3"
                            data-bs-toggle="modal" data-bs-target="#filterModal">
                        Filters
                    </button>
                </form>
            </div>
        </div>
    </div>
</section>

<div class="container my-4 my-md-5">
    <%
        List<AuctionSummary> auctions =
                (List<AuctionSummary>) request.getAttribute("auctions");
        String error = (String) request.getAttribute("error");
    %>

    <% if (error != null) { %>
        <div class="alert alert-danger"><%= error %></div>
    <% } %>

    <% if (auctions == null || auctions.isEmpty()) { %>
        <div class="text-center py-5 text-muted">
            <h5 class="mb-2">No live auctions match your search.</h5>
            <p class="mb-0">Try clearing filters or using a different keyword.</p>
        </div>
    <% } else { %>

    <div class="row g-4">
        <% for (AuctionSummary a : auctions) { %>
            <div class="col-sm-6 col-md-4 col-lg-3">
                <div class="card card-auction h-100">
                    <div class="position-relative">
                        <img src="<%= a.getPhotoUrl() %>" class="card-img-top" alt="<%= a.getTitle() %>">
                        <div class="position-absolute top-0 start-0 m-2 d-flex gap-1">
                            <span class="badge badge-tag text-uppercase text-white">
                                Live auction
                            </span>
                            <% if (a.getCategoryName() != null) { %>
                                <span class="badge bg-light text-dark text-uppercase"
                                      style="font-size: .7rem; letter-spacing: .06em;">
                                    <%= a.getCategoryName() %>
                                </span>
                            <% } %>
                        </div>
                    </div>
                    <div class="card-body d-flex flex-column">
                        <h6 class="mb-1"><%= a.getTitle() %></h6>
                        <p class="text-muted mb-2">
                            <%= a.getBrand() != null ? a.getBrand() : "Brand -" %>
                        </p>

                        <div class="d-flex flex-wrap gap-2 mb-3">
                            <span class="pill-meta">Size <%= a.getSize() != null ? a.getSize() : "N/A" %></span>
                            <span class="pill-meta"><%= a.getColor() != null ? a.getColor() : "Color N/A" %></span>
                        </div>

                        <div class="mt-auto d-flex justify-content-between align-items-end">
                            <div>
                                <div class="price-main">
                                    $<%= a.getCurrentHigh() != null ? a.getCurrentHigh() : a.getStartPrice() %>
                                </div>
                                <small class="text-muted">
                                    Ends
                                    <% if (a.getEndTime() != null) { %>
                                        on <%= new java.text.SimpleDateFormat("MMM dd, yyyy HH:mm")
                                                     .format(a.getEndTime()) %>
                                    <% } else { %>
                                        soon
                                    <% } %>
                                </small>
                            </div>
                            <a href="auction?id=<%= a.getAuctionId() %>" class="btn btn-sm"
                               style="background: var(--buyme-pink); color: #fff;">
                                View &amp; bid
                            </a>
                        </div>
                    </div>
                </div>
            </div>
        <% } %>
    </div>

    <% } %>
</div>

<!-- Filters modal (single button opens this) -->
<div class="modal fade" id="filterModal" tabindex="-1" aria-hidden="true">
    <div class="modal-dialog modal-dialog-centered">
        <div class="modal-content">
            <form method="get" action="browse">
                <div class="modal-header">
                    <h5 class="modal-title">Search &amp; filter auctions</h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal"
                            aria-label="Close"></button>
                </div>
                <div class="modal-body">

                    <div class="mb-3">
                        <label class="form-label">Search</label>
                        <input type="text" class="form-control" name="q"
                               value="<%= q != null ? q : "" %>"
                               placeholder="e.g., green dress, Zara, black jeans">
                    </div>

                    <div class="mb-3">
                        <label class="form-label">Size</label>
                        <select class="form-select" name="size">
                            <option value="">Any</option>
                            <option value="XS" <%= "XS".equals(size) ? "selected" : "" %>>XS</option>
                            <option value="S"  <%= "S".equals(size)  ? "selected" : "" %>>S</option>
                            <option value="M"  <%= "M".equals(size)  ? "selected" : "" %>>M</option>
                            <option value="L"  <%= "L".equals(size)  ? "selected" : "" %>>L</option>
                            <option value="XL" <%= "XL".equals(size) ? "selected" : "" %>>XL</option>
                        </select>
                    </div>

                    <div class="mb-3">
                        <label class="form-label">Color</label>
                        <input type="text" class="form-control" name="color"
                               value="<%= color != null ? color : "" %>"
                               placeholder="e.g., Black, Beige">
                    </div>

                    <div class="mb-3">
                        <label class="form-label">Category</label>
                        <input type="text" class="form-control" name="category"
                               value="<%= category != null ? category : "" %>"
                               placeholder="e.g., Tops, Dresses">
                    </div>

                    <div class="row g-3">
                        <div class="col-6">
                            <label class="form-label">Min price</label>
                            <input type="number" min="0" step="1"
                                   class="form-control" name="minPrice"
                                   value="<%= minPrice != null ? minPrice : "" %>">
                        </div>
                        <div class="col-6">
                            <label class="form-label">Max price</label>
                            <input type="number" min="0" step="1"
                                   class="form-control" name="maxPrice"
                                   value="<%= maxPrice != null ? maxPrice : "" %>">
                        </div>
                    </div>

                </div>
                <div class="modal-footer">
                    <a href="browse" class="btn btn-outline-secondary">Clear</a>
                    <button type="submit" class="btn"
                            style="background: var(--buyme-pink); color: #fff;">
                        Apply filters
                    </button>
                </div>
            </form>
        </div>
    </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
