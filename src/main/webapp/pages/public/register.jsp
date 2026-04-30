<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>

<div class="public-page">
    <section class="public-page__section public-page__section--soft">
        <div class="container content-narrow">
            <div class="surface-block surface-block-xl">
                <div class="section-title">
                    <span class="section-title__eyebrow">Criar conta</span>
                    <h1 class="section-title__heading">Regista-te no TravelExplorer</h1>
                    <p class="section-title__description">
                        Cria a tua conta para guardar ofertas favoritas, acompanhar reservas e aceder à tua área pessoal.
                    </p>
                </div>

                <form class="flow" action="#" method="post" style="margin-top: 2rem;">
                    <div>
                        <label for="registerName">Nome completo</label>
                        <input type="text" id="registerName" name="name" placeholder="Ex.: Filipe Aroso" required>
                    </div>

                    <div>
                        <label for="registerEmail">Email</label>
                        <input type="email" id="registerEmail" name="email" placeholder="Ex.: filipe@email.com" required>
                    </div>

                    <div>
                        <label for="registerPassword">Palavra-passe</label>
                        <input type="password" id="registerPassword" name="password" placeholder="Cria uma palavra-passe" required>
                    </div>

                    <div>
                        <label for="registerConfirmPassword">Confirmar palavra-passe</label>
                        <input type="password" id="registerConfirmPassword" name="confirmPassword" placeholder="Repete a palavra-passe" required>
                    </div>

                    <div>
                        <label for="registerPhone">Telefone</label>
                        <input type="tel" id="registerPhone" name="phone" placeholder="Ex.: 912345678">
                    </div>

                    <div style="display: flex; flex-direction: column; gap: 0.85rem; margin-top: 0.5rem;">
                        <label style="display: inline-flex; align-items: center; gap: 0.5rem; margin-bottom: 0; font-weight: 500;">
                            <input type="checkbox" name="terms" style="width: auto;" required>
                            Aceito os termos e condições
                        </label>

                        <label style="display: inline-flex; align-items: center; gap: 0.5rem; margin-bottom: 0; font-weight: 500;">
                            <input type="checkbox" name="promotions" style="width: auto;">
                            Aceito receber comunicações e promoções
                        </label>
                    </div>

                    <button class="btn btn-primary" type="submit" style="width: 100%; margin-top: 1rem;">
                        Criar conta
                    </button>

                    
                </form>

                <div class="surface-block" style="margin-top: 1.5rem;">
                    <div class="flow">
                        <h2 style="font-size: 1.15rem;">Já tens conta?</h2>
                        <p class="text-muted">
                            Entra com a tua conta para continuar a explorar ofertas e acompanhar as tuas reservas.
                        </p>
                        <a class="btn btn-secondary" href="${pageContext.request.contextPath}/index.jsp?page=login">
                            Ir para o login
                        </a>
                    </div>
                </div>

                <div class="surface-block" style="margin-top: 1.5rem;">
                    <div class="flow">
                        <h2 style="font-size: 1.15rem;">Modo demonstração</h2>
                        <p class="text-muted">
                            Enquanto o registo real ainda não estiver ligado ao backend, podes abrir diretamente as áreas já desenhadas para testar o frontend.
                        </p>

                        <div class="actions-row">
                            <a class="btn btn-primary" href="${pageContext.request.contextPath}/index.jsp?page=customer-dashboard">
                                Ver área de cliente
                            </a>
                            <a class="btn btn-secondary" href="${pageContext.request.contextPath}/index.jsp?page=staff-dashboard">
                                Ver área staff
                            </a>
                        </div>

                        
                    </div>
                </div>
            </div>
        </div>
    </section>
</div>