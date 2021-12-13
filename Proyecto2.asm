* Proyecto 2 EyPC: Convertidor
* Creado por:
* Luis Axel Nuñez Quintana
* Christian Alejandro Leyva Mercado

* DECLARACION CONSTANTES	**********************************************************************

SCDR   EQU   $102F
SCCR2  EQU   $102D
SCSR   EQU   $102E
SCCR1  EQU   $102C
BAUD   EQU   $102B
HPRIO  EQU   $103C
SPCR   EQU   $1028
CSCTL  EQU   $105D
OPT2   EQU   $1038
DDRD   EQU   $1009

* DECLARACION DE VARIABLES 	**********************************************************************

ORDEN EQU $0000
U1    EQU $0001
U2    EQU $0002
U3    EQU $0003
U4    EQU $0004
CONT  EQU $0005
NUM   EQU $0006
REF   EQU $0007
REFT  EQU $0008
REFC  EQU $0009
REFL  EQU $0010
REFD  EQU $0011
REFM  EQU $0012
CARACTER  EQU $0013
RESULTADO  EQU $0014
DIFZ  EQU $0015

DUMP  EQU $0050

*DECLARACION DE FUNCIONES	**********************************************************************

***********************************
* MAIN
***********************************

      ORG $8000
      LDS #$00FF
      JSR SERIAL

START 
      JSR LIMPIAMEMO
      CLR U1
      CLR U2
      CLR U3
      CLR U4
      CLR CONT
      JSR ENTRADA 

      LDAA U1
      LDAB U2
      CBA
      BEQ ERROR
      
      CLR U3
      JSR LONGITUD

      LDAA U3
      BNE ERROR
      
      JSR COMPRUEBA

      LDAA U3
      BNE ERROR
      
      JSR CONVIERTE

      LDAA U3
      BNE ERROR

      JSR ESCRIBELETRAS
      JMP ESPERAOK

ERROR
      JSR LIMPIAYERROR

ESPERAOK
      JSR ESPERAOK1
      JMP START

* FUNCIONES LECTURA	**********************************************************************

***********************************
* Lectura de Datos
***********************************
ENTRADA
      LDAA #'?
      STAA ORDEN
CICLO
      LDAA ORDEN
      CMPA #'?
      BEQ  CICLO
       
      CLR U3
      CLR U4

      JSR ESDIGITO
      JSR ESROMANO
      JSR NOESNINGUNO

      LDAA ORDEN
      STAA $00,X
      INX 

      CMPA #'=
      BNE ENTRADA
      
      RTS

***********************************
* Es digito?
***********************************
ESDIGITO
      LDAA ORDEN
      LDAB #'/
      CBA            
      BLT NOESDIGITO
      LDAB #':
      CBA
      BGT NOESDIGITO
      
      LDAB #$1
      STAB U1

      LDAB #$1
      STAB U3
      
      TAB
      LDAA CONT
      ADDA #$1
      STAA CONT
      TBA

NOESDIGITO
      RTS

***********************************
* Es romano?
***********************************
ESROMANO
      LDAA ORDEN
      LDAB #'I
      CBA            
      BEQ SIESROMANO

      LDAB #'V
      CBA
      BEQ SIESROMANO

      LDAB #'X
      CBA
      BEQ SIESROMANO

      LDAB #'L
      CBA
      BEQ SIESROMANO

      LDAB #'C
      CBA
      BEQ SIESROMANO

      LDAB #'D
      CBA
      BEQ SIESROMANO

      LDAB #'M
      CBA
      BNE NOESROMANO

SIESROMANO
      LDAB #$1
      STAB U2

      LDAB #$1
      STAB U4

      TAB
      LDAA CONT
      ADDA #$1
      STAA CONT
      TBA

NOESROMANO
      RTS

***********************************
* Es algo que no es digito ni romano ni =?
***********************************
NOESNINGUNO
      LDAA ORDEN
      CMPA #'=
      BEQ ESALGO

      LDAA U3
      CMPA #$1
      BEQ ESALGO

      LDAA U4
      CMPA #$1
      BEQ ESALGO
  
      LDAA #$1
      STAA U1

      LDAA #$1
      STAA U2
ESALGO

      RTS

* FUNCIONES LONGITUD	**********************************************************************

***********************************
* Comprueba longitud
***********************************
LONGITUD
      LDAA U1
      CMPA #$1
      BEQ ESNUMERO1

      LDAA U2
      CMPA #$1
      BEQ ESROMANO1

ESNUMERO1
      LDAA CONT
      CMPA #$5
      BLT FINLONGITUD
      LDAA #$1
      STAA U3

ESROMANO1
      LDAA CONT
      CMPA #$16
      BLT FINLONGITUD
      LDAA #$1
      STAA U3
      
FINLONGITUD
      RTS

* FUNCIONES COMPROBACION	**********************************************************************

***********************************
* COMPRUEBA
***********************************
COMPRUEBA 
      CLR U3
      LDAA U1
      CMPA #$1    
      BNE SIGUET
      JSR COMPDIG

SIGUET
      RTS

***********************************
* COMPRUEBA DIGITO   <- convierte a romano, lo escribe y *prende U3 si error*
***********************************
COMPDIG
      LDAA DUMP
      CMPA #'0
      BNE DIGCORRECTO
      LDAA #$1
      STAA U3

DIGCORRECTO
  
      RTS

*************
* CONVIERTE
*************
CONVIERTE
      CLR U3 * Bandera error
      XGDX
      STAB RESULTADO
      LDAA U1 * Bandera digitos
      CMPA #$1 
      BEQ CDIGITO  * Si es digito
      JSR CONVROMANO  * Si es romano
      LDAB U3
      CMPB #$1 * Se verifica si no hay un error
      BEQ TERMCONV
      JSR TRANSFORMACIONHEX *No hay error y escribe el numero en memoria en ASCII

CDIGITO
      JSR CONVDIGITO
TERMCONV
      RTS
*************
* CONVIERTE ROMANO
*************

CONVROMANO 
      LDD #DUMP   * Direccion base ($0050)
      ADDB CONT    * $Direccion base + N caracteres
      SUBB #1
      XGDY
      LDAA $00,Y  * Arreglo[n] -> CONT contiene el numero de caracteres que ingresaron    

      STAA CARACTER * Almacena el caracter en posicion actual
      LDX #0      * X -> CONT=0
      CLR NUM 
      CLR REF * CIV
      CLR REFT
      CLR REFC
      CLR REFL
      CLR REFD
      CLR REFM
      * En este punto A tiene el valor de un caracter romano (i)
      
NEXTI
      LDAA CARACTER
      LDAB #'I 
      CBA            
      BNE NEXTV
      JSR ROMI

      ** INCREMENTA CONT
      LDAA CONT * Incrementa el contador para comprobar que se haya terminado de leer
      SUBA #1
      STAA CONT
      ** VERIFICA ERROR
      LDAB  U3
      CMPB #$1 * Se verifica si no hay un error
      BNE NEXTI
      RTS * SI HAY ERROR SE SALE

