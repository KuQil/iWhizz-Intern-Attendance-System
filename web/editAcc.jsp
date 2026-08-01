<%@page import="model.User"%>
<%
    User user = (User) session.getAttribute("user");

    if (user == null || !"intern".equals(user.getRole())) {
        response.sendRedirect("login.jsp");
        return;
    }
%>

<!DOCTYPE html>
<html>
    <head>
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <meta charset="UTF-8">
        <title>Edit Profile</title>
        <link rel="stylesheet" href="css/dashboard.css">
        <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.2/css/all.min.css">
        <style>
            .form-container {
                padding: 20px;
                background: #fff;
                border-radius: 10px;
                margin: 20px;
            }
            .form-group {
                margin-bottom: 15px;
                display: flex;
                flex-direction: column;
            }
            .form-group label {
                margin-bottom: 5px;
                font-weight: bold;
                color: #333;
            }
            .form-group input {
                padding: 10px;
                border: 1px solid #ccc;
                border-radius: 5px;
                font-size: 14px;
            }
            .btn-container {
                display: flex;
                gap: 10px;
                margin-top: 20px;
            }
            .save-btn {
                background-color: #28a745;
                color: white;
                border: none;
                padding: 10px 15px;
                border-radius: 5px;
                cursor: pointer;
                flex: 1;
                font-weight: bold;
            }
            .cancel-btn {
                background-color: #6c757d;
                color: white;
                text-decoration: none;
                padding: 10px 15px;
                border-radius: 5px;
                text-align: center;
                flex: 1;
                font-weight: bold;
            }
        </style>
    </head>
    <body>
        <div class="phone-container">
            <div class="header">
                <h2>Edit Account</h2>
                <a href="dashboard.jsp" style="color: #333; font-size: 20px;">
                    <i class="fa-solid fa-arrow-left"></i>
                </a>
            </div>

            <div class="form-container">
                <form action="EditProfileServlet" method="POST">

                    <div class="form-group">
                        <label for="username">Username</label>
                        <input type="text" id="username" name="username" value="<%= user.getUsername()%>" required>
                    </div>

                    <div class="form-group">
                        <label for="fullName">Full Name</label>
                        <input type="text" id="fullName" name="fullName" value="<%= user.getFullName()%>" required>
                    </div>

                    <div class="form-group">
                        <label for="password">New Password</label>
                        <input type="password" id="password" name="password" placeholder="Leave blank to keep current password">
                    </div>

                    <div class="form-group">
                        <label for="startDate">Internship Start Date</label>
                        <input type="date" id="startDate" name="startDate" value="<%= user.getInternshipStart() != null ? user.getInternshipStart() : ""%>" required>
                    </div>

                    <div class="form-group">
                        <label for="endDate">Internship End Date</label>
                        <input type="date" id="endDate" name="endDate" value="<%= user.getInternshipEnd()!= null ? user.getInternshipEnd() : ""%>" required>
                    </div>

                    <div class="btn-container">
                        <button type="submit" class="save-btn">Save Changes</button>
                        <a href="dashboard.jsp" class="cancel-btn">Cancel</a>
                    </div>
                </form>
            </div>
        </div>
    </body>
</html>