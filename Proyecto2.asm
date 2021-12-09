* PROGRAMA ROMANO

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
      BNE COMPROMANO

      JSR COMPDIG
      RTS

***********************************
* COMPRUEBA ROMANO   <- convierte a decimal, lo escribe y prende U3 si error
***********************************
COMPROMANO

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

* FUNCIONES TRANSFORMACION	**********************************************************************




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
      RTS

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
