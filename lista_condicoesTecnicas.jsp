<%@ page isELIgnored="false"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<%@ taglib uri="/WEB-INF/tld/struts-logic.tld" prefix="logic"%>
<!DOCTYPE html>
<html lang="en">
<head>
	<title>Biblioteca Virtual - Diretrizes Cl&iacute;nicas</title>
	<meta http-equiv="X-UA-Compatible" content="IE=edge" />
	<link href="<%=request.getContextPath()%>/view/resources/css/auditorialupa.css" rel="stylesheet" type="text/css" />
	<script type="text/javascript" src="<%=request.getContextPath()%>/js/jquery/jquery-1.4.4.js"></script>
	<script type="text/javascript">
		$(document).ready(function() {
			$("#lupa .aba:first").addClass("selected");
			$("#lupa .lp_conteudo:first").show();
			$("#lupa .aba").click(function() {
				$(".aba").removeClass("selected");
				$(this).addClass("selected");
				var index = $(this).index();
				index++;
				$("#lupa .lp_conteudo").hide();
				$("#lupa .lp_conteudo:nth-child(" + index + ")").show();
			});
			
			$("#aplicarRegras").click(function(){
				var glosa = '';
				var descricaoGlosa = '';
				var observacaoCompleta = '';

				$("input:checkbox[name=listaRegra]:checked").each(function(){
					var tr = $(this).closest('tr');

					if (glosa == '') {
						glosa = tr.find('.regra_glosa').attr('innerHTML');
						descricaoGlosa = tr.find('.regra_glosa').attr('title');
					}

					var observacao = tr.find('.regra_observacao').attr('innerHTML');

					if (observacao !== undefined && observacao !== '-') {
						if (observacaoCompleta !== '') {
							observacaoCompleta += ' / ';
						}
						observacaoCompleta += observacao
					}
				});
				if (glosa == "") {
					alert("Selecionar ao menos uma regra para aplicar.");
				} else {
					incluirDiretrizRegra($("#nrOrdem").val(), glosa, descricaoGlosa, observacaoCompleta.trim());
				}
			});
			$("input:checkbox[name=listaRegra]").click(function(){
				var tr = $(this).closest('tr');
				if ($(this).is(":checked")) {
					tr.addClass("regra_selecionada");
				} else {
					tr.removeClass("regra_selecionada");
				}
			});
		});
		var popup = null;
		function abrirNovaTelaDiretriz(codigoMidia){
			var height = screen.height;
        	popup = window.open("${pageContext.request.contextPath}/tratarImagem.do?method=abrirImagemDiretriz&codigoMidia=" + codigoMidia,
        		'Imagem','top=-40,left=-25,toolbars=no,resizable=yes,scrollbars=yes,status=yes,width='+window.screen.availWidth+',height='+height);
        }
        function pesquisarRegrasAuditoriaEnter(event) {
        	if(event.key == 'Enter') {
        		pesquisarRegrasAuditoria();
		    }
        }
        function pesquisarRegrasAuditoria() {
			var codigoEvento = $("#codigoEvento").text();
			var buscaRapida = $("#buscaRapida").val();

			limparTabelaRegrasAuditoria();
			buscarRegrasAuditoria(codigoEvento, buscaRapida);
		}
		function limparPesquisarRegrasAuditoria() {
			$("#buscaRapida").val("");
			pesquisarRegrasAuditoria();
		}
        function limparTabelaRegrasAuditoria() {
			$("#regrasAud").empty();
		}
        function buscarRegrasAuditoria(codigoEvento, buscaRapida) {
			$.ajax({
				type: "POST",
				dataType: "json",
				async:false,
				global: false,
				url: "auditoria.do",
				data: {
					method:"buscarRegrasAuditoria",
					codigoEvento: codigoEvento,
					buscaRapida: buscaRapida
				},
				success: function(obj) {
					if (!obj) {
						alert("N�o foi poss�vel buscar as Regras de Auditoria.")
						return;
					}

					var tbody = $("#regrasAud");

					var checkbox = "<input type='checkbox' name='listaRegra' onchange='alterarSelecaoRegra(this)' />";

					var tdCenter = document.createElement('td');
					tdCenter.classList.add("center");

					var tdWrap = document.createElement('td');
					tdWrap.classList.add("wrap");

					for (var i = 0; i < obj.length; i++) {
						var chk = tdCenter.cloneNode();
						chk.innerHTML = checkbox;

						var sit = tdWrap.cloneNode();
						sit.innerHTML = obj[i].situacao;

						var span = document.createElement('span');
						span.classList.add("regra_glosa");

						if (obj[i].descricaoAcao !== undefined) {
							span.title = obj[i].descricaoAcao;
						}
						span.innerHTML = obj[i].acao;

						var gls = tdCenter.cloneNode();
						gls.appendChild(span);

						var obs = tdWrap.cloneNode();
						obs.classList.add("regra_observacao");
						if (obj[i].observacoes !== undefined) {
							obs.innerHTML = obj[i].observacoes;
						} else {
							obs.innerHTML = "-";
						}

						var tr = document.createElement('tr');
						tr.appendChild(chk);
						tr.appendChild(sit);
						tr.appendChild(gls);
						tr.appendChild(obs);

						tbody.append(tr);
					}
				},
				error: function(xhr, status, error) {
					alert("Falha ao carregar Regras de Auditoria - Erro ao efetuar a requisicao: " + xhr.status + " - " + xhr.statusText + "\n" + status + " - " + error)
				}
			});
		}
        function alterarSelecaoRegra(element) {
			var tr = element.closest("tr");
			if (element.checked) {
				tr.classList.add("regra_selecionada");
			} else {
				tr.classList.remove("regra_selecionada");
			}
		}
	</script>
