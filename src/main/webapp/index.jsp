<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="Connection.Security.StaffAuth" %>
<%
String pageParam = request.getParameter("page");
String contentPage = "/pages/public/home.jsp";
String layoutPage = "/layouts/public_layout.jsp";
String staffPermissionRequired = null;

if ("offers".equals(pageParam)) {
    contentPage = "/pages/public/offers.jsp";
} else if ("about".equals(pageParam)) {
    contentPage = "/pages/public/about.jsp";
} else if ("destinations".equals(pageParam)) {
    contentPage = "/pages/public/destinations.jsp";
} else if ("login".equals(pageParam)) {
    contentPage = "/pages/public/login.jsp";
} else if ("register".equals(pageParam)) {
    contentPage = "/pages/public/register.jsp";
} else if ("offer-details".equals(pageParam)) {
    contentPage = "/pages/public/offer_details.jsp";
} else if ("customer-dashboard".equals(pageParam)) {
    contentPage = "/pages/customer/customer_dashboard.jsp";
    layoutPage = "/layouts/customer_layout.jsp";
} else if ("my-reservations".equals(pageParam)) {
    contentPage = "/pages/customer/my_reservations.jsp";
    layoutPage = "/layouts/customer_layout.jsp";
} else if ("saved-offers".equals(pageParam)) {
    contentPage = "/pages/customer/saved_offers.jsp";
    layoutPage = "/layouts/customer_layout.jsp";
} else if ("profile".equals(pageParam)) {
    contentPage = "/pages/customer/profile.jsp";
    layoutPage = "/layouts/customer_layout.jsp";
} else if ("reservation-details".equals(pageParam)) {
    contentPage = "/pages/customer/reservation_details.jsp";
    layoutPage = "/layouts/customer_layout.jsp";
} else if ("staff-dashboard".equals(pageParam)) {
    contentPage = "/pages/staff/dashboard.jsp";
    layoutPage = "/layouts/staff_layout.jsp";
    staffPermissionRequired = "STAFF_DASHBOARD";
} else if ("staff-reservations".equals(pageParam)) {
    contentPage = "/pages/staff/reservations.jsp";
    layoutPage = "/layouts/staff_layout.jsp";
    staffPermissionRequired = "STAFF_RESERVATIONS";
} else if ("staff-clients".equals(pageParam)) {
    contentPage = "/pages/staff/clients.jsp";
    layoutPage = "/layouts/staff_layout.jsp";
    staffPermissionRequired = "STAFF_CLIENTS";
} else if ("staff-offers".equals(pageParam) || "offers-management".equals(pageParam)) {
    contentPage = "/pages/staff/offers.jsp";
    layoutPage = "/layouts/staff_layout.jsp";
    staffPermissionRequired = "STAFF_OFFERS";
} else if ("staff-promotions".equals(pageParam)) {
    contentPage = "/pages/staff/promotions.jsp";
    layoutPage = "/layouts/staff_layout.jsp";
    staffPermissionRequired = "STAFF_PROMOTIONS";
} else if ("staff-communication".equals(pageParam)) {
    contentPage = "/pages/staff/communication.jsp";
    layoutPage = "/layouts/staff_layout.jsp";
    staffPermissionRequired = "STAFF_COMMUNICATION";
} else if ("staff-admin".equals(pageParam)) {
    contentPage = "/pages/staff/admin.jsp";
    layoutPage = "/layouts/staff_layout.jsp";
    staffPermissionRequired = "STAFF_ADMIN";
}

if ("logout".equals(pageParam)) {
    session.invalidate();
    response.sendRedirect(request.getContextPath() + "/index.jsp?page=login");
    return;
}

if (staffPermissionRequired != null) {
    if (!StaffAuth.isStaffLoggedIn(request)) {
        if (Boolean.TRUE.equals(session.getAttribute("auth")) && "cliente".equals(session.getAttribute("userType"))) {
            response.sendRedirect(request.getContextPath() + "/index.jsp?page=customer-dashboard");
        } else {
            response.sendRedirect(request.getContextPath() + "/index.jsp?page=login");
        }
        return;
    }
    if (!StaffAuth.hasPermission(request, staffPermissionRequired)) {
        response.sendRedirect(request.getContextPath() + "/index.jsp?page=staff-dashboard&error=no-permission");
        return;
    }
}

request.setAttribute("contentPage", contentPage);
%>
<jsp:include page="<%= layoutPage %>" />
