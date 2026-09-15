<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="model.User" %>
<%@ page import="model.Attendance" %>
<%@ page import="java.util.List" %>
<%@ page import="java.text.SimpleDateFormat" %>

<%
    User user = (User) session.getAttribute("user");
    if (user == null || !"supervisor".equalsIgnoreCase(user.getRole())) {
        response.sendRedirect("login.jsp");
        return;
    }

    User intern = (User) request.getAttribute("intern");
    @SuppressWarnings("unchecked")
    List<Attendance> attendanceHistory = (List<Attendance>) request.getAttribute("attendanceHistory");
    
    if (intern == null) {
        response.sendRedirect("SupervisorInternManagementServlet");
        return;
    }

    SimpleDateFormat dateFormat = new SimpleDateFormat("yyyy-MM-dd");
    SimpleDateFormat timeFormat = new SimpleDateFormat("HH:mm");
    request.setAttribute("activeMenu", "interns");
%>

<!DOCTYPE html>
<html lang="en">
    <head>
        <meta charset="UTF-8">
        <title>Supervisor - Intern Attendance History</title>
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
                        <h2><i class="fa-solid fa-history"></i> Attendance History</h2>
                    </div>
                </div>

                <!-- Intern Info Card -->
                <div class="record-card">
                    <div style="display: grid; grid-template-columns: 1fr 1fr 1fr; gap: 20px;">
                        <div>
                            <p style="color: #6c757d; font-size: 12px; text-transform: uppercase;">Intern Name</p>
                            <p style="margin: 0; font-weight: bold; font-size: 16px;"><%= intern.getFullName()%></p>
                        </div>
                        <div>
                            <p style="color: #6c757d; font-size: 12px; text-transform: uppercase;">Username</p>
                            <p style="margin: 0; font-weight: bold; font-size: 16px;"><%= intern.getUsername()%></p>
                        </div>
                        <div>
                            <p style="color: #6c757d; font-size: 12px; text-transform: uppercase;">Internship Period</p>
                            <p style="margin: 0; font-weight: bold; font-size: 14px;"><%= intern.getInternshipStart()%> to <%= intern.getInternshipEnd()%></p>
                        </div>
                    </div>
                </div>

                <!-- Filter Card -->
                <div class="filter-card">
                    <div class="filter-group">
                        <label for="filterStatus"><i class="fa-solid fa-filter"></i> Attendance Status:</label>
                        <select id="filterStatus" class="filter-select" onchange="filterTable()">
                            <option value="">All Status</option>
                            <option value="present">Present</option>
                            <option value="late">Late</option>
                            <option value="personal leave">Personal Leave</option>
                            <option value="medical leave">Medical Leave</option>
                            <option value="out station">Out Station</option>
                            <option value="absent">Absent</option>
                        </select>
                    </div>

                    <button class="btn btn-outline" onclick="resetFilters()"><i class="fa-solid fa-rotate-right"></i> Reset</button>
                </div>

                <!-- Attendance History Table -->
                <div class="table-responsive">
                    <table class="table" id="attendanceTable">
                        <thead>
                            <tr>
                                <th>Date</th>
                                <th>Clock In Time</th>
                                <th>Verification Selfie In</th>
                                <th>Clock Out Time</th>
                                <th>Verification Selfie Out</th>
                                <th>Attendance Status</th>
                                <th>Comments</th>
                            </tr>
                        </thead>
                        <tbody>
                            <% if (attendanceHistory != null && !attendanceHistory.isEmpty()) {
                                    for (Attendance att : attendanceHistory) {
                                        String status = (att.getAttendanceStatus() != null) ? att.getAttendanceStatus().toLowerCase() : "absent";
                                        String imgIn = att.getSelfiePathIn();
                                        String imgOut = att.getSelfiePathOut();
                            %>
                            <tr class="attendance-row" data-status="<%= status%>">
                                <td><strong><%= (att.getAttendanceDate() != null) ? dateFormat.format(att.getAttendanceDate()) : "N/A"%></strong></td>
                                <td><%= (att.getClockIn() != null) ? timeFormat.format(att.getClockIn()) : "-"%></td>
                                <td>
                                    <% if (imgIn != null && !imgIn.trim().isEmpty()) {%>
                                    <img src="<%= imgIn%>" alt="Selfie In" class="selfie-thumb" onclick="window.open(this.src)">
                                    <% } else { %>
                                    <span class="no-img">No Image</span>
                                    <% }%>
                                </td>
                                <td><%= (att.getClockOut() != null) ? timeFormat.format(att.getClockOut()) : "-"%></td>
                                <td>
                                    <% if (imgOut != null && !imgOut.trim().isEmpty()) {%>
                                    <img src="<%= imgOut%>" alt="Selfie Out" class="selfie-thumb" onclick="window.open(this.src)">
                                    <% } else { %>
                                    <span class="no-img">No Image</span>
                                    <% }%>
                                </td>
                                <td>
                                    <span class="status-badge <%= status%>">
                                        <%= status%>
                                    </span>
                                </td>
                                <td><%= (att.getComment() != null && !att.getComment().isEmpty()) ? att.getComment() : "-"%></td>
                            </tr>
                            <%  }
                            } else { %>
                            <tr>
                                <td colspan="7" style="text-align: center; color: #6c757d; padding: 20px;">
                                    No attendance records found for this intern.
                                </td>
                            </tr>
                            <% }%>

                            <!-- Hidden row displayed when filters match no results -->
                            <tr id="noResultsRow" style="display: none;">
                                <td colspan="7" style="text-align: center; color: #6c757d; padding: 20px;">
                                    No matching attendance records found.
                                </td>
                            </tr>
                        </tbody>
                    </table>
                </div>
            </div>
        </div>

        <script>
            function filterTable() {
                const statusFilter = document.getElementById("filterStatus").value.toLowerCase().trim();
                const rows = document.querySelectorAll("#attendanceTable tbody .attendance-row");
                let visibleCount = 0;

                rows.forEach(row => {
                    const rowStatus = row.getAttribute("data-status");
                    const matchesFilter = statusFilter === "" || rowStatus === statusFilter;

                    if (matchesFilter) {
                        row.style.display = "";
                        visibleCount++;
                    } else {
                        row.style.display = "none";
                    }
                });

                // Show "No matching records" message if all rows are hidden
                const noResultsRow = document.getElementById("noResultsRow");
                if (noResultsRow) {
                    noResultsRow.style.display = (visibleCount === 0 && rows.length > 0) ? "" : "none";
                }
            }

            function resetFilters() {
                document.getElementById("filterStatus").value = "";
                filterTable();
            }
        </script>
    </body>
</html>