NEXTV
      LDAA CARACTER
      LDAB #'V
      CBA
      BNE NEXTX 
      JSR ROMV
      
      ** INCREMENTA CONT
      LDAA CONT * Incrementa el contador para comprobar que se haya terminado de leer
      SUBA #1
      STAA CONT
      ** VERIFICA ERROR
      LDAB  U3
      CMPB #$1 * Se verifica si no hay un error
      BNE NEXTX
      RTS * SI HAY ERROR SE SALE

NEXTX
      LDAA CARACTER
      LDAB #'X
      CBA
      BNE NEXTL 
      JSR ROMX
      
      ** INCREMENTA CONT
      LDAA CONT * Incrementa el contador para comprobar que se haya terminado de leer
      SUBA #1
      STAA CONT
      ** VERIFICA ERROR
      LDAB  U3
      CMPB #$1
      CBA * Se verifica si no hay un error
      BNE NEXTX
      RTS * SI HAY ERROR SE SALE

NEXTL
      LDAA CARACTER
      LDAB #'L
      CBA
      BNE NEXTC 
      JSR ROML
      
      ** INCREMENTA CONT
      LDAA CONT * Incrementa el contador para comprobar que se haya terminado de leer
      SUBA #1
      STAA CONT
      ** VERIFICA ERROR
      LDAB  U3
      CMPB #$1
      CBA * Se verifica si no hay un error
      BNE NEXTC
      RTS * SI HAY ERROR SE SALE

NEXTC
      LDAA CARACTER
      LDAB #'C
      CBA
      BNE NEXTD 
      JSR ROMC
      
      ** INCREMENTA CONT
      LDAA CONT * Incrementa el contador para comprobar que se haya terminado de leer
      SUBA #1
      STAA CONT
      ** VERIFICA ERROR
      LDAB  U3
      CMPB #$1
      CBA * Se verifica si no hay un error
      BNE NEXTC
      RTS * SI HAY ERROR SE SALE

NEXTD
      LDAA CARACTER
      LDAB #'D
      CBA
      BNE NEXTM 
      JSR ROMD
      
      ** INCREMENTA CONT
      LDAA CONT * Incrementa el contador para comprobar que se haya terminado de leer
      SUBA #1
      STAA CONT
      ** VERIFICA ERROR
      LDAB  U3
      CMPB #$1
      CBA * Se verifica si no hay un error
      BNE NEXTM
      RTS * SI HAY ERROR SE SALE

NEXTM
      LDAA CARACTER
      LDAB #'M
      CBA
      BNE ERRORCROM
      JSR ROMM
      
      ** INCREMENTA CONT
      LDAA CONT * Incrementa el contador para comprobar que se haya terminado de leer
      SUBA #1
      STAA CONT
      ** VERIFICA ERROR
      LDAB  U3
      CMPB #$1
      CBA * Se verifica si no hay un error
      BNE NEXTM
      RTS * SI HAY ERROR SE SALE

VALIDAFIN
      LDAA CONT
      ADDA #DUMP
      LDAB #DUMP 
      CBA * Se comprueba que no este fuera del arreglo i<n
      BLE ERRORCROM
      RTS

ERRORCROM
      * si no es ninguno de los casos, es un error
      JSR ERRORCONV
      RTS


********
* CASOS ROM
******

ROMI
      LDAB REF
      CMPB #3
      BGE ERRI   * Si REF>= 3 error
      INX *NUM ++
      LDAA REF
      ADDA #1
      STAA REF * REF = REF + 1
      DEY * Recorre el arreglo 
      LDAA $00,Y  * Arreglo[n]    
      STAA CARACTER
      RTS

ERRI
      JSR ERRORCONV
      RTS

ROMV
      LDAB REF
      CMPB #4
      BGE ERRV   * Si REF>= 4 error
      LDAB #5
      ABX * NUM = NUM + 5
      LDAA REF
      ADDA #1
      STAA REF * REF = REF + 1
      DEY * Recorre el arreglo 
      LDAA $00,Y  * Arreglo[n]
      STAA CARACTER
      CMPA #'I
      BNE SIGROMV
      LDAA REF
      CMPA #1
      BNE ERRV
      DEX * NUM - 1
      ADDA #1
      STAA REF * REF++
      LDAA CONT
      SUBA #1
      STAA CONT * recorre el i
      DEY * Recorre el arreglo 
      LDAA $00,Y  * Arreglo[n]
      STAA CARACTER

SIGROMV
      RTS

ERRV
      JSR ERRORCONV
      RTS

ROMX
      LDAB REFT
      CMPB #3
      BGE ERRX   * Si REF>= 3 error
      LDAB #10
      ABX * NUM = NUM + 10
      ADDB #1
      STAB REF * REF = REF +1
      LDAA REFT
      ADDA #1
      STAA REFT * REFT = REFT + 1
      DEY * Recorre el arreglo 
      LDAA $00,Y  * Arreglo[n]
      STAA CARACTER
      CMPA #'I * CAR = I ?
      BNE SIGROMX
      LDAA REFT
      CMPA #1
      BNE ERRX
      DEX * NUM = NUM - 1
      ADDA #1
      STAA REFT * REFT ++
      LDAB REF
      ADDB #1
      STAB REF *REF++
      LDAA CONT
      SUBA #1
      STAA CONT * recorre el i
      DEY * Recorre el arreglo 
      LDAA $00,Y  * Arreglo[n]
      STAA CARACTER

SIGROMX
      RTS
ERRX
      JSR ERRORCONV
      RTS

ROML
      LDAB #50
      ABX * NUM = NUM +50
      LDAA REF
      ADDA #1
      STAA REF
      LDAB REFL
      ADDB #1
      STAB REFL
      DEY * Recorre el arreglo 
      LDAA $00,Y  * Arreglo[n]
      STAA CARACTER
      CMPA #'X
      BNE SIGROML
      CMPB #1 * REFL =1?
      BNE ERRL
      LDAA REFT
      CMPA #0
      BNE ERRL
      XGDX * Para restarle 10 a X, se debe intercambiar con D
      SUBD #10 * D-10
      XGDX * NUM = D-10
      LDAA REF
      ADDA #1
      STAA REF
      LDAA CONT * Se aumenta el contador del ciclo for
      SUBA #1
      STAA CONT * recorre el i
      DEY * Recorre el arreglo 
      LDAA $00,Y  * Arreglo[n]
      STAA CARACTER

SIGROML
      RTS
ERRL
      JSR ERRORCONV
      RTS

ROMC
      LDAB REFC
      CMPB #3
      BGE ERRC   * Si REF>= 3 error
      LDAB #100
      ABX * NUM = NUM + 100
      LDAA REF
      ADDA #1
      STAA REF
      LDAB REFC
      ADDB #1
      STAB REFC
      DEY * Recorre el arreglo 
      LDAA $00,Y  * Arreglo[n]
      STAA CARACTER
      CMPA #'X * CAR = X ?
      BNE SIGROMC
      LDAA REFC
      CMPA #1
      BNE ERRC
      XGDX * Para restarle 10 a X, se debe intercambiar con D
      SUBD #10 * D-10
      XGDX * NUM = D-10
      LDAA REF
      ADDA #1
      STAA REF
      LDAA REFC
      ADDA #1
      STAA REFC
      LDAA CONT * Se aumenta el contador del ciclo for
      SUBA #1
      STAA CONT * recorre el i
      DEY * Recorre el arreglo 
      LDAA $00,Y  * Arreglo[n]
      STAA CARACTER
      
