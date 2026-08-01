/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package dao;

import util.DatabaseConnection;
import model.Geofence;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;

public class GeofenceDAO {
    public Geofence getGeofence() {

        Geofence geofence = null;

        try {

            Connection connection =
                    DatabaseConnection.getConnection();

            String sql = "SELECT * FROM geofence LIMIT 1";

            PreparedStatement ps = connection.prepareStatement(sql);

            ResultSet rs = ps.executeQuery();

            if (rs.next()) {

                geofence = new Geofence();

                geofence.setLatitude(rs.getDouble("latitude"));

                geofence.setLongitude(rs.getDouble("longitude"));

                geofence.setRadiusMeter(rs.getDouble("radius_meter"));
            }

            connection.close();

        } catch (Exception e) {

            e.printStackTrace();
        }

        return geofence;
    }
}
