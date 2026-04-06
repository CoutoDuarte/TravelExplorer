

document.addEventListener('DOMContentLoaded', () => {
  initializeCustomerArea();
});

function initializeCustomerArea() {
  highlightCurrentCustomerSidebarLink();
  highlightCurrentCustomerNavbarLink();
}

function highlightCurrentCustomerSidebarLink() {
  const sidebarLinks = document.querySelectorAll('.customer-sidebar__link');
  const currentPage = getCurrentCustomerPageParam();

  sidebarLinks.forEach((link) => {
    const linkPage = link.dataset.customerPage;

    if (linkPage === currentPage) {
      link.setAttribute('aria-current', 'page');
    } else {
      link.removeAttribute('aria-current');
    }
  });
}

function highlightCurrentCustomerNavbarLink() {
  const navLinks = document.querySelectorAll('.customer-navbar__link');
  const currentPage = getCurrentCustomerPageParam();

  navLinks.forEach((link) => {
    const linkPage = link.dataset.customerNavPage;

    if (linkPage === currentPage) {
      link.setAttribute('aria-current', 'page');
    } else {
      link.removeAttribute('aria-current');
    }
  });
}

function getCurrentCustomerPageParam() {
  const params = new URLSearchParams(window.location.search);
  return params.get('page');
}

/*
Duarte: este ficheiro poderá mais tarde receber lógica real da área de cliente,
como carregamento dinâmico de reservas, favoritos, perfil e interações com API.
*/