SIGROMC
      RTS
ERRC
      JSR ERRORCONV
      RTS

ROMD
      XGDX * Para sumarle 500 a X, se debe intercambiar con D
      ADDD #500 * D+500
      XGDX * NUM = D+500
      LDAA REF
      ADDA #1
      STAA REF
      LDAB REFD
      ADDB #1
      STAB REFD
      DEY * Recorre el arreglo 
      LDAA $00,Y  * Arreglo[n]
      STAA CARACTER
      CMPA #'C * CAR = X ?
      BNE SIGROMD
      LDAB REFC
      CMPB #0
      BNE ERRD
      LDAB REFD
      CMPB #1
      BNE ERRD
      XGDX * Para restarle 10 a X, se debe intercambiar con D
      SUBD #100 * D-100
      XGDX * NUM = D-100
      LDAA REF
      ADDA #1
      STAA REF
      LDAA REFC
      ADDA #1
      STAA REFC
      LDAA CONT * Se aumenta el contador del ciclo for
      SUBA #1
      STAA CONT * recorre el i
      DEY * Recorre el arreglo 
      LDAA $00,Y  * Arreglo[n]
      STAA CARACTER

SIGROMD
      RTS
ERRD
      JSR ERRORCONV
      RTS

ROMM
      XGDX * Para sumarle 500 a X, se debe intercambiar con D
      ADDD #1000 * D+1000
      XGDX * NUM = D+1000
      LDAA REF
      ADDA #1
      STAA REF
      LDAB REFM
      ADDB #1
      STAB REFM
      DEY * Recorre el arreglo 
      LDAA $00,Y  * Arreglo[n]
      STAA CARACTER
      CMPA #'C * CAR = X ?
      BNE SIGROMM
      LDAB REFM
      CMPB #1
      BNE ERRM
      XGDX * Para restarle 10 a X, se debe intercambiar con D
      SUBD #100 * D-100
      XGDX * NUM = D-100
      LDAA REF
      ADDA #1
      STAA REF
      LDAA REFM
      ADDA #1
      STAA REFM
      LDAA CONT * Se aumenta el contador del ciclo for
      SUBA #1
      STAA CONT * recorre el i
      DEY * Recorre el arreglo 
      LDAA $00,Y  * Arreglo[n]
      STAA CARACTER
  
SIGROMM  
      RTS
ERRM
      JSR ERRORCONV
      RTS

*************
* CONVIERTE DIGITO
*************

CONVDIGITO  
      LDD #DUMP   * Direccion base ($0050)
      XGDY
      LDAA $00,Y  * Arreglo[n] -> CONT contiene el numero de caracteres que ingresaron    
      SUBA #$30 * Se resta 30 debido a que en ASCII los numeros estan del 30-39
      *LDX #0      * X -> CONT=0
      CLR DIFZ
      LDD #$0000
      ADDB RESULTADO   * Direccion a escribir
      XGDY
      LDX #DUMP
      LDAA $00,X
      SUBA #$30
      STAA NUM

FORDIGI
      LDAA NUM
      LDAB #DUMP 
      ADDB CONT
      CMPB #DUMP * Se comprueba que no este fuera del arreglo i<n
      BLE NOENTRADIGI
      JSR FOREACHDEC
      LDAB CONT
      SUBB #1
      STAB CONT
      LDAB U3
      CMPB #$1 * Se verifica si no hay un error
      BEQ NOENTRADIGI
      JMP FORDIGI

NOENTRADIGI
      RTS

FOREACHDEC
      LDAA NUM
      LDAB CONT
      CMPA #0
      BEQ NEXTDEC

FORMILES
      CMPB #4
      BNE FORCENT 
      CLR DIFZ
      JSR MILESDEC
      RTS

FORCENT
      CMPB #3
      BNE FORDEC
      CLR DIFZ
      JSR CENTDEC
      RTS

FORDEC
      CMPB #2
      BNE FORUNI
      CLR DIFZ
      JSR DECDEC
      RTS

FORUNI
      CLR DIFZ
      JSR UNIDEC

NEXTDEC
      RTS


***********
* MILES
***********

MILESDEC
      LDAA NUM
      CMPA DIFZ
      BLE EXITMILES *IF i<= Num
      LDAB #'M
      STAB $00,y * SE ESCRIBE EL NUMERO ROMANO
      INY
      LDAA DIFZ
      ADDA #1
      STAA DIFZ
      JMP MILESDEC

EXITMILES
      INX
      LDAA $00,X
      SUBA #$30
      STAA NUM
      RTS

***********
* CENTENAS
***********

CENTDEC
      LDAA NUM
      * HAY 5 CASOS POSIBLES 100-300 (1)-> C^n ; 400 (2)-> CD ; 500 (3)->  ;900 (4)-> CM; 600-800 (5)-> DC^n
      CMPA #3
      BLE CENTUNO
      CMPA #4
      BEQ CENTDOS
      CMPA #5
      BEQ CENTTRES
      CMPA #9
      BEQ CENTCUATRO
      JSR CENTCINCO
      RTS

CENTUNO
      LDAA NUM
      CMPA DIFZ
      BLE  ECUNO *If i<= Num
      LDAB #'C
      STAB $00,y * SE ESCRIBE EL NUMERO ROMANO
      INY
      LDAA DIFZ
      ADDA #1
      STAA DIFZ
      JMP CENTUNO

ECUNO
      INX
      LDAA $00,X
      SUBA #$30
      STAA NUM
      RTS

CENTDOS
      LDAB #'C
      STAB $00,y * SE ESCRIBE EL NUMERO ROMANO
      INY
      LDAB #'D
      STAB $00,y * SE ESCRIBE EL NUMERO ROMANO
      INY
      INX
      LDAA $00,X
      SUBA #$30
      STAA NUM
      RTS

CENTTRES
      LDAB #'D
      STAB $00,y * SE ESCRIBE EL NUMERO ROMANO
      INY
      INX
      LDAA $00,X
      SUBA #$30
      STAA NUM
      RTS

CENTCUATRO
      LDAB #'C
      STAB $00,y * SE ESCRIBE EL NUMERO ROMANO
      INY
      LDAB #'M
      STAB $00,y * SE ESCRIBE EL NUMERO ROMANO
      INY
      INX
      LDAA $00,X
      SUBA #$30
      STAA NUM
      RTS

CENTCINCO
      LDAB #'D
      STAB $00,y * SE ESCRIBE EL NUMERO ROMANO
      INY
      LDAA DIFZ
      ADDA #5
      STAA DIFZ
CICLOCENTCINCO
      LDAA NUM
      CMPA DIFZ
      BLE  ECCINCO *If i<= Num
      LDAB #'C
      STAB $00,y * SE ESCRIBE EL NUMERO ROMANO
      INY
      LDAA DIFZ
      ADDA #1
      STAA DIFZ
      JMP CICLOCENTCINCO
ECCINCO
      INX
      LDAA $00,X
      SUBA #$30
      STAA NUM
      RTS

***********
* DECENAS
***********

