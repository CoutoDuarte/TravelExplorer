const TE_AIRPORTS = [
  { code: 'OPO', city: 'Porto', name: 'Aeroporto Francisco Sá Carneiro', country: 'Portugal' },
  { code: 'LIS', city: 'Lisboa', name: 'Aeroporto Humberto Delgado', country: 'Portugal' },
  { code: 'FAO', city: 'Faro', name: 'Aeroporto de Faro', country: 'Portugal' },
  { code: 'FNC', city: 'Funchal', name: 'Aeroporto Cristiano Ronaldo', country: 'Portugal' },
  { code: 'PDL', city: 'Ponta Delgada', name: 'Aeroporto João Paulo II', country: 'Portugal' },
  { code: 'MAD', city: 'Madrid', name: 'Adolfo Suárez Madrid-Barajas', country: 'Espanha' },
  { code: 'BCN', city: 'Barcelona', name: 'El Prat', country: 'Espanha' },
  { code: 'CDG', city: 'Paris', name: 'Charles de Gaulle', country: 'França' },
  { code: 'ORY', city: 'Paris', name: 'Orly', country: 'França' },
  { code: 'LHR', city: 'Londres', name: 'Heathrow', country: 'Reino Unido' },
  { code: 'LGW', city: 'Londres', name: 'Gatwick', country: 'Reino Unido' },
  { code: 'AMS', city: 'Amesterdão', name: 'Schiphol', country: 'Países Baixos' },
  { code: 'FRA', city: 'Frankfurt', name: 'Frankfurt', country: 'Alemanha' },
  { code: 'MUC', city: 'Munique', name: 'Munique', country: 'Alemanha' },
  { code: 'FCO', city: 'Roma', name: 'Fiumicino', country: 'Itália' },
  { code: 'MXP', city: 'Milão', name: 'Malpensa', country: 'Itália' },
  { code: 'VCE', city: 'Veneza', name: 'Marco Polo', country: 'Itália' },
  { code: 'ZRH', city: 'Zurique', name: 'Zurique', country: 'Suíça' },
  { code: 'GVA', city: 'Genebra', name: 'Genebra', country: 'Suíça' },
  { code: 'BRU', city: 'Bruxelas', name: 'Bruxelas', country: 'Bélgica' },
  { code: 'DUB', city: 'Dublin', name: 'Dublin', country: 'Irlanda' },
  { code: 'CPH', city: 'Copenhaga', name: 'Copenhaga', country: 'Dinamarca' },
  { code: 'ARN', city: 'Estocolmo', name: 'Arlanda', country: 'Suécia' },
  { code: 'OSL', city: 'Oslo', name: 'Oslo', country: 'Noruega' },
  { code: 'ATH', city: 'Atenas', name: 'Atenas', country: 'Grécia' },
  { code: 'IST', city: 'Istambul', name: 'Istambul', country: 'Turquia' },
  { code: 'JFK', city: 'Nova Iorque', name: 'John F. Kennedy', country: 'EUA' },
  { code: 'EWR', city: 'Nova Iorque', name: 'Newark', country: 'EUA' },
  { code: 'MIA', city: 'Miami', name: 'Miami', country: 'EUA' },
  { code: 'BOS', city: 'Boston', name: 'Boston', country: 'EUA' },
  { code: 'LAX', city: 'Los Angeles', name: 'Los Angeles', country: 'EUA' },
  { code: 'DXB', city: 'Dubai', name: 'Dubai', country: 'Emirados Árabes' },
  { code: 'DOH', city: 'Doha', name: 'Doha', country: 'Qatar' },
  { code: 'GRU', city: 'São Paulo', name: 'Guarulhos', country: 'Brasil' },
  { code: 'GIG', city: 'Rio de Janeiro', name: 'Galeão', country: 'Brasil' },
  { code: 'RAI', city: 'Praia', name: 'Cabo Verde', country: 'Cabo Verde' },
  { code: 'LAD', city: 'Luanda', name: '4 de Fevereiro', country: 'Angola' },
];

document.addEventListener('DOMContentLoaded', () => {
  initializePublicArea();
});

