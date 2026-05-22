const TE_AIRPORT_FALLBACK = {
  maia: { code: 'OPO', city: 'Porto', name: 'Aeroporto Francisco Sá Carneiro', label: 'Porto · Aeroporto Francisco Sá Carneiro (OPO)' },
  porto: { code: 'OPO', city: 'Porto', name: 'Aeroporto Francisco Sá Carneiro', label: 'Porto · Aeroporto Francisco Sá Carneiro (OPO)' },
  lisboa: { code: 'LIS', city: 'Lisboa', name: 'Aeroporto Humberto Delgado', label: 'Lisboa · Aeroporto Humberto Delgado (LIS)' },
  lisbon: { code: 'LIS', city: 'Lisboa', name: 'Aeroporto Humberto Delgado', label: 'Lisboa · Aeroporto Humberto Delgado (LIS)' },
};

const TE_AIRPORT_SEARCH_DEBOUNCE = {};
const TE_AIRPORT_LOADING = 'A procurar aeroportos...';
const TE_AIRPORT_NO_MATCH = 'Não encontrámos um aeroporto para essa pesquisa.';

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

  initAirportField('origem', form);
  initAirportField('destino', form);
  initPassengerSelector();
  initTravelDateValidation(form);

  form.addEventListener('submit', async (event) => {
    event.preventDefault();
    await runTravelSearch(form);
  });
}

