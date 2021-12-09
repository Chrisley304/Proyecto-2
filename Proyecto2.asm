* PROGRAMA ROMANO

* DECLARACION CONSTANTES

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

* DECLARACION DE VARIABLES

ORDEN EQU $0000
U1    EQU $0001
U2    EQU $0002
U3    EQU $0003
U4    EQU $0004
CONT  EQU $0005
DUMP  EQU $0050

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
      
    * JSR CONVIERTE

     * JSR ESCRIBELETRAS

      JMP ESPERAOK

ERROR
      JSR LIMPIAYERROR

ESPERAOK
      JSR ESPERAOK1
      JMP START

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
* Es una cosa que no es digito ni romano ni =?
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
* COMPRUEBA
***********************************
COMPRUEBA 
      CLR U3
      LDAA U1
      CMPA #$1
      BNE COMPRUEBA ROMANO

      JSR COMPDIG
      RTS

COMPRUEBAROMANO
      JSR COMPROMANO
      RTS

***********************************
* COMPRUEBA ROMANO
***********************************
COMPROMANO

      RTS

***********************************
* COMPRUEBA DIGITO
***********************************
COMPDIG
      LDAA DUMP
      CMPA #'0
      BNE DIGCORRECTO
      LDAA #$1
      STAA U3

DIGCORRECTO
  
      RTS

***********************************
* ESCRIBE LETRAS
***********************************
ESCRIBELETRAS
      JSR INICIONUM
      LDY #$0070
OTRO
      LDAB CONT
      BEQ FINDENUM

      LDAA $00,x
      INX
      JSR ESCRIBE

FINDENUM
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
      JSR ESCRIBEUNIDAD
      JSR ESCRIBECIENTOS
      JSR ESCRIBEESPACIO
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
      BEQ VEINTE
      JSR ESCRIBEDIEZ 
      RTS

VEINTE
      JSR ESCRIBEVEINTE
      RTS

DECENAHIGH
      JSR ESCRIBEDECENA
      JSR ESCRIBEESPACIO
      RTS


UNIDADES
      CMPA #'0
      DECB
      STAB CONT
      BNE SIUNIDAD
      RTS

SIUNIDAD
      JSR ESCRIBEUNIDAD
      RTS


***********************************
* INICIO NUM
***********************************
INICIONUM
      CLR U3
      LDX DUMP

NEXTNUM
      LDAA $00,X
      STAA ORDEN
      JSR ESDIGITO
      LDAA U3

      BEQ FOUNDINICIO
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
      BNE CUENTATAMANO

      PULX
      RTS

***********************************
* ESCRIBEMIL
***********************************
ESCRIBEMIL
      INY
      LDAA #'m
      STAA $00,y

      INY
      LDAA #'i
      STAA $00,y

      INY
      LDAA #'l
      STAA $00,y
      RTS

***********************************
* ESCRIBEESPACIO
***********************************
ESCRIBEESPACIO
      INY
      LDAA #$20
      STAA $00,y
      RTS


***********************************
* ESCRIBECIEN
***********************************
ESCRIBECIEN
      INY
      LDAA #'c
      STAA $00,y

      INY
      LDAA #'i
      STAA $00,y

      INY
      LDAA #'e
      STAA $00,y

      INY
      LDAA #'n
      STAA $00,y
      RTS

***********************************
* ESCRIBECIENTOS
***********************************
ESCRIBECIENTOS
      JSR ESCRIBECIEN

      INY
      LDAA #'t
      STAA $00,y

      INY
      LDAA #'o
      STAA $00,y

      INY
      LDAA #'s
      STAA $00,y
      RTS

***********************************
* ESCRIBEUNO
***********************************
ESCRIBEUNO
      INY
      LDAA #'u
      STAA $00,y

      INY
      LDAA #'n
      STAA $00,y

      INY
      LDAA #'o
      STAA $00,y
      RTS

***********************************
* ESCRIBEDOS
***********************************
ESCRIBEDOS
      INY
      LDAA #'d
      STAA $00,y

      INY
      LDAA #'o
      STAA $00,y

      INY
      LDAA #'s
      STAA $00,y
      RTS

***********************************
* ESCRIBETRES
***********************************
ESCRIBETRES
      INY
      LDAA #'t
      STAA $00,y

      INY
      LDAA #'r
      STAA $00,y

      INY
      LDAA #'e
      STAA $00,y

      INY
      LDAA #'s
      STAA $00,y
      RTS

***********************************
* ESCRIBECUATRO
***********************************
ESCRIBECUATRO
      INY
      LDAA #'c
      STAA $00,y

      INY
      LDAA #'u
      STAA $00,y

      INY
      LDAA #'a
      STAA $00,y

      INY
      LDAA #'t
      STAA $00,y

      INY
      LDAA #'r
      STAA $00,y

      INY
      LDAA #'o
      STAA $00,y
      RTS

