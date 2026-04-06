document.addEventListener('DOMContentLoaded', () => {
  initializeStaffArea();
});

function initializeStaffArea() {
  highlightCurrentStaffSidebarLink();
  highlightCurrentStaffNavbarLink();
}

function highlightCurrentStaffSidebarLink() {
  const sidebarLinks = document.querySelectorAll('.staff-sidebar__link');
  const currentPage = getCurrentStaffPageParam();

  sidebarLinks.forEach((link) => {
    const linkPage = link.dataset.staffPage;

    if (linkPage === currentPage) {
      link.setAttribute('aria-current', 'page');
    } else {
      link.removeAttribute('aria-current');
    }
  });
}

function highlightCurrentStaffNavbarLink() {
  const navLinks = document.querySelectorAll('.staff-navbar__link');
  const currentPage = getCurrentStaffPageParam();

  navLinks.forEach((link) => {
    const linkPage = link.dataset.staffNavPage;

    if (linkPage === currentPage) {
      link.setAttribute('aria-current', 'page');
    } else {
      link.removeAttribute('aria-current');
    }
  });
}

function getCurrentStaffPageParam() {
  const params = new URLSearchParams(window.location.search);
  return params.get('page');
}

/*
Duarte: este ficheiro poderá mais tarde receber lógica real da área staff,
como carregamento dinâmico de reservas, clientes, promoções, comunicação,
administração e interações com API.
*/