DECDEC
      LDAA NUM
      * HAY 5 CASOS POSIBLES 10-30 (1)-> X^n ; 40 (2)-> XL ; 50 (3)-> L ;90 (4)-> XC; 60-80 (5)-> LX^n
      CMPA #3
      BLE DECUNO
      CMPA #4
      BEQ DECDOS
      CMPA #5
      BEQ DECTRES
      CMPA #9
      BEQ DECCUATRO
      JSR DECCINCO
      RTS

DECUNO
      LDAA NUM
      CMPA DIFZ
      BLE  EDUNO *If i<= Num
      LDAB #'X
      STAB $00,y * SE ESCRIBE EL NUMERO ROMANO
      INY
      LDAA DIFZ
      ADDA #1
      STAA DIFZ
      JMP DECUNO

EDUNO
      INX
      LDAA $00,X
      SUBA #$30
      STAA NUM
      RTS

DECDOS
      LDAB #'X
      STAB $00,y * SE ESCRIBE EL NUMERO ROMANO
      INY
      LDAB #'L
      STAB $00,y * SE ESCRIBE EL NUMERO ROMANO
      INY
      INX
      LDAA $00,X
      SUBA #$30
      STAA NUM
      RTS

DECTRES
      LDAB #'L
      STAB $00,y * SE ESCRIBE EL NUMERO ROMANO
      INY
      INX
      LDAA $00,X
      SUBA #$30
      STAA NUM
      RTS

DECCUATRO
      LDAB #'X
      STAB $00,y * SE ESCRIBE EL NUMERO ROMANO
      INY
      LDAB #'C
      STAB $00,y * SE ESCRIBE EL NUMERO ROMANO
      INY
      INX
      LDAA $00,X
      SUBA #$30
      STAA NUM
      RTS

DECCINCO
      LDAB #'L
      STAB $00,y * SE ESCRIBE EL NUMERO ROMANO
      INY
      LDAA DIFZ
      ADDA #5
      STAA DIFZ
CICLODECCINCO
      LDAA NUM
      CMPA DIFZ
      BLE  EDCINCO *If i<= Num
      LDAB #'X
      STAB $00,y * SE ESCRIBE EL NUMERO ROMANO
      INY
      LDAA DIFZ
      ADDA #1
      STAA DIFZ
      JMP CICLODECCINCO
EDCINCO
      INX
      LDAA $00,X
      SUBA #$30
      STAA NUM
      RTS

***********
* UNIDADES
***********

UNIDEC
      LDAA NUM
      * HAY 5 CASOS POSIBLES 1-3 (1)-> I^n ; 4 (2)-> IV ; 5 (3)-> V ;9 (4)-> IX; 600-800 (5)-> VI^n
      CMPA #3
      BLE UNIUNO
      CMPA #4
      BEQ UNIDOS
      CMPA #5
      BEQ UNITRES
      CMPA #9
      BEQ UNICUATRO
      JSR UNICINCO
      RTS

UNIUNO
      LDAA NUM
      CMPA DIFZ
      BLE  EUUNO *If i<= Num
      LDAB #'I
      STAB $00,y * SE ESCRIBE EL NUMERO ROMANO
      INY
      LDAA DIFZ
      ADDA #1
      STAA DIFZ
      JMP UNIUNO

EUUNO
      INX
      LDAA $00,X
      SUBA #$30
      STAA NUM
      RTS

UNIDOS
      LDAB #'I
      STAB $00,y * SE ESCRIBE EL NUMERO ROMANO
      INY
      LDAB #'V
      STAB $00,y * SE ESCRIBE EL NUMERO ROMANO
      INY
      INX
      LDAA $00,X
      SUBA #$30
      STAA NUM
      RTS

UNITRES
      LDAB #'V
      STAB $00,y * SE ESCRIBE EL NUMERO ROMANO
      INY
      INX
      LDAA $00,X
      SUBA #$30
      STAA NUM
      RTS

UNICUATRO
      LDAB #'I
      STAB $00,y * SE ESCRIBE EL NUMERO ROMANO
      INY
      LDAB #'X
      STAB $00,y * SE ESCRIBE EL NUMERO ROMANO
      INY
      INX
      LDAA $00,X
      SUBA #$30
      STAA NUM
      RTS

UNICINCO
      LDAB #'V
      STAB $00,y * SE ESCRIBE EL NUMERO ROMANO
      INY
      LDAA DIFZ
      ADDA #5
      STAA DIFZ
CICLOUNICINCO
      LDAA NUM
      CMPA DIFZ
      BLE  ECUINCO *If i<= Num
      LDAB #'I
      STAB $00,y * SE ESCRIBE EL NUMERO ROMANO
      INY
      LDAA DIFZ
      ADDA #1
      STAA DIFZ
      JMP CICLOUNICINCO
ECUINCO
      INX
      LDAA $00,X
      SUBA #$30
      STAA NUM
      RTS

*************
* ERROR en CONVIERTE
*************
ERRORCONV
      LDAA #$1
      STAA U3
      RTS


* FUNCIONES TRANSFORMACION	**********************************************************************
* Le llega el numero hexadecimal a colocar en decimal en la memoria en X

TRANSFORMACIONHEX 
      CLR DIFZ *BANDERA DE YA VIMOS ALGO DIFERENTE A 0
      LDD #$0000
      ADDB RESULTADO   * Direccion a escribir
      XGDY * Se coloca la direccion a escribir en Y
      XGDX  *Intercambia el contenido de X con el de D, por lo tanto D tiene el numero a transformar

MILES     
      LDX #1000 * CARGAMOS DIVISOR
      IDIV      * D -> RESIDUO, X -> ENTERO
      PSHA      * GUARDAMOS RESIDUO EN PILA
      PSHB

      CPX #$0000 * SI X ES 0, VAMOS A CENTENAS
      BEQ CENT


      XGDX       * TOTAL EN B
      ADDB #$30
      STAB $00,y * GUARDAMOS TOTAL RESPECTO A Y
      INY        * SIGUIENTE LOCALIDAD PARA GUARDAR SIGUIENTE NUM
      LDAA #$1   * ACTIVAMOS BANDERA DE YA VIMOS ALGO 
      STAA DIFZ     * ACTUALIZAMOS BANDERA

CENT
      LDX #100   * CARGAMOS DIVISOR
      PULB       * CARGAMOS RESIDUO DE PASADA, AHORA DIVIDENDO
      PULA
      IDIV       * D -> RESIDUO, X -> ENTERO
      PSHA       * GUARDAMOS RESIDUO EN PILA
      PSHB

      CPX #$0000  * SI X ES DIFERENTE DE 0, NO CHECAMOS BANDERA
      BNE BANDERA1
 
      LDAA DIFZ    * CARGAMOS BANDERA
      BEQ DEC    * SI BANDERA ES 0 VAMOS A DECENAS

BANDERA1

      XGDX       * TOTAL EN B
      ADDB #$30
      STAB $00,y * GUARDAMOS TOTAL RESPECTO A Y
      INY        * SIGUIENTE LOCALIDAD PARA GUARDAR SIGUIENTE NUM
      LDAA #$1   * ACTIVAMOS BANDERA DE YA VIMOS ALGO 
      STAA DIFZ     * ACTUALIZAMOS BANDERA
      
