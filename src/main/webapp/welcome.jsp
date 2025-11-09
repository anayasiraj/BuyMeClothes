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
