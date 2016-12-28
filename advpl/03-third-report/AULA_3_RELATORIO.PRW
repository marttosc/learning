#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"

#DEFINE CRLF               CHR(13) + CHR(10)
#DEFINE PAD_LEFT           0                //Alinhamento a Esquerda
#DEFINE PAD_RIGHT          1                //Alinhamento a Direita
#DEFINE PAD_CENTER         2                //Centralizado

// TMS Printer.

/**
 * PutSx1 - cria perguntas, vide TDN para parâmetros.
 *
 * TamSx3("nome do param") - retorna um Array com duas posições com o tamanho do campo no configurado e
 * o segundo com a quantidade de casas decimais.
 */

User Function RelCli()

    Local cPerg := "RelCli01" // Nome da pergunta.

    AjusteSx1(cPerg)

    If (Pergunte(cPerg, .T.))
        GeraRel()
    Else
        Alert("Relatório cancelado pelo usuário!")
    Endif

Return

Static Function AjusteSx1(cPerg)

    PutSx1(cPerg, "01", "Código de?", '', '', 'MV_CH01', 'C', TamSx3("A1_COD")[1], 0, 0, "G", "", "SA1", "", "", "MV_PAR01")
    PutSx1(cPerg, "02", "Loja de?", '', '', 'MV_CH03', 'C', TamSx3("A1_LOJA")[1], 0, 0, "G", "", "SA1", "", "", "MV_PAR02")
    PutSx1(cPerg, "03", "Código ate?", '', '', 'MV_CH02', 'C', TamSx3("A1_COD")[1], 0, 0, "G", "", "SA1", "", "", "MV_PAR03")
    PutSx1(cPerg, "04", "Loja ate?", '', '', 'MV_CH04', 'C', TamSx3("A1_LOJA")[1], 0, 0, "G", "", "SA1", "", "", "MV_PAR04")

Return

