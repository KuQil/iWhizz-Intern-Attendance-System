<%@page import="model.User"%>
<%@page import="model.Attendance"%>
<%@page import="dao.AttendanceDAO"%>

<%
    User user = (User) session.getAttribute("user");

    if (user == null || !"intern".equals(user.getRole())) {
        response.sendRedirect("login.jsp");
        return;
    }

    AttendanceDAO dao = new AttendanceDAO();
    Attendance attendance = dao.getTodayAttendance(user.getUserId());

    // Catch backend error parameters from the servlet
    String error = request.getParameter("error");
    String success = request.getParameter("success");
%>

<!DOCTYPE html>
<html>
    <head>
        <meta charset="UTF-8">
        <title>Clock In</title>
        <link rel="stylesheet" href="css/attendance.css">
        <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.2/css/all.min.css">
    </head>

    <body>

        <div class="container">
            
            <div class="attendance-card">

                <% if (error != null) { %>
                <div class="alert alert-danger" style="color: red; margin-bottom: 20px; font-weight: bold; text-align: center; font-size: 14px;">
                    <% if ("tooEarly".equals(error)) { %>
                    You cannot clock out before 5:00 PM.
                    <% } else if ("outsideGeofence".equals(error)) { %>
                    You are outside the permitted geofence region.
                    <% } else if ("alreadyClocked".equals(error)) { %>
                    You have already clocked in for today.
                    <% } else if ("noClockIn".equals(error)) { %>
                    You need to clock in first.
                    <% } else { %>
                    An error occurred. Please try again.
                    <% } %>
                </div>
                <% } %>

                <% if (success != null) {%>
                <div class="alert alert-success" style="color: green; margin-bottom: 20px; font-weight: bold; text-align: center; font-size: 14px;">
                    <%= "clockin".equals(success) ? "Clock-in successful!" : "Clock-out successful!"%>
                </div>
                <% }%>

                <div class="header">
                    <h1><%= user.getFullName()%></h1>
                    <i class="fa-solid fa-bars"></i>
                </div>

                <a class="back-link" href="dashboard.jsp">? Back to homepage</a>

                <div class="info">
                    <p>
                        <strong>Time:</strong>
                        <span id="currentTime"></span>
                    </p>
                    <p>
                        <strong>Duty:</strong>
                        <span><%= user.isOnField() ? "On-Field" : "Office"%></span>
                    </p>
                    <p>
                        <strong>Location Check:</strong>
                        <span id="locationStatus">Waiting...</span>
                    </p>
                </div>

                <% if (attendance == null) { %>

                <form id="clockInForm" action="AttendanceServlet" method="post">
                    <input type="hidden" name="action" value="clockin">
                    <input type="hidden" id="latitude" name="latitude">
                    <input type="hidden" id="longitude" name="longitude">

                    <button type="button" class="clock-btn" onclick="clockIn()">
                        Clock-In
                    </button>
                </form>

                <% } else if (attendance.getClockOut() == null) { %>

                <form action="AttendanceServlet" method="post">
                    <input type="hidden" name="action" value="clockout">
                    <button type="submit" id="clockOutBtn" class="clock-btn">
                        Clock-Out
                    </button>
                </form>

                <% } else { %>

                <div class="completed">Attendance Completed</div>

                <% }%>

            </div> </div>

        <script>
            function updateTime() {
                let now = new Date();

                document.getElementById("currentTime").innerHTML = now.toLocaleTimeString([], {
                    hour: 'numeric',
                    minute: '2-digit'
                });

                // Client-side validation for the 5 PM rule
                let clockOutBtn = document.getElementById("clockOutBtn");
                if (clockOutBtn) {
                    let currentHour = now.getHours();
                    if (currentHour < 17) { // 17 represents 5 PM
                        clockOutBtn.disabled = true;
                        clockOutBtn.style.opacity = "0.5";
                        clockOutBtn.style.cursor = "not-allowed";
                        clockOutBtn.innerText = "Clock-Out (Locked until 5 PM)";
                    } else {
                        clockOutBtn.disabled = false;
                        clockOutBtn.style.opacity = "1";
                        clockOutBtn.style.cursor = "pointer";
                        clockOutBtn.innerText = "Clock-Out";
                    }
                }
            }

            updateTime();
            setInterval(updateTime, 1000);

            function clockIn() {
                if (!navigator.geolocation) {
                    document.getElementById("locationStatus").innerHTML = "Unavailable";
                    return;
                }

                navigator.geolocation.getCurrentPosition(
                    function (position) {
                        document.getElementById("latitude").value = position.coords.latitude;
                        document.getElementById("longitude").value = position.coords.longitude;
                        document.getElementById("locationStatus").innerHTML = "Valid";
                        document.getElementById("clockInForm").submit();
                    },
                    function () {
                        document.getElementById("locationStatus").innerHTML = "Invalid";
                        alert("Please allow location access.");
                    }
                );
            }
        </script>
    </body>
</html>