<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="javax.servlet.http.HttpServletRequest" %>

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>IIAS Login</title>
    <link rel="stylesheet" href="css/login.css">
</head>

<body>

<div class="login-container">

    <div class="login-box">

        <h1 class="brand-logo"><span>i</span>Whizz</h1>
        <p class="brand-sub">Intern Attendance</p>

        <form action="LoginServlet" method="POST">

            <div class="form-group">
                <label for="username">Username</label>
                <input type="text"
                       id="username"
                       name="username"
                       placeholder="Enter your username"
                       required>
            </div>

            <div class="form-group">
                <label for="password">Password</label>
                <input type="password"
                       id="password"
                       name="password"
                       placeholder="Enter your password"
                       required>
            </div>

            <button type="submit" class="login-btn">
                Login
            </button>

        </form>

        <%
            String error = (String) request.getAttribute("error");
            if (error != null) {
        %>
            <p class="error"><%= error %></p>
        <% } %>

    </div>

</div>

</body>
</html>