Static Function GeraRel()

    Local cCodDe := MV_PAR01
    Local cCodAte := MV_PAR03
    Local cLjDe := MV_PAR02
    Local cLjAte := MV_PAR04

    Local oP := TMSPrinter():New()                          // Objeto de impressão.
    Local aArea := GetArea()                                // Área da janela do Protheus.
    Local oFontTit, oFontPag, oFontMed, oFontNeg            // Fontes utilizadas.
    Local lNegrito := .T.                                   // Usará negrito.
    Local nLin := 350, nPag := 1                            // Linha mínima; página inicial.
    Local oBrush := TBrush():New(Nil, RGB(0, 0, 0))         // Pincel na cor preta.
    Local cQuery := ""                                      // Consulta SQL.
    Local aCabec := { "Código", "Loja", "Nome", "N Fantasia", "CNPJ" } // Cabeçalho da tabela.
    Local aExcel := {}                                      // Linhas da tabela com os dados.
    Local cLogo := "\content\logo.png"                      // Caminho da logo.
    Local nQtdCli := 0                                      // Quantidade total de clientes.

    oP:setLandscape()                                       // Configura a página para paisagem.

    oFontTit := TFont():New("Arial", 18, 18, .T., lNegrito, 5, .T., 5, .T., .F., .F.)
    oFontPag := TFont():New("Arial", 12, 12, .T., !lNegrito, 5, .T., 5, .T., .F., .F.)
    oFontNeg := TFont():New("Arial", 12, 12, .T., lNegrito, 5, .T., 5, .T., .F., .F.)
    oFontMed := TFont():New("Arial", 8, 8, .T., !lNegrito, 5, .T., 5, .T., .F., .F.)

    TMSLinha(oP, 160, 500, "Relatório de Clientes - Treinamento AdvPL II", oFontTit, PAD_LEFT)

    oP:SayBitmap(70, 1800, cLogo, 300, 120)

    oP:FillRect({ 280, 0, 285, 3000 }, oBrush) // Imprime uma linha (linha, col. inicial, espaço, col. final, pincel)

    cQuery := "SELECT A1_COD, A1_LOJA, A1_NOME, A1_NREDUZ, A1_CGC " + ;
                "FROM " + RetSQLName("SA1") + " " + ;
                "WHERE A1_FILIAL = '" + xFilial("SA1") + "' AND D_E_L_E_T_ <> '*' "

    If ! (Empty(AllTrim(cCodDe)))
        cQuery += "AND A1_COD >= '" + cCodDe + "' "
    EndIf

    If ! (Empty(AllTrim(cCodAte)))
        cQuery += "AND A1_COD <= '" + cCodAte + "' "
    EndIf

    If ! (Empty(AllTrim(cLjDe)))
        cQuery += "AND A1_LOJA >= '" + cLjDe + "' "
    EndIf

    If ! (Empty(AllTrim(cLjAte)))
        cQuery += "AND A1_LOJA <= '" + cLjAte + "' "
    EndIf

    nCol := 150 // Contador de colunas da tabela.
    TMSLinha(oP, nLin, nCol, "Código", oFontNeg, PAD_LEFT)

    nCol += 150
    TMSLinha(oP, nLin, nCol, "Loja", oFontNeg, PAD_LEFT)

    nCol += 300
    TMSLinha(oP, nLin, nCol, "Razão Social", oFontNeg, PAD_LEFT)

    nCol += 300
    TMSLinha(oP, nLin, nCol, "Nome Fantasia", oFontNeg, PAD_LEFT)

    nCol += 300
    TMSLinha(oP, nLin, nCol, "CNPJ", oFontNeg, PAD_LEFT)

    // Executa a consulta SQL.
    TCQuery cQuery Alias "QSA1" New

    QSA1->(DbGoTop())

    nLin := 350

    While ! (QSA1->(Eof()))
        nLin += 100 // Espaçamento por linha.
        nCol := 150 // Espaçamento por coluna.

        TMSLinha(oP, nLin, nCol, QSA1->A1_COD, oFontPag, PAD_LEFT)

        nCol += 150
        TMSLinha(oP, nLin, nCol, QSA1->A1_LOJA, oFontPag, PAD_LEFT)

        nCol += 300
        TMSLinha(oP, nLin, nCol, QSA1->A1_NOME, oFontPag, PAD_LEFT)

        nCol += 300
        TMSLinha(oP, nLin, nCol, QSA1->A1_NREDUZ, oFontPag, PAD_LEFT)

        nCol += 300
        TMSLinha(oP, nLin, nCol, AllTrim(Transform(QSA1->A1_CGC, "@E 99.999.999/9999-99")), oFontPag, PAD_LEFT)

        nQtdCli++

        If (nLin > 3000)
            oP:FillRect({3380, 0, 3385, 3000}, oBrush)

            TMSLinha(oP, 3400, 500, "Rodapé - Relatório de Clientes", oFontMed, PAD_CENTER)
            TMSLinha(oP, 3400, 2200, "Página " + cValToChar(nPag), oFontMed, PAD_CENTER)

            oP:EndPage()

            nPag++

            TMSLinha(oP, 160, 500, "Relatório de Clientes - Treinamento AdvPL II", oFontTit, PAD_LEFT)

            oP:SayBitmap(70, 1800, cLogo, 148, 40)

            oP:FillRect({ 280, 0, 285, 3000 }, oBrush)

            nCol := 150 // Contador de colunas da tabela.
            TMSLinha(oP, nLin, nCol, "Código", oFontNeg, PAD_LEFT)

            nCol += 150
            TMSLinha(oP, nLin, nCol, "Loja", oFontNeg, PAD_LEFT)

            nCol += 300
            TMSLinha(oP, nLin, nCol, "Razão Social", oFontNeg, PAD_LEFT)

            nCol += 300
            TMSLinha(oP, nLin, nCol, "Nome Fantasia", oFontNeg, PAD_LEFT)

            nCol += 300
            TMSLinha(oP, nLin, nCol, "CNPJ", oFontNeg, PAD_LEFT)

            nLin := 350
        EndIf

        aAdd(aExcel, { QSA1->A1_COD, QSA1->A1_LOJA, QSA1->A1_NOME, QSA1->A1_NREDUZ, AllTrim(Transform(QSA1->A1_CGC, "@E 99.999.999/9999-99")) })

        QSA1->(DbSkip())
    EndDo

    QSA1->(DbCloseArea())

    nLin += 100

    oP:FillRect({ nLin, 0, nLin + 5, 3000 }, oBrush)

    nLin += 105

    TMSLinha(oP, nLin, 150, "Total de clientes:", oFontNeg, PAD_LEFT)
    TMSLinha(oP, nLin, 1800, AllTrim(Transform(nQtdCli, "@E 999999")), oFontPag, PAD_RIGHT)

    oP:FillRect({ 3380, 0, 3385, 3000}, oBrush)

    // Rodapé.
    TMSLinha(oP, 3400, 500, "Rodapé - Relatório de Clientes", oFontMed, PAD_CENTER)
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

Static Function TMSLinha(oPrint, nLin, nCol, cTit, oFont, nAlign)

    oPrint:Say(nLin, nCol, cTit, oFont, Nil, Nil, Nil, nAlign)

Return
