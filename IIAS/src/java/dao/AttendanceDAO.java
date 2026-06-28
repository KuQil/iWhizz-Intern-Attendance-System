/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package dao;

import model.Attendance;
import util.DatabaseConnection;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class AttendanceDAO {
    private Connection connection;

    public AttendanceDAO() {
        connection = DatabaseConnection.getConnection();
    }

    /*
        CHECK IF USER HAS AN ATTENDANCE RECORD TODAY
     */
    public Attendance getTodayAttendance(int userId) {

        Attendance attendance = null;

        try {

            String sql =
                    "SELECT * FROM attendance "
                    + "WHERE user_id=? "
                    + "AND attendance_date=CURDATE()";

            PreparedStatement ps =
                    connection.prepareStatement(sql);

            ps.setInt(1, userId);

            ResultSet rs = ps.executeQuery();

            if (rs.next()) {

                attendance = new Attendance();

                attendance.setAttendanceId(
                        rs.getInt("attendance_id"));

                attendance.setUserId(
                        rs.getInt("user_id"));

                attendance.setAttendanceDate(
                        rs.getDate("attendance_date"));

                attendance.setClockIn(
                        rs.getTimestamp("clock_in"));

                attendance.setClockOut(
                        rs.getTimestamp("clock_out"));

                attendance.setLatitude(
                        rs.getDouble("latitude"));

                attendance.setLongitude(
                        rs.getDouble("longitude"));

                attendance.setAttendanceStatus(
                        rs.getString("attendance_status"));
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        return attendance;
    }
    
    /*
        CLOCK IN
     */
    public boolean clockIn(
            int userId,
            double latitude,
            double longitude,
            String status) {

        try {

            String sql =
                    "INSERT INTO attendance("
                    + "user_id,"
                    + "attendance_date,"
                    + "clock_in,"
                    + "latitude,"
                    + "longitude,"
                    + "attendance_status"
                    + ") VALUES("
                    + "?,CURDATE(),NOW(),?,?,?)";

            PreparedStatement ps = connection.prepareStatement(sql);

            ps.setInt(1, userId);
            ps.setDouble(2, latitude);
            ps.setDouble(3, longitude);
            ps.setString(4, status);

            int result = ps.executeUpdate();

            return result > 0;

        } catch (Exception e) {
            e.printStackTrace();
        }

        return false;
    }

    /*
        CLOCK OUT
     */
    public boolean clockOut(int userId) {

        try {

            String sql =
                    "UPDATE attendance "
                    + "SET clock_out=NOW() "
                    + "WHERE user_id=? "
                    + "AND attendance_date=CURDATE() "
                    + "AND clock_out IS NULL";

            PreparedStatement ps =
                    connection.prepareStatement(sql);

            ps.setInt(1, userId);

            int result = ps.executeUpdate();

            return result > 0;

        } catch (Exception e) {
            e.printStackTrace();
        }

        return false;
    }
    
    /*
        CHECK IF USER CAN CLOCK IN
     */
    public boolean canClockIn(int userId) {

        Attendance attendance =
                getTodayAttendance(userId);

        if (attendance == null) {
            return true;
        }

        /*
         Already clocked in and not clocked out
         Cannot create another record
        */
        if (attendance.getClockOut() == null) {
            return false;
        }

        /*
         Already completed attendance today
        */
        return false;
    }
    
    /*
        CHECK IF USER CAN CLOCK OUT
     */
    public boolean canClockOut(int userId) {

        Attendance attendance =
                getTodayAttendance(userId);

        if (attendance == null) {
            return false;
        }

        return attendance.getClockOut() == null;
    }

    /*
        GET ATTENDANCE HISTORY
     */
    public List<Attendance> getAttendanceHistory(int userId) {

    List<Attendance> list =
            new ArrayList<>();

    try {

        String sql =
                "SELECT * FROM attendance "
              + "WHERE user_id=? "
              + "ORDER BY attendance_date DESC";

        PreparedStatement ps =
                connection.prepareStatement(sql);

        ps.setInt(1, userId);

        ResultSet rs = ps.executeQuery();

        while (rs.next()) {

            Attendance attendance =
                    new Attendance();

            attendance.setAttendanceId(
                    rs.getInt("attendance_id"));

            attendance.setUserId(
                    rs.getInt("user_id"));

            attendance.setAttendanceDate(
                    rs.getDate("attendance_date"));

            attendance.setClockIn(
                    rs.getTimestamp("clock_in"));

            attendance.setClockOut(
                    rs.getTimestamp("clock_out"));

            attendance.setAttendanceStatus(
                    rs.getString("attendance_status"));

            list.add(attendance);
        }

    } catch (Exception e) {
        e.printStackTrace();
    }

    return list;
}
    
    /*
        SUPERVISOR VIEW ALL ATTENDANCE
     */
    public List<Attendance> getAllAttendance() {

        List<Attendance> attendanceList =
                new ArrayList<>();

        try {

            String sql =
                    "SELECT * "
                    + "FROM attendance "
                    + "ORDER BY attendance_date DESC";

            PreparedStatement ps =
                    connection.prepareStatement(sql);

            ResultSet rs = ps.executeQuery();

            while (rs.next()) {

                Attendance attendance =
                        new Attendance();

                attendance.setAttendanceId(
                        rs.getInt("attendance_id"));

                attendance.setUserId(
                        rs.getInt("user_id"));

                attendance.setAttendanceDate(
                        rs.getDate("attendance_date"));

                attendance.setClockIn(
                        rs.getTimestamp("clock_in"));

                attendance.setClockOut(
                        rs.getTimestamp("clock_out"));

                attendance.setAttendanceStatus(
                        rs.getString("attendance_status"));

                attendanceList.add(attendance);
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        return attendanceList;
    }
}
