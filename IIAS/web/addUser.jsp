<%-- 
    Document   : addUser
    Created on : 10 Jun 2026, 6:35:43 pm
    Author     : ASUS
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="model.User"%>
<%
    User user = (User) session.getAttribute("user");

    if (user == null || !"supervisor".equals(user.getRole())) {
        response.sendRedirect("debug.jsp");
        return;
    }
%>

<!DOCTYPE html>
<html>
    <head>
        <title>Add Intern</title>
        <link rel="stylesheet" href="../css/style.css">
    </head>

    <body>

        <div class="login-container">

            <div class="login-box">

                <h2>Add Intern Account</h2>

                <form action="UserServlet" method="POST">

                    <input type="hidden" name="action" value="add">

                    <input type="text"name="username"placeholder="Username"required>

                    <input type="password"name="password"placeholder="Password"required>

                    <input type="text"name="fullName"placeholder="Full Name"required>

                    <input type="date"name="startDate"required>

                    <input type="date"name="endDate"required>

                    <button type="submit">
                        Add User
                    </button>

                </form>

            </div>

        </div>

    </body>
</html>
