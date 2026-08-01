<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="model.User" %>
<%@ page import="model.LeaveApplication" %>
<%@ page import="java.util.List" %>
<%@ page import="java.text.SimpleDateFormat" %>

<%
    // Session Guard Check
    User user = (User) session.getAttribute("user");
    if (user == null || !"intern".equals(user.getRole())) {
        response.sendRedirect("login.jsp");
        return;
    }

    // Retrieve data set by LeaveServlet.showHistory()
    List<LeaveApplication> leaveHistory = (List<LeaveApplication>) request.getAttribute("leaveHistory");
    Integer remainingLeave = (Integer) request.getAttribute("remainingLeave");
    
    if (remainingLeave == null) {
        remainingLeave = 0;
    }

    SimpleDateFormat dateFormat = new SimpleDateFormat("yyyy-MM-dd");
    SimpleDateFormat timestampFormat = new SimpleDateFormat("yyyy-MM-dd HH:mm");
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Leave History</title>
    <!-- FontAwesome icons for UI consistency -->
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    
    <style>
        .history-container {
            max-width: 900px;
            margin: 30px auto;
            padding: 25px;
            background: #ffffff;
            border-radius: 10px;
            box-shadow: 0 4px 12px rgba(0,0,0,0.1);
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
        }
        .header-section {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 25px;
            border-bottom: 2px solid #f1f1f1;
            padding-bottom: 15px;
        }
        .header-title h2 {
            margin: 0;
            color: #333;
        }
        .header-actions {
            display: flex;
            gap: 10px;
            align-items: center;
        }
        .balance-badge {
            background-color: #e3f2fd;
            color: #0d47a1;
            padding: 8px 14px;
            border-radius: 20px;
            font-weight: 600;
            font-size: 14px;
        }
        .btn-apply {
            background-color: #28a745;
            color: white;
            padding: 8px 16px;
            text-decoration: none;
            border-radius: 6px;
            font-weight: 600;
            font-size: 14px;
            transition: background 0.3s ease;
        }
        .btn-apply:hover {
            background-color: #218838;
        }
        .history-table-container {
            overflow-x: auto;
        }
        .history-table {
            width: 100%;
            border-collapse: collapse;
            font-size: 14px;
            text-align: left;
        }
        .history-table th, .history-table td {
            padding: 12px 14px;
            border-bottom: 1px solid #e9ecef;
        }
        .history-table th {
            background-color: #f8f9fa;
            color: #495057;
            font-weight: 600;
        }
        .history-table tr:hover {
            background-color: #f1f3f5;
        }
        /* Status Badges */
        .status-badge {
            padding: 4px 10px;
            border-radius: 12px;
            font-weight: bold;
            font-size: 12px;
            display: inline-block;
            text-align: center;
        }
        .status-pending {
            background-color: #fff3cd;
            color: #856404;
        }
        .status-approved {
            background-color: #d4edda;
            color: #155724;
        }
        .status-rejected {
            background-color: #f8d7da;
            color: #721c24;
        }
        .cert-link {
            color: #007bff;
            text-decoration: none;
            font-weight: 500;
        }
        .cert-link:hover {
            text-decoration: underline;
        }
        .no-data {
            text-align: center;
            color: #6c757d;
            padding: 30px;
            font-style: italic;
        }
        .back-link {
            display: inline-block;
            margin-top: 20px;
            color: #6c757d;
            text-decoration: none;
            font-weight: 500;
        }
        .back-link:hover {
            color: #333;
        }
    </style>
</head>
<body>

<div class="history-container">
    
    <!-- Top Bar Navigation & Title -->
    <div class="header-section">
        <div class="header-title">
            <h2><i class="fa-solid fa-clock-rotate-left"></i> Leave Application History</h2>
        </div>
        <div class="header-actions">
            <span class="balance-badge">
                <i class="fa-solid fa-wallet"></i> Personal Leave: <%= remainingLeave %> Days Left
            </span>
            <a href="leave.jsp" class="btn-apply">
                <i class="fa-solid fa-plus"></i> Apply Leave
            </a>
        </div>
    </div>

    <!-- Leave Records Table -->
    <div class="history-table-container">
        <table class="history-table">
            <thead>
                <tr>
                    <th>Applied Date</th>
                    <th>Type</th>
                    <th>Duration</th>
                    <th>Days</th>
                    <th>Reason</th>
                    <th>Attachment</th>
                    <th>Status</th>
                </tr>
            </thead>
            <tbody>
                <% if (leaveHistory != null && !leaveHistory.isEmpty()) { 
                    for (LeaveApplication leave : leaveHistory) { 
                        
                        String statusClass = "status-pending";
                        if ("Approved".equalsIgnoreCase(leave.getStatus())) {
                            statusClass = "status-approved";
                        } else if ("Rejected".equalsIgnoreCase(leave.getStatus())) {
                            statusClass = "status-rejected";
                        }
                %>
                <tr>
                    <td><%= leave.getAppliedDate() != null ? timestampFormat.format(leave.getAppliedDate()) : "-" %></td>
                    <td><strong><%= leave.getLeaveType() %></strong></td>
                    <td>
                        <%= dateFormat.format(leave.getStartDate()) %> <br>
                        <small style="color: #6c757d;">to <%= dateFormat.format(leave.getEndDate()) %></small>
                    </td>
                    <td><%= leave.getTotalDays() %> <%= leave.getTotalDays() > 1 ? "Days" : "Day" %></td>
                    <td style="max-width: 180px; word-break: break-word;"><%= leave.getReason() %></td>
                    <td>
                        <% if (leave.getDocs() != null && !leave.getDocs().trim().isEmpty()) { %>
                            <a href="<%= leave.getDocs() %>" target="_blank" class="cert-link">
                                <i class="fa-solid fa-file-arrow-down"></i> View File
                            </a>
                        <% } else { %>
                            <span style="color: #aaa;">None</span>
                        <% } %>
                    </td>
                    <td>
                        <span class="status-badge <%= statusClass %>">
                            <%= leave.getStatus() != null ? leave.getStatus() : "Pending" %>
                        </span>
                    </td>
                </tr>
                <%  } 
                   } else { %>
                <tr>
                    <td colspan="7" class="no-data">
                        <i class="fa-regular fa-folder-open fa-2x"></i><br><br>
                        No leave applications found.
                    </td>
                </tr>
                <% } %>
            </tbody>
        </table>
    </div>

    <a href="dashboard.jsp" class="back-link">
        <i class="fa-solid fa-arrow-left"></i> Back to Dashboard
    </a>

</div>

</body>
</html>