/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package model;

import java.sql.Date;
import java.sql.Timestamp;

public class Attendance {

    private int attendanceId;
    private int userId;
    private Date attendanceDate;
    private Timestamp clockIn;
    private Timestamp clockOut;
    private String attendanceStatus;
    private String selfiePathIn;
    private String selfiePathOut;
    private String userName;
    private String comment;

    public String getComment() {
        return comment;
    }

    public void setComment(String comment) {
        this.comment = comment;
    }

    public String getUserName() {
        return userName;
    }

    public void setUserName(String userName) {
        this.userName = userName;
    }

    public String getSelfiePathOut() {
        return selfiePathOut;
    }

    public void setSelfiePathOut(String selfiePathOut) {
        this.selfiePathOut = selfiePathOut;
    }

    public int getAttendanceId() {
        return attendanceId;
    }

    public void setAttendanceId(int attendanceId) {
        this.attendanceId = attendanceId;
    }

    public int getUserId() {
        return userId;
    }

    public void setUserId(int userId) {
        this.userId = userId;
    }

    public Date getAttendanceDate() {
        return attendanceDate;
    }

    public void setAttendanceDate(Date attendanceDate) {
        this.attendanceDate = attendanceDate;
    }

    public Timestamp getClockIn() {
        return clockIn;
    }

    public void setClockIn(Timestamp clockIn) {
        this.clockIn = clockIn;
    }

    public Timestamp getClockOut() {
        return clockOut;
    }

    public void setClockOut(Timestamp clockOut) {
        this.clockOut = clockOut;
    }

    public String getAttendanceStatus() {
        return attendanceStatus;
    }

    public void setAttendanceStatus(String attendanceStatus) {
        this.attendanceStatus = attendanceStatus;
    }

    public String getSelfiePathIn() {
        return selfiePathIn;
    }

    public void setSelfiePathIn(String selfiePath) {
        this.selfiePathIn = selfiePath;
    }

}
