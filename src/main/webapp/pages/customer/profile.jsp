<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>

<div class="flow customer-shell">
    <jsp:include page="/components/shared/page_header.jsp">
        <jsp:param name="eyebrow" value="Perfil" />
        <jsp:param name="heading" value="A minha conta" />
        <jsp:param name="description" value="Consulta e atualiza os teus dados pessoais e preferências da tua conta." />
    </jsp:include>

    <div class="surface-block surface-block-lg customer-action-panel">
        <form class="flow" action="#" method="post">
            <div class="customer-dashboard-grid">
                <div>
                    <label for="profileName">Nome completo</label>
                    <input type="text" id="profileName" name="name" value="Filipe Aroso">
                </div>

                <div>
                    <label for="profileEmail">Email</label>
                    <input type="email" id="profileEmail" name="email" value="filipe@email.com">
                </div>

                <div>
                    <label for="profilePhone">Telefone</label>
                    <input type="tel" id="profilePhone" name="phone" value="912345678">
                </div>
            </div>

            <div class="customer-dashboard-grid">
                <div>
                    <label for="profilePassword">Nova palavra-passe</label>
                    <input type="password" id="profilePassword" name="password" placeholder="Introduz uma nova palavra-passe">
                </div>

                <div>
                    <label for="profileConfirmPassword">Confirmar palavra-passe</label>
                    <input type="password" id="profileConfirmPassword" name="confirmPassword" placeholder="Repete a nova palavra-passe">
                </div>

                <div>
                    <label for="profileCity">Cidade</label>
                    <input type="text" id="profileCity" name="city" value="Porto">
                </div>
            </div>

            <div class="flow" style="gap: 0.85rem;">
                <label style="display: inline-flex; align-items: center; gap: 0.5rem; margin-bottom: 0; font-weight: 500;">
                    <input type="checkbox" name="promotions" checked style="width: auto;">
                    Quero receber promoções e novidades
                </label>
            </div>

            <div class="actions-row">
                <button class="btn btn-primary" type="submit">Guardar alterações</button>
                <a class="btn btn-secondary" href="${pageContext.request.contextPath}/index.jsp?page=offers">Explorar ofertas</a>
            </div>

            
        </form>
    </div>
</div>
