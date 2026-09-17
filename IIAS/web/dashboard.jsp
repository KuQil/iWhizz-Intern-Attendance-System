<%@page import="model.User"%>
<%@page import="dao.AttendanceDAO"%>
<%@page import="model.Attendance"%>

<%
    User user = (User) session.getAttribute("user");

    if (user == null || !"intern".equals(user.getRole())) {
        response.sendRedirect("login.jsp");
        return;
    }

    AttendanceDAO attDao = new AttendanceDAO();
    Attendance att = attDao.getTodayAttendance(user.getUserId());
    Attendance cocheck = attDao.clockOutCheck(user.getUserId());

%>

<!DOCTYPE html>
<html>
    <head>
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
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
                    <div id="currentDate">--</div>
                    </p>
                </div>
                <div class="dropdown">
                    <button class="dropbtn">
                        <i class="fa-solid fa-bars"></i>
                    </button>
                    <div class="drop-content">
                        <a href="editAcc.jsp">
                            <i class="fa-solid fa-user-pen"></i> Edit Account
                        </a>
                    </div>
                </div>

            </div>

            <a href="attendance.jsp" class="dashboard-card">
                <i class="fa-regular fa-clock"></i>
                <% if (cocheck == null && att.getClockIn() == null) { %>
                <h3>Clock-In</h3>
                <% } else {%>
                <h3>Clock-Out</h3>
                <%};%>

                <div id="currentTime">--</div>
            </a>

            <a href="LeaveServlet" class="dashboard-card">
                <i class="fa-regular fa-calendar"></i>
                <h3>Leave Application</h3>
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

            function updateClock() {
                let now = new Date();

                // Set Date
                document.getElementById("currentDate").innerHTML = now.toLocaleDateString([], {
                    weekday: 'long',
                    year: 'numeric',
                    month: 'long',
                    day: 'numeric'
                });

                // Set Time
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