DEC
      LDX #10    * CARGAMOS DIVISOR
      PULB       * CARGAMOS RESIDUO DE PASADA, AHORA DIVIDENDO
      PULA
      IDIV       * D -> RESIDUO, X -> ENTERO
      PSHA       * GUARDAMOS RESIDUO EN PILA
      PSHB

      CPX #$0000  * SI X ES DIFERENTE DE 0, NO CHECAMOS BANDERA
      BNE BANDERA2
 
      LDAA DIFZ    * CARGAMOS BANDERA
      BEQ UNI    * SI BANDERA ES 0 VAMOS A DECENAS

BANDERA2

      XGDX       * TOTAL EN B
      ADDB #$30
      STAB $00,y * GUARDAMOS TOTAL RESPECTO A Y
      INY        * SIGUIENTE LOCALIDAD PARA GUARDAR SIGUIENTE NUM
      LDAA #$1   * ACTIVAMOS BANDERA DE YA VIMOS ALGO 
      STAA DIFZ     * ACTUALIZAMOS BANDERA
UNI

      LDX #1     * CARGAMOS DIVISOR
      PULB       * CARGAMOS RESIDUO DE PASADA, AHORA DIVIDENDO
      PULA
      IDIV       * D -> RESIDUO, X -> ENTERO

      CPX #$0000  * SI X ES DIFERENTE DE 0, NO CHECAMOS BANDERA
      BNE BANDERA3
 
      LDAA DIFZ    * CARGAMOS BANDERA
      BEQ FIN    * SI BANDERA ES 0 VAMOS A DECENAS

BANDERA3

      XGDX       * TOTAL EN B
      ADDB #$30
      STAB $00,y * GUARDAMOS TOTAL RESPECTO A Y
      INY        * SIGUIENTE LOCALIDAD PARA GUARDAR SIGUIENTE NUM
      LDAA #$1   * ACTIVAMOS BANDERA DE YA VIMOS ALGO 
      STAA DIFZ     * ACTUALIZAMOS BANDERA
FIN
      RTS


* FUNCIONES ESCRITURA LETRAS	**********************************************************************

***********************************
* ESCRIBE LETRAS
***********************************
ESCRIBELETRAS
      JSR INICIONUM
      JSR ESCRIBEABRE
OTRO
      LDAA $00,x
      INX
      JSR ESCRIBE
      LDAB CONT
      BNE OTRO
      JSR ESCRIBECIERRA
      JSR ESCRIBEMAYUS
      RTS

***********************************
* INICIO NUM
***********************************
INICIONUM
      CLR U3
      LDX #DUMP

NEXTNUM
      LDAA $00,X
      STAA ORDEN
      JSR ESDIGITO
      LDAA U3

      BNE FOUNDINICIO
      INX
      JMP NEXTNUM

FOUNDINICIO
      PSHX *INICIO DE NUMERO
      CLR CONT
      CLR U3

CUENTATAMANO
      CLR U3
      LDAA $00,X
      STAA ORDEN
      JSR ESDIGITO
      LDAA U3
      BEQ ENDINICIONUM
      INX
      JMP CUENTATAMANO

ENDINICIONUM
      PULX
      RTS

***********************************
* ESCRIBE NUM CORRESPONDIENTE
***********************************
ESCRIBE
      LDAB CONT
      CMPB #$4
      BNE CENTENAS

      DECB
      STAB CONT
      
      CMPA #'1
      BNE NOMIL
      JSR ESCRIBEMIL
      JSR ESCRIBEESPACIO
      RTS

NOMIL
      JSR ESCRIBEUNIDAD
      JSR ESCRIBEESPACIO
      JSR ESCRIBEMIL
      JSR ESCRIBEESPACIO
      RTS

CENTENAS
      CMPB #$3
      BNE DECENAS

      DECB
      STAB CONT

      CMPA #'1
      BNE NOCIEN
      JSR ESCRIBECIEN
      LDAB #$1          *FLAG = 1
      STAB U3
      RTS

NOCIEN
      CMPA #'0
      BEQ ESCERO
      CMPA #'5
      BNE NOQUIN
      JSR ESCRIBEQUINIENTOS
      JSR ESCRIBEESPACIO
      RTS
NOQUIN
      CMPA #'7
      BNE NOSETE
      JSR ESCRIBESETECIENTOS
      JSR ESCRIBEESPACIO
      RTS
NOSETE
      CMPA #'9
      BNE NONOVE
      BNE NONOVE
      JSR ESCRIBENOVECIENTOS
      JSR ESCRIBEESPACIO
      RTS
NONOVE
      JSR ESCRIBEUNIDAD
      JSR ESCRIBECIENTOS
      JSR ESCRIBEESPACIO
ESCERO
      RTS

DECENAS
      CMPB #$2
      BNE UNIDADES

      DECB
      STAB CONT

      CMPA #'0
      BNE SIDECENAS
      RTS

SIDECENAS
      CMPA #'2
      BGT DECENAHIGH
      LDAB #$0
      STAB CONT
      CMPA #'2
      BEQ VEINTE
      JSR ESCRIBEDIEZ 
      RTS

VEINTE
      JSR ESCRIBEVEINTE
      RTS

DECENAHIGH
      JSR ESCRIBEDECENA
      LDAB #$2          *FLAG = 2
      STAB U3
      RTS

UNIDADES
      DECB
      STAB CONT
      CMPA #'0
      BNE SIUNIDAD
      RTS

SIUNIDAD
      JSR ESCRIBEUNIDAD
      RTS

***********************************
* ESCRIBEDECENA
***********************************
ESCRIBEDECENA
      LDAB U3
      CMPB #$1
      BNE NOTO2
      JSR ESCRIBETO
      JSR ESCRIBEESPACIO
      CLR U3

NOTO2
      CMPA #'3
      BNE NOTREINTA
      JSR ESCRIBETREINTA
      
NOTREINTA
      CMPA #'4
      BNE NOCUARENTA
      JSR ESCRIBECUARENTA

NOCUARENTA
      CMPA #'5
      BNE NOCINCUENTA
      JSR ESCRIBECINCUENTA

NOCINCUENTA
      CMPA #'6
      BNE NOSESENTA
      JSR ESCRIBESESENTA

NOSESENTA
      CMPA #'7
      BNE NOSETENTA
      JSR ESCRIBESETENTA

NOSETENTA
      CMPA #'8
      BNE NOOCHENTA
      JSR ESCRIBEOCHENTA

NOOCHENTA
      CMPA #'9
      BNE FINDECENA
      JSR ESCRIBENOVENTA

FINDECENA
      JSR ESCRIBEESPACIO
      RTS


***********************************
* ESCRIBEVEINTE
***********************************
ESCRIBEVEINTE
      LDAB U3
      CMPB #$1
      BNE NOTO3
      JSR ESCRIBETO
      JSR ESCRIBEESPACIO
      CLR U3
     
NOTO3
      LDAA $00,x
      JSR ESCRIBEVEINT
      CMPA #'0
      BNE NOVEINTE
      JSR ESCRIBEE