function initializePublicArea() {
  highlightCurrentPublicLink();
  initializeTravelSearch();
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

function initializeTravelSearch() {
  const form = document.getElementById('public-travel-search-form');
  if (!form) return;

  const loadingEl = document.getElementById('public-search-loading');
  const errorEl = document.getElementById('public-search-error');
  const resultsEl = document.getElementById('public-search-results');
  const loginEl = document.getElementById('public-search-login-required');

  hideElement(loadingEl);
  hideElement(errorEl);
  hideElement(resultsEl);
  hideElement(loginEl);

  initAirportField('origem');
  initAirportField('destino');
  initPassengerSelector();

  form.addEventListener('submit', async (event) => {
    event.preventDefault();
    await runTravelSearch(form);
  });
}

function initAirportField(prefix) {
  const display = document.getElementById(`${prefix}-display`);
  const hidden = document.getElementById(prefix);
  const dropdown = document.getElementById(`${prefix}-dropdown`);
  if (!display || !hidden || !dropdown) return;

  const render = (query) => {
    const matches = filterAirports(query);
    if (!matches.length) {
      dropdown.hidden = true;
      dropdown.innerHTML = '';
      return;
    }
    dropdown.innerHTML = matches.map((airport) => `
      <button type="button" class="te-airport-option" data-code="${airport.code}" data-label="${escapeHtml(airportLabel(airport))}">
        <span class="te-airport-option__code">${airport.code}</span>
        <span class="te-airport-option__body">
          <strong>${escapeHtml(airport.city)} — ${escapeHtml(airport.name)}</strong>
          <span>${escapeHtml(airport.country)}</span>
        </span>
      </button>
    `).join('');
    dropdown.hidden = false;
  };

  display.addEventListener('input', () => {
    hidden.value = '';
    render(display.value);
  });

  display.addEventListener('focus', () => render(display.value));

  dropdown.addEventListener('click', (event) => {
    const option = event.target.closest('.te-airport-option');
    if (!option) return;
    hidden.value = option.dataset.code;
    display.value = option.dataset.label;
    dropdown.hidden = true;
  });

  display.addEventListener('blur', () => {
    window.setTimeout(() => {
      if (!dropdown.matches(':hover') && !display.matches(':focus')) {
        dropdown.hidden = true;
      }
      if (!hidden.value && display.value.trim()) {
        const resolved = resolveAirportFromText(display.value.trim());
        if (resolved) {
          hidden.value = resolved.code;
          display.value = airportLabel(resolved);
        }
      }
    }, 150);
  });
}

function initPassengerSelector() {
  const trigger = document.getElementById('passenger-trigger');
  const panel = document.getElementById('passenger-panel');
  const done = document.getElementById('passenger-done');
  const adultosInput = document.getElementById('adultos');
  const criancasInput = document.getElementById('criancas');
  const adultosCount = document.getElementById('adultos-count');
  const criancasCount = document.getElementById('criancas-count');
  if (!trigger || !panel || !adultosInput || !criancasInput) return;

  let adultos = parseInt(adultosInput.value, 10) || 2;
  let criancas = parseInt(criancasInput.value, 10) || 0;

  const sync = () => {
    adultosInput.value = String(adultos);
    criancasInput.value = String(criancas);
    adultosCount.textContent = String(adultos);
    criancasCount.textContent = String(criancas);
    trigger.textContent = buildPassengerSummary(adultos, criancas);
  };

  sync();

  trigger.addEventListener('click', () => {
    const open = panel.hidden;
    panel.hidden = !open;
    trigger.setAttribute('aria-expanded', String(open));
  });

  done.addEventListener('click', () => {
    panel.hidden = true;
    trigger.setAttribute('aria-expanded', 'false');
  });

  panel.addEventListener('click', (event) => {
    const action = event.target.closest('[data-passenger-action]');
    if (!action) return;
    const type = action.getAttribute('data-passenger-action');
    if (type === 'adultos-minus' && adultos > 1) adultos -= 1;
    if (type === 'adultos-plus' && adultos < 6) adultos += 1;
    if (type === 'criancas-minus' && criancas > 0) criancas -= 1;
    if (type === 'criancas-plus' && criancas < 4) criancas += 1;
    sync();
  });

  document.addEventListener('click', (event) => {
    if (!event.target.closest('.te-passenger-field')) {
      panel.hidden = true;
      trigger.setAttribute('aria-expanded', 'false');
    }
  });
}

document.addEventListener('click', (event) => {
  if (!event.target.closest('.te-airport-field')) {
    document.querySelectorAll('.te-airport-dropdown').forEach((el) => {
      el.hidden = true;
    });
  }
});

function filterAirports(query) {
  const q = normalizeSearch(query);
  if (!q) return TE_AIRPORTS.slice(0, 8);
  return TE_AIRPORTS.filter((airport) => {
    const hay = [
      airport.code,
      airport.city,
      airport.name,
      airport.country,
    ].map(normalizeSearch).join(' ');
    return hay.includes(q) || airport.code.toLowerCase() === q;
  }).slice(0, 8);
}

function resolveAirportFromText(text) {
  const q = normalizeSearch(text);
  const exact = TE_AIRPORTS.find((a) =>
    normalizeSearch(a.code) === q
    || normalizeSearch(a.city) === q
    || normalizeSearch(`${a.city} ${a.name}`) === q);
  if (exact) return exact;
  const partial = TE_AIRPORTS.find((a) =>
    normalizeSearch(a.city).includes(q)
    || normalizeSearch(a.name).includes(q)
    || normalizeSearch(a.country).includes(q));
  return partial || null;
}

function airportLabel(airport) {
  return `${airport.city} — ${airport.name}`;
}

function normalizeSearch(value) {
  return String(value || '')
    .normalize('NFD')
    .replace(/[\u0300-\u036f]/g, '')
    .toLowerCase()
    .trim();
}

function buildPassengerSummary(adultos, criancas) {
  const total = adultos + criancas;
  if (criancas === 0) {
    return `${total} ${total === 1 ? 'passageiro' : 'passageiros'}`;
  }
  return `${adultos} adulto${adultos > 1 ? 's' : ''}, ${criancas} criança${criancas > 1 ? 's' : ''}`;
}

function isClienteLoggedIn(form) {
  return form.dataset.clienteLoggedIn === 'true';
}

async function runTravelSearch(form) {
  const loadingEl = document.getElementById('public-search-loading');
  const errorEl = document.getElementById('public-search-error');
  const resultsEl = document.getElementById('public-search-results');
  const loginEl = document.getElementById('public-search-login-required');
  const submitBtn = document.getElementById('public-search-submit');

  hideElement(errorEl);
  hideElement(resultsEl);
  hideElement(loginEl);

  if (!isClienteLoggedIn(form)) {
    showElement(loginEl);
    loginEl?.scrollIntoView({ behavior: 'smooth', block: 'nearest' });
    return;
  }

  const origemDisplay = document.getElementById('origem-display');
  const destinoDisplay = document.getElementById('destino-display');
  let origem = form.elements.origem.value.trim();
  let destino = form.elements.destino.value.trim();

  if (!origem && origemDisplay?.value.trim()) {
    const resolved = resolveAirportFromText(origemDisplay.value.trim());
    if (resolved) origem = resolved.code;
  }
  if (!destino && destinoDisplay?.value.trim()) {
    const resolved = resolveAirportFromText(destinoDisplay.value.trim());
    if (resolved) destino = resolved.code;
  }

  const dataPartida = form.elements.data_partida.value;
  const dataRegresso = form.elements.data_regresso.value;
  const adultos = form.elements.adultos.value;
  const criancas = form.elements.criancas.value;

  if (!origem || !destino || !dataPartida || !dataRegresso) {
    showSearchError(errorEl, resultsEl, loadingEl);
    return;
  }

  const loadingText = loadingEl?.querySelector('.public-search-status__text');
  if (loadingText) loadingText.textContent = 'A procurar voos disponíveis...';

  setSearchLoading(true, loadingEl, submitBtn);

  const params = new URLSearchParams({
    origem,
    destino,
    data_partida: dataPartida,
    data_regresso: dataRegresso,
    adultos,
    criancas,
  });

  const searchUrl = getSearchApiUrl(form);
  if (!searchUrl) {
    showSearchError(errorEl, resultsEl, loadingEl);
    return;
  }

  try {
    const response = await fetch(`${searchUrl}?${params}`, {
      method: 'GET',
      headers: { Accept: 'application/json' },
      credentials: 'same-origin',
    });

    let data;
    try {
      data = await response.json();
    } catch (parseErr) {
      showSearchError(errorEl, resultsEl, loadingEl);
      return;
    }

    if (!data || data.ok !== true) {
      if (data?.authRequired) {
        showElement(loginEl);
        loginEl?.scrollIntoView({ behavior: 'smooth', block: 'nearest' });
      } else {
        showSearchError(errorEl, resultsEl, loadingEl, data?.message || null);
      }
      return;
    }

    if (!isInitialSearchSuccess(data)) {
      showSearchError(
        errorEl,
        resultsEl,
        loadingEl,
        'Não encontrámos voos de ida para esta pesquisa.'
      );
      return;
    }

    renderBookingWizard(resultsEl, data, {
      origemLabel: origemDisplay?.value || data.origem,
      destinoLabel: destinoDisplay?.value || data.destino,
      dataPartida,
      dataRegresso,
      adultos,
      criancas,
    }, form);
    showElement(resultsEl);
  } catch (err) {
    showSearchError(errorEl, resultsEl, loadingEl);
  } finally {
    setSearchLoading(false, loadingEl, submitBtn);
  }
}

function setSearchLoading(isLoading, loadingEl, submitBtn) {
  if (loadingEl) loadingEl.hidden = !isLoading;
  if (submitBtn) submitBtn.disabled = isLoading;
}

function showSearchError(errorEl, resultsEl, loadingEl, message) {
  hideElement(loadingEl);
  hideElement(resultsEl);
  if (resultsEl) {
    resultsEl.innerHTML = '';
    resultsEl.classList.remove('te-booking-panel--active');
  }
  document.getElementById('hero-studio')?.classList.remove('hero-studio--results');
  if (errorEl) {
    const textEl = errorEl.querySelector('p') || errorEl;
    if (message && textEl) {
      textEl.textContent = message;
    } else if (!message && textEl) {
      textEl.textContent = 'Não foi possível concluir a pesquisa neste momento. Tente novamente daqui a pouco.';
    }
  }
  showElement(errorEl);
  errorEl?.scrollIntoView({ behavior: 'smooth', block: 'nearest' });
}

function getSearchApiUrl(form) {
  return form?.dataset.searchUrl || form?.dataset.apiUrl || '';
}

function extractOutboundFlights(data) {
  if (!data) return [];
  return pickFlights(data.voosIda, data.voos);
}

function extractReturnFlights(data) {
  if (!data) return [];
  return pickFlights(data.voosRegresso, []);
}

function isInitialSearchSuccess(data) {
  if (!data || data.ok !== true) return false;
  const voosIda = extractOutboundFlights(data);
  return voosIda.length > 0;
}

function isWizardStep3Complete() {
  return Boolean(tripSelection.hotel) || tripSelection.hotelSkipped;
}

function canNavigateToWizardStep(container, step) {
  if (!container) return false;
  switch (step) {
    case 1:
      return Array.isArray(container.__voosIda) && container.__voosIda.length > 0;
    case 2:
      return Boolean(tripSelection.flightIda);
    case 3:
      return Boolean(tripSelection.flightRegresso);
    case 4:
      return isWizardStep3Complete();
    case 5:
      return Boolean(tripSelection.sugestao);
    default:
      return false;
  }
}

function clearFromRegresso(container) {
  tripSelection.flightRegressoId = null;
  tripSelection.flightRegresso = null;
  clearFromHotel(container);
}

function clearFromHotel(container) {
  tripSelection.hotelId = null;
  tripSelection.hotel = null;
  tripSelection.hotelSkipped = false;
  clearFromPackage(container);
}

function clearFromPackage(container) {
  tripSelection.sugestao = null;
  const target = container?.querySelector('#wizard-final-package');
  if (target) target.innerHTML = '';
}

function formatFlightStepSummary(voo) {
  if (!voo) return '';
  const parts = [decodeApiText(voo.companhia || ''), decodeApiText(voo.numeroVoo || '')].filter(Boolean);
  const label = parts.join(' ').trim();
  const time = formatTimeShort(voo.partida);
  return label ? `${label} · ${time}` : time;
}

function formatFlightChoiceLine(voo, title) {
  if (!voo) return '';
  const airline = decodeApiText(voo.companhia || '');
  const num = decodeApiText(voo.numeroVoo || '');
  const dep = formatTimeShort(voo.partida);
  const arr = formatTimeShort(voo.chegada);
  return `${title}: ${airline} ${num} · ${decodeApiText(voo.origem)} ${dep} → ${decodeApiText(voo.destino)} ${arr} · ${formatEuro(voo.precoTotal)}`;
}

function getWizardStepSummary(step) {
  switch (step) {
    case 1:
      return tripSelection.flightIda ? formatFlightStepSummary(tripSelection.flightIda) : 'Escolher voo';
    case 2:
      return tripSelection.flightRegresso ? formatFlightStepSummary(tripSelection.flightRegresso) : 'Escolher voo';
    case 3:
      if (tripSelection.hotel) {
        const name = decodeApiText(tripSelection.hotel.nome || '');
        return name.length > 28 ? `${name.slice(0, 28)}…` : name;
      }
      if (tripSelection.hotelSkipped) return 'Sem alojamento';
      return 'Opcional';
    case 4:
      if (tripSelection.sugestao) return 'Gerado';
      return isWizardStep3Complete() ? 'Pronto para criar' : 'Por rever';
    case 5:
      return tripSelection.sugestao ? 'Gerado' : 'Ainda por gerar';
    default:
      return '';
  }
}

const WIZARD_SCROLL_OFFSET = 100;

function scrollToBookingPanel(container) {
  const panel = container || document.getElementById('public-search-results');
  if (!panel) return;
  requestAnimationFrame(() => {
    const top = panel.getBoundingClientRect().top + window.scrollY - WIZARD_SCROLL_OFFSET;
    window.scrollTo({ top: Math.max(0, top), behavior: 'smooth' });
  });
}

function scrollToWizardStep(container, step) {
  if (!container) return;
  const panel = container.querySelector(`[data-wizard-step="${step}"]`);
  if (!panel) return;
  requestAnimationFrame(() => {
    const top = panel.getBoundingClientRect().top + window.scrollY - WIZARD_SCROLL_OFFSET;
    window.scrollTo({ top: Math.max(0, top), behavior: 'smooth' });
  });
}

function renderWizardProgressNav() {
  const steps = [
    { n: 1, label: 'Voo de ida' },
    { n: 2, label: 'Voo de regresso' },
    { n: 3, label: 'Alojamento' },
    { n: 4, label: 'Plano' },
    { n: 5, label: 'Pacote' },
  ];
  return `
    <nav class="te-wizard-progress" aria-label="Passos da reserva">
      ${steps.map((s) => `
        <button type="button" class="te-wizard-progress__step" data-wizard-nav="${s.n}" disabled>
          <span class="te-wizard-progress__num">${s.n}</span>
          <span class="te-wizard-progress__body">
            <span class="te-wizard-progress__label">${s.label}</span>
            <span class="te-wizard-progress__summary" data-step-summary="${s.n}"></span>
          </span>
        </button>
      `).join('')}
    </nav>
  `;
}

function updateWizardNav(container, activeStep) {
  container.querySelectorAll('[data-wizard-nav]').forEach((btn) => {
    const n = Number(btn.getAttribute('data-wizard-nav'));
    const reachable = canNavigateToWizardStep(container, n);
    const isActive = n === activeStep;
    const isDone = n < activeStep && reachable;
    const isLocked = !reachable;

    btn.classList.toggle('is-active', isActive);
    btn.classList.toggle('is-done', isDone && !isActive);
    btn.classList.toggle('is-locked', isLocked);
    btn.classList.toggle('is-clickable', reachable && !isLocked);
    btn.disabled = !reachable;
    btn.setAttribute('aria-current', isActive ? 'step' : 'false');

    const summaryEl = btn.querySelector('[data-step-summary]') || btn.querySelector('.te-wizard-progress__summary');
    if (summaryEl) summaryEl.textContent = getWizardStepSummary(n);
  });
}

function formatFlightStripValue(voo) {
  if (!voo) return '';
  const airline = decodeApiText(voo.companhia || '');
  const num = decodeApiText(voo.numeroVoo || '');
  const route = `${decodeApiText(voo.origem)} ${formatTimeShort(voo.partida)} → ${decodeApiText(voo.destino)} ${formatTimeShort(voo.chegada)}`;
  return `${airline} ${num} · ${route} · ${formatEuro(voo.precoTotal)}`;
}

function renderSelectionMiniBlock(label, value, placeholder) {
  const filled = Boolean(value);
  return `
    <div class="te-selection-mini ${filled ? 'is-filled' : 'is-empty'}">
      <span class="te-selection-mini__label">${escapeHtml(label)}</span>
      <span class="te-selection-mini__value">${filled ? escapeHtml(value) : escapeHtml(placeholder)}</span>
    </div>
  `;
}

function updateSelectionStrip(container) {
  const strip = container.querySelector('#wizard-selection-strip');
  if (!strip) return;
  const idaVal = formatFlightStripValue(tripSelection.flightIda);
  const regVal = formatFlightStripValue(tripSelection.flightRegresso);
  let hotelVal = '';
  if (tripSelection.hotel) {
    hotelVal = `${decodeApiText(tripSelection.hotel.nome)} · ${formatEuro(tripSelection.hotel.precoEstimado)}`;
  } else if (tripSelection.hotelSkipped) {
    hotelVal = 'Sem alojamento';
  }
  strip.innerHTML = `
    <div class="te-wizard-selection-strip__grid">
      ${renderSelectionMiniBlock('Ida', idaVal, 'Por escolher')}
      ${renderSelectionMiniBlock('Regresso', regVal, 'Por escolher')}
      ${renderSelectionMiniBlock('Alojamento', hotelVal, 'Opcional')}
    </div>
  `;
  strip.hidden = false;
}

function refreshAllSelectionMarks(container) {
  const step1 = container.querySelector('[data-wizard-step="1"]');
  const step2 = container.querySelector('[data-wizard-step="2"]');
  if (tripSelection.flightIdaId && step1) {
    markFlightSelected(step1, tripSelection.flightIdaId);
  }
  if (tripSelection.flightRegressoId && step2) {
    markFlightSelected(step2, tripSelection.flightRegressoId);
  }
  if (tripSelection.hotelId) {
    container.querySelectorAll('[data-hotel-id]').forEach((el) => {
      const selected = el.getAttribute('data-hotel-id') === tripSelection.hotelId;
      el.classList.toggle('is-selected', selected);
      const selectBtn = el.querySelector('[data-select-hotel]');
      if (selectBtn) selectBtn.textContent = selected ? 'Selecionado' : 'Selecionar';
    });
  }
}

function renderReviewCard(title, bodyHtml, alterStep) {
  const alterBtn = alterStep
    ? `<button type="button" class="btn btn-ghost te-review-card__alter" data-review-alter="${alterStep}">Alterar</button>`
    : '';
  return `
    <article class="te-review-card">
      <div class="te-review-card__head">
        <h4>${escapeHtml(title)}</h4>
        ${alterBtn}
      </div>
      ${bodyHtml}
    </article>
  `;
}

function renderHotelAmenityChips(amenities, maxVisible) {
  if (!amenities) return '';
  const items = decodeApiText(amenities)
    .split(/[,;|•·]/)
    .map((s) => s.trim())
    .filter(Boolean);
  if (!items.length) return '';
  const max = maxVisible || 3;
  const visible = items.slice(0, max);
  const extra = items.length - max;
  const chips = visible.map((a) => `<span class="te-chip te-chip--soft">${escapeHtml(a)}</span>`).join('');
  const more = extra > 0 ? `<span class="te-chip te-chip--more">+${extra}</span>` : '';
  return `<div class="te-hotel-card__chips">${chips}${more}</div>`;
}

function hideElement(el) {
  if (el) el.hidden = true;
}

function showElement(el) {
  if (el) el.hidden = false;
}

const tripSelection = {
  hotelId: null,
  hotel: null,
  hotelSkipped: false,
  flightIdaId: null,
  flightIda: null,
  flightRegressoId: null,
  flightRegresso: null,
  sugestao: null,
};

function resetTripSelection() {
  tripSelection.hotelId = null;
  tripSelection.hotel = null;
  tripSelection.hotelSkipped = false;
  tripSelection.flightIdaId = null;
  tripSelection.flightIda = null;
  tripSelection.flightRegressoId = null;
  tripSelection.flightRegresso = null;
  tripSelection.sugestao = null;
}

function renderBookingWizard(container, data, meta, form) {
  resetTripSelection();
  const voosIda = extractOutboundFlights(data);
  const voosRegresso = extractReturnFlights(data);
  const routeLabel = `${escapeHtml(decodeApiText(data.origem || meta.origemLabel))} → ${escapeHtml(decodeApiText(data.destino || meta.destinoLabel))}`;
  const datesLabel = `${formatDisplayDate(data.dataPartida || meta.dataPartida)} – ${formatDisplayDate(data.dataRegresso || meta.dataRegresso)}`;
  const travellersLabel = buildPassengerSummary(Number(data.adultos), Number(data.criancas));

  container.__meta = {
    origem: data.origem,
    destino: data.destino,
    origemLabel: meta.origemLabel,
    destinoLabel: meta.destinoLabel,
    dataPartida: data.dataPartida || meta.dataPartida,
    dataRegresso: data.dataRegresso || meta.dataRegresso,
    adultos: Number(data.adultos),
    criancas: Number(data.criancas),
    routeLabel,
    datesLabel,
    travellersLabel,
  };
  container.__voosIda = voosIda;
  container.__voosRegresso = voosRegresso;
  container.__hotels = [];
  container.__hotelsLoaded = false;
  container.__form = form;
  container.classList.add('te-booking-panel--active');
  document.getElementById('hero-studio')?.classList.add('hero-studio--results');

  container.innerHTML = `
    <header class="te-booking-head">
      <div class="te-booking-head__route">${routeLabel}</div>
      <div class="te-booking-head__meta">
        <span class="te-chip">${datesLabel}</span>
        <span class="te-chip">${escapeHtml(travellersLabel)}</span>
      </div>
    </header>

    ${renderWizardProgressNav()}

    <div class="te-wizard-selection-strip" id="wizard-selection-strip"></div>

    <div class="te-wizard">
      <section class="te-wizard-step is-active" data-wizard-step="1">
        <h3 class="te-section-title">Escolhe o voo de ida</h3>
        ${renderFlightListSelectable(voosIda, 'ida', 'Não foram encontrados voos de ida para esta data.')}
      </section>

      <section class="te-wizard-step" data-wizard-step="2" hidden>
        <h3 class="te-section-title">Escolhe o voo de regresso</h3>
        ${renderFlightListSelectable(voosRegresso, 'regresso', 'Não encontrámos voos de regresso para esta data.')}
      </section>

      <section class="te-wizard-step" data-wizard-step="3" hidden>
        <h3 class="te-section-title">Escolhe alojamento</h3>
        <p class="te-wizard-step__hint">O alojamento é opcional. Pode continuar sem selecionar.</p>
        <div class="te-wizard-loading" id="wizard-hotels-loading" hidden>
          <span class="public-search-status__spinner" aria-hidden="true"></span>
          <p>A procurar alojamentos...</p>
        </div>
        <div class="te-hotels__grid" id="wizard-hotels-grid"></div>
        <div class="te-wizard-step__actions">
          <button type="button" class="btn btn-secondary" id="wizard-skip-hotel">Continuar sem alojamento</button>
        </div>
      </section>

      <section class="te-wizard-step" data-wizard-step="4" hidden>
        <h3 class="te-section-title">Revê o teu plano</h3>
        <p class="te-wizard-step__lead">Confirma os voos e o alojamento antes de criar o plano personalizado.</p>
        <div class="te-wizard-review" id="wizard-pre-summary"></div>
        <div class="te-wizard-loading" id="wizard-sugestao-loading" hidden>
          <span class="public-search-status__spinner" aria-hidden="true"></span>
          <p>A preparar o teu plano de viagem...</p>
        </div>
        <button type="button" class="btn btn-primary te-wizard-create-btn" id="wizard-create-sugestao">Criar plano de viagem</button>
      </section>

      <section class="te-wizard-step" data-wizard-step="5" hidden>
        <div id="wizard-final-package"></div>
      </section>
    </div>

    <div class="te-modal" id="hotel-details-modal" hidden>
      <div class="te-modal__backdrop" data-close-hotel-modal></div>
      <div class="te-modal__dialog te-modal__dialog--hotel" role="dialog" aria-labelledby="hotel-details-title">
        <div id="hotel-details-content"></div>
      </div>
    </div>

    <div class="te-modal" id="save-trip-modal" hidden>
      <div class="te-modal__backdrop" data-close-modal></div>
      <div class="te-modal__dialog" role="dialog" aria-labelledby="save-trip-modal-title">
        <h3 id="save-trip-modal-title">Guardar viagem</h3>
        <div id="save-trip-modal-body">
          <p>A tua viagem será guardada como reserva na área de cliente.</p>
        </div>
        <div class="te-modal__actions" id="save-trip-modal-actions">
          <button type="button" class="btn btn-secondary" data-close-modal>Cancelar</button>
          <button type="button" class="btn btn-primary" id="save-trip-modal-confirm">Guardar</button>
        </div>
      </div>
    </div>
  `;

  container.__scrollToPanelOnInit = true;
  initBookingWizard(container);
}

function safeHotelImageUrl(raw) {
  if (raw == null || typeof raw !== 'string') return '';
  const u = raw.trim();
  return /^https?:\/\//i.test(u) ? u : '';
}

function formatHotelBadge(hotel) {
  if (!hotel) return '—';
  const rating = Number(hotel.rating);
  if (!Number.isNaN(rating) && rating > 0) {
    if (rating <= 5 && Math.abs(rating - Math.round(rating)) < 0.01) {
      return String(Math.round(rating));
    }
    return rating.toFixed(1);
  }
  const cat = decodeApiText(hotel.categoria || '').trim();
  if (/^hotel$/i.test(cat)) return 'Hotel';
  const starMatch = cat.match(/(\d+)\s*estrelas?/i);
  if (starMatch) return starMatch[1];
  if (cat && /\d+([.,]\d+)?\s*avalia/i.test(cat)) {
    const m = cat.match(/(\d+([.,]\d+)?)/);
    if (m) return m[1].replace(',', '.');
  }
  if (cat) return cat.length > 12 ? cat.slice(0, 12) : cat;
  return '—';
}

function formatHotelLabel(hotel) {
  if (!hotel) return 'Classificação não disponível';
  const cat = decodeApiText(hotel.categoria || '').trim();
  if (cat && /^hotel$/i.test(cat)) return 'Hotel';
  if (cat && !/^hotel$/i.test(cat)) {
    const starMatch = cat.match(/(\d+)\s*estrelas?/i);
    if (starMatch) {
      const n = parseInt(starMatch[1], 10);
      if (n >= 1 && n <= 5) return `${n} ${n === 1 ? 'estrela' : 'estrelas'}`;
    }
    if (/\d+([.,]\d+)?\s*avalia/i.test(cat)) return cat;
    if (cat.length > 0) return cat;
  }
  const rating = Number(hotel.rating);
  if (!Number.isNaN(rating) && rating > 0) {
    if (rating <= 5 && Math.abs(rating - Math.round(rating)) < 0.01) {
      const n = Math.round(rating);
      return `${n} ${n === 1 ? 'estrela' : 'estrelas'}`;
    }
    return `${rating.toFixed(1)} avaliação`;
  }
  return 'Classificação não disponível';
}

function formatHotelRatingMeta(hotel) {
  const rating = Number(hotel?.rating);
  const reviews = Number(hotel?.reviews);
  if (Number.isNaN(rating) || rating <= 0) return '';
  const parts = [`${rating.toFixed(1)} ★`];
  if (!Number.isNaN(reviews) && reviews > 0) {
    parts.push(`${reviews} avaliações`);
  }
  return parts.join(' ');
}

function renderHotelCardsSelectable(hotels) {
  if (!hotels.length) {
    return '<p class="te-empty">Sem opções de alojamento disponíveis.</p>';
  }
  return hotels.map((hotel, index) => {
    const id = `hotel-${index}`;
    const gradientStyle = buildGradientStyle(hotel.nome || hotel.zona || 'hotel', index + 1);
    const imgSrc = safeHotelImageUrl(hotel.imagemUrl);
    const reviews = Number(hotel.reviews);
    const hotelBadge = formatHotelBadge(hotel);
    const hotelLabel = formatHotelLabel(hotel);
    const ratingMeta = formatHotelRatingMeta(hotel);
    const metaLine = ratingMeta ? `<p class="te-hotel-card__meta">${escapeHtml(ratingMeta)}</p>` : '';
    const categoryLine = hotelLabel ? `<p class="te-hotel-card__category">${escapeHtml(hotelLabel)}</p>` : '';
    const chips = renderHotelAmenityChips(hotel.amenities, 3);
    const visualInner = imgSrc
      ? `<img class="te-hotel-card__photo" src="${escapeHtml(imgSrc)}" alt="" loading="lazy" decoding="async" referrerpolicy="no-referrer" onerror="this.style.display='none'"><div class="te-hotel-card__shade"></div>`
      : '<div class="te-hotel-card__shade te-hotel-card__shade--soft"></div>';
    const descText = decodeApiText(hotel.descricaoCurta || hotel.descricao || '');
    return `
      <article class="te-hotel-card te-selectable" data-hotel-id="${id}">
        <div class="te-hotel-card__visual" style="${gradientStyle}">
          ${visualInner}
          <span class="te-hotel-card__visual-badge">${escapeHtml(hotelBadge || '—')}</span>
          <strong class="te-hotel-card__visual-title">${escapeHtml(decodeApiText(hotel.nome))}</strong>
        </div>
        <div class="te-hotel-card__body">
          <p class="te-hotel-card__zone">${escapeHtml(decodeApiText(hotel.zona || 'Zona recomendada'))}</p>
          ${categoryLine}
          ${metaLine}
          <p class="te-hotel-card__desc">${escapeHtml(descText)}</p>
          ${chips}
          <div class="te-hotel-card__footer te-hotel-card__footer--stacked">
            <span class="te-hotel-card__price">${formatEuro(hotel.precoEstimado)} <small>estimado</small></span>
            <div class="te-hotel-card__actions">
              <button type="button" class="btn btn-ghost" data-hotel-details="${id}">Ver detalhes</button>
              <button type="button" class="btn btn-secondary te-select-btn" data-select-hotel="${id}">Selecionar</button>
            </div>
          </div>
        </div>
      </article>
    `;
  }).join('');
}

function renderFlightListSelectable(voos, prefix, emptyMessage) {
  if (!voos.length) {
    return `<p class="te-empty">${emptyMessage}</p>`;
  }
  return `<div class="te-flight-list">${voos.map((voo, index) => renderFlightSelectable(voo, `${prefix}-${index}`)).join('')}</div>`;
}

function formatFlightStopsLabel(voo) {
  const escalas = Number(voo?.numEscalas);
  if (!Number.isNaN(escalas) && escalas >= 0) {
    if (escalas === 0) return 'Direto';
    if (escalas === 1) return '1 escala';
    return `${escalas} escalas`;
  }
  const segs = voo?.segmentos;
  if (Array.isArray(segs) && segs.length > 1) {
    const n = segs.length - 1;
    if (n === 1) return '1 escala';
    return `${n} escalas`;
  }
  return 'Direto';
}

function renderFlightSelectable(voo, id) {
  const dep = formatTimeShort(voo.partida);
  const arr = formatTimeShort(voo.chegada);
  const stops = formatFlightStopsLabel(voo);
  const segments = Array.isArray(voo.segmentos) && voo.segmentos.length > 1 ? voo.segmentos : null;
  const segmentDetails = segments
    ? segments.map((seg, idx) => `
        <section>
          <h5>Segmento ${idx + 1}</h5>
          <p>${escapeHtml(decodeApiText(seg.origem || ''))} → ${escapeHtml(decodeApiText(seg.destino || ''))} · ${escapeHtml(decodeApiText(seg.numeroVoo || ''))}</p>
        </section>`).join('')
    : '';
  return `
    <article class="te-flight-row te-selectable" data-flight-id="${id}">
      <div class="te-flight-row__main">
        <div class="te-flight-row__airline">
          <strong>${escapeHtml(decodeApiText(voo.companhia || 'Companhia'))}</strong>
          <span>${escapeHtml(decodeApiText(voo.numeroVoo || ''))}</span>
          <span class="te-flight-row__stops">${escapeHtml(stops)}</span>
        </div>
        <div class="te-flight-row__leg">
          <span class="te-flight-row__code">${escapeHtml(decodeApiText(voo.origem || ''))}</span>
          <span class="te-flight-row__time">${escapeHtml(dep)}</span>
        </div>
        <div class="te-flight-row__mid">
          <span class="te-flight-row__duration">${escapeHtml(decodeApiText(voo.duracao || '—'))}</span>
        </div>
        <div class="te-flight-row__leg te-flight-row__leg--end">
          <span class="te-flight-row__code">${escapeHtml(decodeApiText(voo.destino || ''))}</span>
          <span class="te-flight-row__time">${escapeHtml(arr)}</span>
        </div>
        <div class="te-flight-row__price">
          <strong>${formatEuro(voo.precoTotal)}</strong>
        </div>
        <div class="te-flight-row__actions">
          <button type="button" class="btn btn-secondary te-select-btn" data-select-flight="${id}">Selecionar</button>
          <button type="button" class="btn btn-ghost te-flight-row__details" data-toggle-details="${id}">Detalhes</button>
        </div>
      </div>
      <div class="te-flight-expand" id="${id}" hidden>
        <div class="te-detail-sections te-detail-sections--inline">
          <section><h5>Origem</h5><p>${escapeHtml(decodeApiText(voo.aeroportoOrigem || voo.origem || '—'))}</p></section>
          <section><h5>Destino</h5><p>${escapeHtml(decodeApiText(voo.aeroportoDestino || voo.destino || '—'))}</p></section>
          <section><h5>Partida</h5><p>${escapeHtml(formatDateTime(voo.partida))}</p></section>
          <section><h5>Chegada</h5><p>${escapeHtml(formatDateTime(voo.chegada))}</p></section>
          <section><h5>Escalas</h5><p>${escapeHtml(stops)}</p></section>
          <section><h5>Preço por pessoa</h5><p>${formatEuro(voo.precoPorPessoa)}</p></section>
          ${segmentDetails}
        </div>
      </div>
    </article>
  `;
}

function bindDetailsToggles(container) {
  container.querySelectorAll('[data-toggle-details]').forEach((button) => {
    button.addEventListener('click', (event) => {
      event.preventDefault();
      event.stopPropagation();
      const targetId = button.getAttribute('data-toggle-details');
      const panel = document.getElementById(targetId);
      if (!panel) return;
      const isOpen = !panel.hidden;
      panel.hidden = isOpen;
      button.textContent = isOpen ? 'Detalhes' : 'Ocultar';
      button.setAttribute('aria-expanded', String(!isOpen));
    });
  });
}

function selectHotelChoice(container, id, hotel) {
  tripSelection.hotelSkipped = false;
  tripSelection.hotelId = id;
  tripSelection.hotel = hotel;
  clearFromPackage(container);
  container.querySelectorAll('[data-hotel-id]').forEach((el) => {
    const selected = el.getAttribute('data-hotel-id') === id;
    el.classList.toggle('is-selected', selected);
    const selectBtn = el.querySelector('[data-select-hotel]');
    if (selectBtn) selectBtn.textContent = selected ? 'Selecionado' : 'Selecionar';
  });
  goToWizardStep(container, 4);
  renderWizardPreSummary(container);
}

function initBookingWizard(container) {
  bindDetailsToggles(container);

  container.querySelectorAll('[data-wizard-nav]').forEach((btn) => {
    btn.addEventListener('click', () => {
      const step = Number(btn.getAttribute('data-wizard-nav'));
      if (!canNavigateToWizardStep(container, step)) return;
      goToWizardStep(container, step);
      if (step === 3 && !container.__hotelsLoaded) {
        loadWizardHotels(container);
      }
      if (step === 4) {
        renderWizardPreSummary(container);
      }
      refreshAllSelectionMarks(container);
    });
  });

  container.querySelectorAll('[data-select-flight]').forEach((btn) => {
    btn.addEventListener('click', (event) => {
      event.stopPropagation();
      const id = btn.getAttribute('data-select-flight');
      const isIda = id.startsWith('ida');
      const voos = isIda ? container.__voosIda : container.__voosRegresso;
      const index = parseInt(id.split('-')[1], 10);
      const voo = voos?.[index];
      if (!voo) return;
      const stepEl = container.querySelector(`[data-wizard-step="${isIda ? 1 : 2}"]`);
      if (isIda) {
        const prevId = tripSelection.flightIdaId;
        tripSelection.flightIdaId = id;
        tripSelection.flightIda = voo;
        if (prevId && prevId !== id) {
          clearFromRegresso(container);
          updateWizardNav(container, 1);
        }
        markFlightSelected(stepEl, id);
        goToWizardStep(container, 2);
      } else {
        const prevId = tripSelection.flightRegressoId;
        tripSelection.flightRegressoId = id;
        tripSelection.flightRegresso = voo;
        if (prevId && prevId !== id) {
          clearFromHotel(container);
          updateWizardNav(container, 2);
        }
        markFlightSelected(stepEl, id);
        goToWizardStep(container, 3);
        loadWizardHotels(container);
      }
      updateSelectionStrip(container);
    });
  });

  container.querySelector('#wizard-skip-hotel')?.addEventListener('click', () => {
    tripSelection.hotelSkipped = true;
    tripSelection.hotel = null;
    tripSelection.hotelId = null;
    clearFromPackage(container);
    container.querySelectorAll('[data-hotel-id]').forEach((el) => el.classList.remove('is-selected'));
    goToWizardStep(container, 4);
    renderWizardPreSummary(container);
    updateSelectionStrip(container);
  });

  container.querySelector('#wizard-create-sugestao')?.addEventListener('click', () => {
    createTravelSuggestion(container);
  });

  container.querySelectorAll('[data-close-modal]').forEach((el) => {
    el.addEventListener('click', () => {
      const modal = container.querySelector('#save-trip-modal');
      if (modal) {
        modal.hidden = true;
        resetSaveTripModal(container);
      }
    });
  });

  container.querySelector('#save-trip-modal-confirm')?.addEventListener('click', () => {
    guardarViagem(container);
  });

  container.querySelectorAll('[data-close-hotel-modal]').forEach((el) => {
    el.addEventListener('click', () => {
      const modal = container.querySelector('#hotel-details-modal');
      if (modal) modal.hidden = true;
    });
  });

  goToWizardStep(container, 1);
}

function goToWizardStep(container, step) {
  container.__activeWizardStep = step;
  container.querySelectorAll('[data-wizard-step]').forEach((el) => {
    const n = Number(el.getAttribute('data-wizard-step'));
    el.hidden = n !== step;
    el.classList.toggle('is-active', n === step);
  });
  updateWizardNav(container, step);
  updateSelectionStrip(container);
  if (container.__scrollToPanelOnInit) {
    container.__scrollToPanelOnInit = false;
    scrollToBookingPanel(container);
    return;
  }
  scrollToWizardStep(container, step);
}

function markFlightSelected(stepEl, id) {
  stepEl?.querySelectorAll('[data-flight-id]').forEach((el) => {
    const selected = el.getAttribute('data-flight-id') === id;
    el.classList.toggle('is-selected', selected);
    const selectBtn = el.querySelector('[data-select-flight]');
    if (selectBtn) selectBtn.textContent = selected ? 'Selecionado' : 'Selecionar';
  });
}

async function loadWizardHotels(container) {
  if (container.__hotelsLoaded) {
    bindWizardHotelUI(container);
    return;
  }
  const form = container.__form;
  const meta = container.__meta;
  const hotelsUrl = form?.dataset.hotelsUrl;
  if (!hotelsUrl || !meta) return;

  const loading = container.querySelector('#wizard-hotels-loading');
  const grid = container.querySelector('#wizard-hotels-grid');
  if (loading) loading.hidden = false;
  if (grid) grid.innerHTML = '';

  const params = new URLSearchParams({
    destino: meta.destino,
    data_partida: meta.dataPartida,
    data_regresso: meta.dataRegresso,
    adultos: String(meta.adultos),
    criancas: String(meta.criancas),
  });

  try {
    const response = await fetch(`${hotelsUrl}?${params}`, {
      method: 'GET',
      headers: { Accept: 'application/json' },
      credentials: 'same-origin',
    });
    const data = await response.json();
    if (data?.ok === true && Array.isArray(data.hoteisOpcoes)) {
      container.__hotels = data.hoteisOpcoes.slice(0, 8);
    } else {
      container.__hotels = [];
    }
  } catch (err) {
    container.__hotels = [];
  } finally {
    container.__hotelsLoaded = true;
    if (loading) loading.hidden = true;
    if (grid) {
      grid.innerHTML = renderHotelCardsSelectable(container.__hotels);
      bindWizardHotelUI(container);
    }
  }
}

function bindWizardHotelUI(container) {
  container.querySelectorAll('[data-select-hotel]').forEach((btn) => {
    btn.replaceWith(btn.cloneNode(true));
  });
  container.querySelectorAll('[data-hotel-details]').forEach((btn) => {
    btn.replaceWith(btn.cloneNode(true));
  });

  container.querySelectorAll('[data-select-hotel]').forEach((btn) => {
    btn.addEventListener('click', (event) => {
      event.stopPropagation();
      const id = btn.getAttribute('data-select-hotel');
      const index = parseInt(id.split('-')[1], 10);
      const hotel = container.__hotels?.[index];
      if (!hotel) return;
      selectHotelChoice(container, id, hotel);
    });
  });

  container.querySelectorAll('[data-hotel-details]').forEach((btn) => {
    btn.addEventListener('click', (event) => {
      event.stopPropagation();
      const id = btn.getAttribute('data-hotel-details');
      const index = parseInt(id.split('-')[1], 10);
      const hotel = container.__hotels?.[index];
      if (hotel) openHotelDetailsModal(container, hotel, id);
    });
  });
}

function openHotelDetailsModal(container, hotel, id) {
  const modal = container.querySelector('#hotel-details-modal');
  const content = container.querySelector('#hotel-details-content');
  if (!modal || !content) return;
  content.innerHTML = renderHotelDetailsContent(hotel, id);
  modal.hidden = false;

  content.querySelector('[data-close-hotel-modal]')?.addEventListener('click', () => {
    modal.hidden = true;
  });
  content.querySelector('[data-choose-hotel]')?.addEventListener('click', () => {
    modal.hidden = true;
    selectHotelChoice(container, id, hotel);
  });
}

function renderHotelDetailsContent(hotel, id) {
  const gradientStyle = buildGradientStyle(hotel.nome || hotel.zona || 'hotel', 2);
  const imgSrc = safeHotelImageUrl(hotel.imagemUrl);
  const reviews = Number(hotel.reviews);
  const hotelLabel = formatHotelLabel(hotel);
  const ratingMeta = formatHotelRatingMeta(hotel);
  const visual = imgSrc
    ? `<div class="te-hotel-detail__visual" style="${gradientStyle}"><img src="${escapeHtml(imgSrc)}" alt="" loading="lazy" referrerpolicy="no-referrer" onerror="this.style.display='none'"></div>`
    : `<div class="te-hotel-detail__visual te-hotel-detail__visual--fallback" style="${gradientStyle}"></div>`;
  const ratingLine = ratingMeta
    ? `<span class="te-hotel-detail__rating">${escapeHtml(ratingMeta)}${!Number.isNaN(reviews) && reviews > 0 ? ` · ${reviews} avaliações` : ''}</span>`
    : (!Number.isNaN(reviews) && reviews > 0 ? `<span class="te-hotel-detail__rating">${reviews} avaliações</span>` : '');
  const categoryLine = hotelLabel ? `<span class="te-hotel-detail__category">${escapeHtml(hotelLabel)}</span>` : '';
  const zoneLine = hotel.zona ? `<p class="te-hotel-detail__zone">${escapeHtml(decodeApiText(hotel.zona))}</p>` : '';
  const priceLine = hotel.precoEstimado ? `<p class="te-hotel-detail__price">${formatEuro(hotel.precoEstimado)} <small>estimado</small></p>` : '';
  const chips = renderHotelAmenityChips(hotel.amenities, 8).replace('te-hotel-card__chips', 'te-hotel-detail__chips');
  const desc = decodeApiText(hotel.descricao || hotel.descricaoCurta || '');
  const descLine = desc ? `<p class="te-hotel-detail__desc">${escapeHtml(desc)}</p>` : '';
  const metaRow = [ratingLine, categoryLine].filter(Boolean).join('');
  return `
    <div class="te-hotel-detail">
      <header class="te-hotel-detail__header">
        <h3 id="hotel-details-title">${escapeHtml(decodeApiText(hotel.nome))}</h3>
        ${metaRow ? `<div class="te-hotel-detail__meta">${metaRow}</div>` : ''}
        ${priceLine}
      </header>
      ${visual}
      ${zoneLine}
      ${chips}
      ${descLine}
      <div class="te-hotel-detail__actions">
        <button type="button" class="btn btn-primary" data-choose-hotel="${id}">Escolher este alojamento</button>
        <button type="button" class="btn btn-secondary" data-close-hotel-modal>Fechar</button>
      </div>
    </div>
  `;
}

function renderFlightReviewBody(voo) {
  if (!voo) return '<p class="te-review-card__empty">—</p>';
  return `
    <p><strong>${escapeHtml(decodeApiText(voo.companhia || ''))} ${escapeHtml(decodeApiText(voo.numeroVoo || ''))}</strong></p>
    <p>${escapeHtml(decodeApiText(voo.origem))} ${escapeHtml(formatTimeShort(voo.partida))} → ${escapeHtml(decodeApiText(voo.destino))} ${escapeHtml(formatTimeShort(voo.chegada))}</p>
    <p class="te-review-card__price">${formatEuro(voo.precoTotal)}</p>
  `;
}

function renderWizardPreSummary(container) {
  const el = container.querySelector('#wizard-pre-summary');
  if (!el) return;
  const ida = tripSelection.flightIda;
  const reg = tripSelection.flightRegresso;
  let hotelBody = '<p class="te-review-card__empty">Sem alojamento selecionado</p>';
  if (tripSelection.hotel) {
    hotelBody = `
      <p><strong>${escapeHtml(decodeApiText(tripSelection.hotel.nome))}</strong></p>
      <p>${escapeHtml(decodeApiText(tripSelection.hotel.zona || ''))} · ${escapeHtml(formatHotelLabel(tripSelection.hotel))}</p>
      <p class="te-review-card__price">${formatEuro(tripSelection.hotel.precoEstimado)} estimado</p>
    `;
  }
  el.innerHTML = `
    <div class="te-wizard-review__grid">
      ${renderReviewCard('Ida', renderFlightReviewBody(ida), 1)}
      ${renderReviewCard('Regresso', renderFlightReviewBody(reg), 2)}
      ${renderReviewCard('Alojamento', hotelBody, 3)}
    </div>
  `;
  el.querySelectorAll('[data-review-alter]').forEach((btn) => {
    btn.addEventListener('click', () => {
      const targetStep = Number(btn.getAttribute('data-review-alter'));
      if (!canNavigateToWizardStep(container, targetStep)) return;
      goToWizardStep(container, targetStep);
      if (targetStep === 3 && !container.__hotelsLoaded) {
        loadWizardHotels(container);
      }
      refreshAllSelectionMarks(container);
    });
  });
}

async function createTravelSuggestion(container) {
  const form = container.__form;
  const meta = container.__meta;
  const url = form?.dataset.sugestaoUrl;
  if (!url || !meta || !tripSelection.flightIda || !tripSelection.flightRegresso) return;

  const btn = container.querySelector('#wizard-create-sugestao');
  const loading = container.querySelector('#wizard-sugestao-loading');
  if (btn) btn.disabled = true;
  if (loading) loading.hidden = false;

  const payload = {
    origem: meta.origem,
    destino: meta.destino,
    dataPartida: meta.dataPartida,
    dataRegresso: meta.dataRegresso,
    adultos: meta.adultos,
    criancas: meta.criancas,
    vooIdaSelecionado: tripSelection.flightIda,
    vooRegressoSelecionado: tripSelection.flightRegresso,
  };
  if (tripSelection.hotel) {
    payload.hotelSelecionado = tripSelection.hotel;
  }

  try {
    const response = await fetch(url, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json', Accept: 'application/json' },
      credentials: 'same-origin',
      body: JSON.stringify(payload),
    });
    const data = await response.json();
    if (!data?.ok || !data.sugestao) {
      return;
    }
    tripSelection.sugestao = data.sugestao;
    renderFinalPackage(container);
    goToWizardStep(container, 5);
  } catch (err) {
    return;
  } finally {
    if (btn) btn.disabled = false;
    if (loading) loading.hidden = true;
  }
}

