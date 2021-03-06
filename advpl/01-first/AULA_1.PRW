#INCLUDE 'PROTHEUS.CH'

#DEFINE CRLF CHR(13) + CHR(10)

#DEFINE USR_NAME    1
#DEFINE USR_EMAIL   2
#DEFINE USR_AGE     3
#DEFINE USR_ACTV    4

/**
 * Declara��o de vari�veis:
 * Primeiro as locais, depois as privates e publics.
 */

// Exibe Hello World!
User Function HelloWorld()

    Alert("Hello world!")

Return

// Converter tipos de vari�veis.
User Function TpVar()

    Local xValor := "25/11/2016"

    Alert(CTOD(xValor))

    xValor := 123456789

    Alert(CVALTOCHAR(xValor))

    xValor := STOD("20161125") // N�o posso declarar diretamente.

    Alert(DTOC(xValor)) // Retorna a string "DD/MM/AAAA".

    Alert(DTOS(xValor)) // Usa para consultas no banco.

    xValor := 123

    Alert(STR(xValor))

    xValor := 123

    Alert(STRZERO(xValor, 6))

Return

// Manipular as strings.
User Function ManipStr()

    Local xValor := "   Gustavo   "

    Alert(xValor)

    xValor := AllTrim(xValor)

    Alert(xValor)

    Alert(At("t", xValor))

    Alert(At("V", xValor)) // Case sensitive!

    Alert(Len(xValor))

    Alert(Lower(xValor))

    Alert(Upper(xValor))

    Alert(Substr(xValor, 1, 3))

    Alert(Rat("a", "banana"))

    // Come�arei a partir da posi��o 1, retirarei 6 caracteres e colocarei "A capivara".
    Alert(Stuff("O rato roeu a roupa do rei de Roma.", 1, 6, "A capivara"))

Return

// Manipular os n�meros.
User Function ManipNum()

    Alert(Abs(-100))

    Alert(Int(3.14))

    Alert(NoRound(1.987654321, 3))

    Alert(Round(19.91785, 3))

Return

// Verifica o tipo de vari�vel.
User Function VrfTpVar()

    Local _str := "Gustavo"
    Private var := STOD("20161125")

    Alert(type("var"))
    Alert(valtype(var))
    Alert(valtype(_str))

Return

// Uso de estrutura de repeti��o.
User Function UseLoop()

    Local nCounter := nil // Contador do for.
    Local cFinal := "" // String que receber� os n�meros entre espa�os.

    For nCounter := 0 To 5
        cFinal += cValToChar(nCounter) + " "
    Next

    Alert(AllTrim(cFinal))

    nCounter := 0
    cFinal := ""

    While nCounter <= 10
        If nCounter % 2 == 0
            cFinal += cValToChar(nCounter) + " "
        Endif

        nCounter++
    End

    Alert(AllTrim(cFinal))

Return

// Retorna o m�s do servidor.
User Function GetMonth()

    Local nMes := Month(Date())

    Local cPeriod := ""

    Do Case
        Case nMes <= 3
            cPeriod := "Primeiro Trimestre"
        Case nMes >= 4 .And. nMes <= 6
            cPeriod := "Segundo Trimestre"
        Case nMes >= 7 .And. nMes <= 9
            cPeriod := "Terceiro Trimestre"
        Otherwise
            cPeriod := "Quarto Trimestre"
    EndCase

Return cPeriod

// Teste da fun��o MsgYesNo.
User Function SimNaoTst()

    If MsgYesNo("Deseja continuar?", "Aviso!")
        Alert("Continuando...")
    Else
        Alert("Saindo...")
    Endif

Return

// Teste de chamada de fun��o de usu�rio.
User Function CallFunc()

    u_HelloWorld()

    Alert(u_GetMonth())

    StaticFn()

Return

// Fun��o de usu�rio: pode ser chamada em qualquer lugar.
User Function UserFn()

    //

Return

// Fun��o est�tica: pode ser chamada somente no mesmo PRW.
Static Function StaticFn()

    //

Return

// Retorna um Array com os usu�rios.
User Function GetUsers()

    Local aUsers := {}

    aUsers := { ;
        { "Gustavo",         "protheus@totvs.com", 20, .T. }, ;
        { "Guilherme",     "protheus@totvs.com", 31, .F. }, ;
        { "Gabriela",        "protheus@totvs.com", 22, .T. }  ;
    }

Return aUsers

// Retorna um usu�rio.
User Function GetUser(aUser)

    Local cResult := ""

    cResult += aUser[USR_NAME] + CRLF
    cResult += aUser[USR_EMAIL] + CRLF
    cResult += cValToChar(aUser[USR_AGE]) + CRLF
    cResult += IIf(aUser[USR_ACTV], "Ativado", "Desativado")

Return cResult

// Teste de fun��o com par�metro.
User Function ComParam(aUsers)

    Local nCounter

    Default aUsers := {}

    Alert("Total de usu�rios: " + cValToChar(Len(aUsers)))

    For nCounter := 1 To Len(aUsers)
        Alert(u_GetUser(aUsers[nCounter]))
    Next

Return

// Executa as fun��es GetUsers e ComParam.
User Function RunArray()

    u_ComParam(u_GetUsers())

Return

// Manipulando Arrays.
User Function MnpArray()

    Local aArray     := {}
    Local aArrClo := {}
    Local aNomes     := { "Gustavo", "Bruno", "Ralfe" }
    Local aMulti     := { { "Jo�o", "Pedro" }, { "Jo�o", "Fagundes" }, { "Maria", "Santos" } }

    aAdd(aArray, 1)
    aAdd(aArray, 2)
    aAdd(aArray, 3)

    aArrClo := aClone(aArray)

    aSort(aNomes)

    Alert(aNomes[1] + CRLF + aNomes[2] + CRLF + aNomes[3])

    aSort(aNomes, , , { |x, y| x > y })

    Alert(aNomes[1] + CRLF + aNomes[2] + CRLF + aNomes[3])

    Alert(aScan(aNomes, "Gustavo"))

    Alert(aScan(aMulti, { |e| e[1] == "Jo�o" }))

Return

// Uso do DbEval.
User Function FnDbEval()

    SB1->(dbEval({ || Alert(SB1->B1_DESC) }))

Return

/**
 * Observa��o:
 * Se houver uma fun��o est�tica chamada "GetName" e uma fun��o de usu�rio
 * no mesmo PRW e esta �ltima chamar "GetName()", entretanto caso n�o houvesse
 * a est�tica nesse PRW, ele procuraria por "GetName" dentro das fun��es padr�es
 * do Protheus.
 *
 * Os define's s�o v�lidos apenas no PRW que foram instanciados.
 *
 * Conout (console out) = � a mesma fun��o que o Alert, por�m n�o exibe em tela,
 * mas sim no console do Protheus.
 */
