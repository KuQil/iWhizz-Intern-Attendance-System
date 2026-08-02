/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/Servlet.java to edit this template
 */
package controller;

import dao.AttendanceDAO;
import dao.GeofenceDAO;
import java.io.File;
import java.io.FileOutputStream;
import java.util.Base64;
import model.Attendance;
import model.Geofence;
import model.User;
import util.ConfigManager;

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

    //5.334279365266907, 103.14771422427407 plt
    //5.734034836476247, 102.49390592638133 ijt
    //5.4131091113581755, 103.0854658632978 oma
    //5.410929577902006, 103.08854473100098 ibh12
    //5.738359662486741, 102.50908217108032 hjt
    
    private static final double OFFICE_LAT = 5.734034836476247;
    private static final double OFFICE_LON = 102.49390592638133;
    private static final int ALLOWED_RADIUS = 30; 
    private static final String UPLOAD_DIR = "C:/Users/Win10/Desktop/WebDev/IIAS/uploads/selfies";

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        User user = (session != null) ? (User) session.getAttribute("user") : null;

        if (user == null) {
            response.sendRedirect("login.jsp");
            return;
        }

        String action = request.getParameter("action");
        AttendanceDAO attendanceDAO = new AttendanceDAO();

        if ("clockin".equals(action)) {
            handleClockIn(request, response, user, attendanceDAO);
        } else if ("clockout".equals(action)) {
            handleClockOut(request, response, user, attendanceDAO);
        }
    }

    private void handleClockIn(HttpServletRequest request, HttpServletResponse response, User user, AttendanceDAO attendanceDAO)
            throws IOException {

        double lat = Double.parseDouble(request.getParameter("latitude"));
        double lon = Double.parseDouble(request.getParameter("longitude"));

        //geofence exemption for onfield, and then check
        if (!user.isOnField() && isOutsideGeofence(lat, lon)) {
            response.sendRedirect("attendance.jsp?error=outsideGeofence");
            return;
        }

        // Determine Status
        String attendanceStatus = LocalTime.now().isAfter(LocalTime.parse(ConfigManager.get("clock_in_time"))) ? "late" : "present";
        if(user.isOnField()){
            attendanceStatus = "Out Station";
        }
        

        // Save Image
        String base64Image = request.getParameter("selfie");
        String selfiePathIn = saveSelfie(base64Image);
        
        String commentIn = request.getParameter("comment");

        boolean success = attendanceDAO.clockIn(user.getUserId(), attendanceStatus, selfiePathIn, commentIn);
        response.sendRedirect("attendance.jsp?success=" + (success ? "clockin" : "failed&error=clockinFailed"));
    }

    private void handleClockOut(HttpServletRequest request, HttpServletResponse response, User user, AttendanceDAO attendanceDAO)
            throws IOException {

        double lat = Double.parseDouble(request.getParameter("latitude"));
        double lon = Double.parseDouble(request.getParameter("longitude"));

        if (!user.isOnField() && isOutsideGeofence(lat, lon)) {
            response.sendRedirect("attendance.jsp?error=outsideGeofence");
            return;
        }

        // Save Image
        String base64Image = request.getParameter("selfie");
        String selfiePathOut = saveSelfie(base64Image);

        boolean success = attendanceDAO.clockOut(user.getUserId(), selfiePathOut);
        response.sendRedirect("attendance.jsp?success=" + (success ? "clockout" : "failed&error=clockoutFailed"));
    }

    private boolean isOutsideGeofence(double lat, double lon) {
        double distance = HaversineUtil.calculateDistance(lat, lon, OFFICE_LAT, OFFICE_LON);
        return distance > ALLOWED_RADIUS;
    }

    private String saveSelfie(String base64Image) throws IOException {
        String imageData = base64Image.substring(base64Image.indexOf(",") + 1);
        byte[] imageBytes = Base64.getDecoder().decode(imageData);

        File directory = new File(UPLOAD_DIR);
        if (!directory.exists()) {
            directory.mkdirs();
        }

        String fileName = System.currentTimeMillis() + ".jpg";
        try (FileOutputStream fos = new FileOutputStream(new File(directory, fileName))) {
            fos.write(imageBytes);
        }

        return "uploads/selfies/" + fileName;
    }
}
