#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"

#DEFINE CRLF CHR(13) + CHR(10)

User Function MontaGrid()

    Private cGetUser := Space(TamSx3("Z01_CPF")[1])
    Private cGetNUser := Space(TamSx3("Z01_NOME")[1])

    Private aHdrZ01 := {}   // Header.
    Private aColZ01 := {}   // Data.
    Private oGetDados       // Objeto da grid, ela em si.

    Private oGreen := LoadBitmap(GetResources(), "BR_VERDE")
    Private oRed := LoadBitmap(GetResources(), "BR_VERMELHO")

    MontaAHdr("Z01")
    LoadData("Z01", "Z01_IDADE")

    /**
     * Cria um novo dialog chamado oDlg.
     * O "FROM" é a (linha, coluna), assim como o "TO", ou seja,]
     * inicia na L-0, C-0 e acaba na L-320, C-800. Medida: PIXELS.
     *
     * O "ACTIVATE" ativa o dialog oDlg centralizado por conta do "CENTERED".
     */
    DEFINE MSDIALOG oDlg TITLE "Relação de Usuários" FROM 0, 0 TO 320, 800 COLORS 0, 16777215 PIXEL

        /**
         * 012: linha / 013: coluna.
         * SAY é um objeto cujo nome é oSayCPF.
         * PROMPT é uma propriedade de SAY.
         * Seu tamanho (SIZE) é em pixels. Largura: 25px / Altura: 7px.
         * SOMENTE LEITURA (READONLY).
         */
        @ 012, 013 SAY oSayCPF PROMPT "CPF" SIZE 025, 007 OF oDlg COLORS 0, 16777215 PIXEL
        @ 011, 041 MSGET oGetUser VAR cGetUser SIZE 050, 010 OF oDlg COLORS 0, 16777215 PIXEL READONLY PICTURE PesqPict("Z01", "Z01_CPF")
        @ 011, 100 MSGET oGetNUser VAR cGetNUser SIZE 120, 010 OF oDlg COLORS 0, 16777215 PIXEL READONLY

        // Responsável por criar a grid.
        oGetDados := MsNewGetDados():New(035, 012, 130, 390, GD_INSERT + GD_UPDATE + GD_DELETE, ;
                        Nil, Nil, Nil, Nil, Nil, Nil, Nil, Nil, Nil, ;
                        oDlg, aHdrZ01, aColZ01)

        // Não será executado porque oGetUser está READONLY.
        oGetUser:bChange := { || GetName() }

        oGetDados:bChange := { || SetFields() }

        @ 140, 250 BUTTON oBtnConhec PROMPT "Confirmar" SIZE 059, 012 OF oDlg ACTION(Confirma()) PIXEL
        @ 140, 330 BUTTON oBtnConhec PROMPT "Fechar" SIZE 059, 012 OF oDlg ACTION(oDlg:End()) PIXEL

    ACTIVATE MSDIALOG oDlg CENTERED

Return

User Function VldIdade()

    Local nIdade := M->Z01_IDADE
    Local nPosOk := GetFldPos(aHdrZ01, Nil, "COR")
    Local aDados := oGetDados:aCols
    Local nPosAtu := oGetDados:nAt

    If nIdade < 18
        aDados[nPosAtu][nPosOk] := oRed
    Else
        aDados[nPosAtu][nPosOk] := oGreen
    EndIf

    aColZ01 := aDados

    oGetDados:SetArray(aColZ01, .T.)
    oGetDados:Refresh()

Return .T.

User Function GridCpf()

    Local lRet := .T.
    Local nCont := 1
    Local nPosDel := Len(aHdrZ01) + 1
    Local nPosCpf := GetFldPos(aHdrZ01, Nil, "Z01_CPF")
    Local aDados := oGetDados:aCols
    Local nPosAtu := oGetDados:nAt
    Local cCpf := M->Z01_CPF

    If U_ValidCpf()
        For nCont := 1 To Len(aDados)
            If ! aDados[nCont][nPosDel] .And. aDados[nCont][nPosCpf] == cCpf .And. nPosAtu != nCont
                lRet := .F.

                Exit
            EndIf
        Next
    EndIf

    If ! lRet
        Alert("CPF já cadastrado na lista!")
    EndIf

Return lRet

Static Function SetFields()

    Local nPosCpf := GetFldPos(aHdrZ01, Nil, "Z01_CPF")
    Local nPosNome := GetFldPos(aHdrZ01, Nil, "Z01_NOME")
    Local nPosAtu := oGetDados:nAt
    Local aDados := oGetDados:aCols

    cGetUser := aDados[nPosAtu][nPosCpf]
    cGetNUser := aDados[nPosAtu][nPosNome]

    oGetUser:Refresh()
    oGetNUser:Refresh()

Return

Static Function GetName()

    Local aArea := GetArea()

    Z01->(dbSetOrder(1))
    Z01->(dbGoTop())

    If Z01->(dbSeek(xFilial("Z01") + cGetUser))
        cGetNUser := Z01->Z01_NOME

        oGetNUser:Refresh()
    Else
        Alert("CPF não encontrado!")

        cGetNUser := ""

        oGetNUser:Refresh()

        oGetUser:SetFocus()
    EndIf

    RestArea(aArea)

Return

Static Function Confirma()

    If ProcData()
        MsgInfo("Os dados foram gravados.", "Sucesso")

        aColZ01 := {}

        LoadData("Z01", "Z01_IDADE")

        oGetDados:SetArray(aColZ01, .T.)

        oGetDados:Refresh(.T.)
    Else
        Alert("Processamento falhou. Contate o TI.")
    EndIf

Return .T.

