#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'RESTFUL.CH'
#INCLUDE "FWMVCDEF.CH"


//-------------------------------------------------------------------
/*/{Protheus.doc} PRTL020
Descricao: Servi�o API Rest Evento Titulos

@author Alexandre Ven�ncio
@since 21/09/2021
@version 1.0

@Param:

/*/
//-------------------------------------------------------------------
USER Function PRTL020()
Return

// Serviço.
WsRestFul Financial DESCRIPTION "API REST - EVENTO TITULOS | PORTAL ROBSOL " 
	
	WSDATA CLIENTE As String
    WSDATA TITULO As String
    WSDATA PREFIXO As String
    WSDATA PARCELA As String
    WSDATA VENDEDOR As String
    WSDATA PAGINA As String 
	WSDATA EMISSAO As String
	WSDATA VENCIMENTO As String
	WSDATA STATUS As String

	WsMethod GET Description "Retorna o Cliente especifico ou cadastro todo" WSSYNTAX "/Financial || /Financial/{CLIENTE} || /Financial/{PAGINA}" 

End WsRestFul
//-------------------------------------------------------------------
/*/{Protheus.doc} Metodo Post | Evento Implanta��o 
Descricao: 	Servi�o Rest contendo o Metodo POST do evento de 
				Portal Robsol

@author Alexandre Venancio
@since 21/09/2021
@version 1.0

@Param:

/*/
//-------------------------------------------------------------------
WsMethod GET WsReceive CLIENTE,PAGINA,TITULO,PREFIXO,PARCELA,VENDEDOR,EMISSAO,VENCIMENTO,STATUS WsService Financial

	
	Local cPage		:= Self:PAGINA
    Local cTitulo   := Self:TITULO
    Local cPrefixo  := Self:PREFIXO
    Local cParcela  := Self:PARCELA
	Local cVendedor := Self:VENDEDOR
	Local cEmissao  := Self:EMISSAO
	Local cVencto 	:= Self:VENCIMENTO
	Local cStatus   := Self:STATUS
	Local cCliente 	:= Self:CLIENTE
	Local aArea		:= GetArea()
	Local nCont		:= 0
	Local cVirg		:= ""
	Local aAux		:= {}
	//Local ccnpj 	:=	''

	lRet					:= .T.

	::SetContentType("application/json")
	
	RpcSetType(3)
	RPCSetEnv("01","0101")
	
	conout("chegou aqui PRTL020")
	
	conout('cliente' + cvaltochar(cCliente))
	conout('vendedor' + cvaltochar(cVendedor))

	DbSelectArea("SE1")
	SE1->(DBSetOrder(1))
	SE1->(DBGoTOP())

	If !Empty(cPrefixo) .Or. !Empty(cParcela) .Or. !Empty(cEmissao) .Or. !Empty(cVencto) .Or. !Empty(cStatus) .OR. !Empty(cCliente)
		cTitulo := ""
	ENDIF

	If !Empty(cTitulo)
		If SE1->(DBSeek(xFilial("SE1")+Avkey(cPrefixo,"E1_PREFIXO")+Avkey(cTitulo,"E1_NUM")+Avkey(cParcela,"E1_PARCELA")))
			//ccnpj := Posicione("SA1",1,xFilial("SA1")+SE1->E1_CLIENTE+SE1->E1_LOJA,"A1_CGC")
			::SetResponse('{')
			::SetResponse('"filial":"'+SE1->E1_FILORIG+'",')
			::SetResponse('"codigo":"'+cTitulo+'",')
			::SetResponse('"razao_social":"'+Alltrim(Posicione("SA1",1,xFilial("SA1")+SE1->E1_CLIENTE+SE1->E1_LOJA,"A1_NOME"))+'",')
			::SetResponse('"nome_fantasia":"'+Alltrim(Posicione("SA1",1,xFilial("SA1")+SE1->E1_CLIENTE+SE1->E1_LOJA,"A1_NREDUZ"))+'",')
			::SetResponse('"prefixo":"'+SE1->E1_PREFIXO+'",')
			::SetResponse('"titulo":"'+SE1->E1_NUM+'",')
			::SetResponse('"parcela":"'+SE1->E1_PARCELA+'",')
			::SetResponse('"emissao":"'+cvaltochar(SE1->E1_EMISSAO)+'",')
			::SetResponse('"vencimento":"'+cvaltochar(SE1->E1_VENCREA)+'",')
			::SetResponse('"valor":"'+Transform(SE1->E1_VALOR,"@E 999,999,999.99")+'",')
            ::SetResponse('"status":"'+If(!Empty(SE1->E1_BAIXA),"Pago",If(SE1->E1_VENCREA>=DDATABASE,"Em Aberto","Atrasado"))+'"')
			::SetResponse('}')
		Else
			::SetResponse('{"codigo":"'+cTitulo+'","Erro":"Titulo nao encontrado"}')
		EndIf
	ELSE
		::SetResponse('{')
		::SetResponse('"items": [')
		
		If !Empty(cPrefixo) .Or. !Empty(cParcela) .Or. !Empty(cEmissao) .Or. !Empty(cVencto) .Or. !Empty(cStatus) .Or. !Empty(cCliente)
			cQuery := "SELECT *"
			cQuery += " FROM ( SELECT "
		Else
			cQuery := "SELECT TOP(50) * 
			cQuery += " FROM(
			cQuery += "	SELECT TOP("+If(!Empty(cPage),cvaltochar(val(cPage)*50),'50')+")"
		EndIf

		cQuery += " E1_PREFIXO,E1_NUM,E1_PARCELA,E1_FILORIG,"
        cQuery += " E1_CLIENTE,E1_LOJA,E1_EMISSAO,E1_VENCREA,E1_VALOR,E1_BAIXA,A1_NOME,A1_NREDUZ,A1_CGC"
		cQuery += " FROM "+RetSQLName("SE1")+ " E1"
        cQuery += " INNER JOIN "+RetSQLName("SA1")+" A1 ON A1_FILIAL='"+xFilial("SA1")+"' AND A1_COD=E1_CLIENTE AND A1_LOJA=E1_LOJA AND A1.D_E_L_E_T_=' '"
		
		If !Empty(cCliente) //.And. Empty(cVendedor)
			cQuery += " AND A1_COD = '"+cCliente+"'"
		endIf	

		cQuery += " WHERE E1.D_E_L_E_T_=' '"
		
		If !Empty(cVendedor)
			cQuery += " AND E1_VEND1='"+cVendedor+"' " 
		EndIf
		
		If !Empty(cPrefixo)
			cQuery += " AND E1_PREFIXO='"+cPrefixo+"'"
		EndIf
		
		If !Empty(cParcela)
			cQuery += " AND E1_PARCELA='"+cParcela+"'"
		EndIf

		If !Empty(cEmissao)
			cQuery += " AND E1_EMISSAO='"+dtos(ctod(cEmissao))+"'"
		EndIf

		If !Empty(cVencto)
			cQuery += " AND E1_VENCREA='"+dtos(ctod(cVencto))+"'"
		EndIf

		iF !Empty(cStatus)
			cQuery += " AND E1_BAIXA "+If(cStatus=="Em Aberto","=' '","<>' '")
		EndIf

		If !Empty(cPrefixo) .Or. !Empty(cParcela) .Or. !Empty(cEmissao) .Or. !Empty(cVencto) .Or. !Empty(cStatus) .Or. !Empty(cCliente)
			cQuery += " ) TMP"
		Else
			cQuery += "		ORDER BY E1_CLIENTE ) TMP"
		EndIf

		cQuery += " ORDER BY E1_CLIENTE DESC"

		If Select('TRB') > 0
			dbSelectArea('TRB')
			dbCloseArea()
		EndIf

		DBUseArea( .T., "TOPCONN", TCGenQry( ,, cQuery ), "TRB", .F., .T. )

		DbSelectArea("TRB")

		While !EOF()
			Aadd(aAux,{	TRB->E1_PREFIXO,TRB->E1_NUM,TRB->E1_PARCELA,;
                        TRB->E1_CLIENTE,TRB->E1_LOJA,TRB->E1_EMISSAO,;
                        TRB->E1_VENCREA,TRB->E1_VALOR,TRB->A1_NOME,;
						TRB->E1_BAIXA,TRB->E1_FILORIG,TRB->A1_CGC})
			Dbskip()
		ENDDO

		Asort(aAux,,,{|x,y| x[2] < y[2]})

		
		
		For nCont := 1 to len(aAux)
			//Gerpdf(aAux[nCont,02],aAux[nCont,01],aAux[nCont,12],aAux[nCont,11])
			cPathweb := 'http://portal.robsol.com.br/'+Alltrim(aAux[nCont,12])+'/'
			::SetResponse(cVirg+'{')
			::SetResponse('"filial":"'+aAux[nCont,11]+'",')
			::SetResponse('"titulo":"'+aAux[nCont,02]+'",')
			::SetResponse('"prefixo":"'+Alltrim(aAux[nCont,01])+'",')
			::SetResponse('"parcela":"'+Alltrim(aAux[nCont,03])+'",')
			::SetResponse('"cliente":"'+Alltrim(aAux[nCont,09])+'",')
			::SetResponse('"emissao":"'+cvaltochar(stod(aAux[nCont,06]))+'",')
			::SetResponse('"vencimento":"'+cvaltochar(stod(aAux[nCont,07]))+'",')
			::SetResponse('"valor":"'+Transform(aAux[nCont,08],"@E 999,999,999.99")+'",')
			::SetResponse('"status":"'+If(!Empty(aAux[nCont,10]),'Pago',If(stod(aAux[nCont,07])>=DDATABASE,"Em Aberto","Atrasado"))+'",')
			::SetResponse('"boleto":"'+cPathweb+'Boleto_'+Alltrim(aAux[nCont,02])+'.pdf",')
			::SetResponse('"danfe":"'+cPathweb+Alltrim(aAux[nCont,02])+'.pdf",')
			::SetResponse('"xml":"'+cPathweb+Alltrim(aAux[nCont,02])+'.xml"')
			::SetResponse('}')
			conout(cPathweb+Alltrim(aAux[nCont,02])+'.pdf'+CRLF)
			cVirg := ','
		Next nCont
		
		
		::SetResponse(']')
		::SetResponse('}')
	EndIf

	RestArea(aArea)

	
Return lRet


