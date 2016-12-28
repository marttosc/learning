#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "FILEIO.CH"

#DEFINE CRLF                CHR(13) + CHR(10)

#DEFINE CODPROD             1
#DEFINE DESCPROD            2

#DEFINE PAD_LEFT            0                //Alinhamento a Esquerda
#DEFINE PAD_RIGHT           1                //Alinhamento a Direita
#DEFINE PAD_CENTER          2                //Centralizado

// Importação.

User Function Prova()

    /* Criar uma tabela de cores de produtos com os seguintes campos:
     * 1. Código do Produto;
     * 2. Cor do Produto.
     *
     * Tabela criada: Z02.
     */

     Local cPerg := "XIMPSBCOR"

     AjusteSx1(cPerg)

     If Pergunte(cPerg, .T.)
         Processa({ || ImpCores() }, "Processando...")
     Else
         Alert("Operação cancelada pelo usuário!")
     EndIf

Return

Static Function ImpCores()

    Local cLog := ""
    Local aCores := {}
    Local nCont := 1

    FT_FUse(AllTrim(MV_PAR01)) // Abre o arquivo.

    nLinAtu := 1 // Linha atual do arquivo.

    nQtdLin := FT_FLastRec() - 1 // Total de linhas do arquivo (desconsidera cabeçalho).

    FT_FGoTop() // Vai para o início do arquivo.
    FT_FSkip() // Pula o cabeçalho do arquivo.

    ProcRegua(nQtdLin - 1)

    While ! FT_FEOF()
        IncProc("Processando linha " + cValToChar(nLinAtu) + " de " + cValToChar(nQtdLin) + "...")

        nLinAtu++

        cDados := AllTrim(FT_FReadLn())

        // Ajusta as colunas em branco para não ocorrer inconsistências na quantidade de colunas.
        While At(";;", cDados) > 0
            cDados := StrTran(cDados, ";;", "; ;")
        EndDo

        aDados := StrTokArr(cDados, ";")

        SB1->(dbGoTop())
        SB1->(dbSetOrder(1))

        If (SB1->(dbSeek(xFilial("SB1") + PadR(aDados[CODPROD], TamSx3("B1_COD")[1]))))
            Z02->(dbGoTop())
            Z02->(dbSetOrder(3))

            If ! (Z02->(dbSeek(xFilial("Z02") + PadR(aDados[CODPROD], TamSx3("Z02_PROD")[1]) + PadR(aDados[DESCPROD], TamSx3("Z02_DESC")[1]))))
                aAdd(aCores, { aDados[CODPROD], aDados[DESCPROD] })
            Else
                cLog += "PRODUTO: " + Z02->Z02_PROD + CRLF + "COR: " + Z02->Z02_DESC + CRLF + "JÁ EXISTE!" + CRLF + CRLF
            EndIf
        Else
            cLog += "SB1: PRODUTO: " + aDados[CODPROD] + " NÃO EXISTE" + CRLF + CRLF
        EndIf

        FT_FSkip()
    EndDo

    For nCont := 1 To Len(aCores)
        RecLock("Z02", .T.)

        Z02_PROD := aCores[nCont][CODPROD]
        Z02_DESC := aCores[nCont][DESCPROD]

        Z02->(MsUnlock())
    Next

    If AllTrim(cLog) != ""
        Alert(cLog)
    EndIf

    FClose(AllTrim(MV_PAR01))

Return

Static Function AjusteSx1(cPerg)

    PutSx1(cPerg, "01", "Local do arquivo", "", "", "MV_CH01", "C", 99, 0, 0, "G", "", "", "", "", "MV_PAR01")

Return

// Relatório.

User Function ProvaRel()

    Local cPerg := "RelCores01"

    Sx1Rel(cPerg)

    If Pergunte(cPerg, .T.)
        GeraRel()
    Else
        Alert("Relatório cancelado pelo usuário.")
    EndIf

Return

