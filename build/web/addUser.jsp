<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="model.User"%>
<%
    User user = (User) session.getAttribute("user");

    if (user == null || !"supervisor".equals(user.getRole())) {
        response.sendRedirect("login.jsp");
        return;
    }
%>

<!DOCTYPE html>
<html>
    <head>
        <meta charset="UTF-8">
        <title>Add Intern Account</title>
        <link rel="stylesheet" href="css/addUser.css">
        <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.2/css/all.min.css">
    </head>

    <body>

        <div class="sidebar">
            <div class="brand">Iwhizz<span>Attendance</span></div>
            <div class="sidebar-menu">
                <a href="SupervisorDashboardServlet"><i class="fa-solid fa-chart-pie"></i> Dashboard</a>
                <a href="addIntern.jsp" class="active"><i class="fa-solid fa-user-plus"></i> Add Intern</a>
                <a href="ViewAllRecordsServlet"><i class="fa-solid fa-folder-open"></i> Attendance Logs</a>
                <a href="supervisorLeave.jsp"><i class="fa-solid fa-folder-open"></i> Leave request</a>
                <a href="LogoutServlet" style="margin-top: auto; color: #dc3545;"><i class="fa-solid fa-right-from-bracket"></i> Logout</a>
            </div>
        </div>

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

                    <button type="submit" class="btn-submit">
                        <i class="fa-solid fa-user-plus"></i> Add User Account
                    </button>
                </form>
            </div>
        </div>

    </body>
</html>