</head>
<body>
	<div id="lupa">
		<div id="lupa_cabecalho">
			<table class="tabela_cabecalho tabela_texto">
				<tr>
					<td class="titulo" width="10%">Evento</td>
					<td id="codigoEvento" class="texto" width="10%" style="font-weight:bold;"><c:out value="${cdEventoCondicao}" /></td>
					<td class="titulo" width="10%">Descri&ccedil;&atilde;o</td>
					<td class="texto" width="70%" style="font-weight:bold;"><c:out value="${dsEventoCondicao}" /></td>
				</tr>
			</table>
		</div>
		<c:if test='${sessionScope.permissao}'>
			<div id="lupa_abas">
				<ul class="abas">
					<li class="aba selected">Regras Auditoria</li>
					<li class="aba">Crit&eacute;rios T&eacute;cnicos</li>
				</ul>
			</div>
			<div id="lupa_conteudo">
				<div class="lp_conteudo" style="display: block">
					<fieldset>
						<legend>Regra do Manual</legend>

						<c:if test='${sessionScope.condicoesManual != null}'>
							<table class="tabela_texto">
								<tr>
									<td class="titulo" width="55%">Condi&ccedil;&otilde;es t&eacute;cnicas e observa&ccedil;&otilde;es</td>
									<td class="titulo" width="15%">Pr&eacute; Aprova&ccedil;&atilde;o</td>
									<td class="titulo" width="15%">Consolida&ccedil;&atilde;o/Revis&atilde;o</td>
									<td class="titulo" width="15%">Periodicidade</td>
								</tr>
								<tr>
									<td rowspan="4" class="texto wrap"><c:out value="${sessionScope.condicoesManual.observacoes}" /></td>
									<td class="subtitulo">Obrigat�ria</td>
									<td class="subtitulo">Imagem Diagn�stica</td>
									<td rowspan="2" class="texto texto_centralizado"><c:out value="${sessionScope.condicoesManual.periodicidade}" /></td>
								</tr>
								<tr>
									<td class="texto texto_centralizado"><c:out value="${sessionScope.condicoesManual.preAprovacaoObrigatoria}" /></td>
									<td class="texto texto_centralizado"><c:out value="${sessionScope.condicoesManual.imagemDiagnostica}" /></td>
								</tr>
								<tr>
									<td class="subtitulo">Imagem diagn�stica</td>
									<td class="subtitulo">Imagem p�s-tratamento</td>
									<td class="titulo">Protocolo GTO</td>
								</tr>
								<tr>
									<td class="texto texto_centralizado"><c:out value="${sessionScope.condicoesManual.imagemDiagnosticaPre}" /></td>
									<td class="texto texto_centralizado"><c:out value="${sessionScope.condicoesManual.imagemDiagnosticaPos}" /></td>
									<td class="texto texto_centralizado" style="background-color: <c:out value="${sessionScope.condicoesManual.corMensagem}" />;"><c:out value="${sessionScope.condicoesManual.protocoloGTO}" /></td>
								</tr>
							</table>
						</c:if>
						<c:if test='${sessionScope.condicoesManual == null}'>
							<h4>Sem registros.</h4>
						</c:if>
					</fieldset>

					<fieldset>
						<legend>Regra Auditoria</legend>

						<c:if test='${not empty sessionScope.regrasAuditoria}'>
							<div class="conteudo_regras">
								<div class="center" style="margin-bottom: 10px;">
									Busca R&aacute;pida <input type="text" id="buscaRapida" name="buscaRapida" onkeydown="pesquisarRegrasAuditoriaEnter(event)" />
									<input type="button" value="Pesquisar" onclick="pesquisarRegrasAuditoria()" />
									<input type="button" value="Limpar" onclick="limparPesquisarRegrasAuditoria()" />
								</div>
								<table id="tabelaRegrasAuditoria" class="tabela_comum">
									<thead>
										<tr class="titulo">
											<th width="5%">Sele&ccedil;&atilde;o</th>
											<th width="45%">Situa&ccedil;&atilde;o</th>
											<th width="5%" class="center">A&ccedil;&atilde;o</th>
											<th width="45%">Observa&ccedil;&otilde;es Complementares</th>
										</tr>
									</thead>
									<tbody id="regrasAud">
										<logic:iterate id="regrasAuditoria" name="regrasAuditoria">
											<tr>
												<td class="center"><input type="checkbox" name="listaRegra" onchange="alterarSelecaoRegra(this)" /></td>
												<td class="wrap"><c:out value="${regrasAuditoria.situacao}"/></td>
												<td class="center"><span class="regra_glosa"
													title="<c:out value="${regrasAuditoria.descricaoAcao}"/>"><c:out value="${regrasAuditoria.acao}"/></span></td>
												<td class="wrap regra_observacao"><c:out value="${regrasAuditoria.observacoes}"/></td>
											</tr>
										</logic:iterate>
									</tbody>
								</table>
							</div>
							<div class="center" style="padding: 10px 0;">
								<input type="hidden" id="nrOrdem" value="<c:out value='${nrOrdem}' />" />
								<input type="button" value="Aplicar" id="aplicarRegras" style="font-size:1.5em;"/>
							</div>
						</c:if>
						<c:if test='${empty sessionScope.regrasAuditoria}'>
							<h4>Sem registros.</h4>
						</c:if>
					</fieldset>
				</div>
				<div class="lp_conteudo" style="display: none">
					<fieldset>
						<legend>Crit�rio/Orienta&ccedil;&otilde;es</legend>

						<c:if test='${not empty sessionScope.criteriosOrientacoes}'>
							<div class="conteudo_criterios">
								<table class="tabela_comum">
									<tr class="titulo">
										<th>Crit�rio/Orienta&ccedil;&otilde;es</th>
									</tr>
									<logic:iterate id="criteriosOrientacoes" name="criteriosOrientacoes">
										<tr>
											<td><c:out value="${criteriosOrientacoes.observacoes}"/></td>
										</tr>
									</logic:iterate>
								</table>
							</div>
						</c:if>
						<c:if test='${empty sessionScope.criteriosOrientacoes}'>
							<h4>Sem registros.</h4>
						</c:if>
					</fieldset>

					<fieldset>
						<legend>Imagens</legend>

						<c:if test='${not empty sessionScope.criteriosImagens}'>
							<div class="conteudo_imagens">
								<table>
									<c:set var="contador" value="${0}" />

									<tr><logic:iterate id="criterioImagem" name="criteriosImagens">
										<c:if test="${contador % 6 == 0}">
											</tr><tr>
										</c:if>
										<c:set var="contador" value="${contador + 1}" />
										<td>
											<div class="center"><a href="#" onClick="abrirNovaTelaDiretriz(<c:out value='${criterioImagem.codigoMidia}'/>)">
												<img alt="${criterioImagem.codigoMidia}" src="${pageContext.request.contextPath}/servico/DiretrizMidiaServlet?codigoMidia=<c:out value='${criterioImagem.codigoMidia}'/>&thumb=true" />
											</a></div>
											<p class="wrap"><c:out value="${criterioImagem.legenda}" /></p>
										</td>
									</logic:iterate></tr>
								</table>
							</div>
						</c:if>
						<c:if test='${empty sessionScope.criteriosImagens}'>
							<h4>Sem registros.</h4>
						</c:if>
					</fieldset>

					<fieldset>
						<legend>Refer�ncias</legend>

						<c:if test='${not empty sessionScope.criteriosReferencias}'>
							<div class="conteudo_referencias">
								<table class="tabela_comum">
									<tr class="titulo">
										<th width="50%">Refer�ncias</th>
										<th width="40%">Link</th>
										<th width="10%">Download</th>
									</tr>
									<logic:iterate id="criteriosReferencias" name="criteriosReferencias">
										<tr>
											<td class="wrap"><c:out value="${criteriosReferencias.referencia}"/></td>
											<td class="wrap">
												<c:if test="${criteriosReferencias.possuiLinkValido()}">
													<a href="<c:out value="${criteriosReferencias.link}"/>" target="_blank">
														<c:out value="${criteriosReferencias.link}"/>
													</a>
												</c:if>
												<c:if test="${!criteriosReferencias.possuiLinkValido()}">
													<c:out value="${criteriosReferencias.link}"/>
												</c:if>
											</td>
											<td class="center">
												<c:if test="${criteriosReferencias.tipoMidia != null}">
													<a download="Referencia_<c:out value='${criteriosReferencias.codigoMidia}'/>"
														href="${pageContext.request.contextPath}/servico/DiretrizMidiaServlet?codigoMidia=<c:out value='${criteriosReferencias.codigoMidia}'/>">
														<c:out value='${criteriosReferencias.tipoMidia}'/>
													</a>
												</c:if>
											</td>
										</tr>
									</logic:iterate>
								</table>
							</div>
						</c:if>
						<c:if test='${empty sessionScope.criteriosReferencias}'>
							<h4>Sem registros.</h4>
						</c:if>
					</fieldset>
				</div>
			</div>
		</c:if>
		<c:if test='${!sessionScope.permissao}'>
			<h4>Usu&aacute;rio sem permiss&atilde;o para acessar informa&ccedil;&atilde;o</h4>
		</c:if>
	</div>
</body>
