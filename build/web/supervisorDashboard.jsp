<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="java.util.List"%>
<%@page import="model.Attendance"%>
<%@page import="model.User"%>
<%
    List<Attendance> todayAttendance = (List<Attendance>) request.getAttribute("todayAttendanceList");
    User supervisor = (User) session.getAttribute("user");

    int totalPresent = 0;
    int totalLate = 0;

    if (todayAttendance != null) {
        for (Attendance a : todayAttendance) {
            if ("late".equalsIgnoreCase(a.getAttendanceStatus())) {
                totalLate++;
            } else if ("present".equalsIgnoreCase(a.getAttendanceStatus())) {
                totalPresent++;
            }
        }
    }
%>
<!DOCTYPE html>
<html>
    <head>
        <meta charset="UTF-8">
        <title>Supervisor Dashboard</title>
        <link rel="stylesheet" href="css/viewRecord.css">
        <link rel="stylesheet" href="css/addUser.css">
        <link rel="stylesheet" href="css/supervisorDashboard.css">
        <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    </head>

    <body class="dashboard-layout">

        <div class="sidebar">
            <div class="brand">Iwhizz<span>Attendance</span></div>
            <div class="sidebar-menu">
                <a href="SupervisorDashboardServlet" class="active"><i class="fa-solid fa-chart-pie"></i> Dashboard</a>
                <a href="addUser.jsp"><i class="fa-solid fa-user-plus"></i> Add Intern</a>
                <a href="ViewAllRecordsServlet"><i class="fa-solid fa-folder-open"></i> Attendance Logs</a>
                <a href="supervisorLeave.jsp"><i class="fa-solid fa-folder-open"></i> Leave request</a>
                
                <a href="LogoutServlet" style="margin-top: auto; color: #dc3545;"><i class="fa-solid fa-right-from-bracket"></i> Logout</a>
            </div>
        </div>

        <div class="main-content">
            <div class="container">

                <div class="record-card">
                    <h1>Today's Intern Attendance</h1>

                    <div class="table-wrapper">
                        <table id="attendanceTable">
                            <thead>
                                <tr>
                                    <th>Intern Name</th> <th>Clock In Time</th>
                                    <th>Verification Selfie</th>
                                    <th>Clock Out Time</th>
                                    <th>Status Badge</th>
                                </tr>
                            </thead>
                            <tbody>
                                <%
                                    if (todayAttendance != null && !todayAttendance.isEmpty()) {
                                        for (Attendance attendance : todayAttendance) {
                                            String status = (attendance.getAttendanceStatus() != null) ? attendance.getAttendanceStatus().toLowerCase() : "present";
                                            String imgIn = attendance.getSelfiePathIn();
                                %>
                                <tr>
                                    <td><strong><%= (attendance.getUserName() != null) ? attendance.getUserName() : "Unknown Intern"%></strong></td>
                                    <td><%= (attendance.getClockIn() != null) ? attendance.getClockIn().toString().substring(11, 16) : "-"%></td>
                                    <td>
                                        <% if (imgIn != null && !imgIn.trim().isEmpty()) {%>
                                        <img src="${pageContext.request.contextPath}/<%= imgIn%>" alt="Selfie" class="selfie-thumb" onclick="window.open(this.src)">
                                        <% } else { %>
                                        <span class="no-img">No Image</span>
                                        <% }%>
                                    </td>
                                    <td><%= (attendance.getClockOut() != null) ? attendance.getClockOut().toString().substring(11, 16) : "-"%></td>
                                    <td>
                                        <span class="status-badge <%= status%>">
                                            <%= status%>
                                        </span>
                                    </td>
                                </tr>
                                <%
                                    }
                                } else {
                                %>
                                <tr>
                                    <td colspan="5" style="color: #999999; padding: 40px; text-align: center;">
                                        No intern attendance submissions recorded for today yet.
                                    </td>
                                </tr>
                                <%  }%>
                            </tbody>
                        </table>
                    </div>

                </div> 
            </div>
        </div>
    </body>
</html>