function initAirportField(prefix, form) {
  const display = document.getElementById(`${prefix}-display`);
  const hidden = document.getElementById(prefix);
  const dropdown = document.getElementById(`${prefix}-dropdown`);
  if (!display || !hidden || !dropdown) return;

  const showLoading = () => {
    dropdown.innerHTML = `<p class="te-airport-option te-airport-option--loading">${escapeHtml(TE_AIRPORT_LOADING)}</p>`;
    dropdown.hidden = false;
  };

  const renderOptions = (matches, emptyMessage) => {
    if (!matches.length) {
      dropdown.innerHTML = `<p class="te-airport-option te-airport-option--empty">${escapeHtml(emptyMessage || TE_AIRPORT_NO_MATCH)}</p>`;
      dropdown.hidden = false;
      return;
    }
    dropdown.innerHTML = matches.map((airport) => {
      const label = airportDisplayLabel(airport);
      const sub = airport.name && airport.city && airport.name !== airport.city
        ? airport.name
        : (airport.name || airport.city || '');
      return `
      <button type="button" class="te-airport-option" data-code="${escapeHtml(airport.code)}" data-label="${escapeHtml(label)}">
        <span class="te-airport-option__code">${escapeHtml(airport.code)}</span>
        <span class="te-airport-option__body">
          <strong>${escapeHtml(label)}</strong>
          ${sub ? `<span>${escapeHtml(sub)}</span>` : ''}
        </span>
      </button>`;
    }).join('');
    dropdown.hidden = false;
  };

  const runSearch = (query) => {
    const q = String(query || '').trim();
    if (q.length < 2) {
      dropdown.hidden = true;
      dropdown.innerHTML = '';
      return;
    }
    const fallback = tinyAirportFallback(q);
    if (fallback) {
      renderOptions([fallback]);
      return;
    }
    showLoading();
    scheduleAirportAutocomplete(prefix, q, form, renderOptions);
  };

  display.addEventListener('input', () => {
    hidden.value = '';
    runSearch(display.value);
  });

  display.addEventListener('focus', () => runSearch(display.value));

  dropdown.addEventListener('click', (event) => {
    const option = event.target.closest('.te-airport-option');
    if (!option || !option.dataset.code) return;
    hidden.value = option.dataset.code;
    display.value = option.dataset.label || option.dataset.code;
    dropdown.hidden = true;
  });

  display.addEventListener('blur', () => {
    window.setTimeout(async () => {
      if (!dropdown.matches(':hover') && !display.matches(':focus')) {
        dropdown.hidden = true;
      }
      if (!hidden.value && display.value.trim().length >= 2) {
        const resolved = await resolveAirportForQuery(display.value.trim(), form);
        if (resolved) {
          hidden.value = resolved.code;
          display.value = airportDisplayLabel(resolved);
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

function airportDisplayLabel(airport) {
  if (!airport) return '';
  if (airport.label) return airport.label;
  const city = airport.city || '';
  const name = airport.name || '';
  const code = airport.code || '';
  if (city && name && city !== name) {
    return `${city} · ${name} (${code})`;
  }
  if (name) return `${name} (${code})`;
  if (city) return `${city} (${code})`;
  return code;
}

function tinyAirportFallback(query) {
  const q = normalizeSearch(query);
  return TE_AIRPORT_FALLBACK[q] || null;
}

function scheduleAirportAutocomplete(prefix, query, form, renderOptions) {
  const key = `${prefix}:${normalizeSearch(query)}`;
  if (TE_AIRPORT_SEARCH_DEBOUNCE[key]) {
    window.clearTimeout(TE_AIRPORT_SEARCH_DEBOUNCE[key]);
  }
  TE_AIRPORT_SEARCH_DEBOUNCE[key] = window.setTimeout(async () => {
    const display = document.getElementById(`${prefix}-display`);
    if (!display || normalizeSearch(display.value) !== normalizeSearch(query)) {
      return;
    }
    const airports = await fetchFlightAutocomplete(query, form);
    if (!display || normalizeSearch(display.value) !== normalizeSearch(query)) {
      return;
    }
    if (airports.length) {
      renderOptions(airports);
    } else {
      const fallback = tinyAirportFallback(query);
      if (fallback) {
        renderOptions([fallback]);
      } else {
        renderOptions([], TE_AIRPORT_NO_MATCH);
      }
    }
  }, 250);
}

async function fetchFlightAutocomplete(query, form) {
  const base = form?.dataset.airportSearchUrl;
  if (!base || !query || query.trim().length < 2) return [];
  try {
    const response = await fetch(`${base}?q=${encodeURIComponent(query.trim())}`, {
      headers: { Accept: 'application/json' },
      credentials: 'same-origin',
    });
    if (!response.ok) return [];
    const data = await response.json();
    if (!Array.isArray(data)) return [];
    return data
      .map((item) => ({
        code: String(item.code || '').toUpperCase().slice(0, 3),
        name: item.name || '',
        city: item.city || '',
        label: item.label || '',
      }))
      .filter((a) => a.code.length === 3);
  } catch (err) {
    return [];
  }
}

async function resolveAirportForQuery(text, form) {
  const q = String(text || '').trim();
  if (q.length < 2) return null;
  const fallback = tinyAirportFallback(q);
  if (fallback) return fallback;
  const airports = await fetchFlightAutocomplete(q, form);
  return airports.length ? airports[0] : null;
}

function initTravelDateValidation(form) {
  const partida = form.elements.data_partida;
  const regresso = form.elements.data_regresso;
  if (!partida || !regresso) return;
  const today = new Date();
  today.setHours(0, 0, 0, 0);
  const isoToday = today.toISOString().slice(0, 10);
  partida.setAttribute('min', isoToday);
  const syncReturnMin = () => {
    regresso.setAttribute('min', partida.value || isoToday);
  };
  partida.addEventListener('change', syncReturnMin);
  syncReturnMin();
}

function validateTravelDates(form) {
  const partidaVal = form.elements.data_partida?.value;
  const regressoVal = form.elements.data_regresso?.value;
  if (!partidaVal || !regressoVal) {
    return { ok: false, message: 'Preenche as datas de partida e regresso.' };
  }
  const today = new Date();
  today.setHours(0, 0, 0, 0);
  const partida = new Date(`${partidaVal}T00:00:00`);
  const regresso = new Date(`${regressoVal}T00:00:00`);
  if (partida < today) {
    return { ok: false, message: 'A data de partida não pode ser anterior à data de hoje.' };
  }
  if (regresso < partida) {
    return { ok: false, message: 'A data de regresso não pode ser anterior à data de partida.' };
  }
  return { ok: true };
}

function airportLabel(airport) {
  return airportDisplayLabel(airport);
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

function isWizardAuthorized(form) {
  return form.dataset.wizardAuthorized === 'true' || form.dataset.clienteLoggedIn === 'true';
}

function isStaffOfferMode(form) {
  return form?.dataset.wizardMode === 'staff';
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

  if (!isWizardAuthorized(form)) {
    showElement(loginEl);
    loginEl?.scrollIntoView({ behavior: 'smooth', block: 'nearest' });
    return;
  }

  const origemDisplay = document.getElementById('origem-display');
  const destinoDisplay = document.getElementById('destino-display');
  let origem = form.elements.origem.value.trim();
  let destino = form.elements.destino.value.trim();

  if (!origem && origemDisplay?.value.trim()) {
    const resolved = await resolveAirportForQuery(origemDisplay.value.trim(), form);
    if (resolved) {
      origem = resolved.code;
      form.elements.origem.value = resolved.code;
      origemDisplay.value = airportDisplayLabel(resolved);
    }
  }
  if (!destino && destinoDisplay?.value.trim()) {
    const resolved = await resolveAirportForQuery(destinoDisplay.value.trim(), form);
    if (resolved) {
      destino = resolved.code;
      form.elements.destino.value = resolved.code;
      destinoDisplay.value = airportDisplayLabel(resolved);
    }
  }

  const dataPartida = form.elements.data_partida.value;
  const dataRegresso = form.elements.data_regresso.value;
  const adultos = form.elements.adultos.value;
  const criancas = form.elements.criancas.value;

  const dateCheck = validateTravelDates(form);
  if (!dateCheck.ok) {
    showSearchError(errorEl, resultsEl, loadingEl, dateCheck.message);
    return;
  }

  if (!origem || !destino || !dataPartida || !dataRegresso) {
    showSearchError(errorEl, resultsEl, loadingEl, 'Seleciona aeroportos de origem e destino válidos.');
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
      if (isStaffOfferMode(container.__form)) {
        return Boolean(tripSelection.flightRegresso) && isWizardStep3Complete();
      }
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
  const time = formatTimeDisplay(voo.partida);
  return label ? `${label} · ${time}` : time;
}

function formatFlightChoiceLine(voo, title) {
  if (!voo) return '';
  const airline = decodeApiText(voo.companhia || '');
  const num = decodeApiText(voo.numeroVoo || '');
  const dep = formatTimeDisplay(voo.partida);
  const arr = formatTimeDisplay(voo.chegada);
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
  const route = `${decodeApiText(voo.origem)} ${formatTimeDisplay(voo.partida)} → ${decodeApiText(voo.destino)} ${formatTimeDisplay(voo.chegada)}`;
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
    <article class="te-review-card te-summary-card">
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
  const staffWizard = isStaffOfferMode(form);

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

    <div class="te-wizard${staffWizard ? ' te-wizard--staff-offer' : ''}">
      <section class="te-wizard-step te-wizard-card is-active" data-wizard-step="1">
        <h3 class="te-section-title">Escolhe o voo de ida</h3>
        ${renderFlightListSelectable(voosIda, 'ida', 'Não foram encontrados voos de ida para esta data.')}
      </section>

      <section class="te-wizard-step te-wizard-card" data-wizard-step="2" hidden>
        <h3 class="te-section-title">Escolhe o voo de regresso</h3>
        ${renderFlightListSelectable(voosRegresso, 'regresso', 'Não encontrámos voos de regresso para esta data.')}
      </section>

      <section class="te-wizard-step te-wizard-card" data-wizard-step="3" hidden>
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

      <section class="te-wizard-step te-wizard-card" data-wizard-step="4" hidden>
        <h3 class="te-section-title">${staffWizard ? 'Rever oferta' : 'Revê o teu plano'}</h3>
        <p class="te-wizard-step__lead">${staffWizard ? 'Confirma os voos e o alojamento antes de publicar a oferta.' : 'Confirma os voos e o alojamento antes de criar o plano personalizado.'}</p>
        <div class="te-wizard-review te-summary-card" id="wizard-pre-summary"></div>
        <div class="te-wizard-loading" id="wizard-sugestao-loading" hidden>
          <span class="public-search-status__spinner" aria-hidden="true"></span>
          <p>${staffWizard ? 'A preparar sugestões…' : 'A preparar o teu plano de viagem...'}</p>
        </div>
        <button type="button" class="btn btn-primary te-wizard-create-btn" id="wizard-create-sugestao">${staffWizard ? 'Gerar plano com IA (opcional)' : 'Criar plano de viagem'}</button>
      </section>

      <section class="te-wizard-step te-wizard-card" data-wizard-step="5" hidden>
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
  if (isStaffOfferMode(form)) {
    initStaffOfferWizardActions(container);
  }
}

function buildMinimalOfferSugestao(meta, form) {
  const origem = meta?.origem || '';
  const destino = meta?.destino || '';
  const staffMode = isStaffOfferMode(form);
  return {
    titulo: origem && destino ? `${origem} → ${destino}` : (staffMode ? 'Oferta pública' : 'A sua viagem'),
    descricao: '',
    hotelSugerido: tripSelection.hotel?.nome || '',
    transporteSugerido: '',
    atividades: [],
    precoEstimadoTotal: computeSelectionTotal(),
    resumoFinal: staffMode ? 'Oferta criada pela equipa TravelExplorer.' : 'Reserva com os componentes selecionados.',
  };
}

function initStaffOfferWizardActions(container) {
  const step4 = container.querySelector('[data-wizard-step="4"]');
  const createBtn = container.querySelector('#wizard-create-sugestao');
  if (!step4 || !createBtn || step4.querySelector('#wizard-publish-offer-preview')) {
    return;
  }
  const previewBtn = document.createElement('button');
  previewBtn.type = 'button';
  previewBtn.className = 'btn btn-primary te-wizard-create-btn';
  previewBtn.id = 'wizard-publish-offer-preview';
  previewBtn.textContent = 'Continuar para publicar';
  createBtn.insertAdjacentElement('afterend', previewBtn);
  previewBtn.addEventListener('click', () => {
    tripSelection.sugestao = buildMinimalOfferSugestao(container.__meta, container.__form);
    renderFinalPackage(container);
    goToWizardStep(container, 5);
  });
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
    const ratingMeta = formatHotelRatingMeta(hotel);
    const hotelLabel = formatHotelLabel(hotel);
    const metaLine = ratingMeta ? `<p class="te-hotel-card__meta">${escapeHtml(ratingMeta)}</p>` : '';
    const categoryLine = !ratingMeta && hotelLabel ? `<p class="te-hotel-card__category">${escapeHtml(hotelLabel)}</p>` : '';
    const chips = renderHotelAmenityChips(hotel.amenities, 3);
    const visualInner = imgSrc
      ? `<img class="te-hotel-card__photo" src="${escapeHtml(imgSrc)}" alt="" loading="lazy" decoding="async" referrerpolicy="no-referrer" onerror="this.style.display='none'"><div class="te-hotel-card__shade"></div>`
      : '<div class="te-hotel-card__shade te-hotel-card__shade--soft"></div>';
    const descText = decodeApiText(hotel.descricaoCurta || hotel.descricao || '');
    return `
      <article class="te-hotel-card te-selectable" data-hotel-id="${id}">
        <div class="te-hotel-card__visual" style="${gradientStyle}">
          ${visualInner}
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
  const segs = Array.isArray(voo?.segmentos) ? voo.segmentos.filter((s) => s && String(s.origem || s.destino || '').trim()) : [];
  if (segs.length > 1) {
    const n = segs.length - 1;
    if (n === 1) return '1 escala';
    return `${n} escalas`;
  }
  return 'Direto';
}

function getClientSaveLabel(form) {
  const custom = form?.dataset?.saveLabel;
  if (custom && custom.trim()) return custom.trim();
  return 'Guardar viagem';
}

function renderFlightSelectable(voo, id) {
  const dep = formatTimeDisplay(voo.partida);
  const arr = formatTimeDisplay(voo.chegada);
  const stops = formatFlightStopsLabel(voo);
  const origem = decodeApiText(voo.origem || '').trim();
  const destino = decodeApiText(voo.destino || '').trim();
  const route = origem && destino ? `${origem} → ${destino}` : (origem || destino || 'Rota não disponível');
  const durRaw = decodeApiText(voo.duracao || '').trim();
  const dur = durRaw && durRaw !== '—' && durRaw !== '-' ? durRaw : '';
  const flightNo = decodeApiText(voo.numeroVoo || '').trim();
  const segments = Array.isArray(voo.segmentos)
    ? voo.segmentos.filter((s) => s && String(s.origem || s.destino || s.companhia || '').trim())
    : [];
  const segmentDetails = segments.length > 1
    ? segments.map((seg, idx) => {
        const segDep = formatTimeDisplay(seg.partida);
        const segArr = formatTimeDisplay(seg.chegada);
        const timeLine = [segDep !== 'Horário não disponível' ? `Partida ${segDep}` : '', segArr !== 'Horário não disponível' ? `Chegada ${segArr}` : ''].filter(Boolean).join(' · ');
        return `
        <section>
          <h5>Segmento ${idx + 1}</h5>
          <p><strong>${escapeHtml(decodeApiText(seg.companhia || voo.companhia || ''))}</strong> ${escapeHtml(decodeApiText(seg.numeroVoo || ''))}</p>
          <p>${escapeHtml(decodeApiText(seg.origem || ''))} → ${escapeHtml(decodeApiText(seg.destino || ''))}</p>
          ${timeLine ? `<p>${escapeHtml(timeLine)}</p>` : ''}
        </section>`;
      }).join('')
    : '';
  const depLabel = dep === 'Horário não disponível' ? dep : dep;
  const arrLabel = arr === 'Horário não disponível' ? arr : arr;
  const origLabel = origem || '—';
  const destLabel = destino || '—';
  return `
    <article class="te-flight-card te-selectable" data-flight-id="${id}">
      <div class="te-flight-card__main">
        <div class="te-flight-card__meta">
          <strong class="te-flight-card__airline">${escapeHtml(decodeApiText(voo.companhia || 'Companhia'))}</strong>
          ${flightNo ? `<span class="te-flight-card__flightno">${escapeHtml(flightNo)}</span>` : ''}
        </div>
        <div class="te-flight-card__route">
          <span class="te-flight-card__badge">${escapeHtml(stops)}</span>
          <div class="te-flight-card__route-times">
            <span class="te-flight-card__endpoint"><strong>${escapeHtml(origLabel)}</strong> ${escapeHtml(depLabel)}</span>
            <span class="te-flight-card__arrow">→</span>
            <span class="te-flight-card__endpoint"><strong>${escapeHtml(destLabel)}</strong> ${escapeHtml(arrLabel)}</span>
          </div>
          ${dur ? `<span class="te-flight-card__duration">${escapeHtml(dur)}</span>` : ''}
        </div>
        <div class="te-flight-card__actions">
          <div class="te-flight-card__price">${formatEuro(voo.precoTotal)}</div>
          <button type="button" class="btn btn-secondary te-select-btn" data-select-flight="${id}">Selecionar</button>
        </div>
      </div>
      <div class="te-flight-expand" id="${id}" hidden>
        <button type="button" class="btn btn-ghost te-flight-card__details" data-toggle-details="${id}">Detalhes</button>
        <div class="te-detail-sections te-detail-sections--inline">
          <section><h5>Origem</h5><p>${escapeHtml(decodeApiText(voo.aeroportoOrigem || voo.origem || ''))}</p></section>
          <section><h5>Destino</h5><p>${escapeHtml(decodeApiText(voo.aeroportoDestino || voo.destino || ''))}</p></section>
          <section><h5>Partida</h5><p>${escapeHtml(formatDateTimeDisplay(voo.partida))}</p></section>
          <section><h5>Chegada</h5><p>${escapeHtml(formatDateTimeDisplay(voo.chegada))}</p></section>
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
  const categoryLine = !ratingMeta && hotelLabel ? `<span class="te-hotel-detail__category">${escapeHtml(hotelLabel)}</span>` : '';
  const zoneLine = hotel.zona ? `<p class="te-hotel-detail__zone">${escapeHtml(decodeApiText(hotel.zona))}</p>` : '';
  const priceLine = hotel.precoEstimado ? `<p class="te-hotel-detail__price">${formatEuro(hotel.precoEstimado)} <small>estimado</small></p>` : '';
  const chips = renderHotelAmenityChips(hotel.amenities, 8).replace('te-hotel-card__chips', 'te-hotel-detail__chips');
  const desc = decodeApiText(hotel.descricao || hotel.descricaoCurta || '');
  const descLine = desc ? `<p class="te-hotel-detail__desc">${escapeHtml(desc)}</p>` : '';
  const metaRow = [ratingLine, categoryLine].filter(Boolean).join(' · ');
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
    <p>${escapeHtml(decodeApiText(voo.origem))} ${escapeHtml(formatTimeDisplay(voo.partida))} → ${escapeHtml(decodeApiText(voo.destino))} ${escapeHtml(formatTimeDisplay(voo.chegada))}</p>
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
      if (isStaffOfferMode(form)) {
        tripSelection.sugestao = buildMinimalOfferSugestao(meta, form);
        renderFinalPackage(container);
        goToWizardStep(container, 5);
      } else {
        const preSummary = container.querySelector('#wizard-pre-summary');
        if (preSummary) {
          preSummary.insertAdjacentHTML('beforeend', '<p class="te-empty">Não foi possível gerar o plano automático. Tenta novamente.</p>');
        }
      }
      return;
    }
    tripSelection.sugestao = data.sugestao;
    renderFinalPackage(container);
    goToWizardStep(container, 5);
  } catch (err) {
    if (isStaffOfferMode(form)) {
      tripSelection.sugestao = buildMinimalOfferSugestao(meta, form);
      renderFinalPackage(container);
      goToWizardStep(container, 5);
    }
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
    <p>${escapeHtml(decodeApiText(voo.origem))} ${escapeHtml(formatTimeDisplay(voo.partida))} → ${escapeHtml(decodeApiText(voo.destino))} ${escapeHtml(formatTimeDisplay(voo.chegada))}</p>
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

  const staffMode = isStaffOfferMode(container.__form);
  const saveLabel = staffMode ? 'Publicar oferta' : getClientSaveLabel(container.__form);
  const totalSelecionado = computeSelectionTotal();

  const finalWrapClass = staffMode ? 'te-summary-card te-package-card te-package-card--final' : 'te-package-card te-package-card--final';
  target.innerHTML = `
    <article class="${finalWrapClass}">
      <div class="te-package-card__hero te-package-card__hero--large" style="${gradientStyle}">
        <span class="te-package-card__label">${staffMode ? 'Oferta pública' : 'Plano de viagem personalizado'}</span>
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
          <span>Total com componentes selecionados</span>
          <strong>${formatEuro(totalSelecionado)}</strong>
          <small>Soma de voos, alojamento e transporte escolhidos</small>
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
          <button type="button" class="btn btn-primary" id="save-trip-btn">${escapeHtml(saveLabel)}</button>
        </div>
      </div>
    </article>
  `;

  target.querySelector('#save-trip-btn')?.addEventListener('click', () => {
    openSaveTripModal(container);
  });
}

function computeSelectionTotal() {
  let sum = 0;
  if (tripSelection.flightIda) sum += Number(tripSelection.flightIda.precoTotal) || 0;
  if (tripSelection.flightRegresso) sum += Number(tripSelection.flightRegresso.precoTotal) || 0;
  if (tripSelection.hotel) sum += Number(tripSelection.hotel.precoEstimado) || 0;
  const transporte = tripSelection.sugestao?.transporte;
  if (transporte && Number(transporte.precoEstimado) > 0) {
    sum += Number(transporte.precoEstimado);
  }
  return sum;
}

function buildGuardarPayload(container) {
  const meta = container.__meta;
  const form = container.__form;
  if (!meta || !tripSelection.flightIda || !tripSelection.flightRegresso) {
    return null;
  }
  let sugestao = tripSelection.sugestao;
  if (!sugestao) {
    sugestao = buildMinimalOfferSugestao(meta, form);
  }
  if (!sugestao) {
    return null;
  }
  if (!isStaffOfferMode(form) && form?.dataset.clienteLoggedIn !== 'true') {
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
    sugestao,
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
  const staffMode = isStaffOfferMode(container.__form);
  const title = container.querySelector('#save-trip-modal-title');
  if (title) {
    title.textContent = staffMode ? 'Publicar oferta' : getClientSaveLabel(container.__form);
  }
  if (body) {
    body.innerHTML = staffMode
      ? '<p>Confirma a publicação desta oferta na área pública. Não será criada nenhuma reserva de cliente.</p>'
      : '<p>A tua viagem será guardada como reserva na área de cliente.</p>';
  }
  if (actions) actions.hidden = false;
  if (confirmBtn) {
    confirmBtn.hidden = false;
    confirmBtn.disabled = false;
    confirmBtn.textContent = staffMode ? 'Publicar' : 'Guardar';
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
  if (isStaffOfferMode(form) && url && /\/guardar-viagem\/?$/.test(url)) {
    setSaveTripModalState(
      container,
      '<p>Apenas clientes podem criar reservas.</p>',
      { hideActions: true, hideConfirm: true },
    );
    return;
  }
  const payload = buildGuardarPayload(container);
  const saveBtn = container.querySelector('#save-trip-btn');
  const confirmBtn = container.querySelector('#save-trip-modal-confirm');

  if (!url || !payload) {
    const hint = isStaffOfferMode(form)
      ? 'Seleciona os voos de ida e regresso (e opcionalmente alojamento) antes de publicar.'
      : 'Não foi possível preparar os dados da viagem.';
    setSaveTripModalState(container, `<p class="te-empty">${escapeHtml(hint)}</p>`, { hideActions: true, hideConfirm: true });
    return;
  }

  if (!isStaffOfferMode(form) && form?.dataset.clienteLoggedIn !== 'true') {
    setSaveTripModalState(
      container,
      '<p>As reservas de cliente só podem ser guardadas com sessão de cliente.</p>',
      { hideActions: true, hideConfirm: true },
    );
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
  const savingMsg = isStaffOfferMode(form) ? 'A publicar a oferta…' : 'A guardar a tua reserva…';
  setSaveTripModalState(container, `<p>${escapeHtml(savingMsg)}</p>`, { disableConfirm: true });

  try {
    const response = await fetch(url, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json', Accept: 'application/json' },
      credentials: 'same-origin',
      body: JSON.stringify(payload),
    });
    const data = await response.json();

    if (data?.permissionDenied) {
      setSaveTripModalState(
        container,
        `<p class="te-modal__error">${escapeHtml(data.message || 'Não tens permissão para criar ofertas.')}</p>`,
        { hideActions: true, hideConfirm: true },
      );
      return;
    }

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

    const basePath = url.replace(/\/guardar-(viagem|oferta)\/?$/, '');
    const staffMode = isStaffOfferMode(form);
    const successUrl = staffMode && window.TE_STAFF_OFFER_SUCCESS_URL
      ? window.TE_STAFF_OFFER_SUCCESS_URL
      : `${basePath}/index.jsp?page=customer-dashboard`;
    if (staffMode && window.TE_STAFF_OFFER_SUCCESS_URL) {
      window.location.assign(window.TE_STAFF_OFFER_SUCCESS_URL);
      return;
    }
    if (!staffMode && data?.ok) {
      const basePath = url.replace(/\/guardar-(viagem|oferta)\/?$/, '');
      window.location.assign(`${basePath}/index.jsp?page=my-reservations&success=created`);
      return;
    }
    const successTitle = staffMode ? 'Oferta criada' : 'Reserva guardada';
    const successCta = staffMode ? 'Ver ofertas' : 'Ver área de cliente';
    setSaveTripModalState(
      container,
      `<h4>${escapeHtml(successTitle)}</h4><p>${escapeHtml(data.message || '')}</p><p><a class="btn btn-primary" href="${escapeHtml(successUrl)}">${escapeHtml(successCta)}</a></p>`,
      { hideActions: true, hideConfirm: true },
    );
    if (saveBtn) saveBtn.textContent = staffMode ? 'Oferta guardada' : 'Reserva guardada';
  } catch (err) {
    const failMsg = isStaffOfferMode(form)
      ? 'Não foi possível publicar a oferta. Verifica a ligação e tenta novamente.'
      : 'Não foi possível guardar a viagem. Tenta novamente.';
    setSaveTripModalState(
      container,
      `<p>${escapeHtml(failMsg)}</p>`,
      { hideActions: true, hideConfirm: true },
    );
  } finally {
    if (confirmBtn && !confirmBtn.hidden) {
      confirmBtn.disabled = false;
      confirmBtn.textContent = 'Guardar';
    }
    if (saveBtn && saveBtn.textContent === 'A guardar…') {
      saveBtn.disabled = false;
      saveBtn.textContent = isStaffOfferMode(form) ? 'Publicar oferta' : getClientSaveLabel(form);
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
  if (!value) return '';
  const normalized = String(value).replace(' ', 'T');
  const date = new Date(normalized);
  let out = '';
  if (Number.isNaN(date.getTime())) {
    const parts = String(value).split(' ');
    out = parts.length > 1 ? parts[1].slice(0, 5) : String(value).trim();
  } else {
    out = new Intl.DateTimeFormat('pt-PT', { hour: '2-digit', minute: '2-digit' }).format(date);
  }
  if (!out || out === '00:00' || out === '24:00') return '';
  return out;
}

function formatTimeDisplay(value) {
  const t = formatTimeShort(value);
  return t || 'Horário não disponível';
}

function formatDateTimeDisplay(value) {
  if (!value) return 'Horário não disponível';
  const normalized = String(value).replace(' ', 'T');
  const date = new Date(normalized);
  if (Number.isNaN(date.getTime())) return decodeApiText(value) || 'Horário não disponível';
  const formatted = new Intl.DateTimeFormat('pt-PT', {
    day: '2-digit', month: 'short', hour: '2-digit', minute: '2-digit',
  }).format(date);
  if (formatted.includes('00:00') && !String(value).match(/[1-9]\d*:\d{2}/)) {
    return 'Horário não disponível';
  }
  return formatted;
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
