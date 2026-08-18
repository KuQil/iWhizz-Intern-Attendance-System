package util;

import java.io.InputStream;
import java.io.IOException;
import java.util.Properties;

public class ConfigManager {

    private static final String CONFIG_FILE = "system_config.properties";
    private static final Properties properties = new Properties();

    static {
        loadProperties();
    }

    private static void loadProperties() {
        // Read directly from the application classpath (WEB-INF/classes or src/resources)
        try (InputStream input = ConfigManager.class.getClassLoader().getResourceAsStream(CONFIG_FILE)) {
            if (input == null) {
                System.err.println("CRITICAL: Unable to find " + CONFIG_FILE + " in classpath.");
                // Fallback defaults if file is completely missing
                properties.setProperty("clock_in_time", "08:30");
                properties.setProperty("clock_out_time", "17:00");
            } else {
                properties.load(input);
            }
        } catch (IOException e) {
            e.printStackTrace();
        }
    }

    // Read a setting
    public static String get(String key) {
        return properties.getProperty(key);
    }

    // Optional default fallback getter
    public static String get(String key, String defaultValue) {
        return properties.getProperty(key, defaultValue);
    }
}