NOVEINTE
      CMPA #'1
      BNE NOVEINUNO
      JSR ESCRIBEI
      JSR ESCRIBEUNO

NOVEINUNO
      CMPA #'2
      BNE NOVEINDOS
      JSR ESCRIBEI
      JSR ESCRIBEDOSACENTO

NOVEINDOS
      CMPA #'3
      BNE NOVEINTRES
      JSR ESCRIBEI
      JSR ESCRIBETRESACENTO

NOVEINTRES
      CMPA #'4
      BNE NOVEINCUATRO
      JSR ESCRIBEI
      JSR ESCRIBECUATRO

NOVEINCUATRO
      CMPA #'5
      BNE NOVEINCINCO
      JSR ESCRIBEI
      JSR ESCRIBECINCO

NOVEINCINCO
      CMPA #'6
      BNE NOVEINSEIS
      JSR ESCRIBEI
      JSR ESCRIBESEISACENTO

NOVEINSEIS
      CMPA #'7
      BNE NOVEISIETE
      JSR ESCRIBEI
      JSR ESCRIBESIETE

NOVEISIETE
      CMPA #'8
      BNE NOVEINOCHO
      JSR ESCRIBEI
      JSR ESCRIBEOCHO

NOVEINOCHO
      CMPA #'9
      BNE FINVEIN
      JSR ESCRIBEI
      JSR ESCRIBENUEVE

FINVEIN
 
      RTS

***********************************
* ESCRIBEDIEZ
***********************************
ESCRIBEDIEZ
      LDAB U3
      CMPB #$1
      BNE NOTO1
      JSR ESCRIBETO
      JSR ESCRIBEESPACIO
      CLR U3

NOTO1
      LDAA $00,x
      CMPA #'0
      BNE NODIEZ
      JSR ESCRIBEDIEZ1

NODIEZ
      CMPA #'1
      BNE NOONCE
      JSR ESCRIBEONCE

NOONCE
      CMPA #'2
      BNE NODOCE
      JSR ESCRIBEDOCE

NODOCE
      CMPA #'3
      BNE NOTRECE
      JSR ESCRIBETRECE

NOTRECE
      CMPA #'4
      BNE NOCATORCE
      JSR ESCRIBECATORCE

NOCATORCE
      CMPA #'5
      BNE NOQUINCE
      JSR ESCRIBEQUINCE

NOQUINCE
      CMPA #'6
      BNE NODIECISEIS
      JSR ESCRIBEDIECISEIS

NODIECISEIS
      CMPA #'7
      BNE NODIECISIETE
      JSR ESCRIBEDIECISIETE

NODIECISIETE
      CMPA #'8
      BNE NODIECIOCHO
      JSR ESCRIBEDIECIOCHO

NODIECIOCHO
      CMPA #'9
      BNE FINDIEZ
      JSR ESCRIBEDIECINUEVE

FINDIEZ
 
      RTS

***********************************
* ESCRIBEUNIDAD
***********************************
ESCRIBEUNIDAD
      LDAB U3
      CMPB #$1
      BNE NOTO
      JSR ESCRIBETO
      JSR ESCRIBEESPACIO
      CLR U3
      JMP INICIOUNIDAD

NOTO
      LDAB U3
      CMPB #$2
      BNE INICIOUNIDAD
      JSR ESCRIBEY
      JSR ESCRIBEESPACIO
      CLR U3

INICIOUNIDAD
      CMPA #'1
      BNE NOUNO
      JSR ESCRIBEUNO

NOUNO
      CMPA #'2
      BNE NODOS
      JSR ESCRIBEDOS

NODOS
      CMPA #'3
      BNE NOTRES
      JSR ESCRIBETRES

NOTRES
      CMPA #'4
      BNE NOCUATRO
      JSR ESCRIBECUATRO

NOCUATRO
      CMPA #'5
      BNE NOCINCO
      JSR ESCRIBECINCO

NOCINCO
      CMPA #'6
      BNE NOSEIS
      JSR ESCRIBESEIS

NOSEIS
      CMPA #'7
      BNE NOSIETE
      JSR ESCRIBESIETE

NOSIETE
      CMPA #'8
      BNE NOOCHO
      JSR ESCRIBEOCHO

NOOCHO
      CMPA #'9
      BNE FINUNIDAD
      JSR ESCRIBENUEVE

FINUNIDAD

      RTS

* FUNCIONES ESCRITURA MEMO	**********************************************************************

***********************************
* ESCRIBEMIL
***********************************
ESCRIBEMIL
      INY
      LDAB #'m
      STAB $00,y

      INY
      LDAB #'i
      STAB $00,y

      INY
      LDAB #'l
      STAB $00,y
      RTS

***********************************
* ESCRIBENOVECIENTOS
***********************************
ESCRIBENOVECIENTOS
      INY
      LDAB #'n
      STAB $00,y

      INY
      LDAB #'o
      STAB $00,y

      INY
      LDAB #'v
      STAB $00,y

      INY
      LDAB #'e
      STAB $00,y


      JSR ESCRIBECIENTOS
      RTS

***********************************
* ESCRIBESETECIENTOS
***********************************
ESCRIBESETECIENTOS
      INY
      LDAB #'s
      STAB $00,y

      INY
      LDAB #'e
      STAB $00,y

      INY
      LDAB #'t
      STAB $00,y

      INY
      LDAB #'e
      STAB $00,y


      JSR ESCRIBECIENTOS
      RTS

***********************************
* ESCRIBEQUINIENTOS
***********************************
ESCRIBEQUINIENTOS
      INY
      LDAB #'q
      STAB $00,y

      INY
      LDAB #'u
      STAB $00,y

      INY
      LDAB #'i
      STAB $00,y

      INY
      LDAB #'n
      STAB $00,y

      INY
      LDAB #'i
      STAB $00,y

      INY
      LDAB #'e
      STAB $00,y

      INY
      LDAB #'n
      STAB $00,y

      INY
      LDAB #'t
      STAB $00,y

      INY
      LDAB #'o
      STAB $00,y

      INY
      LDAB #'s
      STAB $00,y
      RTS

***********************************
* ESCRIBECIENTOS
***********************************
ESCRIBECIENTOS
      JSR ESCRIBECIEN

      INY
      LDAB #'t
      STAB $00,y

      INY
      LDAB #'o
      STAB $00,y

      INY
      LDAB #'s
      STAB $00,y
      RTS

***********************************
* ESCRIBECIEN
***********************************
ESCRIBECIEN
      INY
      LDAB #'c
      STAB $00,y

      INY
      LDAB #'i
      STAB $00,y

      INY
      LDAB #'e
      STAB $00,y

      INY
      LDAB #'n
      STAB $00,y
      RTS

***********************************
* ESCRIBETO
***********************************
ESCRIBETO
      INY
      LDAB #'t
      STAB $00,y

      INY
      LDAB #'o
      STAB $00,y
      RTS

***********************************
* ESCRIBETREINTA
***********************************
ESCRIBETREINTA
      INY
      LDAB #'t
      STAB $00,y

      INY
      LDAB #'r
      STAB $00,y

      INY
      LDAB #'e
      STAB $00,y


      INY
      LDAB #'i
      STAB $00,y


      JSR ESCRIBENTA
      RTS

