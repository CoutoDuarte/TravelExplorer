package Connection.Servlets;

public class JsonUtil {
    public static String escape(String s) {
        if (s == null) return "";
        return s.replace("\\", "\\\\")
                .replace("\"", "\\\"")
                .replace("\n", "\\n")
                .replace("\r", "\\r")
                .replace("\t", "\\t");
    }

    public static String unescapeJsonText(String s) {
        if (s == null || s.isEmpty()) {
            return "";
        }
        StringBuilder out = new StringBuilder();
        for (int i = 0; i < s.length(); i++) {
            char c = s.charAt(i);
            if (c == '\\' && i + 1 < s.length()) {
                char next = s.charAt(++i);
                if (next == 'u' && i + 4 < s.length()) {
                    String hex = s.substring(i + 1, i + 5);
                    try {
                        out.append((char) Integer.parseInt(hex, 16));
                        i += 4;
                        continue;
                    } catch (NumberFormatException ignored) {
                        out.append('\\').append(next);
                        continue;
                    }
                }
                switch (next) {
                    case 'n': out.append('\n'); break;
                    case 'r': out.append('\r'); break;
                    case 't': out.append('\t'); break;
                    case '"': out.append('"'); break;
                    case '\\': out.append('\\'); break;
                    default: out.append(next);
                }
            } else {
                out.append(c);
            }
        }
        return decodeBareUnicode(out.toString());
    }

    private static String decodeBareUnicode(String s) {
        if (s == null || s.isEmpty()) {
            return "";
        }
        StringBuilder result = new StringBuilder();
        int i = 0;
        while (i < s.length()) {
            if (i + 4 < s.length() && s.charAt(i) == 'u') {
                String hex = s.substring(i + 1, i + 5);
                if (hex.matches("[0-9a-fA-F]{4}")) {
                    try {
                        result.append((char) Integer.parseInt(hex, 16));
                        i += 5;
                        continue;
                    } catch (NumberFormatException ignored) {
                    }
                }
            }
            result.append(s.charAt(i));
            i++;
        }
        return result.toString();
    }
}