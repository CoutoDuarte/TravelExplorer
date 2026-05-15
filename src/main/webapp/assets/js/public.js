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

  setSearchLoading(true, loadingEl, submitBtn);

  const params = new URLSearchParams({
    origem,
    destino,
    data_partida: dataPartida,
    data_regresso: dataRegresso,
    adultos,
    criancas,
  });

  try {
    const response = await fetch(`${form.dataset.apiUrl}?${params}`, {
      method: 'GET',
      headers: { Accept: 'application/json' },
      credentials: 'same-origin',
    });
    const data = await response.json();

    if (!data || data.ok !== true) {
      if (data?.authRequired) {
        showElement(loginEl);
        loginEl?.scrollIntoView({ behavior: 'smooth', block: 'nearest' });
      } else {
        showSearchError(errorEl, resultsEl, loadingEl);
      }
      return;
    }

    renderSearchResults(resultsEl, data, {
      origemLabel: origemDisplay?.value || data.origem,
      destinoLabel: destinoDisplay?.value || data.destino,
      dataPartida,
      dataRegresso,
      adultos,
      criancas,
    });
    showElement(resultsEl);
    resultsEl.scrollIntoView({ behavior: 'smooth', block: 'nearest' });
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

function showSearchError(errorEl, resultsEl, loadingEl) {
  hideElement(loadingEl);
  hideElement(resultsEl);
  if (resultsEl) {
    resultsEl.innerHTML = '';
    resultsEl.classList.remove('te-booking-panel--active');
  }
  document.getElementById('hero-studio')?.classList.remove('hero-studio--results');
  showElement(errorEl);
  errorEl?.scrollIntoView({ behavior: 'smooth', block: 'nearest' });
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
  flightIdaId: null,
  flightIda: null,
  flightRegressoId: null,
  flightRegresso: null,
};

function resetTripSelection() {
  tripSelection.hotelId = null;
  tripSelection.hotel = null;
  tripSelection.flightIdaId = null;
  tripSelection.flightIda = null;
  tripSelection.flightRegressoId = null;
  tripSelection.flightRegresso = null;
}

function renderSearchResults(container, data, meta) {
  resetTripSelection();
  const sugestao = data.sugestao || {};
  const voosIda = pickFlights(data.voosIda, data.voos);
  const voosRegresso = pickFlights(data.voosRegresso, []);
  const hotels = buildHotelList(data);
  const hasRegresso = voosRegresso.length > 0;
  const routeLabel = `${escapeHtml(decodeApiText(data.origem || meta.origemLabel))} → ${escapeHtml(decodeApiText(data.destino || meta.destinoLabel))}`;
  const datesLabel = `${formatDisplayDate(data.dataPartida || meta.dataPartida)} – ${formatDisplayDate(data.dataRegresso || meta.dataRegresso)}`;
  const travellersLabel = buildPassengerSummary(Number(data.adultos), Number(data.criancas));
  const destLabel = decodeApiText(meta.destinoLabel || data.destino || 'Destino');
  const gradientStyle = buildGradientStyle(destLabel, 0);

  container.__sugestao = sugestao;
  container.__voosIda = voosIda;
  container.__voosRegresso = voosRegresso;
  container.__hotels = hotels;
  container.classList.add('te-booking-panel--active');
  document.getElementById('hero-studio')?.classList.add('hero-studio--results');

  const activitiesHtml = renderActivitiesList(sugestao.atividades);
  const transportText = decodeApiText(sugestao.transporteSugerido || '');

  container.innerHTML = `
    <header class="te-booking-head">
      <div class="te-booking-head__route">${routeLabel}</div>
      <div class="te-booking-head__meta">
        <span class="te-chip">${datesLabel}</span>
        <span class="te-chip">${escapeHtml(travellersLabel)}</span>
      </div>
    </header>

    <div class="te-booking-layout" data-has-regresso="${hasRegresso}">
      <article class="te-package-card">
        <div class="te-package-card__hero" style="${gradientStyle}">
          <span class="te-package-card__label">Sugestão da agência</span>
          <h3>${escapeHtml(decodeApiText(sugestao.titulo || 'A sua viagem'))}</h3>
          <p class="te-package-card__route">${routeLabel}</p>
        </div>
        <div class="te-package-card__body">
          <p class="te-package-card__desc">${escapeHtml(decodeApiText(sugestao.descricao || ''))}</p>
          <div class="te-package-card__price">
            <span>Preço estimado do pacote</span>
            <strong>${formatEuro(sugestao.precoEstimadoTotal)}</strong>
            <small>Valores indicativos; confirmação final na fase de reservas</small>
          </div>
          ${activitiesHtml}
          ${transportText ? `<p class="te-package-card__transport">${escapeHtml(transportText)}</p>` : ''}
          <div class="te-package-card__selections">
            <div class="te-selection-block" id="selected-hotel-summary">
              <h4>Alojamento escolhido</h4>
              <p class="te-selection-block__empty">Ainda não selecionou alojamento.</p>
            </div>
            <div class="te-selection-block" id="selected-flight-ida-summary">
              <h4>Voo de ida escolhido</h4>
              <p class="te-selection-block__empty">Ainda não selecionou o voo de ida.</p>
            </div>
            <div class="te-selection-block" id="selected-flight-regresso-summary">
              <h4>Voo de regresso escolhido</h4>
              <p class="te-selection-block__empty">${hasRegresso ? 'Ainda não selecionou o voo de regresso.' : 'Sem regresso nesta pesquisa.'}</p>
            </div>
          </div>
          <div class="te-package-card__actions">
            <button type="button" class="btn btn-primary" id="save-trip-btn" disabled>Guardar viagem</button>
            <p class="te-package-card__hint" id="save-trip-hint">Escolha alojamento e voos para continuar.</p>
          </div>
        </div>
      </article>

      <div class="te-booking-choices">
        <section class="te-hotels" id="section-hotels">
          <h3 class="te-section-title">Opções de alojamento</h3>
          <div class="te-hotels__grid">${renderHotelCardsSelectable(hotels)}</div>
        </section>

        <section class="te-flights" id="section-flights">
          <div class="te-flights__head">
            <h3 class="te-section-title">Escolher voos</h3>
            <div class="te-segmented" role="tablist">
              <button type="button" class="te-segmented__btn is-active" data-flight-tab="ida" aria-selected="true">Ida (${voosIda.length})</button>
              <button type="button" class="te-segmented__btn" data-flight-tab="regresso" aria-selected="false">Regresso (${voosRegresso.length})</button>
            </div>
          </div>
          <div class="te-flights__panel" data-flight-panel="ida">
            ${renderFlightListSelectable(voosIda, 'ida', 'Não foram encontrados voos de ida para esta data.')}
          </div>
          <div class="te-flights__panel" data-flight-panel="regresso" hidden>
            ${renderFlightListSelectable(voosRegresso, 'regresso', hasRegresso ? 'Não foram encontradas opções de regresso para esta data.' : 'Sem voos de regresso nesta pesquisa.')}
          </div>
        </section>
      </div>
    </div>

    <div class="te-modal" id="save-trip-modal" hidden>
      <div class="te-modal__backdrop" data-close-modal></div>
      <div class="te-modal__dialog" role="dialog" aria-labelledby="save-trip-modal-title">
        <h3 id="save-trip-modal-title">Guardar viagem</h3>
        <p>Esta funcionalidade será ligada às reservas na próxima fase.</p>
        <button type="button" class="btn btn-primary" data-close-modal>Entendido</button>
      </div>
    </div>
  `;

  initTripSelectionUI(container, { hasRegresso });
}

function safeHotelImageUrl(raw) {
  if (raw == null || typeof raw !== 'string') return '';
  const u = raw.trim();
  return /^https?:\/\//i.test(u) ? u : '';
}

function renderHotelCardsSelectable(hotels) {
  if (!hotels.length) {
    return '<p class="te-empty">Sem opções de alojamento disponíveis.</p>';
  }
  return hotels.map((hotel, index) => {
    const id = `hotel-${index}`;
    const gradientStyle = buildGradientStyle(hotel.nome || hotel.zona || 'hotel', index + 1);
    const imgSrc = safeHotelImageUrl(hotel.imagemUrl);
    const rating = Number(hotel.rating);
    const reviews = Number(hotel.reviews);
    const metaParts = [];
    if (!Number.isNaN(rating) && rating > 0) metaParts.push(`${rating.toFixed(1)} ★`);
    if (!Number.isNaN(reviews) && reviews > 0) metaParts.push(`${reviews} avaliações`);
    const metaLine = metaParts.length ? `<p class="te-hotel-card__meta">${escapeHtml(metaParts.join(' · '))}</p>` : '';
    const amenitiesLine = hotel.amenities ? `<p class="te-hotel-card__amenities">${escapeHtml(decodeApiText(hotel.amenities))}</p>` : '';
    const visualInner = imgSrc
      ? `<img class="te-hotel-card__photo" src="${escapeHtml(imgSrc)}" alt="" loading="lazy" decoding="async" referrerpolicy="no-referrer" onerror="this.style.display='none'"><div class="te-hotel-card__shade"></div>`
      : '<div class="te-hotel-card__shade te-hotel-card__shade--soft"></div>';
    const descText = decodeApiText(hotel.descricaoCurta || hotel.descricao || '');
    return `
      <article class="te-hotel-card te-selectable" data-hotel-id="${id}">
        <div class="te-hotel-card__visual" style="${gradientStyle}">
          ${visualInner}
          <span class="te-hotel-card__visual-badge">${escapeHtml(decodeApiText(hotel.categoria || 'Opção sugerida'))}</span>
          <strong class="te-hotel-card__visual-title">${escapeHtml(decodeApiText(hotel.nome))}</strong>
        </div>
        <div class="te-hotel-card__body">
          <p class="te-hotel-card__zone">${escapeHtml(decodeApiText(hotel.zona || 'Zona recomendada'))}</p>
          ${metaLine}
          <p class="te-hotel-card__desc">${escapeHtml(descText)}</p>
          ${amenitiesLine}
          <div class="te-hotel-card__footer">
            <span class="te-hotel-card__price">${formatEuro(hotel.precoEstimado)} <small>estimado</small></span>
            <button type="button" class="btn btn-secondary te-select-btn" data-select-hotel="${id}">Selecionar</button>
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

function renderFlightSelectable(voo, id) {
  const dep = formatTimeShort(voo.partida);
  const arr = formatTimeShort(voo.chegada);
  return `
    <article class="te-flight-row te-selectable" data-flight-id="${id}">
      <div class="te-flight-row__main">
        <div class="te-flight-row__airline">
          <strong>${escapeHtml(decodeApiText(voo.companhia || 'Companhia'))}</strong>
          <span>${escapeHtml(decodeApiText(voo.numeroVoo || ''))}</span>
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
          <section><h5>Preço por pessoa</h5><p>${formatEuro(voo.precoPorPessoa)}</p></section>
        </div>
      </div>
    </article>
  `;
}

function initTripSelectionUI(container, options) {
  const { hasRegresso } = options;

  bindFlightTabs(container);
  bindDetailsToggles(container);

  container.querySelectorAll('[data-select-hotel]').forEach((btn) => {
    btn.addEventListener('click', (event) => {
      event.stopPropagation();
      const id = btn.getAttribute('data-select-hotel');
      const index = parseInt(id.split('-')[1], 10);
      const hotel = container.__hotels?.[index];
      if (!hotel) return;
      tripSelection.hotelId = id;
      tripSelection.hotel = hotel;
      container.querySelectorAll('[data-hotel-id]').forEach((el) => {
        const selected = el.getAttribute('data-hotel-id') === id;
        el.classList.toggle('is-selected', selected);
        const selectBtn = el.querySelector('[data-select-hotel]');
        if (selectBtn) selectBtn.textContent = selected ? 'Selecionado' : 'Selecionar';
      });
      updateSelectionSummaries(container, hasRegresso);
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
      const panelName = isIda ? 'ida' : 'regresso';
      if (isIda) {
        tripSelection.flightIdaId = id;
        tripSelection.flightIda = voo;
      } else {
        tripSelection.flightRegressoId = id;
        tripSelection.flightRegresso = voo;
      }
      const panel = container.querySelector(`[data-flight-panel="${panelName}"]`);
      panel?.querySelectorAll('[data-flight-id]').forEach((el) => {
        const selected = el.getAttribute('data-flight-id') === id;
        el.classList.toggle('is-selected', selected);
        const selectBtn = el.querySelector('[data-select-flight]');
        if (selectBtn) selectBtn.textContent = selected ? 'Selecionado' : 'Selecionar';
      });
      updateSelectionSummaries(container, hasRegresso);
    });
  });

  container.querySelector('#save-trip-btn')?.addEventListener('click', () => {
    const btn = container.querySelector('#save-trip-btn');
    if (btn?.disabled) return;
    const modal = container.querySelector('#save-trip-modal');
    if (modal) modal.hidden = false;
  });

  container.querySelectorAll('[data-close-modal]').forEach((el) => {
    el.addEventListener('click', () => {
      const modal = container.querySelector('#save-trip-modal');
      if (modal) modal.hidden = true;
    });
  });
}

function updateSelectionSummaries(container, hasRegresso) {
  const hotelSummary = container.querySelector('#selected-hotel-summary');
  const idaSummary = container.querySelector('#selected-flight-ida-summary');
  const regressoSummary = container.querySelector('#selected-flight-regresso-summary');
  const saveBtn = container.querySelector('#save-trip-btn');
  const hint = container.querySelector('#save-trip-hint');

  if (hotelSummary) {
    if (tripSelection.hotel) {
      const rh = Number(tripSelection.hotel.rating);
      const rr = Number(tripSelection.hotel.reviews);
      const ratingFrag = !Number.isNaN(rh) && rh > 0 ? ` · ${rh.toFixed(1)} ★` : '';
      const reviewsFrag = !Number.isNaN(rr) && rr > 0 ? ` · ${rr} avaliações` : '';
      hotelSummary.innerHTML = `
        <h4>Alojamento escolhido</h4>
        <p><strong>${escapeHtml(decodeApiText(tripSelection.hotel.nome))}</strong></p>
        <p>${escapeHtml(decodeApiText(tripSelection.hotel.zona || ''))} · ${escapeHtml(decodeApiText(tripSelection.hotel.categoria || ''))}${ratingFrag}${reviewsFrag}</p>
        <p>${formatEuro(tripSelection.hotel.precoEstimado)} estimado</p>
      `;
    } else {
      hotelSummary.innerHTML = '<h4>Alojamento escolhido</h4><p class="te-selection-block__empty">Ainda não selecionou alojamento.</p>';
    }
  }

  if (idaSummary) {
    if (tripSelection.flightIda) {
      const v = tripSelection.flightIda;
      idaSummary.innerHTML = `
        <h4>Voo de ida escolhido</h4>
        <p><strong>${escapeHtml(decodeApiText(v.companhia || ''))} ${escapeHtml(decodeApiText(v.numeroVoo || ''))}</strong></p>
        <p>${escapeHtml(decodeApiText(v.origem))} ${escapeHtml(formatTimeShort(v.partida))} → ${escapeHtml(decodeApiText(v.destino))} ${escapeHtml(formatTimeShort(v.chegada))}</p>
        <p>${formatEuro(v.precoTotal)}</p>
      `;
    } else {
      idaSummary.innerHTML = '<h4>Voo de ida escolhido</h4><p class="te-selection-block__empty">Ainda não selecionou o voo de ida.</p>';
    }
  }

  if (regressoSummary) {
    if (!hasRegresso) {
      regressoSummary.innerHTML = '<h4>Voo de regresso escolhido</h4><p class="te-selection-block__empty">Sem regresso nesta pesquisa.</p>';
    } else if (tripSelection.flightRegresso) {
      const v = tripSelection.flightRegresso;
      regressoSummary.innerHTML = `
        <h4>Voo de regresso escolhido</h4>
        <p><strong>${escapeHtml(decodeApiText(v.companhia || ''))} ${escapeHtml(decodeApiText(v.numeroVoo || ''))}</strong></p>
        <p>${escapeHtml(decodeApiText(v.origem))} ${escapeHtml(formatTimeShort(v.partida))} → ${escapeHtml(decodeApiText(v.destino))} ${escapeHtml(formatTimeShort(v.chegada))}</p>
        <p>${formatEuro(v.precoTotal)}</p>
      `;
    } else {
      regressoSummary.innerHTML = '<h4>Voo de regresso escolhido</h4><p class="te-selection-block__empty">Ainda não selecionou o voo de regresso.</p>';
    }
  }

  const complete = tripSelection.hotel
    && tripSelection.flightIda
    && (!hasRegresso || tripSelection.flightRegresso);

  if (saveBtn) saveBtn.disabled = !complete;
  if (hint) {
    hint.textContent = complete
      ? 'Pronto para guardar quando a ligação às reservas estiver ativa.'
      : 'Escolha alojamento e voos para continuar.';
  }
}

function renderActivitiesList(atividades) {
  if (!Array.isArray(atividades) || !atividades.length) return '';
  const items = atividades
    .slice(0, 5)
    .map((item) => `<li>${escapeHtml(decodeApiText(item))}</li>`)
    .join('');
  return `<ul class="te-package-card__activities">${items}</ul>`;
}

function buildHotelList(data) {
  const sugestao = (data && data.sugestao) || {};
  const fromRoot = data && Array.isArray(data.hoteisOpcoes) ? data.hoteisOpcoes : null;
  const fromSug = Array.isArray(sugestao.hoteisOpcoes) ? sugestao.hoteisOpcoes : null;
  const raw = fromRoot && fromRoot.length ? fromRoot : fromSug;
  if (Array.isArray(raw) && raw.length) {
    return raw.slice(0, 8);
  }
  if (sugestao.hotelSugerido) {
    return [{
      nome: sugestao.hotelSugerido,
      zona: 'Zona recomendada',
      categoria: 'Opção sugerida',
      descricao: decodeApiText(sugestao.descricao || ''),
      precoEstimado: sugestao.precoEstimadoTotal ? sugestao.precoEstimadoTotal * 0.45 : 0,
    }];
  }
  return [];
}

function bindFlightTabs(container) {
  const buttons = container.querySelectorAll('[data-flight-tab]');
  const panels = container.querySelectorAll('[data-flight-panel]');
  buttons.forEach((button) => {
    button.addEventListener('click', () => {
      const tab = button.getAttribute('data-flight-tab');
      buttons.forEach((btn) => {
        const active = btn.getAttribute('data-flight-tab') === tab;
        btn.classList.toggle('is-active', active);
        btn.setAttribute('aria-selected', String(active));
      });
      panels.forEach((panel) => {
        panel.hidden = panel.getAttribute('data-flight-panel') !== tab;
      });
    });
  });
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