Static Function GeraRel()

    Local cAlias := GetNextAlias()

    Local cProdDe := MV_PAR01
    Local cProdAte := MV_PAR02

    Local oP := TMSPrinter():New()                          // Objeto de impressão.
    Local aArea := GetArea()                                // Área da janela do Protheus.
    Local oFontTit, oFontPag, oFontMed, oFontNeg            // Fontes utilizadas.
    Local lNegrito := .T.                                   // Usará negrito.
    Local nLin := 350, nPag := 1                            // Linha mínima; página inicial.
    Local oBrush := TBrush():New(Nil, RGB(0, 0, 0))         // Pincel na cor preta.
    Local cQuery := ""                                      // Consulta SQL.
    Local aCabec := { "Código", "Descrição", "Cor" }        // Cabeçalho da tabela.
    Local aExcel := {}                                      // Linhas da tabela com os dados.
    Local cLogo := "\content\logo.png"                      // Caminho da logo.
    Local nQtdCor := 0                                      // Quantidade total de linhas de produtos/cores.

    oP:setLandscape()

    oFontTit := TFont():New("Arial", 18, 18, .T., lNegrito, 5, .T., 5, .T., .F., .F.)
    oFontPag := TFont():New("Arial", 12, 12, .T., !lNegrito, 5, .T., 5, .T., .F., .F.)
    oFontNeg := TFont():New("Arial", 12, 12, .T., lNegrito, 5, .T., 5, .T., .F., .F.)
    oFontMed := TFont():New("Arial", 8, 8, .T., !lNegrito, 5, .T., 5, .T., .F., .F.)

    TMSLinha(oP, 160, 500, "Relatório de Produtos/Cores - Treinamento AdvPL II", oFontTit, PAD_LEFT)

    oP:SayBitmap(70, 1800, cLogo, 300, 120)

    oP:FillRect({ 280, 0, 285, 3000 }, oBrush) // Imprime uma linha (linha, col. inicial, espaço, col. final, pincel)

    cQuery := "SELECT SB1.B1_COD CODIGO, SB1.B1_DESC DESCRICAO, Z02.Z02_DESC COR " + ;
                "FROM " + RetSQLName("SB1") + " SB1 " + ;
                "INNER JOIN " + RetSQLName("Z02") + " Z02 ON (Z02.Z02_FILIAL = '" + xFilial("Z02") + "' AND Z02.Z02_PROD = SB1.B1_COD AND Z02.D_E_L_E_T_ <> '*') " + ;
                "WHERE SB1.B1_FILIAL = '" + xFilial("SB1") + "' AND SB1.D_E_L_E_T_ <> '*' "

    If ! (Empty(AllTrim(cProdDe)))
        cQuery += "AND SB1.B1_COD >= '" + cProdDe + "' "
    EndIf

    If ! (Empty(AllTrim(cProdAte)))
        cQuery += "AND SB1.B1_COD <= '" + cProdAte + "' "
    EndIf

    nCol := 150 // Contador de colunas da tabela.
    TMSLinha(oP, nLin, nCol, "Código", oFontNeg, PAD_LEFT)

    nCol += 300
    TMSLinha(oP, nLin, nCol, "Descrição", oFontNeg, PAD_LEFT)

    nCol += 300
    TMSLinha(oP, nLin, nCol, "Cor", oFontNeg, PAD_LEFT)

    // Executa a consulta SQL.
    TCQuery cQuery Alias (cAlias) New

    (cAlias)->(DbGoTop())

    nLin := 350

    While ! ((cAlias)->(Eof()))
        nLin += 100 // Espaçamento por linha.
        nCol := 150 // Espaçamento por coluna.

        TMSLinha(oP, nLin, nCol, (cAlias)->CODIGO, oFontPag, PAD_LEFT)

        nCol += 300
        TMSLinha(oP, nLin, nCol, (cAlias)->DESCRICAO, oFontPag, PAD_LEFT)

        nCol += 300
        TMSLinha(oP, nLin, nCol, (cAlias)->COR, oFontPag, PAD_LEFT)

        nQtdCor++

        If (nLin > 3000)
            oP:FillRect({3380, 0, 3385, 3000}, oBrush)

            TMSLinha(oP, 3400, 500, "Rodapé - Relatório de Produtos/Cores", oFontMed, PAD_CENTER)
            TMSLinha(oP, 3400, 2200, "Página " + cValToChar(nPag), oFontMed, PAD_CENTER)

            oP:EndPage()

            nPag++

            TMSLinha(oP, 160, 500, "Relatório de Produtos/Cores - Treinamento AdvPL II", oFontTit, PAD_LEFT)

            oP:SayBitmap(70, 1800, cLogo, 148, 40)

            oP:FillRect({ 280, 0, 285, 3000 }, oBrush)

            nCol := 150 // Contador de colunas da tabela.
            TMSLinha(oP, nLin, nCol, "Código", oFontNeg, PAD_LEFT)

            nCol += 300
            TMSLinha(oP, nLin, nCol, "Descrição", oFontNeg, PAD_LEFT)

            nCol += 300
            TMSLinha(oP, nLin, nCol, "Cor", oFontNeg, PAD_LEFT)

            nLin := 350
        EndIf

        aAdd(aExcel, { (cAlias)->CODIGO, (cAlias)->DESCRICAO, (cAlias)->COR })

        (cAlias)->(DbSkip())
    EndDo

    (cAlias)->(DbCloseArea())

    nLin += 100

    oP:FillRect({ nLin, 0, nLin + 5, 3000 }, oBrush)

    nLin += 105

    TMSLinha(oP, nLin, 150, "Total de cores:", oFontNeg, PAD_LEFT)
    TMSLinha(oP, nLin, 1800, AllTrim(Transform(nQtdCor, "@E 999999")), oFontPag, PAD_RIGHT)

    oP:FillRect({ 3380, 0, 3385, 3000}, oBrush)

    // Rodapé.
    TMSLinha(oP, 3400, 500, "Rodapé - Relatório de Produtos/Cores", oFontMed, PAD_CENTER)
    TMSLinha(oP, 3400, 2200, "Página " + cValToChar(nPag), oFontMed, PAD_CENTER)

    // Finaliza a página.
    oP:EndPage()

    // Mostra a pré-visualização do relatório.
    oP:Preview()

    If MsgYesNo("Deseja exportar para o Excel?")
        MS_Flush() // Integração com o Microsoft Office.

        If ! ApOleClient("msexcel")
            MsgAlert("O Microsoft Excel não está instalado!")
            Return
        EndIf

        DlgToExcel({ { "ARRAY", "Exportar para Excel", aCabec, aExcel } })
    EndIf

    RestArea(aArea)

