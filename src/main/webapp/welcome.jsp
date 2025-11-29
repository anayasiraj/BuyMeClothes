<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html>
<head>
    <title>Welcome</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
</head>
<body class="bg-light">
<%
    String username = (String) session.getAttribute("username");
    if (username == null) {
        response.sendRedirect("login.jsp");
        return;
    }
%>

<nav class="navbar navbar-expand-lg navbar-dark" style="background:#ff4f87;">
    <div class="container-fluid px-4">
        <a class="navbar-brand" href="welcome.jsp">BuyMe</a>
        <button class="navbar-toggler" type="button" data-bs-toggle="collapse"
                data-bs-target="#buymeNav" aria-controls="buymeNav" aria-expanded="false">
            <span class="navbar-toggler-icon"></span>
        </button>
        <div class="collapse navbar-collapse" id="buymeNav">
            <ul class="navbar-nav ms-auto mb-2 mb-lg-0">
                <li class="nav-item"><a class="nav-link text-white" href="browse">Browse</a></li>
                <li class="nav-item"><a class="nav-link text-white" href="logout.jsp">Logout</a></li>
            </ul>
        </div>
    </div>
</nav>


<div class="container py-5">
    <div class="card mx-auto" style="max-width:480px;">
        <div class="card-body text-center">
            <h3 class="card-title mb-3">Welcome, <%= username %> 👋</h3>
            <p class="text-muted">You’re logged in to BuyMe.</p>
            <a href="logout.jsp" class="btn btn-outline-danger mt-3">Logout</a>
        </div>
    </div>
</div>
</body>
</html>
