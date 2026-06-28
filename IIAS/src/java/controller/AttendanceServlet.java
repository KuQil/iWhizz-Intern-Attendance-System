/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/Servlet.java to edit this template
 */
package controller;

import dao.AttendanceDAO;
import dao.GeofenceDAO;

import model.Attendance;
import model.Geofence;
import model.User;

import util.HaversineUtil;

import java.io.IOException;
import java.io.PrintWriter;
import java.time.LocalTime;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

public class AttendanceServlet extends HttpServlet {

    //5.333243429409472, 103.14766259022731 plt
    //5.752639602493289, 102.49807911983044 ijt
    //5.4131091113581755, 103.0854658632978 oma
    private static final double OFFICE_LAT
            = 5.333243429409472;

    private static final double OFFICE_LON
            = 103.14766259022731;

    private static final int ALLOWED_RADIUS
            = 100; // meters

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String action = request.getParameter("action");

        if ("clockin".equals(action)) {

            handleClockIn(request, response);

        } else if ("clockout".equals(action)) {

            handleClockOut(request, response);

        }
    }

    private void handleClockIn(HttpServletRequest request, HttpServletResponse response)
            throws IOException {

        HttpSession session = request.getSession(false);

        if (session == null) {

            response.sendRedirect("login.jsp");

            return;
        }

        User user = (User) session.getAttribute("user");

        if (user == null) {

            response.sendRedirect("login.jsp");

            return;
        }

        AttendanceDAO attendanceDAO = new AttendanceDAO();

        //User cannot clock in again
        if (!attendanceDAO.canClockIn(user.getUserId())) {

            response.sendRedirect("attendance.jsp?error=alreadyClocked");

            return;
        }

        double latitude = Double.parseDouble(request.getParameter("latitude"));

        double longitude = Double.parseDouble(request.getParameter("longitude"));

        //Geofence Logic
        if (!user.isOnField()) {//skips geofence for on field interns

            GeofenceDAO geofenceDAO = new GeofenceDAO();

            Geofence geofence = geofenceDAO.getGeofence();

            double distance = HaversineUtil.calculateDistance(latitude, longitude, OFFICE_LAT, OFFICE_LON);

            if (distance > 1000) {
                response.sendRedirect("attendance.jsp?error=outsideGeofence");
                return;
            }
        }

        //Attendance Logic
        LocalTime cutoff = LocalTime.of(8, 30);
        LocalTime currentTime = LocalTime.now();
        String attendanceStatus;

        if (currentTime.isAfter(cutoff)) {
            attendanceStatus = "late";
        } else {
            attendanceStatus = "present";
        }
        boolean success = attendanceDAO.clockIn(user.getUserId(), latitude, longitude, attendanceStatus);

        if (success) {
            response.sendRedirect("attendance.jsp?success=clockin");
        } else {
            response.sendRedirect("attendance.jsp?error=clockinFailed");
        }
    }

    private void handleClockOut(HttpServletRequest request, HttpServletResponse response)
            throws IOException {

        HttpSession session = request.getSession(false);
        if (session == null) {
            response.sendRedirect("index.jsp");
            return;
        }

        User user = (User) session.getAttribute("user");
        if (user == null) {
            response.sendRedirect("index.jsp");
            return;
        }

        AttendanceDAO attendanceDAO = new AttendanceDAO();

        // Must clock in first
        if (!attendanceDAO.canClockOut(user.getUserId())) {
            response.sendRedirect("attendance.jsp?error=noClockIn");
            return;
        }

        // New Time Restriction: Only allow clock out after 5:00 PM
        LocalTime clockOutAllowedTime = LocalTime.of(17, 0); // 17:00 is 5:00 PM
        LocalTime currentTime = LocalTime.now();

        if (currentTime.isBefore(clockOutAllowedTime)) {
            response.sendRedirect("attendance.jsp?error=tooEarly");
            return;
        }

        boolean success = attendanceDAO.clockOut(user.getUserId());

        if (success) {
            response.sendRedirect("attendance.jsp?success=clockout");
        } else {
            response.sendRedirect("attendance.jsp?error=clockoutFailed");
        }
    }

}
