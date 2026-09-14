<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="model.User" %>
<%@ page import="dao.UserDAO" %>

<%
    User user = (User) session.getAttribute("user");
    if (user == null || !"supervisor".equalsIgnoreCase(user.getRole())) {
        response.sendRedirect("login.jsp");
        return;
    }

    int userId = 0;
    User intern = null;
    
    try {
        String userIdParam = request.getParameter("userId");
        if (userIdParam != null && !userIdParam.isEmpty()) {
            userId = Integer.parseInt(userIdParam);
            UserDAO userDAO = new UserDAO();
            intern = userDAO.getUserById(userId);
        }
    } catch (Exception e) {
        e.printStackTrace();
    }

    if (intern == null) {
        response.sendRedirect("SupervisorInternManagementServlet");
        return;
    }

    request.setAttribute("activeMenu", "interns");
%>

<!DOCTYPE html>
<html lang="en">
    <head>
        <meta charset="UTF-8">
        <title>Supervisor - Edit Intern</title>
        <%@ include file="snippets/supervisor-head.jspf" %>
    </head>
    <body>

        <%@ include file="includes/sidebar.jspf" %>

        <!-- Main Content Wrapper -->
        <div class="main-content">
            <div class="container">
                
                <!-- Back Button & Header -->
                <div style="display: flex; align-items: center; gap: 12px; margin-bottom: 20px;">
                    <a href="SupervisorInternManagementServlet" class="btn btn-outline">
                        <i class="fa-solid fa-arrow-left"></i> Back
                    </a>
                    <div class="header" style="margin: 0;">
                        <h2><i class="fa-solid fa-pen-to-square"></i> Edit Intern Information</h2>
                    </div>
                </div>

                <!-- Edit Form -->
                <div class="form-card">
                    <form action="SupervisorInternManagementServlet?action=update" method="POST" class="form-grid">
                        <input type="hidden" name="userId" value="<%= intern.getUserId()%>">

                        <div class="form-group">
                            <label>Full Name</label>
                            <input type="text" name="fullName" value="<%= intern.getFullName()%>" placeholder="Enter intern's full name" required>
                        </div>

                        <div class="form-group">
                            <label>Username</label>
                            <input type="text" name="username" value="<%= intern.getUsername()%>" placeholder="Enter username" required>
                        </div>

                        <div class="form-group">
                            <label>Password (Leave blank to keep current)</label>
                            <input type="password" name="password" placeholder="Leave blank to keep current password">
                        </div>

                        <div class="form-group">
                            <label>Internship Start Date</label>
                            <input type="date" name="startDate" value="<%= intern.getInternshipStart()%>" required>
                        </div>

                        <div class="form-group">
                            <label>Internship End Date</label>
                            <input type="date" name="endDate" value="<%= intern.getInternshipEnd()%>" required>
                        </div>

                        <div class="form-group">
                            <label>Personal Leave Remaining</label>
                            <input type="number" name="leaveRemaining" value="<%= intern.getPersonalLeaveRemaining()%>" min="0" required>
                        </div>

                        <div style="display: flex; gap: 12px;">
                            <button type="submit" class="btn btn-primary">
                                <i class="fa-solid fa-save"></i> Save Changes
                            </button>
                            <a href="SupervisorInternManagementServlet" class="btn btn-outline">
                                <i class="fa-solid fa-times"></i> Cancel
                            </a>
                        </div>
                    </form>
                </div>
            </div>
        </div>

    </body>
</html>
