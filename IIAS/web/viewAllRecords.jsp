<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="java.util.List"%>
<%@page import="java.util.Set"%>
<%@page import="java.util.HashSet"%>
<%@page import="model.Attendance"%>
<%
    List<Attendance> allRecords = (List<Attendance>) request.getAttribute("allRecordsList");

    // Extract unique intern names dynamically to populate the dropdown filter
    Set<String> uniqueNames = new HashSet<>();
    if (allRecords != null) {
        for (Attendance a : allRecords) {
            if (a.getUserName() != null) {
                uniqueNames.add(a.getUserName());
            }
        }
    }
%>
<!DOCTYPE html>
<html>
    <head>
        <meta charset="UTF-8">
        <title>All Attendance Logs</title>
        <link rel="stylesheet" href="css/viewRecord.css">
        <link rel="stylesheet" href="css/addUser.css">
        <link rel="stylesheet" href="css/supervisorDashboard.css">
        <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    </head>

    <body class="dashboard-layout">

        <div class="sidebar">
            <div class="brand">Iwhizz<span>Attendance</span></div>
            <div class="sidebar-menu">
                <a href="SupervisorDashboardServlet"><i class="fa-solid fa-chart-pie"></i> Dashboard</a>
                <a href="addUser.jsp"><i class="fa-solid fa-user-plus"></i> Add Intern</a>
                <a href="ViewAllRecordsServlet" class="active"><i class="fa-solid fa-folder-open"></i> Attendance Logs</a>
                <a href="supervisorLeave.jsp"><i class="fa-solid fa-folder-open"></i> Leave request</a>
                <a href="LogoutServlet" style="margin-top: auto; color: #dc3545;"><i class="fa-solid fa-right-from-bracket"></i> Logout</a>
            </div>
        </div>

        <div class="main-content">
            <div class="container">

                <div class="record-card">
                    <h1>Master Attendance Logs</h1>

                    <div class="filter-section" style="display: flex; gap: 20px; margin-bottom: 25px; flex-wrap: wrap;">
                        <div style="display: flex; flex-direction: column; gap: 5px;">
                            <label for="nameFilter">Filter by Intern:</label>
                            <select id="nameFilter" onchange="filterTable()">
                                <option value="">-- All Interns --</option>
                                <% for (String name : uniqueNames) {%>
                                <option value="<%= name.toLowerCase()%>"><%= name%></option>
                                <% } %>
                            </select>
                        </div>

                        <div style="display: flex; flex-direction: column; gap: 5px;">
                            <label for="dateFilter">Filter by Date:</label>
                            <input type="date" id="dateFilter" onchange="filterTable()" style="padding: 9px 12px; border: 1px solid #cccccc; border-radius: 10px; outline: none;">
                        </div>

                        <div style="display: flex; align-items: flex-end;">
                            <button onclick="resetFilters()" style="padding: 10px 15px; background: #f5f5f5; border: 1px solid #ccc; border-radius: 10px; cursor: pointer; font-weight: 600;">Clear Filters</button>
                        </div>
                    </div>

                    <div class="table-wrapper">
                        <table id="masterAttendanceTable">
                            <thead>
                                <tr>
                                    <th>Date</th>
                                    <th>Intern Name</th>
                                    <th>Clock In</th>
                                    <th>Verification Selfie</th>
                                    <th>Clock Out</th>
                                    <th>Status</th>
                                </tr>
                            </thead>
                            <tbody>
                                <%
                                    if (allRecords != null && !allRecords.isEmpty()) {
                                        for (Attendance attendance : allRecords) {
                                            String dateStr = (attendance.getAttendanceDate() != null) ? attendance.getAttendanceDate().toString() : "";
                                            String status = (attendance.getAttendanceStatus() != null) ? attendance.getAttendanceStatus().toLowerCase() : "present";
                                            String imgIn = attendance.getSelfiePathIn();
                                %>
                                <tr data-name="<%= (attendance.getUserName() != null) ? attendance.getUserName().toLowerCase() : ""%>" data-date="<%= dateStr%>">
                                    <td><%= dateStr%></td>
                                    <td><strong><%= (attendance.getUserName() != null) ? attendance.getUserName() : "Unknown"%></strong></td>
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
                                        <span class="status-badge <%= status%>"><%= status%></span>
                                    </td>
                                </tr>
                                <%
                                    }
                                } else {
                                %>
                                <tr>
                                    <td colspan="6" style="color: #999999; padding: 40px; text-align: center;">No system records found.</td>
                                </tr>
                                <% }%>
                            </tbody>
                        </table>
                    </div>
                </div> 
            </div>
        </div>

        <script>
            function filterTable() {
                let selectedName = document.getElementById("nameFilter").value;
                let selectedDate = document.getElementById("dateFilter").value;
                let rows = document.querySelectorAll("#masterAttendanceTable tbody tr");

                rows.forEach(row => {
                    // Skip 'No records found' placeholder row
                    if (row.cells.length === 1)
                        return;

                    intName = row.dataset.name;
                    attDate = row.dataset.date;

                    let nameMatches = (selectedName === "" || intName === selectedName);
                    let dateMatches = (selectedDate === "" || attDate === selectedDate);

                    if (nameMatches && dateMatches) {
                        row.style.display = "";
                    } else {
                        row.style.display = "none";
                    }
                });
            }

            function resetFilters() {
                document.getElementById("nameFilter").value = "";
                document.getElementById("dateFilter").value = "";
                filterTable();
            }
        </script>
    </body>
</html>
