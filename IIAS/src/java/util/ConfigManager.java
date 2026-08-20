package util;

import java.io.File;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.IOException;
import java.util.Properties;

public class ConfigManager {
    
    private static final String CONFIG_FILE = "IIAS/conf/system_config.properties";
    private static Properties properties = new Properties();

    static {
        loadProperties();
    }

    private static void loadProperties() {
        File file = new File(CONFIG_FILE);
        try {
            if (!file.exists()) {
                // Ensure parent directory exists before creating the file
                if (file.getParentFile() != null && !file.getParentFile().exists()) {
                    file.getParentFile().mkdirs();
                }

                file.createNewFile();
                // Set default values if file is newly created
                properties.setProperty("clock_in_time", "08:30");
                properties.setProperty("clock_out_time", "17:00");
                saveProperties();
            } else {
                try (FileInputStream fis = new FileInputStream(file)) {
                    properties.load(fis);
                }
            }
        } catch (IOException e) {
            e.printStackTrace();
        }
    }

    // Read a setting
    public static String get(String key) {
        return properties.getProperty(key);
    }

    // Update a setting and save to file
    public static void set(String key, String value) {
        properties.setProperty(key, value);
        saveProperties();
    }

    private static void saveProperties() {
        try (FileOutputStream fos = new FileOutputStream(CONFIG_FILE)) {
            properties.store(fos, "Iwhizz System Configuration");
        } catch (IOException e) {
            e.printStackTrace();
        }
    }
}