function renderPackageSelectionBlock(title, linesHtml) {
  if (!linesHtml) return '';
  return `
    <div class="te-selection-block">
      <h4>${escapeHtml(title)}</h4>
      ${linesHtml}
    </div>
  `;
}

function renderPackageFlightLines(voo) {
  if (!voo) return '';
  return `
    <p><strong>${escapeHtml(decodeApiText(voo.companhia || ''))} ${escapeHtml(decodeApiText(voo.numeroVoo || ''))}</strong></p>
    <p>${escapeHtml(decodeApiText(voo.origem))} ${escapeHtml(formatTimeShort(voo.partida))} → ${escapeHtml(decodeApiText(voo.destino))} ${escapeHtml(formatTimeShort(voo.chegada))}</p>
    <p class="te-selection-block__price">${formatEuro(voo.precoTotal)}</p>
  `;
}

function renderFinalPackage(container) {
  const target = container.querySelector('#wizard-final-package');
  if (!target) return;
  const sugestao = tripSelection.sugestao || {};
  const meta = container.__meta || {};
  const destLabel = decodeApiText(meta.destinoLabel || meta.destino || 'Destino');
  const gradientStyle = buildGradientStyle(destLabel, 0);
  const activitiesHtml = renderActivitiesList(sugestao.atividades);
  const transportText = decodeApiText(sugestao.transporteSugerido || '');
  const resumo = decodeApiText(sugestao.resumoFinal || sugestao.descricao || '');
  const ida = tripSelection.flightIda;
  const reg = tripSelection.flightRegresso;

  let hotelCard = '';
  if (tripSelection.hotel) {
    hotelCard = `
      <article class="te-package-mini-card">
        <h4>Alojamento</h4>
        <p><strong>${escapeHtml(decodeApiText(tripSelection.hotel.nome))}</strong></p>
        <p>${escapeHtml(decodeApiText(tripSelection.hotel.zona || ''))} · ${escapeHtml(formatHotelLabel(tripSelection.hotel))}</p>
        <p class="te-package-mini-card__price">${formatEuro(tripSelection.hotel.precoEstimado)} estimado</p>
      </article>`;
  } else {
    hotelCard = `
      <article class="te-package-mini-card te-package-mini-card--muted">
        <h4>Alojamento</h4>
        <p>Sem alojamento incluído</p>
      </article>`;
  }

  target.innerHTML = `
    <article class="te-package-card te-package-card--final">
      <div class="te-package-card__hero te-package-card__hero--large" style="${gradientStyle}">
        <span class="te-package-card__label">Plano de viagem personalizado</span>
        <h3>${escapeHtml(decodeApiText(sugestao.titulo || 'A sua viagem'))}</h3>
        <div class="te-package-card__chips">
          <span class="te-chip">${escapeHtml(meta.routeLabel || '')}</span>
          <span class="te-chip">${escapeHtml(meta.datesLabel || '')}</span>
          <span class="te-chip">${escapeHtml(meta.travellersLabel || '')}</span>
        </div>
      </div>
      <div class="te-package-card__body te-package-card__body--final">
        <p class="te-package-card__desc">${escapeHtml(resumo)}</p>
        <div class="te-package-card__price te-package-card__price--highlight">
          <span>Preço estimado do pacote</span>
          <strong>${formatEuro(sugestao.precoEstimadoTotal)}</strong>
          <small>Valores indicativos; confirmação final na fase de reservas</small>
        </div>
        ${activitiesHtml}
        ${transportText ? `<div class="te-package-card__transport"><h4>Transporte sugerido</h4><p>${escapeHtml(transportText)}</p></div>` : ''}
        <div class="te-package-final__selections">
          <article class="te-package-mini-card">
            <h4>Voo de ida</h4>
            ${renderPackageFlightLines(ida)}
          </article>
          <article class="te-package-mini-card">
            <h4>Voo de regresso</h4>
            ${renderPackageFlightLines(reg)}
          </article>
          ${hotelCard}
        </div>
        <div class="te-package-card__actions">
          <button type="button" class="btn btn-primary" id="save-trip-btn">Guardar viagem</button>
        </div>
      </div>
    </article>
  `;

  target.querySelector('#save-trip-btn')?.addEventListener('click', () => {
    openSaveTripModal(container);
  });
}