***********************************
* ESCRIBECUARENTA
***********************************
ESCRIBECUARENTA
      INY
      LDAB #'c
      STAB $00,y

      INY
      LDAB #'u
      STAB $00,y

      INY
      LDAB #'a
      STAB $00,y


      INY
      LDAB #'r
      STAB $00,y


      INY
      LDAB #'e
      STAB $00,y

      JSR ESCRIBENTA
      RTS

***********************************
* ESCRIBECINCUENTA
***********************************
ESCRIBECINCUENTA
      INY
      LDAB #'c
      STAB $00,y

      INY
      LDAB #'i
      STAB $00,y

      INY
      LDAB #'n
      STAB $00,y


      INY
      LDAB #'c
      STAB $00,y

      INY
      LDAB #'u
      STAB $00,y

      INY
      LDAB #'e
      STAB $00,y

      JSR ESCRIBENTA
      RTS

***********************************
* ESCRIBESESENTA
***********************************
ESCRIBESESENTA
      INY
      LDAB #'s
      STAB $00,y

      INY
      LDAB #'e
      STAB $00,y

      INY
      LDAB #'s
      STAB $00,y


      INY
      LDAB #'e
      STAB $00,y

      JSR ESCRIBENTA
      RTS

***********************************
* ESCRIBESETENTA
***********************************
ESCRIBESETENTA
      INY
      LDAB #'s
      STAB $00,y

      INY
      LDAB #'e
      STAB $00,y

      INY
      LDAB #'t
      STAB $00,y


      INY
      LDAB #'e
      STAB $00,y

      JSR ESCRIBENTA
      RTS

***********************************
* ESCRIBEOCHENTA
***********************************
ESCRIBEOCHENTA
      INY
      LDAB #'o
      STAB $00,y

      INY
      LDAB #'c
      STAB $00,y

      INY
      LDAB #'h
      STAB $00,y


      INY
      LDAB #'e
      STAB $00,y

      JSR ESCRIBENTA
      RTS

***********************************
* ESCRIBENOVENTA
***********************************
ESCRIBENOVENTA
      INY
      LDAB #'n
      STAB $00,y

      INY
      LDAB #'o
      STAB $00,y

      INY
      LDAB #'v
      STAB $00,y

      INY
      LDAB #'e
      STAB $00,y

      JSR ESCRIBENTA
      RTS


***********************************
* ESCRIBENTA
***********************************
ESCRIBENTA
      INY
      LDAB #'n
      STAB $00,y

      INY
      LDAB #'t
      STAB $00,y
      INY

      LDAB #'a
      STAB $00,y
      RTS

***********************************
* ESCRIBEY
***********************************
ESCRIBEY
      INY
      LDAB #'y
      STAB $00,y
      RTS

***********************************
* ESCRIBEVEINT
***********************************
ESCRIBEVEINT

      INY
      LDAB #'v
      STAB $00,y

      INY
      LDAB #'e
      STAB $00,y

      INY
      LDAB #'i
      STAB $00,y

      INY
      LDAB #'n
      STAB $00,y

      INY
      LDAB #'t
      STAB $00,y
      RTS

***********************************
* ESCRIBEI
***********************************
ESCRIBEI

      INY
      LDAB #'i
      STAB $00,y
      RTS

***********************************
* ESCRIBEE
***********************************
ESCRIBEE

      INY
      LDAB #'e
      STAB $00,y
      RTS

***********************************
* ESCRIBEDIECI
***********************************
ESCRIBEDIECI
      INY
      LDAB #'d
      STAB $00,y

      INY
      LDAB #'i
      STAB $00,y

      INY
      LDAB #'e
      STAB $00,y

      INY
      LDAB #'c
      STAB $00,y

      INY
      LDAB #'i
      STAB $00,y

      RTS

***********************************
* ESCRIBEDIECINUEVE
***********************************
ESCRIBEDIECINUEVE
      JSR ESCRIBEDIECI
      JSR ESCRIBENUEVE

      RTS

***********************************
* ESCRIBEDIECIOCHO
***********************************
ESCRIBEDIECIOCHO
      JSR ESCRIBEDIECI
      JSR ESCRIBEOCHO

      RTS

***********************************
* ESCRIBEDIECISIETE
***********************************
ESCRIBEDIECISIETE
      JSR ESCRIBEDIECI
      JSR ESCRIBESIETE

      RTS

***********************************
* ESCRIBEDIECISEIS
***********************************
ESCRIBEDIECISEIS
      JSR ESCRIBEDIECI
      JSR ESCRIBESEISACENTO
      RTS

***********************************
* ESCRIBEQUINCE
***********************************
ESCRIBEQUINCE
      INY
      LDAB #'q
      STAB $00,y

      INY
      LDAB #'u
      STAB $00,y

      INY
      LDAB #'i
      STAB $00,y

      INY
      LDAB #'n
      STAB $00,y

      INY
      LDAB #'c
      STAB $00,y

      INY
      LDAB #'e
      STAB $00,y
      RTS

***********************************
* ESCRIBECATORCE
***********************************
ESCRIBECATORCE
      INY
      LDAB #'c
      STAB $00,y

      INY
      LDAB #'a
      STAB $00,y

      INY
      LDAB #'t
      STAB $00,y

      INY
      LDAB #'o
      STAB $00,y

      INY
      LDAB #'r
      STAB $00,y

      INY
      LDAB #'c
      STAB $00,y

      INY
      LDAB #'e
      STAB $00,y
      RTS

***********************************
* ESCRIBETRECE
***********************************
ESCRIBETRECE
      INY
      LDAB #'t
      STAB $00,y

      INY
      LDAB #'r
      STAB $00,y

      INY
      LDAB #'e
      STAB $00,y

      INY
      LDAB #'c
      STAB $00,y

      INY
      LDAB #'e
      STAB $00,y

      RTS

***********************************
* ESCRIBEDOCE
***********************************
ESCRIBEDOCE
      INY
      LDAB #'d
      STAB $00,y

      INY
      LDAB #'o
      STAB $00,y

      INY
      LDAB #'c
      STAB $00,y

      INY
      LDAB #'e
      STAB $00,y

      RTS

***********************************
* ESCRIBEONCE
***********************************
ESCRIBEONCE
      INY
      LDAB #'o
      STAB $00,y

      INY
      LDAB #'n
      STAB $00,y

      INY
      LDAB #'c
      STAB $00,y

      INY
      LDAB #'e
      STAB $00,y

      RTS

***********************************
* ESCRIBEDIEZ1
***********************************
ESCRIBEDIEZ1
      INY
      LDAB #'d
      STAB $00,y

      INY
      LDAB #'i
      STAB $00,y

      INY
      LDAB #'e
      STAB $00,y

      INY
      LDAB #'z
      STAB $00,y
      RTS

***********************************
* ESCRIBENUEVE
***********************************
ESCRIBENUEVE
      INY
      LDAB #'n
      STAB $00,y

      INY
      LDAB #'u
      STAB $00,y

      INY
      LDAB #'e
      STAB $00,y

      INY
      LDAB #'v
      STAB $00,y

      INY
      LDAB #'e
      STAB $00,y

      RTS