Return

Static Function Sx1Rel(cPerg)

    PutSx1(cPerg, "01", "Produto de?", "", "", "MV_CH01", "C", TamSx3("Z02_PROD")[1], 0, 0, "G", "", "SB1", "", "", "MV_PAR01")
    PutSx1(cPerg, "02", "Produto ate?", "", "", "MV_CH02", "C", TamSx3("Z02_PROD")[1], 0, 0, "G", "", "SB1", "", "", "MV_PAR02")

Return

Static Function TMSLinha(oPrint, nLin, nCol, cTit, oFont, nAlign)

    oPrint:Say(nLin, nCol, cTit, oFont, Nil, Nil, Nil, nAlign)

Return

// Ponto de Entrada

User Function MTA010MNU()

    AAdd( aRotina, { "Cores", "U_GridCor", 0, 6, 1, Nil })

Return

User Function GridCor()

    Private cXProd := SB1->B1_COD // Produto selecionado no browse.

    Private aHdrZ02 := {}
    Private aColZ02 := {}
    Private oGetDados

    MontaAHdr("Z02")
    LoadData("Z02")

    DEFINE MSDIALOG oDlg TITLE "Relação de Usuários" FROM 0, 0 TO 320, 800 COLORS 0, 16777215 PIXEL

        oGetDados := MsNewGetDados():New(035, 012, 130, 390, GD_INSERT + GD_UPDATE + GD_DELETE, ;
                        Nil, Nil, Nil, Nil, Nil, Nil, Nil, Nil, Nil, ;
                        oDlg, aHdrZ02, aColZ02)

        @ 140, 250 BUTTON oBtnConhec PROMPT "Confirmar" SIZE 059, 012 OF oDlg ACTION(Confirma()) PIXEL
        @ 140, 330 BUTTON oBtnConhec PROMPT "Fechar" SIZE 059, 012 OF oDlg ACTION(oDlg:End()) PIXEL

    ACTIVATE MSDIALOG oDlg CENTERED

Return

Static Function Confirma()

Return .T.

user function sfspoa()
MontaAHdr("Z02")

Return