function buildGuardarPayload(container) {
  const meta = container.__meta;
  if (!meta || !tripSelection.flightIda || !tripSelection.flightRegresso || !tripSelection.sugestao) {
    return null;
  }
  const payload = {
    origem: meta.origem,
    destino: meta.destino,
    dataPartida: meta.dataPartida,
    dataRegresso: meta.dataRegresso,
    adultos: meta.adultos,
    criancas: meta.criancas,
    vooIdaSelecionado: tripSelection.flightIda,
    vooRegressoSelecionado: tripSelection.flightRegresso,
    sugestao: tripSelection.sugestao,
  };
  if (tripSelection.hotel) {
    payload.hotelSelecionado = tripSelection.hotel;
  }
  return payload;
}

function resetSaveTripModal(container) {
  const body = container.querySelector('#save-trip-modal-body');
  const actions = container.querySelector('#save-trip-modal-actions');
  const confirmBtn = container.querySelector('#save-trip-modal-confirm');
  if (body) {
    body.innerHTML = '<p>A tua viagem será guardada como reserva na área de cliente.</p>';
  }
  if (actions) actions.hidden = false;
  if (confirmBtn) {
    confirmBtn.hidden = false;
    confirmBtn.disabled = false;
    confirmBtn.textContent = 'Guardar';
  }
}

