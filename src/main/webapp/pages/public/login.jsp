<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>

<div class="public-page">
    <section class="public-page__section public-page__section--soft">
        <div class="container content-narrow">
            <div class="surface-block surface-block-xl">
                <div class="section-title">
                    <span class="section-title__eyebrow">Entrar</span>
                    <h1 class="section-title__heading">Acede à tua conta</h1>
                    <p class="section-title__description">
                        Inicia sessão para acompanhar reservas, guardar ofertas favoritas e aceder à tua área pessoal.
                    </p>
                </div>

                <form class="flow" action="#" method="post" style="margin-top: 2rem;">
                    <div>
                        <label for="loginEmail">Email</label>
                        <input type="email" id="loginEmail" name="email" placeholder="Ex.: filipe@email.com" required>
                    </div>

                    <div>
                        <label for="loginPassword">Palavra-passe</label>
                        <input type="password" id="loginPassword" name="password" placeholder="Introduz a tua palavra-passe" required>
                    </div>

                    <div class="actions-row" style="justify-content: space-between; align-items: center; margin-top: 0.5rem;">
                        <label style="display: inline-flex; align-items: center; gap: 0.5rem; margin-bottom: 0; font-weight: 500;">
                            <input type="checkbox" name="remember" style="width: auto;">
                            Manter sessão iniciada
                        </label>

                        <a href="#" class="text-muted">Esqueceste-te da palavra-passe?</a>
                    </div>

                    <button class="btn btn-primary" type="submit" style="width: 100%; margin-top: 1rem;">
                        Entrar
                    </button>

                    
                </form>

                <div class="surface-block" style="margin-top: 1.5rem;">
                    <div class="flow">
                        <h2 style="font-size: 1.15rem;">Ainda não tens conta?</h2>
                        <p class="text-muted">
                            Cria a tua conta para guardar ofertas favoritas e acompanhar futuras reservas.
                        </p>
                        <a class="btn btn-secondary" href="${pageContext.request.contextPath}/index.jsp?page=register">
                            Criar conta
                        </a>
                    </div>
                </div>

                <div class="surface-block" style="margin-top: 1.5rem;">
                    <div class="flow">
                        <h2 style="font-size: 1.15rem;">Modo demonstração</h2>
                        <p class="text-muted">
                            Enquanto o backend não estiver ligado, podes entrar diretamente nas áreas já desenhadas para testar a navegação e o visual.
                        </p>

                        <div class="actions-row">
                            <a class="btn btn-primary" href="${pageContext.request.contextPath}/index.jsp?page=customer-dashboard">
                                Entrar como cliente
                            </a>
                            <a class="btn btn-secondary" href="${pageContext.request.contextPath}/index.jsp?page=staff-dashboard">
                                Entrar como staff
                            </a>
                        </div>

                        
                    </div>
                </div>
            </div>
        </div>
    </section>
</div>