Static Function MontaAHdr(cTabela)

    Local cAlias := cTabela

    SX3->(dbGoTop())
    SX3->(DbSetOrder(1))

    If  SX3->(DbSeek(cAlias))
        While (!SX3->(EOF())) //.And. SX3->X3_ARQUIVO == cAlias
            alert(SX3->X3_CAMPO)
            If X3Uso(SX3->X3_USADO)
                aAdd(aHdrZ02, X3Col(SX3->X3_CAMPO))
            EndIf
            SX3->(DbSkip())
        EndDo
    Endif

Return

Static Function LoadData(cTabela)

    Local cAlias := cTabela
    Local nSize := Len(aHdrZ02) + 1
    Local nCols := 1
    Local i := 1

    DbSelectArea(cAlias)

    (cAlias)->(DbGoTop())
    (cAlias)->(dbSetOrder(1))

    If (cAlias)->(dbSeek(xFilial(cTabela) + cXProd))

        While (!(cAlias)->(EOF())) .And. (cAlias)->Z03_PROD == cXProd
            // Inicializa uma linha vazia para poder percorrer pelos campos.
            aAdd(aColZ02, Array(nSize))

            For i := 1 to nSize - 1
                // Verifica se o "X3_CONTEXT" é diferente de VIRTUAL.
                If aHdrZ02[i][10] != "V"
                    // FieldGet retorna o valor do campo no banco de dados.
                    aColZ02[nCols][i] := FieldGet(FieldPos(aHdrZ02[i][2]))
                Else
                    // CriaVar dispara o inicializador padrão do campo.
                    aColZ02[nCols][i] := CriaVar(aHdrZ02[i][2], .T.)
                EndIf
            Next

            aColZ02[nCols][nSize] := .F.

            (cAlias)->(DbSkip())

            nCols++
        EndDo

    EndIf

    If Len(aColZ02) == 0
        aColZ02 := Array(nSize)

        aColZ02[1][nSize] := .F.
    EndIf

Return

Static Function X3Col(cCampo)

    Local aX3Col := {}

    //DBSelectArea("SX3")
    //DBSetOrder(2)
    SX3->(DBSetOrder(2))

    If SX3->(DbSeek(cCampo))
        aX3Col := { ;
            AllTrim(SX3->X3_TITULO)                                                            , ;
            SX3->X3_CAMPO                                                                        , ;
            SX3->X3_PICTURE                                                                    , ;
            SX3->X3_TAMANHO                                                                    , ;
            SX3->X3_DECIMAL                                                                    , ;
            SX3->X3_VALID                                                                        , ;
            SX3->X3_USADO                                                                        , ;
            SX3->X3_TIPO                                                                        , ;
            SX3->X3_F3                                                                            , ;
            SX3->X3_CONTEXT                                                                    , ;
            SX3->X3_CBOX                                                                        , ;
            SX3->X3_RELACAO                                                                      ;
        }
    EndIf

Return aX3Col

// MsSelect

