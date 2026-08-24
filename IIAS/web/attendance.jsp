<%@page import="model.User"%>
<%@page import="model.Attendance"%>
<%@page import="dao.AttendanceDAO"%>

<%
    User user = (User) session.getAttribute("user");
    if (user == null || !"intern".equals(user.getRole())) {
        response.sendRedirect("login.jsp");
        return;
    }

    AttendanceDAO dao = new AttendanceDAO();
    Attendance clockOutPrevSession = dao.clockOutCheck(user.getUserId());
    Attendance attendance = dao.getTodayAttendance(user.getUserId());
    
    if (clockOutPrevSession != null){
        attendance = dao.clockOutCheck(user.getUserId());
    }
    

    String error = request.getParameter("error");
    String success = request.getParameter("success");
%>

<!DOCTYPE html>
<html>
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no">
        <title>Clock In</title>
        <link rel="stylesheet" href="css/attendance.css">
        <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.2/css/all.min.css">
    </head>

    <body>
        
        <div class="container">
            <div class="attendance-card">
                
                <% if (error != null) { %>
                <div class="alert alert-danger" style="color: red; margin-bottom: 20px; font-weight: bold; text-align: center; font-size: 14px;">
                    <% if ("tooEarly".equals(error)) { %>
                    You cannot clock out before 5:00 PM.
                    <% } else if ("outsideGeofence".equals(error)) { %>
                    You are outside the permitted geofence region.
                    <% } else if ("alreadyClocked".equals(error)) { %>
                    You have already clocked in for today.
                    <% } else if ("noClockIn".equals(error)) { %>
                    You need to clock in first.
                    <% } else { %>
                    An error occurred. Please try again.
                    <% } %>
                </div>
                <% } %>

                <% if (success != null) {%>
                <div class="alert alert-success" style="color: green; margin-bottom: 20px; font-weight: bold; text-align: center; font-size: 14px;">
                    <%= "clockin".equals(success) ? "Clock-in successful!" : "Clock-out successful!"%>
                </div>
                <% }%>

                <div class="header">
                    <h1><%= user.getFullName()%></h1>
                    <i class="fa-solid fa-bars"></i>
                </div>

                <a class="back-link" href="dashboard.jsp">? Back to homepage</a>

                <div class="info">
                    <p><strong>Time:</strong> <span id="currentTime"></span></p>
                    <p><strong>Duty:</strong> <span><%= user.isOnField() ? "On-Field" : "Office"%></span></p>
                    <p><strong>Location Check:</strong> <span id="locationStatus">Waiting...</span></p>
                </div>

                <% if (clockOutPrevSession == null && 
                        attendance.getClockIn() == null && (
                        "Out Station".equals(attendance.getAttendanceStatus()) ||
                        "Absent".equals(attendance.getAttendanceStatus()))) { %>

                <form id="clockInForm" action="AttendanceServlet" method="post">
                    <input type="hidden" name="action" value="clockin">
                    <input type="hidden" id="latitude" name="latitude">
                    <input type="hidden" id="longitude" name="longitude">

                    <div class="camera-container">
                        <video id="video" autoplay playsinline style="width: 100%; border-radius: 8px; background: #000;"></video>
                        <canvas id="canvas" style="display:none;"></canvas>
                        <img id="preview" style="display:none; width: 100%; border-radius: 8px;">
                        <input type="hidden" id="selfie" name="selfie">

                        <br>
                        <button type="button" id="captureBtn" class="camera-btn" onclick="captureSelfie()">Take Selfie</button>
                        <button type="button" id="retakeBtn" class="camera-btn" onclick="startCamera()" style="display: none; background-color: #6c757d;">Retake Selfie</button>
                    </div>

                    <div class="input-group" style="margin-bottom: 20px; text-align: left;">
                        <label for="comment" style="display: block; font-weight: bold; margin-bottom: 8px; font-size: 14px; color: #333;">
                            <i class="fa-solid fa-comment-dots"></i> Add a comment/notes (Optional):
                        </label>
                        <textarea 
                            id="comment" 
                            name="comment" 
                            rows="3" 
                            placeholder="Type any updates, field notes, or remarks here..." 
                            style="width: 100%; padding: 10px; border: 1px solid #ccc; border-radius: 6px; font-family: inherit; font-size: 14px; box-sizing: border-box; resize: vertical;"></textarea>
                    </div>

                    <button type="button" class="clock-btn" onclick="clockIn()">Clock-In</button>
                </form>

                <% } else if (attendance.getClockIn() != null && (attendance.getClockOut() == null)) {%>

                <form id="clockOutForm" action="AttendanceServlet" method="post">
                    <input type="hidden" name="action" value="clockout">
                    <input type="hidden" id="latitude" name="latitude">
                    <input type="hidden" id="longitude" name="longitude">
                    <input type="hidden" id="attID" name="attID" value="<%=attendance.getAttendanceId()%>">

                    <div class="camera-container">
                        <video id="video" autoplay playsinline style="width: 100%; border-radius: 8px; background: #000;"></video>
                        <canvas id="canvas" style="display:none;"></canvas>
                        <img id="preview" style="display:none; width: 100%; border-radius: 8px;">
                        <input type="hidden" id="selfie" name="selfie">

                        <br>
                        <button type="button" id="captureBtn" class="camera-btn" onclick="captureSelfie()">Take Selfie</button>
                        <button type="button" id="retakeBtn" class="camera-btn" onclick="startCamera()" style="display: none; background-color: #6c757d;">Retake Selfie</button>
                    </div>

                    <div class="input-group" style="margin-bottom: 20px; text-align: left;">
                        <label for="comment" style="display: block; font-weight: bold; margin-bottom: 8px; font-size: 14px; color: #333;">
                            <i class="fa-solid fa-comment-dots"></i> Add a comment/notes (Optional):
                        </label>
                        <textarea 
                            id="comment" 
                            name="comment" 
                            rows="3" 
                            placeholder="Type any updates, field notes, or remarks here..." 
                            style="width: 100%; padding: 10px; border: 1px solid #ccc; border-radius: 6px; font-family: inherit; font-size: 14px; box-sizing: border-box; resize: vertical;"></textarea>
                    </div>

                    <button type="button" id="clockOutBtn" onclick="clockOut()" class="clock-btn">Clock-Out</button>
                </form>

                <% } else { %>
                <div class="completed" style="text-align: center; padding: 20px; font-weight: bold; color: #2e7d32;">Attendance Completed</div>
                <% }%>

            </div> 
        </div>

        <script>
            let localStream = null;
            const video = document.getElementById("video");
            const preview = document.getElementById("preview");
            const captureBtn = document.getElementById("captureBtn");
            const retakeBtn = document.getElementById("retakeBtn");
            const selfieInput = document.getElementById("selfie");

            function updateTime() {
                let now = new Date();
                document.getElementById("currentTime").innerHTML = now.toLocaleTimeString([], {
                    hour: 'numeric',
                    minute: '2-digit'
                });
                
                
            }

            updateTime();
            setInterval(updateTime, 1000);

            // Turn on webcam and clear preview UI state
            function startCamera() {
                selfieInput.value = "";
                preview.style.display = "none";
                preview.src = "";
                retakeBtn.style.display = "none";

                if (video) {
                    video.style.display = "block";
                    navigator.mediaDevices.getUserMedia({video: {facingMode: "user"}})
                            .then(function (stream) {
                                localStream = stream;
                                video.srcObject = stream;
                                captureBtn.style.display = "inline-block";
                            })
                            .catch(function () {
                                alert("Unable to access camera.");
                            });
                }
            }

            // Kill active media hardware tracks
            function stopCamera() {
                if (localStream) {
                    localStream.getTracks().forEach(track => track.stop());
                }
                if (video) {
                    video.style.display = "none";
                    video.srcObject = null;
                }
            }

            function captureSelfie() {
                const canvas = document.getElementById("canvas");
                canvas.width = video.videoWidth;
                canvas.height = video.videoHeight;

                const ctx = canvas.getContext("2d");
                ctx.drawImage(video, 0, 0, canvas.width, canvas.height);

                let image = canvas.toDataURL("image/jpeg");
                selfieInput.value = image;

                preview.src = image;
                preview.style.display = "block";

                captureBtn.style.display = "none";
                retakeBtn.style.display = "inline-block";

                stopCamera();
            }

            // Run camera on launch if action forms are visible
            if (video) {
                startCamera();
            }

            function clockIn() {
                let selfie = selfieInput.value;
                if (!selfie) {
                    alert("Please take a selfie first.");
                    return;
                }
                if (!navigator.geolocation) {
                    alert("Geolocation not supported.");
                    return;
                }

                navigator.geolocation.getCurrentPosition(
                        function (position) {
                            document.getElementById("latitude").value = position.coords.latitude;
                            document.getElementById("longitude").value = position.coords.longitude;
                            document.getElementById("clockInForm").submit();
                        },
                        function () {
                            alert("Location permission denied.");
                        }
                );
            }

            function clockOut() {
                let selfie = selfieInput.value;
                if (!selfie) {
                    alert("Please take a selfie first.");
                    return;
                }

                // Check if current time is before 5:00 PM (17:00)
                let now = new Date();
                let hours = now.getHours();

                if (hours < 17) {
                    let proceed = confirm("It is currently before 5:00 PM. Are you sure you want to clock out early?");
                    if (!proceed) {
                        return; // Cancel submission if user selects 'Cancel'
                    }
                }

                if (!navigator.geolocation) {
                    alert("Geolocation not supported.");
                    return;
                }

                navigator.geolocation.getCurrentPosition(
                        function (position) {
                            // Find the active clockOutForm hidden inputs dynamically
                            let form = document.getElementById("clockOutForm");
                            form.querySelector("#latitude").value = position.coords.latitude;
                            form.querySelector("#longitude").value = position.coords.longitude;
                            form.submit();
                        },
                        function () {
                            alert("Location permission denied.");
                        }
                );
            }
        </script>
    </body>
</html> 