function openSaveTripModal(container) {
  const modal = container.querySelector('#save-trip-modal');
  if (!modal) return;
  resetSaveTripModal(container);
  modal.hidden = false;
}

function setSaveTripModalState(container, html, options = {}) {
  const body = container.querySelector('#save-trip-modal-body');
  const actions = container.querySelector('#save-trip-modal-actions');
  const confirmBtn = container.querySelector('#save-trip-modal-confirm');
  if (body) body.innerHTML = html;
  if (options.hideActions && actions) actions.hidden = true;
  if (confirmBtn) {
    if (options.confirmLabel) confirmBtn.textContent = options.confirmLabel;
    if (options.hideConfirm) confirmBtn.hidden = true;
    confirmBtn.disabled = Boolean(options.disableConfirm);
  }
}

async function guardarViagem(container) {
  const form = container.__form;
  const url = form?.dataset.guardarUrl;
  const payload = buildGuardarPayload(container);
  const saveBtn = container.querySelector('#save-trip-btn');
  const confirmBtn = container.querySelector('#save-trip-modal-confirm');

  if (!url || !payload) {
    setSaveTripModalState(container, '<p class="te-empty">Não foi possível preparar os dados da viagem.</p>', { hideActions: true });
    return;
  }

  if (saveBtn) {
    saveBtn.disabled = true;
    saveBtn.textContent = 'A guardar…';
  }
  if (confirmBtn) {
    confirmBtn.disabled = true;
    confirmBtn.textContent = 'A guardar…';
  }
  setSaveTripModalState(container, '<p>A guardar a tua reserva…</p>', { disableConfirm: true });

  try {
    const response = await fetch(url, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json', Accept: 'application/json' },
      credentials: 'same-origin',
      body: JSON.stringify(payload),
    });
    const data = await response.json();

    if (data?.authRequired) {
      const loginUrl = form?.dataset.loginUrl || '';
      const loginLink = loginUrl
        ? `<a class="btn btn-primary" href="${escapeHtml(loginUrl)}">Iniciar sessão</a>`
        : '';
      setSaveTripModalState(
        container,
        `<p>${escapeHtml(data.message || 'Precisas de iniciar sessão para guardar a viagem.')}</p>${loginLink ? `<div class="te-modal__actions">${loginLink}</div>` : ''}`,
        { hideActions: true, hideConfirm: true },
      );
      return;
    }

    if (!data?.ok) {
      setSaveTripModalState(
        container,
        `<p>${escapeHtml(data?.message || 'Não foi possível guardar a viagem.')}</p>`,
        { hideActions: true, hideConfirm: true },
      );
      return;
    }

    const basePath = url.replace(/\/guardar-viagem\/?$/, '');
    const dashboardUrl = `${basePath}/index.jsp?page=customer-dashboard`;
    setSaveTripModalState(
      container,
      `<h4>Reserva guardada</h4><p>${escapeHtml(data.message || 'A tua viagem foi guardada na área de cliente.')}</p><p><a class="btn btn-primary" href="${escapeHtml(dashboardUrl)}">Ver área de cliente</a></p>`,
      { hideActions: true, hideConfirm: true },
    );
    if (saveBtn) saveBtn.textContent = 'Reserva guardada';
  } catch (err) {
    setSaveTripModalState(
      container,
      '<p>Não foi possível guardar a viagem. Tenta novamente.</p>',
      { hideActions: true, hideConfirm: true },
    );
  } finally {
    if (confirmBtn && !confirmBtn.hidden) {
      confirmBtn.disabled = false;
      confirmBtn.textContent = 'Guardar';
    }
    if (saveBtn && saveBtn.textContent === 'A guardar…') {
      saveBtn.disabled = false;
      saveBtn.textContent = 'Guardar viagem';
    }
  }
}

