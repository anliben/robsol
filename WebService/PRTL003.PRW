#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'RESTFUL.CH'
#INCLUDE "FWMVCDEF.CH"

#Define Enter Chr(13)+Chr(10)

//-------------------------------------------------------------------
/*/{Protheus.doc} PRTL003
Descricao: Servico API Rest Evento Geracao de Pedidos

@author Alexandre Ven�ncio
@since 21/09/2021
@version 1.0

@Param:

/*/
//-------------------------------------------------------------------
USER Function PRTL003()
Return

// Servico.
WsRestFul PRTL003 DESCRIPTION "API REST - EVENTO GERACAO PEDIDOS | PORTAL ROBSOL " 
	
	WsMethod POST Description "API REST - EVENTO GERACAO PEDIDOS - METODO POST "  WsSyntax "PRTL003"

End WsRestFul
//-------------------------------------------------------------------
/*/{Protheus.doc} Metodo Post | Evento Implantacao 
Descricao: 	Serviço Rest contendo o Metodo POST do evento de 
				Portal Robsol

@author Alexandre Venancio
@since 21/09/2021
@version 1.0

@Param:

/*/
//-------------------------------------------------------------------
WsMethod POST WsReceive RECEIVE WsService PRTL003

	Local cCode			As Character 
	Local cMessage		As Character
	Local cEmp			As Character 
	Local cFil			As Character 
	Local cUser			As Character
	Local cCodUsu		As Character
	Local cNomUsu		As Character
	Local cCodVnd		As Character 
	Local cCodClt 		As Character
	Local cLojCli		As Character
	Local cAcesso		As Character

	Local aRetExec		As Array
	Local aErro			As Array

	Local lRet			As Logical 
	
	Local oBody			As J 
	Local oJsonIM
	Local cCondPg
	Local nX
	Local cBarra
	Local aSld 				:=	{}
	
	
	Local aItens			:=	{}
	Local aCliente			:=	{}

	cCode					:= ''
	cCodUsu					:= ''
	cNomUsu					:= ''
	cCodVnd					:= ''
	cCodClt					:= ''
	cLojCli					:= ''
 	cEmp					:= '01'
	cFil					:= '0101'
	cMessage				:= ''
	cAcesso					:= ''

	aTitulos				:= {}
	aTitTrans			    := {}
	aRetExec				:= {}
	aRastro				    := {}
	aErro					:= {}

	lRet					:= .T.

	cBody := ::GetContent()
	cBody := upper(cbody)
	conout("chegou aqui PRTL003")
	conout("o que veio = "+cBody)
	conout("")
	conout("")
	IF FWJsonDeserialize(cBody,@oJsonIM)
		// recupera o body da requisicao
		oBody  := JsonObject():New()
		oBody:fromJson(oJsonIM:Body)
		cUser 		:= oBody:getJsonText("VENDEDOR")
		cCondPg		:= oBody:getJsonText("CONDPAGTO")
		aItens		:=	oBody:getJsonText("ITEMS")
		aCliente	:=	oBody:getJsonText("CLIENTE")
	ENDIF
	
	/*If AllTrim( self:getContent() ) != 'U' //ValType(oBody:fromJson( AllTrim( self:getContent() ) )) != 'U'	
		cCode 	:= "#500"
		cMessage	:= "Formato Json nao reconhecido. Revisar a estrutura e layout informado."
		lRet		:= .F.
	Else*/
		lRet		:= .T.

		conout(cUser)
		conout(cCondPg)
		

		// Verifica se os campos Obrigatorios para abertura da Empresa/Filial foram preenchidos.
		If (Empty(cUser) .Or. AllTrim(cUser)=='null')
			cCode 	:= "#500"
			cMessage	:= "Campos Obrigatorios de Preenchimento nao informados: VENDEDOR"
			lRet		:= .T.
			conout(cCode+CHR(13)+CHR(10)+cMessage)
		
		Else
			RPCSetType(3)  
			RpcSetEnv(cEmp,cFil,,,,GetEnvServer(),{ }) 
		EndIf

		// Chama Rotina que irá analisar os dados recebidos.
		If lRet .And. Empty(cCode) .And. Empty(cMessage)
            StatPed(oBody,@aRetExec, @aErro,@aSld)
			conout("passou statped")
			
            cCode 		:= aRetExec[1]
            cCodUsu		:= aRetExec[2]
			cProdsld	:= aRetExec[3]
			
			conout("retornou "+ccode)
			conout(ccodusu)
			conout(cProdsld)

			If len(aSld) > 0
				cJsonRet := '{"codigo": "410",
				cJsonRet += '"mensagem": "Itens sem saldo",'
				cJsonRet += '"produtos": ['
				//aSld := separa(cProdsld,",")
				cBarra := ''
				For nX := 1 to len(aSld)
					If !Empty(aSld[nX,01])
						cJsonRet += cBarra+'{'
						cJsonRet += '"codigo":"'+cvaltochar(aSld[nX,01])+'",
						cJsonRet += '"saldo": "'+cvaltochar(aSld[nX,02])+'" }'
						cBarra := ','
					EndIf
				Next nX
				cJsonRet += ']'
				cJsonRet += '}'
			else
				cJsonRet := '{"code" : "200",
				cJsonRet += '"pedido": "'+cCode+'",'
				cJsonRet += '"mensagem": "'+cCodUsu+'"}'				
			EndIf
			conout(cJsonret)
		EndIf 

	//EndIf

	//-> Mensagem de Retorno da Requisição
	self:setContentType("application/json")
	//self:setResponse(fwJsonSerialize(StatReq(cCode,cCodUsu,cNomUsu,cCodVnd,cAcesso,cCodClt,cLojCli)))
    //self:setResponse(fwJsonSerialize(StatReq(cCode,cCodUsu,cProdsld)))
	self:setResponse(cJsonRet)
	// Realiza o fechamento do Ambiente
	RpcClearEnv()
	Freeobj(oBody)

