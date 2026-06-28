<%@page import="model.User"%>

<%
    User user = (User) session.getAttribute("user");

    if (user == null || !"intern".equals(user.getRole())) {
        response.sendRedirect("../index.jsp");
        return;
    }
%>

<!DOCTYPE html>
<html>
    <head>
        <meta charset="UTF-8">
        <title>Intern Dashboard</title>
        <link rel="stylesheet" href="css/dashboard.css">
        <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.2/css/all.min.css">
    </head>

    <body>
        <div class="phone-container">
            <div class="header">
                <div>
                    <h2><%= user.getFullName()%></h2>
                    <p>
                        Duty: <%= user.isOnField() ? "On-Field" : "Office"%>
                    </p>
                </div>
                <button class="menu-btn" onclick="toggleMenu()">
                    <i class="fa-solid fa-bars"></i>
                </button>
            </div>

            <a href="attendance.jsp" class="dashboard-card">
                <i class="fa-regular fa-clock"></i>
                <h3>Clock-In</h3>
                <span id="currentTime">--</span>
            </a>

            <a href="leave.jsp" class="dashboard-card">
                <i class="fa-regular fa-calendar"></i>
                <h3>Leave Application</h3>
                <p>Days Left: <%= user.getPersonalLeaveRemaining()%></p>
            </a>
                
            <a href="AttendanceHistory" class="dashboard-card">
                <i class="fa-solid fa-list"></i>
                <h3>View Records</h3>
            </a>

            <div class="action-section">
                <a href="LogoutServlet" class="action-button danger-btn">
                    <i class="fa-solid fa-right-from-bracket"></i> Logout Account
                </a>
            </div>

        </div>

        <script>
            function toggleMenu() {
                let menu = document.getElementById("menu");
                if (menu.style.display === "block") {
                    menu.style.display = "none";
                } else {
                    menu.style.display = "block";
                }
            }

            function updateClock() {
                let now = new Date();
                document.getElementById("currentTime").innerHTML = now.toLocaleTimeString([], {
                    hour: '2-digit',
                    minute: '2-digit'
                });
            }

            updateClock();
            setInterval(updateClock, 1000);
        </script>
    </body>
</html>