User Function XSelect()

    Local aArea := GetArea()
    Local lOk := .F.
    Local cMsgAux := ""
    Local oDlg, oBtnCanc, oBtnConf
    Local nJanLarg := 600
    Local nJanAltu := 400

    Private aCores := {}
    Private cAliasTmp    := "TMP_" + RetCodUsr()
    Private oBrowChk
    Private cFiles
    Private cMark    := "OK"
    Private aCampos := {}
    Private aStruTmp := {}

    fCarrTab()

    DEFINE MSDIALOG oDlg TITLE "Exemplo MsSelect" FROM 000, 000  TO nJanAltu, nJanLarg COLORS 0, 16777215 PIXEL

        oBrowChk := MsSelect():New(    cAliasTmp, ;                                            //cAlias
                                        "TMP_OK", ;                                                //cCampo
                                        , ;                                                        //cCpo
                                        aCampos, ;                                                //aCampos
                                        , ;                                                        //lInv
                                        @cMark, ;                                                //cMar
                                        {003, 003, (nJanAltu/2)-28, (nJanLarg/2)-3},;        //aCord
                                        ,;                                                        //cTopFun
                                        ,;                                                        //cBotFun
                                        oDlg,;                                                    //oWnd
                                        ,;                                                        //uPar11
                                        )

        //Definindo que pode marcar um a um
        oBrowChk:oBrowse:lHasMark    := .T.

        //Definindo que pode marcar todos
        oBrowChk:oBrowse:lCanAllmark := .T.

        //Criando os botões
        @ (nJanAltu/2)-22,(nJanLarg/2-3)-(75*1)    BUTTON oBtnCanc PROMPT 'Cancelar'     OF oDlg SIZE 68,17 PIXEL ACTION oDlg:End()
        @ (nJanAltu/2)-22,(nJanLarg/2-3)-(75*2)    BUTTON oBtnConf PROMPT 'Confirmar'    OF oDlg SIZE 68,17 PIXEL ACTION (lOk:=.T., oDlg:End())

    ACTIVATE MSDIALOG oDlg CENTERED

    //Se foi confirmado a tela
    If lOk
        //Posiciona no topo e percorre os dados
        (cAliasTmp)->(DbGoTop())
        While !(cAliasTmp)->(EoF())
            //Se tiver checado
            If (cAliasTmp)->TMP_OK == cMark
                cMsgAux += "- " + (cAliasTmp)->TMP_COD + "("+Alltrim((cAliasTmp)->TMP_DESC)+")" + STR_PULA
            EndIf

            (cAliasTmp)->(DbSkip())
        EndDo

        //Se tiver dados checados
        If !Empty(cMsgAux)
            cMsgAux := "Os seguintes produtos foram checados: "+STR_PULA+cMsgAux
            Aviso('Atenção', cMsgAux, {'Ok'}, 03)
        EndIf
    EndIf

    //Se tiver aberto o alias, fecha e exclui o temporário
    If Select(cAliasTmp)>0
        (cAliasTmp)->(DbCloseArea())
    EndIf

    fErase(cAliasTmp + GetDBExtension())

    RestArea(aArea)

Return

// Carrega a tabela temporária
Static Function fCarrTab()

    Local cQuery := ""
    Local cAlias := GetNextAlias()

    If Select(cAliasTmp) > 0
        (cAliasTmp)->(dbCloseArea())
    EndIf

    fErase(cAliasTmp + GetDBExtension())

    // Estrutura (campo, tipo, tamanho, decimal).
    aStruTmp := {}

    aAdd(aStruTmp, { "TMP_OK", "C", 2, 0 })
    aAdd(aStruTmp, { "TMP_COD", "C", TamSx3("B1_COD")[1], 0 })
    aAdd(aStruTmp, { "TMP_PROD", "C", TamSx3("B1_DESC")[1], 0 })
    aAdd(aStruTmp, { "TMP_COR", "C", TamSx3("Z02_DESC")[1], 0 })

    //Criando tabela temporária
    cFiles := CriaTrab( aStruTmp, .T. )
    dbUseArea( .T., "DBFCDX", cFiles, cAliasTmp, .T., .F. )

    //Setando os campos que serão mostrados no MsSelect
    aCampos := {}
    aAdd(aCampos,{    "TMP_OK",        ,    " ",                ""})
    aAdd(aCampos,{    "TMP_COD",        ,    "Cod.Produto",    "@!"})
    aAdd(aCampos,{    "TMP_PROD",    ,    "Descricao",        "@!"})
    aAdd(aCampos,{    "TMP_COR",    ,    "Cor",            "@!"})

    cQuery := "SELECT SB1.B1_COD CODIGO, SB1.B1_DESC DESCRICAO, Z02.Z02_DESC COR " + ;
                "FROM " + RetSQLName("SB1") + " SB1 " + ;
                "INNER JOIN " + RetSQLName("Z02") + " Z02 ON (Z02.Z02_FILIAL = '" + xFilial("Z02") + "' AND Z02.Z02_PROD = SB1.B1_COD AND Z02.D_E_L_E_T_ <> '*') " + ;
                "WHERE SB1.B1_FILIAL = '" + xFilial("SB1") + "' AND SB1.D_E_L_E_T_ <> '*' "

    TCQuery cQuery New Alias (cAlias)

    While (!(cAlias)->(EOF()))
        RecLock(cAliasTmp, .T.)

        TMP_OK := Space(2)
        TMP_COD := (cAlias)->CODIGO
        TMP_PROD := (cAlias)->DESCRICAO
        TMP_COR := (cAlias)->COR

        (cAliasTmp)->(MsUnlock())

        (cAlias)->(dbSkip())
    EndDo

    (cAlias)->(dbCloseArea())

    (cAliasTmp)->(dbGoTop())

Return
