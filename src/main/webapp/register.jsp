<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>BuyMe | Register</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <style>
        body {
            min-height: 100vh;
            margin: 0;
            background-image: url('images/fashion-bg.jpg');
            background-size: cover;
            background-position: center;
            background-repeat: no-repeat;
            background-attachment: fixed;
            background-color: rgba(255, 255, 255, 0.4);
            background-blend-mode: lighten;
            display: flex;
            align-items: center;
            justify-content: center;
        }
        .auth-card {
            max-width: 460px;
            background: rgba(255, 255, 255, 0.97);
            border-radius: 1.25rem;
            box-shadow: 0 14px 40px rgba(0,0,0,0.08);
        }
        .btn-shein {
            background: #ff4f87;
            border: none;
        }
        .btn-shein:hover {
            background: #ff2f72;
        }
    </style>
</head>
<body>
<div class="auth-card p-4 p-md-5">
    <div class="text-center mb-4">
        <h3>Create your account</h3>
        <p class="text-muted mb-0">It’s fast and free.</p>
    </div>
    <form action="register" method="post" class="needs-validation" novalidate>
        <div class="mb-3">
            <label class="form-label">Full name</label>
            <input type="text" name="full_name" class="form-control" placeholder="e.g. Varshini Vishnubhotla">
        </div>
        <div class="mb-3">
            <label class="form-label">Username *</label>
            <input type="text" name="username" class="form-control" required>
            <div class="invalid-feedback">Username is required.</div>
        </div>
        <div class="mb-3">
            <label class="form-label">Email *</label>
            <input type="email" name="email" class="form-control" required>
            <div class="invalid-feedback">Valid email is required.</div>
        </div>
        <div class="mb-3">
            <label class="form-label">Password *</label>
            <input type="password" name="password" class="form-control" required>
            <div class="invalid-feedback">Password is required.</div>
        </div>
        <button type="submit" class="btn btn-shein w-100 text-white py-2">Sign up</button>
    </form>

    <div class="text-center mt-3">
        <small class="text-muted">Already have an account?</small><br>
        <a href="login.jsp" style="color:#ff4f87;">Login</a>
    </div>

    <%
        String msg = (String) request.getAttribute("message");
        if (msg != null) {
    %>
    <div class="alert alert-info mt-3 mb-0"><%= msg %></div>
    <% } %>
</div>

<script>
    (function () {
        'use strict'
        const forms = document.querySelectorAll('.needs-validation')
        Array.from(forms).forEach((form) => {
            form.addEventListener('submit', (event) => {
                if (!form.checkValidity()) {
                    event.preventDefault()
                    event.stopPropagation()
                }
                form.classList.add('was-validated')
            }, false)
        })
    })()
</script>
</body>
</html>
