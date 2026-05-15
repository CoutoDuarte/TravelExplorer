package ExternalAPI;

import java.io.BufferedReader;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Locale;
import java.util.Map;

public class ApiConfig {
    private static final Map<String, String> DOT_ENV = loadDotEnv();

    public static final String OPENAI_API_KEY = resolve("OPENAI_API_KEY");
    public static final String SERPAPI_KEY    = resolve("SERPAPI_KEY");
    public static final boolean OPENAI_TRUST_ALL_SSL = resolveBoolean("OPENAI_TRUST_ALL_SSL");
    public static final String OPENAI_BASE_URL = resolveWithDefault(
            "OPENAI_BASE_URL",
            "https://api.iaedu.pt/agent-chat//api/v1/agent/cmamvd3n40000c801qeacoad2/stream");
    public static final String OPENAI_MODEL = resolveWithDefault("OPENAI_MODEL", "gpt-4o-mini");
    public static final String OPENAI_AUTH_HEADER = resolveWithDefault("OPENAI_AUTH_HEADER", "x-api-key");
    public static final String OPENAI_AUTH_PREFIX = resolveWithDefault("OPENAI_AUTH_PREFIX", "");
    public static final String OPENAI_API_MODE = resolveWithDefault("OPENAI_API_MODE", "IAEDU_AGENT");
    public static final String OPENAI_CHANNEL_ID = resolveWithDefault(
            "OPENAI_CHANNEL_ID", "cmp79g5mm20hli601c4cegl25");
    public static final String OPENAI_THREAD_ID = resolveWithDefault(
            "OPENAI_THREAD_ID", "travel-explorer-local-test");

    public static boolean isIaeduAgentMode() {
        return "IAEDU_AGENT".equalsIgnoreCase(OPENAI_API_MODE);
    }

    public static boolean hasOpenAIKey() {
        return OPENAI_API_KEY != null && !OPENAI_API_KEY.isBlank();
    }

    public static String buildOpenAiAuthHeaderValue() {
        if (!hasOpenAIKey()) {
            return "";
        }
        if (OPENAI_AUTH_PREFIX == null || OPENAI_AUTH_PREFIX.isBlank()) {
            return OPENAI_API_KEY;
        }
        return OPENAI_AUTH_PREFIX + " " + OPENAI_API_KEY;
    }

    public static boolean hasSerpAPIKey() {
        return SERPAPI_KEY != null && !SERPAPI_KEY.isBlank();
    }

    private static String resolve(String name) {
        String fromEnv = System.getenv(name);
        if (fromEnv != null && !fromEnv.isBlank()) {
            return fromEnv.trim();
        }
        String fromFile = DOT_ENV.get(name);
        if (fromFile != null && !fromFile.isBlank()) {
            return fromFile.trim();
        }
        return "";
    }

    private static String resolveWithDefault(String name, String defaultValue) {
        String value = resolve(name);
        if (value == null || value.isBlank()) {
            return defaultValue;
        }
        return value;
    }

    private static boolean resolveBoolean(String name) {
        String value = resolve(name);
        if (value == null || value.isBlank()) {
            return false;
        }
        String normalized = value.trim().toLowerCase(Locale.ROOT);
        return "true".equals(normalized) || "1".equals(normalized) || "yes".equals(normalized);
    }

    private static Map<String, String> loadDotEnv() {
        Map<String, String> vars = new HashMap<>();
        for (Path path : envFilePaths()) {
            if (Files.isRegularFile(path)) {
                mergeEnvFile(path, vars);
            }
        }
        return vars;
    }

    private static List<Path> envFilePaths() {
        List<Path> paths = new ArrayList<>();
        String userDir = System.getProperty("user.dir", ".");
        paths.add(Paths.get(userDir, ".env"));
        paths.add(Paths.get(".env"));
        Path webappEnv = webappRootEnvPath();
        if (webappEnv != null) {
            paths.add(webappEnv);
        }
        String catalinaBase = System.getenv("catalina.base");
        if (catalinaBase != null && !catalinaBase.isBlank()) {
            paths.add(Paths.get(catalinaBase, "webapps", "TravelExplorer", ".env"));
        }
        paths.add(Paths.get(userDir, "TravelExplorer", ".env"));
        return paths;
    }

    private static Path webappRootEnvPath() {
        try {
            Path codeLocation = Paths.get(
                    ApiConfig.class.getProtectionDomain().getCodeSource().getLocation().toURI());
            Path normalized = codeLocation.toAbsolutePath().normalize();
            Path fileName = normalized.getFileName();
            if (fileName != null && "classes".equals(fileName.toString())) {
                Path parent = normalized.getParent();
                if (parent != null && "WEB-INF".equals(String.valueOf(parent.getFileName()))) {
                    Path webappRoot = parent.getParent();
                    if (webappRoot != null) {
                        return webappRoot.resolve(".env");
                    }
                }
                Path projectRoot = normalized.getParent();
                if (projectRoot != null) {
                    projectRoot = projectRoot.getParent();
                }
                if (projectRoot != null) {
                    return projectRoot.resolve(".env");
                }
            }
        } catch (Exception ignored) {
        }
        return null;
    }

    private static void mergeEnvFile(Path path, Map<String, String> vars) {
        try (BufferedReader reader = Files.newBufferedReader(path)) {
            String line;
            while ((line = reader.readLine()) != null) {
                line = line.trim();
                if (line.isEmpty() || line.startsWith("#")) {
                    continue;
                }
                int eq = line.indexOf('=');
                if (eq <= 0) {
                    continue;
                }
                String key = line.substring(0, eq).trim();
                String value = line.substring(eq + 1).trim();
                if ((value.startsWith("\"") && value.endsWith("\""))
                        || (value.startsWith("'") && value.endsWith("'"))) {
                    value = value.substring(1, value.length() - 1);
                }
                vars.put(key, value);
            }
        } catch (Exception ignored) {
        }
    }
}