Static Function MontaAHdr(cTabela)

    Local cAlias := cTabela

    aAdd(aHdrZ01, { "STATUS", "COR", "@BMP", 1, 0, .T., "", "", "", "R", "", "" })

    SX3->(DbSetOrder(1))

    If  SX3->(DbSeek(cAlias))
        While (!SX3->(EOF())) .And. SX3->X3_ARQUIVO == cAlias
            If X3Uso(SX3->X3_USADO)
                aAdd(aHdrZ01, X3Col(SX3->X3_CAMPO))
            EndIf

            SX3->(DbSkip())
        EndDo
    Endif

Return

Static Function LoadData(cTabela, cCol)

    Local cAlias := cTabela
    Local nSize := Len(aHdrZ01) + 1
    Local nCols := 1
    Local i := 1

    DbSelectArea(cAlias)

    (cAlias)->(DbGoTop())

    While !(cAlias)->(EOF())
        // Inicializa uma linha vazia para poder percorrer pelos campos.
        aAdd(aColZ01, Array(nSize))

        For i := 1 to nSize - 1
            If i == 1
                If (cAlias)->(&(cCol)) < 18
                    aColZ01[nCols][i] := oRed
                Else
                    aColZ01[nCols][i] := oGreen
                EndIf
            Else
                // Verifica se o "X3_CONTEXT" é diferente de VIRTUAL.
                If aHdrZ01[i][10] != "V"
                    // FieldGet retorna o valor do campo no banco de dados.
                    aColZ01[nCols][i] := FieldGet(FieldPos(aHdrZ01[i][2]))
                Else
                    // CriaVar dispara o inicializador padrão do campo.
                    aColZ01[nCols][i] := CriaVar(aHdrZ01[i][2], .T.)
                EndIf
            EndIf
        Next

        aColZ01[nCols][nSize] := .F.

        (cAlias)->(DbSkip())

        nCols++
    EndDo

    If Len(aColZ01) == 0
        aColZ01 := Array(nSize)

        aColZ01[1][nSize] := .F.
    EndIf

Return

/**
 * Busca os dados de um determinado campo na X3 e retorna um vetor multidimensional.
 */
Static Function X3Col(cCampo)

    Local aX3Col := {}
    Local cValid := ""

    //DBSelectArea("SX3")
    //DBSetOrder(2)
    SX3->(DBSetOrder(2))

    If SX3->(DbSeek(cCampo))
        If AllTrim(Upper(cCampo)) == "Z01_CPF"
            cValid := "U_GRIDCPF()"
        ElseIf AllTrim(Upper(cCampo)) == "Z01_IDADE"
            cValid := "U_VLDIDADE()"
        Else
            cValid := SX3->X3_VALID
        EndIf

        aX3Col := { ;
            AllTrim(SX3->X3_TITULO)                                                            , ;
            SX3->X3_CAMPO                                                                      , ;
            SX3->X3_PICTURE                                                                    , ;
            SX3->X3_TAMANHO                                                                    , ;
            SX3->X3_DECIMAL                                                                    , ;
            cValid                                                                             , ;
            SX3->X3_USADO                                                                      , ;
            SX3->X3_TIPO                                                                       , ;
            SX3->X3_F3                                                                         , ;
            SX3->X3_CONTEXT                                                                    , ;
            SX3->X3_CBOX                                                                       , ;
            SX3->X3_RELACAO                                                                      ;
        }
    EndIf

Return aX3Col

Static Function GetFldPos(aHeader, nIndex, cField)

    Local nPos := 0

    Default nIndex := 2

    nPos := aScan(aHeader, { |x| AllTrim(Upper(x[nIndex])) == cField })

Return nPos

Static Function ProcData()

    Local nCont := 1
    Local nPosDel := Len(aHdrZ01) + 1
    Local nPosCpf := GetFldPos(aHdrZ01, Nil, "Z01_CPF")
    Local nPosNome := GetFldPos(aHdrZ01, Nil, "Z01_NOME")
    Local nPosIdade := GetFldPos(aHdrZ01, Nil, "Z01_IDADE")
    Local lOp := .F.
    Local lRet := .T.
    Local aDados := oGetDados:aCols

    If nPosCpf == 0 .OR. nPosNome == 0 .OR. nPosIdade == 0
        Alert("Campos inválidos. Abortando ação." + CRLF + ;
                "CPF: " + iIf(nPosCpf == 0, "Erro", "OK") + ;
                "Nome: " + iIf(nPosNome == 0, "Erro", "OK") + ;
                "Idade: " + iIf(nPosIdade == 0, "Erro", "OK") ;
        )

        lRet := .F.
    EndIf

    If lRet
        For nCont := 1 To Len(aDados)
            // Se não estiver marcado para exclusão.
            If ! aDados[nCont][nPosDel]
                Z01->(dbSetOrder(1))
                Z01->(dbGoTop())

                If Z01->(dbSeek(xFilial("Z01") + aDados[nCont][nPosCpf]))
                    lOp := .F.
                Else
                    lOp := .T.
                EndIf

                RecLock("Z01", lOp)

                If lOp
                    Z01_CPF := aDados[nCont][nPosCpf]
                EndIf

                Z01_NOME := aDados[nCont][nPosNome]
                Z01_IDADE := aDados[nCont][nPosIdade]

                Z01->(MsUnlock())
            Else
                Z01->(dbSetOrder(1))
                Z01->(dbGoTop())

                If Z01->(dbSeek(xFilial("Z01") + aDados[nCont][nPosCpf]))
                    RecLock("Z01", .F.)

                    dbDelete()

                    Z01->(MsUnlock())
                EndIf
            EndIf
        Next
    EndIf

Return lRet