Return lRet
//-------------------------------------------------------------------
/*/{Protheus.doc} StatReq
Descricao: 	Realiza o Tratamento para envio de Mensagem de Retorno 
				da API 

@author Alexandre Venâncio
@since 12/05/2020
@version 1.0

@Param: 
	cCode 	= 	Codigo do Erro que sera informado no Retorno da API
	cMessage	= 	Mensagem de Retorno que sera informado no Retorno 
					da API

/*/
//-------------------------------------------------------------------
Static Function StatReq(cCode As Character, cCodUsu As Character, cProds As Character ) As J

	Local oJsonBody	As J
	Local oJsonRet 	As J
	Local nX 			:= 0
	Local aSaldos		:=	{}
	Local aItens		:=	{}

	Default cCode		:= ''
	Default cCodUsu		:= ''
	Default cProds		:= ''


	//Cria o Objeto de Retono da Requisição.
	oJsonRet  := JsonObject():New()
	oJsonRet["statusrequest"] := {}
	oJsonRet["produtos"] := {}

	oJsonBody := JsonObject():New()
	oJsonBody["codigo"]      := cCode
	oJsonBody["mensagem"]   := cCodUsu

	If !Empty(cProds)
		aSaldos := Separa(cProds,",")
			
		For nX := 1 to len(aSaldos)
			Aadd(aItens,JsonObject():new())
			aItens[nX]['codigo'] := aSaldos[nX]
		Next nX
	EndIf

	AAdd( oJsonRet["statusrequest"], oJsonBody )
	AAdd( oJsonRet["produtos"],aItens )

Return oJsonRet

