<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="java.util.List"%>
<%@page import="model.Attendance"%>
<%
    // Ensure the array list is declared and intercepted correctly at the top hook
    List<Attendance> attendanceList = (List<Attendance>) request.getAttribute("attendanceList");
%>
<!DOCTYPE html>
<html>
    <head>
        <meta charset="UTF-8">
        <title>Attendance Records</title>
        <link rel="stylesheet" href="css/viewRecord.css">
    </head>

    <body>

        <div class="container">
            
            <div class="record-card">

                <h1>Attendance Records</h1>

                <div class="table-wrapper">
                    <table id="attendanceTable">
                        <thead>
                            <tr>
                                <th>Date</th>
                                <th>Clock In</th>
                                <th>Clock Out</th>
                                <th>Status</th>
                            </tr>
                        </thead>
                        <tbody>
                            <%
                                if (attendanceList != null && !attendanceList.isEmpty()) {
                                    for (Attendance attendance : attendanceList) {
                                        String dateStr = (attendance.getAttendanceDate() != null) ? attendance.getAttendanceDate().toString() : "";
                                        String monthValue = (dateStr.length() >= 7) ? dateStr.substring(5, 7) : "";
                                        String status = (attendance.getAttendanceStatus() != null) ? attendance.getAttendanceStatus().toLowerCase() : "present";
                            %>
                            <tr data-month="<%= monthValue %>">
                                <td><%= dateStr %></td>
                                <td><%= (attendance.getClockIn() != null) ? attendance.getClockIn() : "-" %></td>
                                <td><%= (attendance.getClockOut() != null) ? attendance.getClockOut() : "-" %></td>
                                <td>
                                    <span class="status-badge <%= status %>">
                                        <%= status %>
                                    </span>
                                </td>
                            </tr>
                            <%
                                    }
                                } else {
                            %>
                            <tr>
                                <td colspan="4" style="color: #999999; padding: 30px;">No attendance records found.</td>
                            </tr>
                            <%  } %>
                        </tbody>
                    </table>
                </div>

                <a class="back-link" href="dashboard.jsp">← Back To Dashboard</a>

            </div> </div>

        <script>
            // Client-side script filtering implementation logic
            document.getElementById("monthFilter").addEventListener("change", function () {
                let selectedMonth = this.value;
                let rows = document.querySelectorAll("#attendanceTable tbody tr");

                rows.forEach(function (row) {
                    // Skip handling if it is the clean empty state notice row
                    if(row.cells.length === 1) return;

                    if (selectedMonth === "") {
                        row.style.display = "";
                    } else if (row.dataset.month === selectedMonth) {
                        row.style.display = "";
                    } else {
                        row.style.display = "none";
                    }
                });
            });
        </script>

    </body>
</html>