***********************************
* ESCRIBECINCO
***********************************
ESCRIBECINCO
      INY
      LDAA #'c
      STAA $00,y

      INY
      LDAA #'i
      STAA $00,y

      INY
      LDAA #'n
      STAA $00,y

      INY
      LDAA #'c
      STAA $00,y

      INY
      LDAA #'o
      STAA $00,y
      RTS

***********************************
* ESCRIBESEIS
***********************************
ESCRIBESEIS
      INY
      LDAA #'s
      STAA $00,y

      INY
      LDAA #'e
      STAA $00,y

      INY
      LDAA #'i
      STAA $00,y

      INY
      LDAA #'s
      STAA $00,y

      RTS

***********************************
* ESCRIBESIETE
***********************************
ESCRIBESIETE
      INY
      LDAA #'s
      STAA $00,y

      INY
      LDAA #'i
      STAA $00,y

      INY
      LDAA #'e
      STAA $00,y

      INY
      LDAA #'t
      STAA $00,y

      INY
      LDAA #'e
      STAA $00,y

      RTS

***********************************
* ESCRIBEOCHO
***********************************
ESCRIBEOCHO
      INY
      LDAA #'o
      STAA $00,y

      INY
      LDAA #'c
      STAA $00,y

      INY
      LDAA #'h
      STAA $00,y

      INY
      LDAA #'o
      STAA $00,y

      RTS

***********************************
* ESCRIBENUEVE
***********************************
ESCRIBENUEVE
      INY
      LDAA #'n
      STAA $00,y

      INY
      LDAA #'u
      STAA $00,y

      INY
      LDAA #'e
      STAA $00,y

      INY
      LDAA #'v
      STAA $00,y

      INY
      LDAA #'e
      STAA $00,y

      RTS

***********************************
* ESCRIBEONCE
***********************************
ESCRIBEONCE
      INY
      LDAA #'o
      STAA $00,y

      INY
      LDAA #'n
      STAA $00,y

      INY
      LDAA #'c
      STAA $00,y

      INY
      LDAA #'e
      STAA $00,y

      RTS


***********************************
* ESCRIBEDOCE
***********************************
ESCRIBEDOCE
      INY
      LDAA #'d
      STAA $00,y

      INY
      LDAA #'o
      STAA $00,y

      INY
      LDAA #'c
      STAA $00,y

      INY
      LDAA #'e
      STAA $00,y

      RTS

***********************************
* ESCRIBETRECE
***********************************
ESCRIBETRECE
      INY
      LDAA #'t
      STAA $00,y

      INY
      LDAA #'r
      STAA $00,y

      INY
      LDAA #'e
      STAA $00,y

      INY
      LDAA #'c
      STAA $00,y

      INY
      LDAA #'e
      STAA $00,y

      RTS

***********************************
* ESCRIBECATORCE
***********************************
ESCRIBECATORCE
      INY
      LDAA #'c
      STAA $00,y

      INY
      LDAA #'a
      STAA $00,y

      INY
      LDAA #'t
      STAA $00,y

      INY
      LDAA #'o
      STAA $00,y

      INY
      LDAA #'r
      STAA $00,y

      INY
      LDAA #'c
      STAA $00,y

      INY
      LDAA #'e
      STAA $00,y
      RTS

***********************************
* ESCRIBEQUINCE
***********************************
ESCRIBEQUINCE
      INY
      LDAA #'q
      STAA $00,y

      INY
      LDAA #'u
      STAA $00,y

      INY
      LDAA #'i
      STAA $00,y

      INY
      LDAA #'n
      STAA $00,y

      INY
      LDAA #'c
      STAA $00,y

      INY
      LDAA #'e
      STAA $00,y
      RTS

***********************************
* ESCRIBEDICEI
***********************************
ESCRIBEDIECI
      INY
      LDAA #'d
      STAA $00,y

      INY
      LDAA #'i
      STAA $00,y

      INY
      LDAA #'e
      STAA $00,y

      INY
      LDAA #'c
      STAA $00,y

      INY
      LDAA #'i
      STAA $00,y

      RTS

***********************************
* ESCRIBEDICEISEIS
***********************************
ESCRIBEDICEISEIS
      JSR ESCRIBEDIECI

      INY
      LDAA #'s
      STAA $00,y

      INY
      LDAA #'E
      STAA $00,y

      INY
      LDAA #'i
      STAA $00,y

      INY
      LDAA #'s
      STAA $00,y

      RTS

***********************************
* ESCRIBEUNIDAD
***********************************
ESCRIBEUNIDAD

      RTS

***********************************
* ESCRIBEDIEZ
***********************************
ESCRIBEDIEZ

      RTS

***********************************
* ESCRIBEVEINTE
***********************************
ESCRIBEVEINTE

      RTS

***********************************
* ESCRIBEDECENA
***********************************
ESCRIBEDECENA

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
