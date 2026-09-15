<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="model.User" %>
<%@ page import="java.util.List" %>

<%
    User user = (User) session.getAttribute("user");
    if (user == null || !"supervisor".equalsIgnoreCase(user.getRole())) {
        response.sendRedirect("login.jsp");
        return;
    }

    @SuppressWarnings("unchecked")
    List<User> internsList = (List<User>) request.getAttribute("internsList");
    String success = request.getParameter("success");
    String error = request.getParameter("error");
    request.setAttribute("activeMenu", "interns");
%>

<!DOCTYPE html>
<html lang="en">
    <head>
        <meta charset="UTF-8">
        <title>Supervisor - Manage Interns</title>
        <%@ include file="snippets/supervisor-head.jspf" %>
    </head>
    <body>

        <%@ include file="includes/sidebar.jspf" %>

        <!-- Main Content Wrapper -->
        <div class="main-content">
            <div class="container">
                <div class="header">
                    <h2><i class="fa-solid fa-users"></i> Manage Intern Accounts</h2>
                </div>

                <!-- Success/Error Messages -->
                <% if ("archived".equals(success)) { %>
                <div class="alert-success">
                    <i class="fa-solid fa-circle-check"></i> Intern account archived successfully.
                </div>
                <% } else if ("deleted".equals(success)) { %>
                <div class="alert-success">
                    <i class="fa-solid fa-circle-check"></i> Intern account deleted successfully.
                </div>
                <% } else if ("archive_failed".equals(error)) { %>
                <div class="alert-error">
                    <i class="fa-solid fa-circle-xmark"></i> Failed to archive intern account. Please try again.
                </div>
                <% } else if ("delete_failed".equals(error)) { %>
                <div class="alert-error">
                    <i class="fa-solid fa-circle-xmark"></i> Failed to delete intern account. Please try again.
                </div>
                <% } %>

                <!-- Filter Card -->
                <div class="filter-card">
                    <div class="filter-group">
                        <label for="searchName"><i class="fa-solid fa-magnifying-glass"></i> Intern Name:</label>
                        <input type="text" id="searchName" class="filter-input" placeholder="Search by name or username..." onkeyup="filterTable()">
                    </div>

                    <button class="btn btn-outline" onclick="resetFilters()"><i class="fa-solid fa-rotate-right"></i> Reset</button>
                </div>

                <!-- Interns Table -->
                <div class="table-responsive">
                    <table class="table" id="internsTable">
                        <thead>
                            <tr>
                                <th>Full Name</th>
                                <th>Username</th>
                                <th>Internship Period</th>
                                <th>Personal Leave Remaining</th>
                                <th>Status</th>
                                <th>Actions</th>
                            </tr>
                        </thead>
                        <tbody>
                            <% if (internsList != null && !internsList.isEmpty()) {
                                    for (User intern : internsList) {
                            %>
                            <tr class="intern-row">
                                <td class="intern-name"><strong><%= intern.getFullName()%></strong></td>
                                <td><%= intern.getUsername()%></td>
                                <td>
                                    <%= intern.getInternshipStart()%> <br>
                                    <small style="color: #6c757d;">to <%= intern.getInternshipEnd()%></small>
                                </td>
                                <td><%= intern.getPersonalLeaveRemaining()%> days</td>
                                <td>
                                    <span class="status-badge present">Active</span>
                                </td>
                                <td class="action-cell">
                                    <a href="SupervisorInternManagementServlet?action=viewHistory&userId=<%= intern.getUserId()%>" 
                                       class="btn-action btn-primary" title="View Attendance History">
                                        <i class="fa-solid fa-history"></i> History
                                    </a>
                                    <a href="supervisorInternEdit.jsp?userId=<%= intern.getUserId()%>" 
                                       class="btn-action btn-primary" title="Edit Intern Information">
                                        <i class="fa-solid fa-pen-to-square"></i> Edit
                                    </a>
                                    <a href="SupervisorInternManagementServlet?action=archive&userId=<%= intern.getUserId()%>" 
                                       class="btn-action btn-outline"
                                       onclick="return confirm('Archive this intern account? They will not be able to log in.');">
                                        <i class="fa-solid fa-archive"></i> Archive
                                    </a>
                                    <a href="SupervisorInternManagementServlet?action=delete&userId=<%= intern.getUserId()%>" 
                                       class="btn-action btn-danger"
                                       onclick="return confirm('Delete this intern account permanently? This action cannot be undone.');">
                                        <i class="fa-solid fa-trash"></i> Delete
                                    </a>
                                </td>
                            </tr>
                            <%  }
                            } else { %>
                            <tr>
                                <td colspan="7" style="text-align: center; color: #6c757d; padding: 20px;">
                                    No active interns found.
                                </td>
                            </tr>
                            <% }%>

                            <!-- Hidden row displayed when filters match no results -->
                            <tr id="noResultsRow" style="display: none;">
                                <td colspan="7" style="text-align: center; color: #6c757d; padding: 20px;">
                                    No matching interns found.
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
                const rows = document.querySelectorAll("#internsTable tbody .intern-row");
                let visibleCount = 0;

                rows.forEach(row => {
                    const nameCell = row.querySelector(".intern-name");
                    const usernameCell = row.cells[2];

                    const nameText = nameCell ? nameCell.textContent.toLowerCase() : "";
                    const usernameText = usernameCell ? usernameCell.textContent.toLowerCase() : "";

                    const matchesFilter = nameText.includes(nameFilter) || usernameText.includes(nameFilter);

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
                document.getElementById("searchName").value = "";
                filterTable();
            }
        </script>
    </body>
</html>
