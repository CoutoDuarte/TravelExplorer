

document.addEventListener('DOMContentLoaded', () => {
  initializeCustomerArea();
});

function initializeCustomerArea() {
  highlightCurrentCustomerSidebarLink();
  highlightCurrentCustomerNavbarLink();
  initPaymentMethodCards();
}

function initPaymentMethodCards() {
  const grid = document.getElementById('payment-method-grid');
  if (!grid) return;
  const sync = () => {
    grid.querySelectorAll('.te-payment-method').forEach((card) => {
      const input = card.querySelector('input[type="radio"]');
      card.classList.toggle('is-selected', Boolean(input && input.checked));
    });
  };
  grid.addEventListener('change', sync);
  sync();
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