***********************************
* ESCRIBEOCHO
***********************************
ESCRIBEOCHO
      INY
      LDAB #'o
      STAB $00,y

      INY
      LDAB #'c
      STAB $00,y

      INY
      LDAB #'h
      STAB $00,y

      INY
      LDAB #'o
      STAB $00,y

      RTS

***********************************
* ESCRIBESIETE
***********************************
ESCRIBESIETE
      INY
      LDAB #'s
      STAB $00,y

      INY
      LDAB #'i
      STAB $00,y

      INY
      LDAB #'e
      STAB $00,y

      INY
      LDAB #'t
      STAB $00,y

      INY
      LDAB #'e
      STAB $00,y

      RTS

***********************************
* ESCRIBESEIS
***********************************
ESCRIBESEIS
      INY
      LDAB #'s
      STAB $00,y

      INY
      LDAB #'e
      STAB $00,y

      INY
      LDAB #'i
      STAB $00,y

      INY
      LDAB #'s
      STAB $00,y

      RTS

***********************************
* ESCRIBESEISACENTO
***********************************
ESCRIBESEISACENTO
      INY
      LDAB #'s
      STAB $00,y

      INY
      LDAB #'E
      STAB $00,y

      INY
      LDAB #'i
      STAB $00,y

      INY
      LDAB #'s
      STAB $00,y
      RTS

***********************************
* ESCRIBECINCO
***********************************
ESCRIBECINCO
      INY
      LDAB #'c
      STAB $00,y

      INY
      LDAB #'i
      STAB $00,y

      INY
      LDAB #'n
      STAB $00,y

      INY
      LDAB #'c
      STAB $00,y

      INY
      LDAB #'o
      STAB $00,y
      RTS

***********************************
* ESCRIBECUATRO
***********************************
ESCRIBECUATRO
      INY
      LDAB #'c
      STAB $00,y

      INY
      LDAB #'u
      STAB $00,y

      INY
      LDAB #'a
      STAB $00,y

      INY
      LDAB #'t
      STAB $00,y

      INY
      LDAB #'r
      STAB $00,y

      INY
      LDAB #'o
      STAB $00,y
      RTS

***********************************
* ESCRIBETRES
***********************************
ESCRIBETRES
      INY
      LDAB #'t
      STAB $00,y

      INY
      LDAB #'r
      STAB $00,y

      INY
      LDAB #'e
      STAB $00,y

      INY
      LDAB #'s
      STAB $00,y
      RTS

***********************************
* ESCRIBETRESACENTO
***********************************
ESCRIBETRESACENTO
      INY
      LDAB #'t
      STAB $00,y

      INY
      LDAB #'r
      STAB $00,y

      INY
      LDAB #'E
      STAB $00,y

      INY
      LDAB #'s
      STAB $00,y
      RTS

***********************************
* ESCRIBEDOS
***********************************
ESCRIBEDOS
      INY
      LDAB #'d
      STAB $00,y

      INY
      LDAB #'o
      STAB $00,y

      INY
      LDAB #'s
      STAB $00,y
      RTS


***********************************
* ESCRIBEDOSACENTO
***********************************
ESCRIBEDOSACENTO
      INY
      LDAB #'d
      STAB $00,y

      INY
      LDAB #'O
      STAB $00,y

      INY
      LDAB #'s
      STAB $00,y
      RTS


***********************************
* ESCRIBEUNO
***********************************
ESCRIBEUNO
      INY
      LDAB #'u
      STAB $00,y

      INY
      LDAB #'n
      STAB $00,y

      INY
      LDAB #'o
      STAB $00,y
      RTS

***********************************
* ESCRIBEESPACIO
***********************************
ESCRIBEESPACIO
      INY
      LDAB #$20
      STAB $00,y
      RTS

***********************************
* ESCRIBEABRE
***********************************
ESCRIBEABRE
      LDY #$0070
      LDAA #'(
      STAA $00,y
      RTS

***********************************
* ESCRIBECIERRA
***********************************
ESCRIBECIERRA
      LDAA $00,y
      CMPA #$20
      BEQ HAYESPACIO
      INY

HAYESPACIO
      LDAA #')
      STAA $00,y
      RTS


***********************************
* ESCRIBEMAYUS
***********************************
ESCRIBEMAYUS
      LDY #$0071
      LDAA $00,y
      LDAB #$20
      SBA
      STAA $00,y
      RTS

* FUNCIONES UTILIDADES	**********************************************************************

***********************************
* LIMPIAYERROR
***********************************

LIMPIAYERROR
      LDX #DUMP

AVANZA
      LDAA $00,x
      INX
      CMPA #'=
      BNE AVANZA
      PSHX    

LIMPIA
      BSET $00,x,#$FF
      INX
      CMPX #$009D
      BNE LIMPIA

      PULX
      LDAA #'E
      STAA $00,x

      INX
      LDAA #'R
      STAA $00,x

      INX
      LDAA #'R
      STAA $00,x

      INX
      LDAA #'O
      STAA $00,x

      INX
      LDAA #'R
      STAA $00,x

      RTS

***********************************
* LIMPIAMEMO
***********************************

LIMPIAMEMO
      LDX #$00
LIMPIAR
      BSET $00,x,#$FF
      INX
      CMPX #$009D
      BNE LIMPIAR
      LDX #DUMP
      RTS

***********************************
* ESPERAOK
***********************************
ESPERAOK1

      CLR U1

LOOP1
      LDAA #'?
      STAA ORDEN
CICLO1
      LDAA ORDEN
      CMPA #'?
      BEQ  CICLO1
      
      LDAA U1
      BNE SIGUEK    * Ya vimos O
      
      LDAA ORDEN    * No hemos visto O
      CMPA #'O
      BNE ESPERAOK1 * No es O
     
      LDAA #$1      * Si es O, bandera 1 prendida
      STAA U1
      JMP LOOP1
     
SIGUEK

      LDAA ORDEN
      CMPA #'K
      BNE ESPERAOK1

      RTS

* FUNCIONES SERIAL	**********************************************************************

***********************************
* Configura puerto serial
***********************************
SERIAL

       LDD   #$302C  * CONFIGURA PUERTO SERIAL
       STAA  BAUD    * BAUD  9600  para cristal de 8MHz
       STAB  SCCR2   * HABILITA  RX Y TX PERO INTERRUPCN SOLO RX
       LDAA  #$00
       STAA  SCCR1   * 8 BITS

       LDAA  #$FE    * CONFIG PUERTO D COMO SALIDAS (EXCEPTO PD0)
       STAA  DDRD    * SEA  ENABLE DEL DISPLAY  PD4  Y RS PD3
                     
      
       LDAA  #$04
       STAA  HPRIO

       LDAA  #$00
       TAP
      RTS

***********************************
* ATENCION A INTERRUPCION SERIAL
***********************************
       ORG  $F100

       LDAA SCSR
       LDAA SCDR
       STAA ORDEN
         
       RTI

***********************************
* VECTOR INTERRUPCION SERIAL
***********************************
       ORG   $FFD6
       FCB   $F1,$00       


***********************************
*RESET
***********************************
       ORG    $FFFE
RESET  FCB    $80,$00
***********************************
       END   $8000
