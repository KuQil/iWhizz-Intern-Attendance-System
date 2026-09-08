<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="model.User"%>
<%
    User user = (User) session.getAttribute("user");

    if (user == null || !"supervisor".equals(user.getRole())) {
        response.sendRedirect("login.jsp");
        return;
    }
    request.setAttribute("activeMenu", "add");
%>

<!DOCTYPE html>
<html>
    <head>
        <meta charset="UTF-8">
        <title>Add Intern Account</title>
        <%@ include file="snippets/supervisor-head.jspf" %>
    </head>

    <body>

        <%@ include file="includes/sidebar.jspf" %>

        <div class="main-content">
            <h1 class="page-title">Add Intern Account</h1>

            <div class="form-card">
                <form action="UserServlet" method="POST" class="form-grid">
                    <input type="hidden" name="action" value="add">

                    <div class="form-group">
                        <label>Username</label>
                        <input type="text" name="username" placeholder="Create unique username" required>
                    </div>

                    <div class="form-group">
                        <label>Password</label>
                        <input type="password" name="password" placeholder="Assign account password" required>
                    </div>

                    <div class="form-group">
                        <label>Full Name</label>
                        <input type="text" name="fullName" placeholder="Enter intern's official full name" required>
                    </div>

                    <div class="form-group">
                        <label>Internship Start Date</label>
                        <input type="date" name="startDate" required>
                    </div>

                    <div class="form-group">
                        <label>Internship End Date</label>
                        <input type="date" name="endDate" required>
                    </div>

                    <button type="submit" class="btn btn-primary">
                        <i class="fa-solid fa-user-plus"></i> Add User Account
                    </button>
                </form>
            </div>
        </div>

    </body>
</html>
