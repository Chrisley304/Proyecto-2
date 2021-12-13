# Proyecto 2 EyPC: Convertidor de numeros romanos

Proyecto para la materia de Estructura y Programación de Computadoras de la Facultad de Ingeniería de la UNAM, el cual consiste en crear un programa en lenguaje ensamblador para el procesador MC68HC11 de Motorola. Este programa debe ser capaz de convertir un numero escrito en romano a su equivalente en decimal y viceversa.

## Uso

#### Entrada:
Ingresar el numero romano o decimal (entre el 1 y 9999) a convertir mediante el puerto serial adicionando el simbolo '='.

    ej.
        MDCLXVI=
        4235=

**Nota:** El procesador MC68HC11 solo es capaz de utilizar caracteres ASCII, por lo tanto para los miles arriba de 3000, se seguira utilizando la letra 'M', por ejemplo:

    5000=MMMMM

#### Salida:
Como se menciono anteriormente, el programa devuelve el numero ingresado a su equivalente en romano o decimal, dependiendo el caso. Esto se visualiza a partir de la localidad de memoria **$0050**.

    ej.
        MDCLXVI=1666
        4235=MMMMCCXXXV