//-------------------------------------------------------------------
/*/{Protheus.doc} StatReq
Descricao: 	Realiza o Tratamento para envio de Mensagem de Retorno 
				da API 

@author Alexandre Venâncio
@since 12/05/2020
@version 1.0

@Param: 
	cCode 	= 	Codigo do Erro que sera informado no Retorno da API
	cMessage	= 	Mensagem de Retorno que sera informado no Retorno 
					da API

/*/
//-------------------------------------------------------------------
Static Function StatPed(oBody As J, aRetExec as Array, aErro As Array, aSld As Array) As J

	//Local oJsonBody	As J
	Local aArea		:=	GetArea()
	Local oJsonRet 	As J

	Local lRet		:=	.F.
	Local aCabec    := {}
	Local aItens   	:= {}   
	Local aLinha    := {}
	Local cDoc 		:= GetSxeNum("SC5", "C5_NUM")
	Local nX		:=	0
	Local aDadCl		:=	{}
	Local nOpcAuto	:=	3
	Local aAI0Auto	:=	{}
	Local aItensCad :=  {}
	Local cPedido
	Local cMessage
	Local nDescon		:=	0
	Local aSaldos 		:=	{}
	Local cProdsSld		:=	''
	Default oBody		:= 	nil
    Default aRetExec    :=  {}
    Default aErro       :=  {}

	cCodVnd := oBody:VENDEDOR
	cCondPg := STRZERO(VAL(oBody:CONDPAGTO),3)
	lForce  := If(UPPER(oBody:FORCE)=='TRUE',.T.,.F.)
	cObsApp := oBody:OBSERVATION
	nDescon := oBody:DESCONTO

	If !lForce
		aSaldos := ValSald(oBody:ITEMS)
	ENDIF
	
	If len(aSaldos) > 0
		cPedido := '410'
		cMessage := 'Itens sem saldo'+CRLF
		cProdsSld := ''
		For nX := 1 to len(aSaldos)	
			cProdsSld += aSaldos[nX,01]+','
		Next nX
		aSld := aSaldos
		
	Else
		If cCondPg == "000"
			cCondPg := '001'
		EndIf

		DbSelectArea("CC2")
		DbSetOrder(4)
		
		If Valtype(oBody:Cliente) == "A"
			If Dbseek(xFilial("CC2")+upper(oBody:Cliente[1]:UF)+upper(oBody:Cliente[1]:CIDADE))
				codmun := CC2->CC2_CODMUN
			else
				codmun := '50308'
			endif
		else
			If Dbseek(xFilial("CC2")+upper(oBody:Cliente:UF)+upper(oBody:Cliente:CIDADE))
				codmun := CC2->CC2_CODMUN
			else
				codmun := '50308'
			EndIf
		endIf
		
		If Valtype(oBody:Cliente) == "A"
			DbSelectArea("SA1")
			If oBody:CLIENTE[1]:GetJsonObject("CNPJ") <> NIL //AttIsMemberOf(oBody:Cliente[1],"CNPJ")
				ccnpjx := oBody:Cliente[1]:cnpj
				DbSetOrder(3)
			Else
				ccnpjx := oBody:Cliente[1]:codigo
				DbSetOrder(1)
			EndIf
		else
			DbSelectArea("SA1")
			If oBody:CLIENTE:GetJsonObject("CNPJ") <> NIL //AttIsMemberOf(oBody:Cliente[1],"CNPJ")
				ccnpjx := oBody:Cliente:cnpj
				DbSetOrder(3)
			Else
				ccnpjx := oBody:Cliente:codigo
				DbSetOrder(1)
			EndIf
		EndIF 

		If Dbseek(xFilial("SA1")+ccnpjx)
			ccnpj 	:= SA1->A1_COD
			cloja 	:= SA1->A1_LOJA
			//CONTACT CELULAR ENDERECO BAIRRO CIDADE 
			Reclock("SA1",.F.)
			If Valtype(oBody:Cliente) == "A"
				If Alltrim(SA1->A1_CONTATO) <> Alltrim(oBody:Cliente[1]:CONTACT)
					SA1->A1_CONTATO := oBody:Cliente[1]:CONTACT
				EndIF

				If Alltrim(SA1->A1_END) <> Alltrim(oBody:Cliente[1]:ENDERECO)
					SA1->A1_END := Alltrim(oBody:Cliente[1]:ENDERECO)
				ENDIF

				If Alltrim(SA1->A1_TEL) <> substr(oBody:Cliente[1]:CELULAR,3) 
					SA1->A1_TEL := substr(oBody:Cliente[1]:CELULAR,3)
				ENDIF
			ELSE
				If Alltrim(SA1->A1_CONTATO) <> Alltrim(oBody:Cliente:CONTACT)
					SA1->A1_CONTATO := oBody:Cliente:CONTACT
				EndIF

				If Alltrim(SA1->A1_END) <> Alltrim(oBody:Cliente:ENDERECO)
					SA1->A1_END := Alltrim(oBody:Cliente:ENDERECO)
				ENDIF

				If Alltrim(SA1->A1_TEL) <> substr(oBody:Cliente:CELULAR,3) 
					SA1->A1_TEL := substr(oBody:Cliente:CELULAR,3)
				ENDIF

			EndIF
			SA1->(MsUnlock())
			
		else
			
			ccnpj := SUBSTR(ccnpjx,1,If(len(ccnpjx)>11,8,9))
			cloja := SUBSTR(ccnpjx,If(len(ccnpjx)>11,9,10),If(len(ccnpjx)>11,4,2))

			Aadd(aDadCl,{"A1_CGC"   ,   ccnpjx              					, NIL})
			Aadd(aDadCl,{"A1_PESSOA",   If(len(ccnpjx)>11,'J','F')           	, NIL})
			Aadd(aDadCl,{"A1_TIPO"  ,   'R'                     				, NIL})
			Aadd(aDadCl,{"A1_COD_MUN",  codmun                 , NIL})
					
			If Valtype(oBody:Cliente) == "A"

				Aadd(aDadCl,{"A1_NOME"  ,   upper(oBody:Cliente[1]:RAZAO_SOCIAL)  			, NIL})
				Aadd(aDadCl,{"A1_NREDUZ",   upper(oBody:Cliente[1]:NOME_FANTASIA)  			, NIL})
				Aadd(aDadCl,{"A1_END"   ,   Alltrim(upper(oBody:Cliente[1]:ENDERECO))  		, NIL})
				Aadd(aDadCl,{"A1_CEP"   ,   oBody:Cliente[1]:CEP                    		, NIL})
				Aadd(aDadCl,{"A1_BAIRRO",   substr(upper(oBody:Cliente[1]:BAIRRO),1,30)    	, NIL})
				Aadd(aDadCl,{"A1_EST"   ,   upper(oBody:Cliente[1]:UF)               		, NIL})
				Aadd(aDadCl,{"A1_MUN"   ,   substr(UPPER(oBody:Cliente[1]:CIDADE),1,60)    	, NIL})
				Aadd(aDadCl,{"A1_EMAIL" ,   upper(oBody:Cliente[1]:EMAIL)                  	, NIL})
				Aadd(aDadCl,{"A1_DDD"   ,   Substr(oBody:Cliente[1]:CELULAR,1,2)            , NIL})
				Aadd(aDadCl,{"A1_TEL"   ,   substr(oBody:Cliente[1]:CELULAR,3)              , NIL})
				Aadd(aDadCl,{"A1_CONTATO",  oBody:Cliente[1]:CONTACT			          	, NIL})
				
			else
				Aadd(aDadCl,{"A1_NOME"  ,   upper(oBody:Cliente:RAZAO_SOCIAL)  				, NIL})
				Aadd(aDadCl,{"A1_NREDUZ",   upper(oBody:Cliente:NOME_FANTASIA)  			, NIL})
				Aadd(aDadCl,{"A1_END"   ,   Alltrim(upper(oBody:Cliente:ENDERECO))  		, NIL})
				Aadd(aDadCl,{"A1_CEP"   ,   oBody:Cliente:CEP                    			, NIL})
				Aadd(aDadCl,{"A1_BAIRRO",   substr(upper(oBody:Cliente:BAIRRO),1,30)    	, NIL})
				Aadd(aDadCl,{"A1_EST"   ,   upper(oBody:Cliente:UF)               			, NIL})
				Aadd(aDadCl,{"A1_MUN"   ,   substr(UPPER(oBody:Cliente:CIDADE),1,60)    	, NIL})
				Aadd(aDadCl,{"A1_EMAIL" ,   upper(oBody:Cliente:EMAIL)                  	, NIL})
				Aadd(aDadCl,{"A1_DDD"   ,   Substr(oBody:Cliente:CELULAR,1,2)               , NIL})
				Aadd(aDadCl,{"A1_TEL"   ,   substr(oBody:Cliente:CELULAR,3)                 , NIL})	
				Aadd(aDadCl,{"A1_CONTATO",  oBody:Cliente:CONTACT			                , NIL})
				
			EndIf

			Aadd(aDadCl,{"A1_PAIS"  ,   '105'                   , NIL})
			Aadd(aDadCl,{"A1_CODPAIS",  '01058'                 , NIL})
			Aadd(aDadCl,{"A1_TPESSOA",  'CI'    	             , NIL})

			Aadd(aDadCl,{"A1_VEND"	,   cCodVnd                 , NIL})
			
			aAdd(aAI0Auto,{"AI0_SALDO" ,0 ,Nil})
			
			aAdd(aDadCl,{"A1_LOJA", cLoja , Nil})
			
			lMsErroAuto := .F.
			//------------------------------------
			// Chamada para cadastrar o cliente.
			//------------------------------------
			MSExecAuto({|a,b,c| CRMA980(a,b,c)}, aDadCl, nOpcAuto, aAI0Auto)
			
			If lMsErroAuto 
				mostraerro('\system\erros_app\','cliente_'+dtos(ddatabase)+strtran(cvaltochar(time()),":"))
				ccnpj := ''
				cloja := ''
				cPedido := '400'
				cMessage := 'Erro ao cadastrar o cliente'
				//loop
			else
				conout("cliente cadastrado")
				//ccnpj  := SA1->A1_COD
				//cLoja  := SA1->A1_LOJA
				DbSelectArea("SA1")
				DbSetOrder(3)
				DbSeek(xFilial("SA1")+ccnpjx)
			EndIf
			
		EndIf

		If !Empty(ccnpj) 
			aItensCad := oBody:ITEMS
			aadd(aCabec, {"C5_NUM"		, cDoc			,Nil})
			aadd(aCabec, {"C5_TIPO"		, "N"			,Nil})
			aadd(aCabec, {"C5_CLIENTE"	, ccnpj			,Nil})
			aadd(aCabec, {"C5_LOJACLI"	, cloja			,Nil})
			aadd(aCabec, {"C5_LOJAENT"	, cloja			,Nil})
			aadd(aCabec, {"C5_EMISSAO"	, dDatabase		,Nil}) // Data de emissao
			aadd(aCabec, {"C5_TIPOCLI"	, SA1->A1_TIPO	,Nil}) // Tipo de cliente
			aadd(aCabec, {"C5_TIPOPV" 	, '1'			,Nil}) //
			aadd(aCabec, {"C5_MOEDA"  	, 1				,Nil})  // Moeda
			aadd(aCabec, {"C5_CONDPAG"	, cCondPg		,Nil})
			aadd(aCabec, {"C5_NATUREZ"  ,"11010007"     ,Nil})  
			aadd(aCabec, {"C5_VEND1"    , cCodVnd       ,Nil})
			aadd(aCabec, {"C5_X_OBS"    , cObsApp		,Nil})


			FOR nX := 1 to len(aItensCad)  
				aLinha := {}
				DbSelectArea("SB1")
				DbSetOrder(1)
				DbSeek(xFilial("SB1")+aItensCad[nX]:PRODUTO)
				
				nQtd := 0
				If valtype(aItensCad[nX]:QUANTIDADE) == "C"
					nQtd := val(aItensCad[nX]:QUANTIDADE)
				else
					nQtd := aItensCad[nX]:QUANTIDADE
				EndIf 
				aadd(aLinha,{"C6_ITEM"		, STRZERO(nX,2)					, Nil})
				aadd(aLinha,{"C6_PRODUTO"	, aItensCad[nX]:PRODUTO			, Nil})
				aadd(aLinha,{"C6_QTDVEN"	, nQtd							, Nil})
				aadd(aLinha,{"C6_PRCVEN"	, val(STRTRAN(aItensCad[nX]:VALOR,",","."))	, Nil})
				aadd(aLinha,{"C6_PRUNIT"	, val(STRTRAN(aItensCad[nX]:VALOR,",","."))	, Nil})
				aadd(aLinha,{"C6_VALOR"		, val(STRTRAN(aItensCad[nX]:VALOR,",",".")) * nQtd	, Nil})
				aadd(aLinha,{"C6_TES"		, '502'			 				, Nil})
				aadd(aLinha,{"C6_LOCAL"		, SB1->B1_LOCPAD	 			, Nil})
				aadd(aLinha,{"C6_DESCONT"	, VAL(nDescon)			  	 	, Nil})
				
				aadd(aItens, aLinha)

			NEXT      

			lMsErroAuto := .F.            

			Begin Transaction 

					
			MSExecAuto({|a, b, c| MATA410(a, b, c)}, aCabec, aItens, 3)
			
			If !lMsErroAuto
				ConOut("Inclu�do com sucesso! " + cDoc)
				ConfirmSX8()
				cPedido := SC5->C5_NUM
				GERHTML(cPedido)
				cMessage := 'Pedido gerado com sucesso'
				lRet := .T.
			Else
				cPedido := '400'
				cMessage := 'Erro ao gerar o pedido'
				mostraerro('\system\erros_app\','pedido_'+dtos(ddatabase)+strtran(cvaltochar(time()),":"))
				lRet := .F.
			EndIf

			End Transaction 
		

		EndIf
	EndIf
	
	aRetExec := {cPedido,cMessage,cProdsSld}

	RestArea(aArea)

Return oJsonRet


user function xxtes

Local cBody := '{"BODY":"{\"CLIENTE\":{\"CNPJ\":\"00898760000168\",\"EMAIL\":\"CONTABIL-TEIXEIRA@OTICADIAS.COM\",\"IE\":\"ASDDASDASD\",\"CONTACT\":\"DASD\",\"PAIS\":\"\",\"PORTE\":\"\",\"BAIRRO\":\"CENTRO\",\"NUMERO\":\"DASDASD\",\"CIDADE\":\"DORMENTES\",\"ENDERECO\":\"R.JOSE LUIS DA SILVA, 146A\",\"NOME_FANTASIA\":\"OTICAS DIAS\",\"RAZAO_SOCIAL\":\"OTICA PETROLINENSE LTDA EPP\",\"UF\":\"PE\",\"CEP\":\"56355000\",\"CELULAR\":\"87 38612698       \",\"FILIAL\":\"0001\",\"ULTIMA_COMPRA\":\"10/02/22\",\"LIMITE_CREDITO\":\" 10.000,00\",\"MAIOR_ATRASO\":\"   0\",\"MAIOR_COMPRA\":\"  8.115,09\",\"PRIMEIRA_COMPRA\":\"05/02/22\",\"QTD_ATRASOS\":\"   0\",\"QTD_COMPRAS\":\"    2\",\"QTD_PAGTO_ATRASO\":\"   0\",\"RISCO\":\"A\",\"SALDO\":\"  1.884,42\",\"SALDO_DUPL_ABERTO\":\"  8.115,58\",\"GEOLOC1\":37.4220094,\"GEOLOC2\":-122.0840352},\"ITEMS\":[{\"DESCRICAO\":\"SOLAR\",\"ITEM\":\"ID\",\"PRODUTO\":\"1006 C5\",\"VALOR\":\"   57,00\",\"DESCONTO\":0,\"QUANTIDADE\":\"500\"}],\"VENDEDOR\":\"000006\",\"DESCONTO\":\"\",\"CONDPAGTO\":\"001\",\"OBSERVATION\":\"TESTE APP\",\"FORCE\":\"FALSE\"}"}'
Local oJsonIM 
Local aItens	:=	{}
Local aCliente 	:=	{}
Local aRetExec	:=	{}
Local aErro		:=	{}

If Select("SM0") == 0
	RpcSetType(3)
	RPCSetEnv("01","0101")
EndIf

IF FWJsonDeserialize(cBody,@oJsonIM)
	//IF VALTYPE(oJsonIM:VENDEDOR) == "C"
		oBody  := JsonObject():New()
		oBody:fromJson(oJsonIM:Body)
		cUser 		:= oBody:getJsonText("VENDEDOR")
		cCondPg		:= oBody:getJsonText("CONDPAGTO")
		aItens		:=	oBody:getJsonText("ITEMS")
		aCliente	:=	oBody:getJsonText("CLIENTE")
		//AttIsMemberOf(AARRAY[nCont]:PEDIDO,"NOTA")

		StatPed(oBody,@aRetExec, @aErro,@aCliente,@aItens,@cUser,@cCondPg)
		//conout(cUser)
		cCode 	:= aRetExec[1]
		cCodUsu := aRetExec[2]
		cPrdSld := aRetExec[3]
		fwJsonSerialize(StatReq(cCode,cCodUsu,cPrdSld))
	//ENDIF
ENDIF

return


/*/{Protheus.doc} HTML
	(long_description)
	@type  Static Function
	@author user
	@since 24/02/2022
	@version version
	@param param_name, param_type, param_descr
	@return return_var, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
/*/
Static Function GERHTML(cPedido)

Local cHtml := ''
Local cRemete   := "Marketing Robsol <marketing@robsol.com.br>"                               
Local cSubject	:=	"Pedido de Venda"
Local aArquivos := {}           
Local cDestino	:=	"alexandre.venancio@avsipro.com.br;wander.donato@avsipro.com.br;financeiro@robsol.com.br;cnoculos@hotmail.com"
Local lEnviar	:=	.F.

cHtml := '<h1 style="color: #5e9ca0;">Pedido de Venda Gerado!</h1>'
cHtml += '<h2 style="color: #2e6c80;">Seu pedido foi gerado com sucesso!!!</h2>
cHtml += '<p>Seu pedido foi gerado em nossa base e logo estaremos realizando o atendimento para realiza&ccedil;&atilde;o da entrega das mercadorias.</p>
cHtml += '<h2 style="color: #2e6c80;">Informa&ccedil;&otilde;es do pedido: Pedido numero '+cPedido+'</h2>
cHtml += '<table class="editorDemoTable" style="width: 544px; height: 72px;">
cHtml += '<thead>
cHtml += '<tr style="height: 18px;">
cHtml += '<td style="width: 148.188px; height: 18px;">Produto</td>
cHtml += '<td style="width: 231.95px; height: 18px;">Descri&ccedil;&atilde;o</td>
cHtml += '<td style="width: 60.575px; height: 18px;">Qtd</td>
cHtml += '<td style="width: 77.2875px; height: 18px;">Valor</td>
cHtml += '</tr>
cHtml += '</thead>
cHtml += '<tbody>

DbSelectArea("SC6")
DbSetOrder(1)
If Dbseek(xFilial("SC6")+cPedido)
	While !EOF() .And. SC6->C6_FILIAL == xFilial("SC6") .and. SC6->C6_NUM == cPedido
		cHtml += '<tr style="height: 18px;">
		cHtml += '<td style="width: 148.188px; height: 18px;">'+ALLTRIM(SC6->C6_PRODUTO)+'</td>'
		cHtml += '<td style="width: 231.95px; height: 18px;">'+ALLTRIM(SC6->C6_DESCRI)+'</td>'
		cHtml += '<td style="width: 60.575px; height: 18px;">'+TRANSFORM(SC6->C6_QTDVEN,"@E 9999")+'</td>'
		cHtml += '<td style="width: 77.2875px; height: 18px;">'+TRANSFORM(SC6->C6_PRCVEN,"@E 999,999,999.99")+'</td>'
		cHtml += '</tr>'
		lEnviar := .T.
		Dbskip()
	ENDDO
endif
cHtml += '</tbody>
cHtml += '</table>
cHtml += '<p><strong>&nbsp;</strong></p>
cHtml += '<p>&nbsp;</p>'

If lEnviar
	U_robmail(cRemete,cDestino,cSubject,cHtml,aArquivos,.T.)
EndIf 

Return 

/*/{Protheus.doc} ValSald(oBody:ITEMS)
	(long_description)
	@type  Static Function
	@author user
	@since 04/03/2022
	@version version
	@param param_name, param_type, param_descr
	@return return_var, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
/*/
Static Function ValSald(aProds)

Local aArea	:=	GetArea()
Local nX
Local aRet 	:=	{}

FOR nX := 1 to len(aProds)  
	aLinha := {}
	DbSelectArea("SB1")
	DbSetOrder(1)
	DbSeek(xFilial("SB1")+aProds[nX]:PRODUTO)
	
	DbSelectArea("SB2")
	DbSetOrder(1)
	If DbSeek(xFilial("SB2")+Avkey(aProds[nX]:PRODUTO,"B2_COD")+SB1->B1_LOCPAD)
		nSaldo := SaldoSb2()

		nDisponivel := nSaldo - 10
		If nDisponivel < 0
			nDisponivel := 0
		EndIf 

		If nDisponivel < If(valtype(aProds[nX]:QUANTIDADE)=="C",val(aProds[nX]:QUANTIDADE),aProds[nX]:QUANTIDADE)
			Aadd(aRet,{aProds[nX]:PRODUTO,nDisponivel})
		EndIf
	Else
		Aadd(aRet,{aProds[nX]:PRODUTO,0})
	EndIf
Next nX

RestArea(aArea)
	
Return(aRet)
