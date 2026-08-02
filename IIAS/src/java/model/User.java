/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package model;

import java.sql.Date;

public class User {
    
    private int userId;
    private String username;
    private String password;
    private String fullName;
    private String role;

    private Date internshipStart;
    private Date internshipEnd;

    private int personalLeaveRemaining;

    private boolean onField;

    private String accountStatus;

    public int getUserId() {
        return userId;
    }

    public void setUserId(int userId) {
        this.userId = userId;
    }

    public String getUsername() {
        return username;
    }

    public void setUsername(String username) {
        this.username = username;
    }

    public String getPassword() {
        return password;
    }

    public void setPassword(String password) {
        this.password = password;
    }

    public String getFullName() {
        return fullName;
    }

    public void setFullName(String fullName) {
        this.fullName = fullName;
    }

    public String getRole() {
        return role;
    }

    public void setRole(String role) {
        this.role = role;
    }

    public Date getInternshipStart() {
        return internshipStart;
    }

    public void setInternshipStart(Date internshipStart) {
        this.internshipStart = internshipStart;
    }

    public Date getInternshipEnd() {
        return internshipEnd;
    }

    public void setInternshipEnd(Date internshipEnd) {
        this.internshipEnd = internshipEnd;
    }

    public int getPersonalLeaveRemaining() {
        return personalLeaveRemaining;
    }

    public void setPersonalLeaveRemaining(int personalLeaveRemaining) {
        this.personalLeaveRemaining = personalLeaveRemaining;
    }

    public boolean isOnField() {
        return onField;
    }

    public void setOnField(boolean onField) {
        this.onField = onField;
    }

    public String getAccountStatus() {
        return accountStatus;
    }

    public void setAccountStatus(String accountStatus) {
        this.accountStatus = accountStatus;
    }
    
}
