<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    session.invalidate();
%>
<!DOCTYPE html>
<html>
<head>
    <title>Logged out</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
</head>
<body class="bg-light">
<div class="container py-5">
    <div class="alert alert-info mx-auto" style="max-width:480px;">
        You have been logged out.
    </div>
    <div class="text-center">
        <a href="login.jsp" class="btn btn-primary">Back to login</a>
    </div>
</div>
</body>
</html>
