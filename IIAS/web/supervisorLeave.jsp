<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="model.User" %>
<%@ page import="model.LeaveApplication" %>
<%@ page import="java.util.List" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%@ page import="dao.LeaveDAO" %>

<%
    User user = (User) session.getAttribute("user");
    if (user == null || !"supervisor".equalsIgnoreCase(user.getRole())) {
        response.sendRedirect("login.jsp");
        return;
    }

    LeaveDAO leaveDAO = new LeaveDAO();
    List<LeaveApplication> leaveList = leaveDAO.getAllLeavesForSupervisor();
    String success = request.getParameter("success");

    SimpleDateFormat dateFormat = new SimpleDateFormat("yyyy-MM-dd");
    SimpleDateFormat timestampFormat = new SimpleDateFormat("yyyy-MM-dd HH:mm");
%>

<!DOCTYPE html>
<html lang="en">
    <head>
        <meta charset="UTF-8">
        <title>Supervisor - Manage Leave Applications</title>
        <link rel="stylesheet" href="css/viewRecord.css">
        <link rel="stylesheet" href="css/addUser.css">
        <link rel="stylesheet" href="css/supervisorDashboard.css">
        <link rel="stylesheet" href="css/SVLeave.css">
        <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">

    </head>
    <body>

        <!-- Sidebar -->
        <div class="sidebar">
            <div class="brand">Iwhizz<span>Attendance</span></div>
            <div class="sidebar-menu">
                <a href="SupervisorDashboardServlet"><i class="fa-solid fa-chart-pie"></i> Dashboard</a>
                <a href="addUser.jsp"><i class="fa-solid fa-user-plus"></i> Add Intern</a>
                <a href="ViewAllRecordsServlet"><i class="fa-solid fa-folder-open"></i> Attendance Logs</a>
                <a href="supervisorLeave.jsp" class="active"><i class="fa-solid fa-folder-open"></i> Leave request</a>

                <a href="LogoutServlet" style="margin-top: auto; color: #dc3545;"><i class="fa-solid fa-right-from-bracket"></i> Logout</a>
            </div>
        </div>

        <!-- Main Content Wrapper -->
        <div class="main-content">
            <div class="container">
                <div class="header">
                    <h2><i class="fa-solid fa-clipboard-check"></i> Manage Intern Leave Applications</h2>
                </div>

                <% if ("approved".equals(success)) { %>
                <div class="alert-success">
                    <i class="fa-solid fa-circle-check"></i> Leave application approved successfully. Attendance records created!
                </div>
                <% } else if ("rejected".equals(success)) { %>
                <div class="alert-success" style="background-color: #f8d7da; color: #721c24;">
                    <i class="fa-solid fa-circle-xmark"></i> Leave application rejected.
                </div>
                <% } %>

                <!-- Filter Card -->
                <div class="filter-card">
                    <div class="filter-group">
                        <label for="searchName"><i class="fa-solid fa-magnifying-glass"></i> Intern Name:</label>
                        <input type="text" id="searchName" class="filter-input" placeholder="Search by name..." onkeyup="filterTable()">
                    </div>

                    <div class="filter-group">
                        <label for="filterStatus"><i class="fa-solid fa-filter"></i> Status:</label>
                        <select id="filterStatus" class="filter-select" onchange="filterTable()">
                            <option value="">All Statuses</option>
                            <option value="Pending">Pending</option>
                            <option value="Approved">Approved</option>
                            <option value="Rejected">Rejected</option>
                        </select>
                    </div>

                    <button class="btn-reset" onclick="resetFilters()"><i class="fa-solid fa-rotate-right"></i> Reset</button>
                </div>

                <div class="table-responsive">
                    <table class="table" id="leaveTable">
                        <thead>
                            <tr>
                                <th>Leave ID</th>
                                <th>Intern Name</th>
                                <th>Type</th>
                                <th>Dates</th>
                                <th>Days</th>
                                <th>Reason</th>
                                <th>Attachment</th>
                                <th>Status</th>
                                <th>Action</th>
                            </tr>
                        </thead>
                        <tbody>
                            <% if (leaveList != null && !leaveList.isEmpty()) {
                                    for (LeaveApplication leave : leaveList) {
                                        String badgeClass = "badge-pending";
                                        if ("Approved".equalsIgnoreCase(leave.getStatus()))
                                            badgeClass = "badge-approved";
                                        else if ("Rejected".equalsIgnoreCase(leave.getStatus()))
                                            badgeClass = "badge-rejected";
                            %>
                            <tr class="leave-row">
                                <td><%= leave.getLeaveId()%></td>
                                <td class="intern-name"><strong><%= leave.getInternName()%></strong></td>
                                <td><%= leave.getLeaveType()%></td>
                                <td>
                                    <%= dateFormat.format(leave.getStartDate())%> <br>
                                    <small style="color: #6c757d;">to <%= dateFormat.format(leave.getEndDate())%></small>
                                </td>
                                <td><%= leave.getTotalDays()%></td>
                                <td style="max-width: 180px;"><%= leave.getReason()%></td>
                                <td>
                                    <% if (leave.getDocs() != null && !leave.getDocs().trim().isEmpty()) {%>
                                    <a href="${pageContext.request.contextPath}/<%= leave.getDocs()%>" target="_blank" style="color: #007bff;">
                                        <i class="fa-solid fa-file"></i> View
                                    </a>
                                    <% } else { %>
                                    <span style="color: #aaa;">None</span>
                                    <% }%>
                                </td>
                                <td>
                                    <span class="badge <%= badgeClass%> leave-status"><%= leave.getStatus()%></span>
                                </td>
                                <td>
                                    <% if ("Pending".equalsIgnoreCase(leave.getStatus())) {%>
                                    <a href="SupervisorLeaveServlet?action=approve&leaveId=<%= leave.getLeaveId()%>" 
                                       class="btn-action btn-approve"
                                       onclick="return confirm('Approve this leave application? Attendance entries will be created.');">
                                        <i class="fa-solid fa-check"></i> Approve
                                    </a>
                                    <a href="SupervisorLeaveServlet?action=reject&leaveId=<%= leave.getLeaveId()%>" 
                                       class="btn-action btn-reject"
                                       onclick="return confirm('Reject this leave application?');">
                                        <i class="fa-solid fa-xmark"></i> Reject
                                    </a>
                                    <% } else { %>
                                    <span style="color: #6c757d; font-size: 12px;">Processed</span>
                                    <% } %>
                                </td>
                            </tr>
                            <%  }
                            } else { %>
                            <tr>
                                <td colspan="9" style="text-align: center; color: #6c757d; padding: 20px;">
                                    No leave applications submitted yet.
                                </td>
                            </tr>
                            <% }%>

                            <!-- Hidden row displayed when filters match no results -->
                            <tr id="noResultsRow" style="display: none;">
                                <td colspan="9" style="text-align: center; color: #6c757d; padding: 20px;">
                                    No matching leave applications found.
                                </td>
                            </tr>
                        </tbody>
                    </table>
                </div>
            </div>
        </div>

        <script>
            function filterTable() {
                const nameFilter = document.getElementById("searchName").value.toLowerCase().trim();
                const statusFilter = document.getElementById("filterStatus").value.toLowerCase().trim();
                const rows = document.querySelectorAll("#leaveTable tbody .leave-row");
                let visibleCount = 0;

                rows.forEach(row => {
                    const nameCell = row.querySelector(".intern-name");
                    const statusCell = row.querySelector(".leave-status");

                    const nameText = nameCell ? nameCell.textContent.toLowerCase() : "";
                    const statusText = statusCell ? statusCell.textContent.toLowerCase() : "";

                    const matchesName = nameText.includes(nameFilter);
                    const matchesStatus = statusFilter === "" || statusText === statusFilter;

                    if (matchesName && matchesStatus) {
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
                document.getElementById("searchName").value = "";
                document.getElementById("filterStatus").value = "";
                filterTable();
            }
        </script>
    </body>
</html>