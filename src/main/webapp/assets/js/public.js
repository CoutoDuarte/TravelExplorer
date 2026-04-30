document.addEventListener('DOMContentLoaded', () => {
  initializePublicArea();
});

function initializePublicArea() {
  highlightCurrentPublicLink();
}

function highlightCurrentPublicLink() {
  const navLinks = document.querySelectorAll('.public-navbar__link');
  const currentPage = getCurrentPageParam();

  navLinks.forEach((link) => {
    const linkPage = getPageParamFromUrl(link.href);
    const isHomeLink = isHomeUrl(link.href);
    const isCurrentHome = currentPage === null;

    if ((isHomeLink && isCurrentHome) || (!isHomeLink && linkPage === currentPage)) {
      link.setAttribute('aria-current', 'page');
    } else {
      link.removeAttribute('aria-current');
    }
  });
}

function getCurrentPageParam() {
  const params = new URLSearchParams(window.location.search);
  return params.get('page');
}

function getPageParamFromUrl(url) {
  const parsedUrl = new URL(url, window.location.origin);
  return parsedUrl.searchParams.get('page');
}

function isHomeUrl(url) {
  const parsedUrl = new URL(url, window.location.origin);
  return !parsedUrl.searchParams.has('page');
}

