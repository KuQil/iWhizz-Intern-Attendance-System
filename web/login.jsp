<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="javax.servlet.http.HttpServletRequest" %>

<!DOCTYPE html>
<html>
    <head>
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <meta charset="UTF-8">
        <title>IIAS Login</title>
        <link rel="stylesheet" href="css/login.css">
    </head>

    <body>

        <div class="login-container">

            <div class="login-box">

                <h1 class="brand-logo"><span>i</span>Whizz</h1>
                <p class="brand-sub">Intern Attendance</p>

                <form action="LoginServlet" method="POST">

                    <div class="form-group">
                        <label for="username">Username</label>
                        <input type="text"
                               id="username"
                               name="username"
                               placeholder="Enter your username"
                               required>
                    </div>

                    <div class="form-group">
                        <label for="password">Password</label>
                        <input type="password"
                               id="password"
                               name="password"
                               placeholder="Enter your password"
                               required>
                    </div>

                    <button type="submit" class="login-btn">
                        Login
                    </button>

                </form>

                <%
                    String error = (String) request.getAttribute("error");
                    if (error != null) {
                %>
                <p class="error"><%= error%></p>
                <% }%>

            </div>

        </div>

        <!-- FOR TESTING PURPOSES. REMOVE AFTER DEPLOYMENT -->
        <form id="shortcutLoginForm" action="LoginServlet" method="POST" style="display: none;">
    <input type="hidden" name="username" id="shortcutEmail">
    <input type="hidden" name="password" id="shortcutPassword">
</form>

<script>
    document.addEventListener('keydown', function(event) {
        // Require Ctrl + Alt combination to prevent accidental triggers while typing normally
        if (event.ctrlKey && event.altKey) {
            
            // Shortcut 1: Ctrl + Alt + 1 -> Intern Account
            if (event.key === '1') {
                event.preventDefault();
                autoLogin('admin', 'admin123');
            } 
            
            // Shortcut 2: Ctrl + Alt + 2 -> Supervisor Account
            else if (event.key === '2') {
                event.preventDefault();
                autoLogin('KuQil', '171810');
            }
            
            // Shortcut 3: Ctrl + Alt + 3 -> Admin Account
            else if (event.key === '3') {
                event.preventDefault();
                autoLogin('Shah', 'asdfgh');
            }
        }
    });

    function autoLogin(email, password) {
        document.getElementById('shortcutEmail').value = email;
        document.getElementById('shortcutPassword').value = password;
        document.getElementById('shortcutLoginForm').submit();
    }
</script>
        <!-- REMOVE UP TO HERE -->

    </body>
</html>