function renderActivitiesList(atividades) {
  if (!Array.isArray(atividades) || !atividades.length) return '';
  const items = atividades
    .slice(0, 7)
    .map((item) => `<li class="te-activity-pill">${escapeHtml(decodeApiText(item))}</li>`)
    .join('');
  return `<div class="te-package-card__activities"><h4>Atividades sugeridas</h4><ul class="te-activity-grid">${items}</ul></div>`;
}

function buildGradientStyle(label, seed) {
  const palettes = [
    ['#d77a61', '#223843'],
    ['#c4a484', '#2f4858'],
    ['#8fa6b8', '#223843'],
    ['#e8b89d', '#3d5a6c'],
  ];
  const palette = palettes[seed % palettes.length];
  return `background:linear-gradient(135deg, ${palette[0]} 0%, ${palette[1]} 100%);`;
}

function pickFlights(primary, fallback) {
  if (Array.isArray(primary) && primary.length) return primary.slice(0, 6);
  if (Array.isArray(fallback) && fallback.length) return fallback.slice(0, 6);
  return [];
}
function decodeApiText(value) {
  if (value == null || value === undefined) return '';
  let text = String(value);
  let prev = '';
  let guard = 0;
  while (text !== prev && guard < 4) {
    prev = text;
    guard += 1;
    if (text.includes('\\u')) {
      text = text.replace(/\\u([0-9a-fA-F]{4})/g, (_, hex) => String.fromCharCode(parseInt(hex, 16)));
    }
    text = text.replace(/(^|[^\\])u([0-9a-fA-F]{4})/g, (match, prefix, hex) =>
      `${prefix}${String.fromCharCode(parseInt(hex, 16))}`);
  }
  return text.replace(/\\n/g, '\n').replace(/\\r/g, '\r').replace(/\\t/g, '\t');
}



