#INCLUDE "PROTHEUS.CH"
#INCLUDE "FILEIO.CH"

#DEFINE CRLF            CHR(13) + CHR(10)

#DEFINE CODFOR          1
#DEFINE NOMEFOR         2
#DEFINE RSOCIAL         3
#DEFINE ENDERECO        4
#DEFINE BAIRRO          5
#DEFINE CIDADE          6
#DEFINE ESTADO          7
#DEFINE CEP             8
#DEFINE FONE            9
#DEFINE EMAIL           12
#DEFINE CONTATO         13
#DEFINE CNPJ            14
#DEFINE INSCEST         15

User Function MsExFrnc()

    Local cPerg := "XIMPFRNC" // Nome da pergunta.

    AjusteSx1(cPerg)

    If Pergunte(cPerg, .T.)
        Processa({ || ImpFrnc() }, "Processando...")
    Else
        Alert("Importação cancelada pelo usuário!")
    EndIf

Return

Static Function ImpFrnc()

    aFornec := {}

    FT_FUse(AllTrim(MV_PAR01)) // Abre o arquivo.

    nLinAtu := 1 // Linha atual no arquivo.

    nQtdLin := FT_FLastRec() - 1 // Total de linhas do arquivo.

    FT_FGoTop() // Vai para o início do arquivo.
    FT_FSkip() // Pula o cabeçalho do arquivo.

    ProcRegua(nQtdLin - 1)

    While ! FT_FEOF()
        aFornec := {}


        IncProc("Processando linha " + cValToChar(nLinAtu) + " de " + cValToChar(nQtdLin) + "...")

        nLinAtu++

        cDados := AllTrim(FT_FReadLn())

        // Ajusta as colunas em branco para não ocorrer inconsistências na quantidade de colunas.
        While At(";;", cDados) > 0
            cDados := StrTran(cDados, ";;", "; ;")
        EndDo

        aDados := StrTokArr(cDados, ";")

        lMsErroAuto := .F.

        SA2->(dbGoTop())
        SA2->(dbSetOrder(1))

        // PadR: Adiciona espaços em branco à direita.
        If SA2->(dbSeek(xFilial("SA2") + PadR(aDados[CODFOR], TamSx3("A2_COD")[1]) + "01"))
            nOpc := 4

            aAdd(aFornec, { "A2_COD", SA2->A2_COD, Nil })
            aAdd(aFornec, { "A2_LOJA", SA2->A2_LOJA, Nil })
        Else
            nOpc := 3

            aAdd(aFornec, { "A2_COD", aDados[CODFOR], Nil })
            aAdd(aFornec, { "A2_LOJA", "01", Nil })
        EndIf

        aAdd(aFornec, { "A2_NOME", aDados[RSOCIAL], Nil })
        aAdd(aFornec, { "A2_NREDUZ", aDados[NOMEFOR], Nil })
        aAdd(aFornec, { "A2_TIPO", "J", Nil })
        aAdd(aFornec, { "A2_END", aDados[ENDERECO], Nil })
        aAdd(aFornec, { "A2_BAIRRO", aDados[BAIRRO], Nil })
        aAdd(aFornec, { "A2_EST", aDados[ESTADO], Nil })
        aAdd(aFornec, { "A2_ESTADO", aDados[ESTADO], Nil })
        aAdd(aFornec, { "A2_COD_MUN", "29005", Nil })
        aAdd(aFornec, { "A2_MUN", aDados[CIDADE], Nil })
        aAdd(aFornec, { "A2_CEP", AllTrim(StrTran(aDados[CEP], "-", "")), Nil })
        aAdd(aFornec, { "A2_CGC", AllTrim(StrTran(StrTran(SubStr(aDados[CNPJ], 2), "-", ""), "/", "")), Nil })

        MSExecAuto({ |x, y| MATA020(x, y) }, aFornec, nOpc)

        If lMsErroAuto
            MostraErro()
        EndIf

        FT_FSkip()
    EndDo

    //FClose(AllTrim(MV_PAR01))
Return

Static Function AjusteSx1(cPerg)

    PutSx1(cPerg, "01", "Local do arquivo", "", "", "MV_CH01", "C", 99, 0, 0, "G", "", "", "", "", "MV_PAR01")

Return
