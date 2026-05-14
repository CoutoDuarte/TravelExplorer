package Connection.Security;

import java.io.IOException;
import java.util.Set;

import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

public class StaffAuth {

    public static boolean isStaffLoggedIn(HttpServletRequest request) {
        HttpSession session = request.getSession(false);
        if (session == null) {
            return false;
        }
        Object auth = session.getAttribute("auth");
        Object userType = session.getAttribute("userType");
        return Boolean.TRUE.equals(auth) && "staff".equals(userType);
    }

    @SuppressWarnings("unchecked")
    public static boolean hasPermission(HttpServletRequest request, String permissionName) {
        if (!isStaffLoggedIn(request)) {
            return false;
        }
        HttpSession session = request.getSession(false);
        if (session == null || permissionName == null) {
            return false;
        }
        Object raw = session.getAttribute("staffPermissions");
        if (!(raw instanceof Set)) {
            return false;
        }
        Set<String> perms = (Set<String>) raw;
        return perms.contains(permissionName);
    }

    public static void requireStaff(HttpServletRequest request, HttpServletResponse response) throws IOException {
        if (!isStaffLoggedIn(request)) {
            response.sendRedirect(request.getContextPath() + "/index.jsp?page=login");
        }
    }

    public static void requirePermission(HttpServletRequest request, HttpServletResponse response, String permissionName) throws IOException {
        if (!isStaffLoggedIn(request)) {
            response.sendRedirect(request.getContextPath() + "/index.jsp?page=login");
            return;
        }
        if (!hasPermission(request, permissionName)) {
            response.sendRedirect(request.getContextPath() + "/index.jsp?page=staff-dashboard&error=no-permission");
        }
    }
}
