<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="model.User" %>
<%@ page import="dao.LeaveDAO" %>
<%@ page import="java.time.LocalDate" %>

<%
    // Session Guard Check
    User user = (User) session.getAttribute("user");
    if (user == null || !"intern".equals(user.getRole())) {
        response.sendRedirect("login.jsp");
        return;
    }

    // Fetch remaining leave balance for display
    LeaveDAO leaveDAO = new LeaveDAO();
    int remainingLeave = leaveDAO.getRemainingPersonalLeave(user.getUserId());
    
    // Status feedback handling
    String error = request.getParameter("error");
    LocalDate today = LocalDate.now();
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Leave Application</title>
    <!-- FontAwesome for matching UI design icons -->
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    
    <style>
        .leave-container {
            max-width: 600px;
            margin: 30px auto;
            padding: 25px;
            background: #ffffff;
            border-radius: 10px;
            box-shadow: 0 4px 12px rgba(0,0,0,0.1);
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
        }
        .form-title {
            text-align: center;
            color: #333;
            margin-bottom: 20px;
        }
        .leave-balance {
            background-color: #e8f4fd;
            border-left: 4px solid #2196F3;
            padding: 12px;
            margin-bottom: 20px;
            border-radius: 4px;
            color: #0d47a1;
            font-weight: 500;
        }
        .alert-danger {
            background-color: #ffebee;
            color: #c62828;
            border-left: 4px solid #f44336;
            padding: 12px;
            margin-bottom: 20px;
            border-radius: 4px;
        }
        .form-group {
            margin-bottom: 18px;
        }
        .form-group label {
            display: block;
            margin-bottom: 6px;
            font-weight: 600;
            color: #444;
        }
        .form-control {
            width: 100%;
            padding: 10px;
            border: 1px solid #ccc;
            border-radius: 6px;
            box-sizing: border-box;
            font-size: 14px;
        }
        .form-control:focus {
            outline: none;
            border-color: #2196F3;
        }
        .form-row {
            display: flex;
            gap: 15px;
        }
        .form-row .form-group {
            flex: 1;
        }
        .btn-submit {
            width: 100%;
            padding: 12px;
            background-color: #007bff;
            color: white;
            border: none;
            border-radius: 6px;
            font-size: 16px;
            font-weight: bold;
            cursor: pointer;
            transition: background 0.3s ease;
        }
        .btn-submit:hover {
            background-color: #0056b3;
        }
        .attachment-note {
            font-size: 12px;
            color: #666;
            margin-top: 4px;
        }
    </style>
</head>
<body>

<div class="leave-container">
    <h2 class="form-title"><i class="fa-solid fa-calendar-plus"></i> Apply for Leave</h2>

    <!-- Alert Notifications -->
    <% if ("insufficient".equals(error)) { %>
        <div class="alert-danger">
            <i class="fa-solid fa-circle-exclamation"></i> Application failed: Requested days exceed your remaining personal leave balance.
        </div>
    <% } else if ("failed".equals(error)) { %>
        <div class="alert-danger">
            <i class="fa-solid fa-circle-exclamation"></i> Application submission failed. Please try again.
        </div>
    <% } %>

    <!-- Balance Info -->
    <div class="leave-balance">
        <i class="fa-solid fa-circle-info"></i> Remaining Personal Leave Entitlement: <strong><%= remainingLeave %> Days</strong>
    </div>

    <!-- Application Form -->
    <form action="LeaveServlet" method="post" enctype="multipart/form-data" onsubmit="return validateForm()">
        
        <!-- Hidden Action Field -->
        <input type="hidden" name="action" value="apply">
        
        <!-- Hidden Intern ID and Created Date (As Requested) -->
        <input type="hidden" name="intern_id" value="<%= user.getUserId() %>">
        <input type="hidden" name="date_created" value="<%= today %>">

        <!-- Leave Type -->
        <div class="form-group">
            <label for="leaveType"><i class="fa-solid fa-list-check"></i> Leave Type</label>
            <select name="leaveType" id="leaveType" class="form-control" onchange="toggleAttachment()" required>
                <option value="">-- Select Leave Type --</option>
                <option value="Personal">Personal Leave</option>
                <option value="Medical">Medical Leave</option>
                <option value="Out Station">Out station</option>
            </select>
        </div>

        <!-- Date Range -->
        <div class="form-row">
            <div class="form-group">
                <label for="startDate"><i class="fa-regular fa-calendar"></i> Start Date</label>
                <input type="date" name="startDate" id="startDate" class="form-control" required>
            </div>
            <div class="form-group">
                <label for="endDate"><i class="fa-regular fa-calendar-check"></i> End Date</label>
                <input type="date" name="endDate" id="endDate" class="form-control" required>
            </div>
        </div>

        <!-- Attachment Field (Medical Certificate / Support Document) -->
        <div class="form-group" id="attachmentGroup">
            <label for="docs"><i class="fa-solid fa-paperclip"></i> Attachment (Document / Image)</label>
            <input type="file" name="docs" id="docs" class="form-control" accept="image/*,.pdf">
            <div class="attachment-note" id="attachmentNote">Required for Medical Leave (JPG, PNG, PDF). Optional for Personal Leave.</div>
        </div>

        <!-- Reason -->
        <div class="form-group">
            <label for="reason"><i class="fa-solid fa-comment-dots"></i> Reason for Leave</label>
            <textarea name="reason" id="reason" rows="4" class="form-control" placeholder="Please state your reason for taking leave..." required></textarea>
        </div>

        <!-- Submit Button -->
        <button type="submit" class="btn-submit">
            <i class="fa-solid fa-paper-plane"></i> Submit Leave Application
        </button>
    </form>
</div>

<script>
    // Dynamically adjust attachment requirement based on leave type
    function toggleAttachment() {
        const leaveType = document.getElementById("leaveType").value;
        const fileInput = document.getElementById("docs");
        const attachmentNote = document.getElementById("attachmentNote");

        if (leaveType === "Medical") {
            fileInput.required = true;
            attachmentNote.style.color = "#c62828";
            attachmentNote.innerHTML = "<strong>* Required:</strong> Medical Certificate must be attached.";
        } else {
            fileInput.required = false;
            attachmentNote.style.color = "#666";
            attachmentNote.innerHTML = "Optional supporting document (JPG, PNG, PDF).";
        }
    }

    // Client-side date range validation
    function validateForm() {
        const start = new Date(document.getElementById("startDate").value);
        const end = new Date(document.getElementById("endDate").value);

        if (end < start) {
            alert("End Date cannot be earlier than Start Date.");
            return false;
        }
        return true;
    }
</script>

</body>
</html>