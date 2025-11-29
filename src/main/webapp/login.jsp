<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>BuyMe | Login</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <style>
        :root {
            --buyme-pink: #ff4f87;
        }
        body {
            min-height: 100vh;
            margin: 0;
            background-color: #f8f9fa;
        }
        /* navbar */
        .navbar-buyme {
            background: var(--buyme-pink);
        }
        .navbar-buyme .navbar-brand,
        .navbar-buyme .nav-link {
            color: #fff !important;
            font-weight: 500;
        }

        /* hero section */
        .hero-wrap {
            position: relative;
            min-height: calc(100vh - 56px); /* navbar height */
            background-image: url('images/fashion-bg.jpg');
            background-size: cover;
            background-position: center;
            display: flex;
            align-items: center;
            justify-content: space-between;
            padding: 3rem 5vw;
        }
        .hero-overlay {
            position: absolute;
            inset: 0;
            background: rgba(255, 255, 255, 0.35);
            backdrop-filter: blur(1px);
        }
        .hero-text {
            position: relative;
            max-width: 460px;
            z-index: 1;
        }
        .hero-tagline {
            display: inline-block;
            background: rgba(0, 0, 0, 0.85);
            color: #fff;
            padding: .6rem 1rem;
            border-radius: .4rem;
            margin-bottom: 1.2rem;
            font-size: .9rem;
            letter-spacing: .04rem;
        }
        .hero-title {
            font-size: 2.4rem;
            font-weight: 700;
            color: #111;
        }
        .hero-sub {
            color: #333;
            max-width: 360px;
            margin-top: .75rem;
        }

        /* form on the right */
        .login-pane {
            position: relative;
            z-index: 1;
            display: flex;
            align-items: stretch;
        }
        .auth-card {
            width: 380px;
            background: #fff;
            border-radius: 1.25rem 0 0 1.25rem;
            box-shadow: 0 14px 40px rgba(0,0,0,0.1);
            padding: 2.2rem 2.3rem 2rem;
        }
        .auth-card h3 {
            margin-bottom: .35rem;
        }
        .auth-card p {
            margin-bottom: 1.3rem;
            color: #666;
        }
        /* pink strip to the right of the form */
        .pink-strip {
            width: 18px; /* about half an inch visually depending on screen */
            background: var(--buyme-pink);
            border-radius: 0 1.25rem 1.25rem 0;
        }

        .btn-shein {
            background: var(--buyme-pink);
            border: none;
        }
        .btn-shein:hover {
            background: #e5386f;
        }

        @media (max-width: 992px) {
            .hero-wrap {
                flex-direction: column;
                align-items: flex-start;
            }
            .login-pane {
                margin-top: 2rem;
            }
            .auth-card {
                border-radius: 1.25rem;
            }
            .pink-strip {
                display: none;
            }
        }
    </style>
</head>
<body>

<nav class="navbar navbar-expand-lg navbar-buyme">
    <div class="container-fluid px-4">
        <a class="navbar-brand" href="#">BuyMe</a>
        <button class="navbar-toggler" type="button" data-bs-toggle="collapse" data-bs-target="#buymeNav"
                aria-controls="buymeNav" aria-expanded="false" aria-label="Toggle navigation">
            <span class="navbar-toggler-icon" style="filter: invert(1);"></span>
        </button>
        <div class="collapse navbar-collapse" id="buymeNav">
            <ul class="navbar-nav ms-auto mb-2 mb-lg-0">
                <li class="nav-item"><a class="nav-link" href="browse">Browse</a></li>
                <li class="nav-item"><a class="nav-link" href="#">Sell</a></li>
                <li class="nav-item"><a class="nav-link" href="#">Alerts</a></li>
                <li class="nav-item"><a class="nav-link" href="#">Support</a></li>
                <li class="nav-item"><a class="nav-link" href="login.jsp">Login</a></li>
            </ul>
        </div>
    </div>
</nav>

<section class="hero-wrap">
    <div class="hero-overlay"></div>

    <div class="hero-text">
        <span class="hero-tagline">Curated, bid-only fashion drops</span>
        <h1 class="hero-title">Style you missed, now up for auction.</h1>
        <p class="hero-sub">Bid on limited pieces, vintage finds, and trending looks from trusted sellers on BuyMe.</p>
    </div>

    <div class="login-pane">
        <div class="auth-card">
            <h3>Sign in</h3>
            <p>Log in to track bids and watchlists.</p>

            <form action="login" method="post" class="needs-validation" novalidate>
                <div class="mb-3">
                    <label class="form-label">Username</label>
                    <input name="username" type="text" class="form-control" required>
                    <div class="invalid-feedback">Please enter your username.</div>
                </div>
                <div class="mb-3">
                    <label class="form-label d-flex justify-content-between">
                        <span>Password</span>
                    </label>
                    <input name="password" type="password" class="form-control" required>
                    <div class="invalid-feedback">Please enter your password.</div>
                </div>
                <button class="btn btn-shein w-100 mt-2 py-2 text-white" type="submit">Login</button>
            </form>

            <div class="text-center mt-3">
                <small class="text-muted">Don’t have an account?</small><br>
                <a href="register.jsp" class="fw-semibold" style="color: var(--buyme-pink);">Create one</a>
            </div>

            <%
                String msg = (String) request.getAttribute("message");
                if (msg != null) {
            %>
            <div class="alert alert-danger mt-3 mb-0"><%= msg %></div>
            <% } %>
        </div>
        <div class="pink-strip"></div>
    </div>
</section>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
<script>
    (function () {
        'use strict';
        const forms = document.querySelectorAll('.needs-validation');
        Array.from(forms).forEach(function (form) {
            form.addEventListener('submit', function (event) {
                if (!form.checkValidity()) {
                    event.preventDefault();
                    event.stopPropagation();
                }
                form.classList.add('was-validated');
            }, false);
        });
    })();
</script>
</body>
</html>