function escapeHtml(value) {
  if (value == null) return '';
  return String(value)
    .replace(/&/g, '&amp;')
    .replace(/</g, '&lt;')
    .replace(/>/g, '&gt;')
    .replace(/"/g, '&quot;')
    .replace(/'/g, '&#39;');
}

function formatEuro(amount) {
  const number = Number(amount);
  if (Number.isNaN(number) || number <= 0) return '—';
  return new Intl.NumberFormat('pt-PT', { style: 'currency', currency: 'EUR' }).format(number);
}

function formatDisplayDate(value) {
  if (!value) return '—';
  const date = new Date(`${value}T00:00:00`);
  if (Number.isNaN(date.getTime())) return value;
  return new Intl.DateTimeFormat('pt-PT', { day: '2-digit', month: 'short', year: 'numeric' }).format(date);
}

function formatDateTime(value) {
  if (!value) return '—';
  const normalized = String(value).replace(' ', 'T');
  const date = new Date(normalized);
  if (Number.isNaN(date.getTime())) return decodeApiText(value);
  return new Intl.DateTimeFormat('pt-PT', {
    day: '2-digit', month: 'short', hour: '2-digit', minute: '2-digit',
  }).format(date);
}

function formatTimeShort(value) {
  if (!value) return '—';
  const normalized = String(value).replace(' ', 'T');
  const date = new Date(normalized);
  if (Number.isNaN(date.getTime())) {
    const parts = String(value).split(' ');
    return parts.length > 1 ? parts[1].slice(0, 5) : value;
  }
  return new Intl.DateTimeFormat('pt-PT', { hour: '2-digit', minute: '2-digit' }).format(date);
}

function getCurrentPageParam() {
  return new URLSearchParams(window.location.search).get('page');
}

function getPageParamFromUrl(url) {
  return new URL(url, window.location.origin).searchParams.get('page');
}

function isHomeUrl(url) {
  return !new URL(url, window.location.origin).searchParams.has('page');
}
