/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/Servlet.java to edit this template
 */
package controller;

import java.io.IOException;
import java.io.PrintWriter;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.time.format.DateTimeFormatter;

import dao.UserDAO;
import model.User;
import util.ConfigManager;


public class LoginServlet extends HttpServlet {

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        String username = request.getParameter("username");
        String password = request.getParameter("password");
        
        ConfigManager con = new ConfigManager();
        
        
        //password hash
        //String hashedPassword = HashUtil.hashPassword(password);

                LocalTime currentTime = LocalTime.now(ZoneId.of("Asia/Kuala_Lumpur"));
LocalTime expectedTime = LocalTime.parse(ConfigManager.get("clock_in_time"));

System.out.println("DEBUG -> Current MY Time: " + currentTime);
System.out.println("DEBUG -> Config Expected Time: " + expectedTime);
System.out.println("DEBUG -> Is Late? " + currentTime.isAfter(expectedTime));

        UserDAO userDAO = new UserDAO();

        User user = userDAO.login(username, password);

        if (user != null) {

            HttpSession session = request.getSession();

            session.setAttribute("user", user);

            if (user.getRole().equals("supervisor")) {

                response.sendRedirect("SupervisorDashboardServlet");

            } else {

                response.sendRedirect("dashboard.jsp");
            }

        } else {

            request.setAttribute("error", "Invalid username or password");

            request.getRequestDispatcher("login.jsp").forward(request, response);
        }
    }

}
