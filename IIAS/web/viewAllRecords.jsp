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
    request.setAttribute("activeMenu", "records");
%>
<!DOCTYPE html>
<html>
    <head>
        <meta charset="UTF-8">
        <title>All Attendance Logs</title>
        <%@ include file="snippets/supervisor-head.jspf" %>
    </head>

    <body class="dashboard-layout">

        <%@ include file="includes/sidebar.jspf" %>

        <div class="main-content">
            <div class="container">

                <div class="record-card">
                    <h1>Master Attendance Logs</h1>

                    <div class="filter-section" style="display: flex; gap: 20px; margin-bottom: 25px; flex-wrap: wrap;">
                        <div style="display: flex; flex-direction: column; gap: 5px;">
                            <label for="nameFilter">Filter by Intern:</label>
                            <select id="nameFilter" onchange="filterTable()" class="filter-select">
                                <option value="">-- All Interns --</option>
                                <% for (String name : uniqueNames) {%>
                                <option value="<%= name.toLowerCase()%>"><%= name%></option>
                                <% } %>
                            </select>
                        </div>

                        <div style="display: flex; flex-direction: column; gap: 5px;">
                            <label for="dateFilter">Filter by Date:</label>
                            <input type="date" id="dateFilter" onchange="filterTable()" class="filter-input">
                        </div>

                        <div style="display: flex; align-items: flex-end;">
                            <button onclick="resetFilters()" class="btn btn-outline">Clear Filters</button>
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
