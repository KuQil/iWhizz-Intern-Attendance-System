<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="java.util.List"%>
<%@page import="model.Attendance"%>
<%
    List<Attendance> attendanceList = (List<Attendance>) request.getAttribute("attendanceList");
%>
<!DOCTYPE html>
<html>
    <head>
        <meta charset="UTF-8">
        <title>Attendance Records</title>
        <link rel="stylesheet" href="css/viewRecord.css">
        <style>
            .selfie-thumb {
                width: 50px;
                height: 50px;
                object-fit: cover;
                border-radius: 4px;
                border: 1px solid #ddd;
                cursor: pointer;
                transition: transform 0.2s;
            }
            .selfie-thumb:hover {
                transform: scale(1.1);
            }
            .no-img {
                color: #bbb;
                font-size: 12px;
                font-style: italic;
            }
            /* Styling for the new editable input element */
            .editable-comment {
                width: 100%;
                padding: 6px 10px;
                border: 1px solid #ccc;
                border-radius: 4px;
                box-sizing: border-box;
                font-family: inherit;
                font-size: 14px;
            }
            .editable-comment:focus {
                border-color: #4CAF50;
                outline: none;
                background-color: #f9fff9;
            }
            .save-btn {
                background-color: #4CAF50;
                color: white;
                border: none;
                padding: 10px 20px;
                border-radius: 4px;
                cursor: pointer;
                font-weight: bold;
                float: right;
                margin-top: 15px;
            }
            .save-btn:hover {
                background-color: #45a049;
            }
        </style>
    </head>

    <body>

        <div class="container">
            <div class="record-card">
                <h1>Attendance Records</h1>

                <!-- Wrapped in a form to allow submitting comments to your server -->
                <form action="UpdateAttendanceCommentServlet" method="post">
                    <div class="table-wrapper">
                        <table id="attendanceTable">
                            <thead>
                                <tr>
                                    <th>Date</th>
                                    <th>Clock In</th>
                                    <th>Selfie In</th>
                                    <th>Clock Out</th>
                                    <th>Selfie Out</th>
                                    <th>Status</th>
                                    <th>Comment</th>
                                </tr>
                            </thead>
                            <tbody>
                                <%
                                    if (attendanceList != null && !attendanceList.isEmpty()) {
                                        for (Attendance attendance : attendanceList) {
                                            String dateStr = (attendance.getAttendanceDate() != null) ? attendance.getAttendanceDate().toString() : "";
                                            String monthValue = (dateStr.length() >= 7) ? dateStr.substring(5, 7) : "";
                                            String status = (attendance.getAttendanceStatus() != null) ? attendance.getAttendanceStatus().toLowerCase() : "present";

                                            String imgIn = attendance.getSelfiePathIn(); 
                                            String imgOut = attendance.getSelfiePathOut(); 
                                            
                                            // Handle null values so they don't print "null" inside the text box
                                            String commentIn = (attendance.getComment() != null) ? attendance.getComment() : "";
                                %>
                                <tr data-month="<%= monthValue%>">
                                    <td><%= dateStr%></td>
                                    <td><%= (attendance.getClockIn() != null) ? attendance.getClockIn() : "-"%></td>
                                    <td>
                                        <% if (imgIn != null && !imgIn.trim().isEmpty()) {%>
                                        <img src="<%= request.getContextPath() %>/<%= imgIn%>" alt="Selfie In" class="selfie-thumb" onclick="window.open(this.src)">
                                        <% } else { %>
                                        <span class="no-img">No Image</span>
                                        <% }%>
                                    </td>
                                    <td><%= (attendance.getClockOut() != null) ? attendance.getClockOut() : "-"%></td>
                                    <td>
                                        <% if (imgOut != null && !imgOut.trim().isEmpty()) {%>
                                        <img src="<%= request.getContextPath() %>/<%= imgOut%>" alt="Selfie Out" class="selfie-thumb" onclick="window.open(this.src)">
                                        <% } else { %>
                                        <span class="no-img">No Image</span>
                                        <% }%>
                                    </td>
                                    <td>
                                        <span class="status-badge <%= status%>">
                                            <%= status%>
                                        </span>
                                    </td>
                                    <td>
                                        <!-- Hidden input tracks the row target while the text box lets users edit -->
                                        <input type="hidden" name="attendanceId" value="<%= attendance.getAttendanceId() %>">
                                        <input type="text" name="comment_<%= attendance.getAttendanceId() %>" value="<%= commentIn %>" class="editable-comment" placeholder="Add a comment...">
                                    </td>
                                </tr>
                                <%
                                        }
                                    } else {
                                %>
                                <tr>
                                    <!-- Updated column span from 6 to 7 to match layout -->
                                    <td colspan="7" style="color: #999999; padding: 30px; text-align: center;">No attendance records found.</td>
                                </tr>
                                <%  }%>
                            </tbody>
                        </table>
                    </div>

                    <% if (attendanceList != null && !attendanceList.isEmpty()) { %>
                        <button type="submit" class="save-btn">Save Comments</button>
                    <% } %>
                </form>

                <div style="clear: both;"></div>
                <a class="back-link" href="dashboard.jsp" style="display: inline-block; margin-top: 15px;">← Back To Dashboard</a>

            </div> 
        </div>

        <script>
            let filterElement = document.getElementById("monthFilter");
            if (filterElement) {
                filterElement.addEventListener("change", function () {
                    let selectedMonth = this.value;
                    let rows = document.querySelectorAll("#attendanceTable tbody tr");

                    rows.forEach(function (row) {
                        if (row.cells.length === 1)
                            return;

                        if (selectedMonth === "" || row.dataset.month === selectedMonth) {
                            row.style.display = "";
                        } else {
                            row.style.display = "none";
                        }
                    });
                });
            }
        </script>

    </body>
</html>