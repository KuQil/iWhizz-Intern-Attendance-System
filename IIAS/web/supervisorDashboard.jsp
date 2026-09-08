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
    request.setAttribute("activeMenu", "dashboard");
%>
<!DOCTYPE html>
<html>
    <head>
        <meta charset="UTF-8">
        <title>Supervisor Dashboard</title>
        <%@ include file="snippets/supervisor-head.jspf" %>
    </head>

    <body class="dashboard-layout">

        <%@ include file="includes/sidebar.jspf" %>

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
                                        <img src="<%= imgIn%>" alt="Selfie" class="selfie-thumb" onclick="window.open(this.src)">
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
