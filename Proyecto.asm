;MACRO para determinar la posicion en la matriz en la que se encuentra la lentra cifrada
Calcular_cifrado MACRO Letra_clave, Letra_mensaje, tamano, num
XOR AX, AX
XOR BX, BX
 SUB Letra_clave, 41h
 SUB Letra_mensaje, 41h


 MOV BL, tamano
 MOV AL, Letra_clave 
 MUL BL
 XOR BX, BX
 MOV BL, Letra_mensaje

 ADD AX, BX

 MOV num, AX
ENDM

Mapeo MACRO X, Y, Rows, Columns, Size
    MOV AL, X
	MOV BL, Rows
	mul BL				; Resultado está en AL
	MOV BL, Size
	MUL BL				; Primera parte de la fórmula
	; Columnas
	MOV CL, AL				; guardar temporalmente el resultado de las filas
	MOV AL, Y
	MOV BL, Size
	MUL BL
	; sumar
	ADD AL, CL				; Resultado en AL
ENDM


Busca_posicion MACRO unaPosicion
	LEA ESI, matriz
	XOR ECX, ECX
	MOV CL, unaPosicion
	ADD ESI, ECX
	MOV CL, [ESI]
	MOV texto, CL
	
	LEA ESI, aux
	XOR ECX, ECX
	MOV CL, contador
	ADD ESI, ECX
	MOV CL, texto
	MOV [ESI], cl


	inc contador

	INVOKE StdOut, ADDR texto
ENDM

.386
.model flat, stdcall
Option casemap: none
;INCLUDES
INCLUDE \masm32\include\windows.inc
INCLUDE \masm32\include\kernel32.inc
INCLUDE \masm32\include\masm32.inc
INCLUDE \masm32\include\masm32rt.inc
.DATA
matriz      DB 690 DUP(0), 0
mensaje_por DB 100 DUP(0), 0
Tab         DB 0Ah, 0
espacio     DB 09h, 0
value       DB 100 DUP(0), 0
key         DB 100 DUP(0), 0
porcentaje  DB 25h, 0
cripto      DB 100 DUP(0), 0
Count_Per   DB 0,0
Count_letra DB 0,0
Count       DB 0,0
count_row   DB 0,0
Count_impri DW 0,0
X           DB 0,0
Y           DB 0,0
Y_Aux       DB 0,0
Position    DB 0,0 
num_recorrido DW 0,0

numOP2 DB 0,0
numOP22 DB 0,0
texto DB 0,0
S DB 0,0
 posicion	DB 0,0
 contador DB 0,0
 aux	 DB 100 DUP(0),0
 Aux_letra   DB 0, 0
 resultado   DB 0, 0
  digito1  DB 00h,0
  digito2  DB 00h,0
  digito3  DB 00h,0
  Aux_      DB 00h
.DATA?
 Option_     DB ? 
 Ej_imprimir DB ? 
 char_K      DB ?
 char_V      DB ?
 num_K       DB ?
 num_V       DB ?
 num         DW ?
 letra_cifrada DB ?
.CONST ; Constantes
;CONTADORES
Rows    DB 1Ah,0
Columns DB 1Ah,0
.CODE 
main:
   ;Generar Matriz
   CALL Generate_Matrix 
   ;CALL IMPRIMIR_MATRIZ                      ;solo para validar las que lo guarda bien

INVOKE StdOut, ADDR Tab
print chr$("  ---Cifrado utilizando matrices---  ")
INVOKE StdOut, ADDR Tab
print chr$("  ---------------------------------  ")
INVOKE StdOut, ADDR Tab
INVOKE StdOut, ADDR Tab
print chr$("                --Menu-- ")
INVOKE StdOut, ADDR Tab
print chr$(" Opcion 1: Generar criptograma con metodo 1 ")
INVOKE StdOut, ADDR Tab
print chr$(" Opcion 2: Generar criptograma con metodo 2 ")
INVOKE StdOut, ADDR Tab
print chr$(" Opcion 3: Descifrar criptograma con metodo 1 ")
INVOKE StdOut, ADDR Tab
print chr$(" Opcion 4: Descifrar criptograma con metodo 2 ")
INVOKE StdOut, ADDR Tab
print chr$(" Opcion 5: Obtener porcentaje dec criptograma ")
INVOKE StdOut, ADDR Tab
print chr$(" Opcion 6: Salir ")
INVOKE StdOut, ADDR Tab
print chr$(" Ingrese la opcion que desea ")
INVOKE StdIn, ADDR Option_, 10
; convertir numero real
SUB Option_, 30h 

; Validar opcion
CMP Option_, 01h
JE Option_1
CMP Option_, 02h
JE Option_2
CMP Option_, 03h
JE Option_3
CMP Option_, 04h
JE Option_4
CMP Option_, 05h
JE Option_5
CMP Option_, 06h
JE  EXIT_Main
JMP EXIT_Main
Option_1:
 print chr$("Unicamente letras mayusculas ")
 INVOKE StdOut, ADDR Tab
 print chr$(" Ingresar clave ")
 INVOKE StdIn, ADDR key, 100
 INVOKE StdOut, ADDR Tab
 print chr$(" Ingresar mensaje ")
 INVOKE StdIn, ADDR value, 100
 INVOKE StdOut, ADDR Tab
 print chr$(" Mensaje Cifrado: ")
 CALL Encrypt_1
 INVOKE StdOut, ADDR Tab
 JMP main

Option_2:
  print chr$("Unicamente letras mayusculas ")
  INVOKE StdOut, ADDR Tab
  print chr$(" Ingresar clave ")
  INVOKE StdIn, ADDR key, 100
  INVOKE StdOut, ADDR Tab
  print chr$(" Ingresar mensaje ")
  INVOKE StdIn, ADDR value, 100
  INVOKE StdOut, ADDR Tab
  print chr$(" Mensaje Cifrado: ")
  CALL Encrypt_2
  INVOKE StdOut, ADDR Tab
  JMP main
Option_3:
	print chr$(" Ingresar un criptograma (en MAYUSCULAS) ")
	INVOKE StdOut, ADDR Tab
	INVOKE StdIn, ADDR cripto, 100
	print chr$(" Ingresar un clave (en MAYUSCULAS) ")
	INVOKE StdOut, ADDR Tab
	INVOKE StdIn, ADDR key, 100

	LEA ESI,cripto
	LEA EDI, key
	MOV S, 0h
OP2C1:
	XOR BX, BX
	MOV BL, [EDI]
	CMP BL, 0
	JNE SIO1
	XOR EDI, EDI
	LEA EDI, key
	
SIO1:	
	XOR AX, AX
	XOR BX, BX
	MOV AL, [ESI]
	CMP AL, 0
	JE SALEOP3

	MOV AL, [ESI]
	MOV BL, [EDI]
	CMP AL, 65
	JAE SI1
	ADD ESI, 1H
	INC S
	JMP OP2C1
SI1:
	CMP AL, 90
	JBE SI2
	ADD ESI, 1
	INC S
	JMP OP2C1
SI2:
	CMP BL, 65
	JAE SI3
	ADD EDI, 1H
	JMP OP2C1
SI3:
	CMP  BL, 90
	JBE OP2
	ADD EDI, 1H
	JMP OP2C1

OP2:
	XOR AX, AX
	XOR BX, BX
	XOR CX, CX
	XOR DX, DX
	MOV AL, [EDI]
	MOV numOP2, AL
	SUB numOP2, 65
	MOV BL, [ESI]
	SUB BL, 65
	MOV numOP22, BL
	MOV posicion, 0h
	CMP BL, numOP2
	JE OP2C2
	CMP BL, numOP2
	JA OP2C3
	CMP BL, numOP2
	JB OP2C4
OP2C2: ;IGUALES
	MOV AL, numOP2
	MOV posicion, AL
	JMP OP2C5
OP2C3: ;MAYOR
	MOV AL, numOP22
	SUB AL, numOP2
	MOV posicion, AL
	JMP OP2C5
OP2C4: ;Menor
	MOV AL, 26
	SUB AL, numOP2
	ADD AL, numOP22
	MOV posicion, AL
OP2C5:


	Busca_posicion posicion
	XOR EAX, EAX
	LEA ESI, cripto
	MOV AL, S
	ADD ESI, EAX

	ADD EDI, 1
	ADD ESI, 1
	INC S

	MOV AL, [ESI]
	CMP AL, 0
	JNE OP2C1
SALEOP3:	
INVOKE StdOut, ADDR Tab
JMP main
Option_4:

print chr$(" Ingresar un criptograma (en MAYUSCULAS) ")
	INVOKE StdOut, ADDR Tab
	INVOKE StdIn, ADDR cripto, 100
	print chr$(" Ingresar un clave (en MAYUSCULAS) ")
	INVOKE StdOut, ADDR Tab
	INVOKE StdIn, ADDR key, 100

	LEA ESI,cripto
	LEA EDI, key
	MOV S, 0h
OP4C1:
	XOR BX, BX
	MOV BL, [EDI]
	CMP BL, 0
	JNE SIP1
	XOR EDI, EDI
	LEA EDI, aux
	
SIP1:	
	XOR AX, AX
	XOR BX, BX
	MOV AL, [ESI]
	CMP AL, 0
	JE SALEOP4

	MOV AL, [ESI]
	MOV BL, [EDI]
	CMP AL, 65
	JAE SO1
	ADD ESI, 1H
	INC S
	JMP OP4C1
SO1:
	CMP AL, 90
	JBE SO2
	ADD ESI, 1
	INC S
	JMP OP4C1
SO2:
	CMP BL, 65
	JAE SO3
	ADD EDI, 1H
	JMP OP4C1
SO3:
	CMP  BL, 90
	JBE OP4
	ADD EDI, 1H
	JMP OP4C1

OP4:
	XOR AX, AX
	XOR BX, BX
	XOR CX, CX
	XOR DX, DX
	MOV AL, [EDI]
	MOV numOP2, AL
	SUB numOP2, 65
	MOV BL, [ESI]
	SUB BL, 65
	MOV numOP22, BL
	MOV posicion, 0h
	CMP BL, numOP2
	JE OP4C2
	CMP BL, numOP2
	JA OP4C3
	CMP BL, numOP2
	JB OP4C4
OP4C2: ;IGUALES
	MOV AL, numOP2
	MOV posicion, AL
	JMP OP4C5
OP4C3: ;MAYOR
	MOV AL, numOP22
	SUB AL, numOP2
	MOV posicion, AL
	JMP OP4C5
OP4C4: ;Menor
	MOV AL, 26
	SUB AL, numOP2
	ADD AL, numOP22
	MOV posicion, AL
OP4C5:


	Busca_posicion posicion
	XOR EAX, EAX
	LEA ESI, cripto
	MOV AL, S
	ADD ESI, EAX

	ADD EDI, 1
	ADD ESI, 1
	INC S

	MOV AL, [ESI]
	CMP AL, 0
	JNE OP4C1
SALEOP4:
INVOKE StdOut, ADDR Tab
JMP main
Option_5:
	print chr$(" Ingresar un criptograma (en MAYUSCULAS) ")
	INVOKE StdOut, ADDR Tab
	print chr$(" Ingresar cadena dec mensaje cifrado ")
	INVOKE StdOut, ADDR Tab
	INVOKE StdIn, ADDR mensaje_por, 100
	INVOKE StdOut, ADDR Tab
	CALL Encrypt_5
JMP main
Encrypt_1 PROC Near
    XOR AX, AX
	XOR BX, BX 
	XOR CX, CX
  ; Inicializar las cadenas 
   LEA EDI, value
   LEA ESI, key
   MOV AH, 0
   Ciclo_E1:
   MOV AL, [ESI]
   MOV BL, [EDI]
  CMP BL, 0             ;si la cadena mensaje llega a su limite
  JE EXIT_E1                       
  CMP AL, 0             ;si la cadena clave llega a su fin
  JE RETORN_KEY

  INC EDI
  INC ESI
  
  MOV char_V, BL       ; caracter de mensaje a evaluar
  MOV char_K, AL       ;caracter de clave a evaluar

  Calcular_cifrado char_K, char_V, 26, num 
  CALL RECORRER_MATRIZ

  JMP Ciclo_E1                                    ;Volver a recorrer el siguiente caracter

 RETORN_KEY:
     LEA ESI, key
	 JMP Ciclo_E1  
 EXIT_E1:
  RET
Encrypt_1 ENDP

Encrypt_2 PROC Near
    XOR AX, AX
	XOR BX, BX 
	XOR CX, CX
  ; Inicializar las cadenas 
   LEA EDI, value
   LEA ESI, key
   MOV AH, 0
   Ciclo_E2:
   MOV AL, [ESI]
   MOV BL, [EDI]
   CMP BL, 0             ;si la cadena mensaje llega a su limite
   JE EXIT_E2                       
   CMP AL, 0             ;si la cadena clave llega a su fin
   JE RETORN_VALUE       ; Enviar a regitsro [ESI] el inicio del mensaje

  INC EDI
  INC ESI
  
  MOV char_V, BL       ; caracter de mensaje a evaluar
  MOV char_K, AL       ;caracter de clave a evaluar

  Calcular_cifrado char_K, char_V, 26, num 
  CALL RECORRER_MATRIZ

  JMP Ciclo_E2                                    ;Volver a recorrer el siguiente caracter

 RETORN_VALUE:
     LEA ESI, value
	 JMP Ciclo_E2  
 EXIT_E2:
RET
Encrypt_2 ENDP

Encrypt_5 PROC Near
    XOR AX, AX
	XOR BX, BX 
	XOR CX, CX
    ; Inicializar las cadenas
	LEA EDI, mensaje_por
	MOV AH, 0
	Incrementar:  ; Optener la cantidad de palabras total
	MOV AL, [EDI]
	CMP AL, 0     
	JE Siguiente
	INC Count_Per     
	INC EDI
	JMP Incrementar
	
	XOR AX, AX
	XOR BX, BX 
	XOR CX, CX
	
	Siguiente:
	MOV AL, Count_Per
    LEA EDI, mensaje_por

	ciclo_grande:
	  LEA ESI, mensaje_por
	  MOV AH, 0 
	  MOV BL, [EDI] 
	  CMP BL, 0
	  JE Exit_Encrypt5
	buscar:
	  MOV AL, [ESI]
	  CMP AL, 0
	  JE avanzar_letra
	  CMP AL, BL
	  JE siguiente_letra
	  INC ESI
	  JMP buscar

   siguiente_letra:
       INC Count_letra
	   INC ESI
	   JMP buscar

    avanzar_letra:    
    MOV Aux_letra, BL 
	MOV CL, 100
    MOV AL, Count_letra
    MUL CL      
    MOV BL, Count_Per
    DIV BL
    MOV resultado, AL
	INVOKE StdOut, ADDR Aux_letra
	INVOKE StdOut, ADDR espacio
	MOV BL, resultado	
	CALL SEPARAR
	INVOKE StdOut, ADDR porcentaje
	INVOKE StdOut, ADDR espacio
	print chr$(" las posibles letras son: ")
	CALL POSIBLE_LETRA
	INVOKE StdOut, ADDR Tab
	MOV Count_letra, 0
    INC EDI 
	JMP ciclo_grande 

Exit_Encrypt5:
RET
Encrypt_5 ENDP

POSIBLE_LETRA PROC Near
    XOR AX, AX
	XOR BX, BX 
	XOR CX, CX
	CMP digito2, 49
	JE Diez 
	CMP digito2, 48
	JE Unidad
	print chr$("Porcentaje mayor a 19%")
	JMP Exit_PL
Diez:
CMP digito1, 34h  ; validar si es 14%
JE Imprimir_e
CMP digito1, 32h ;validar si es 12%
JE Imprimir_a
print chr$("E") ;validar se es 9.9%
JMP Exit_PL
Imprimir_e:
print chr$("E")
JMP Exit_PL
Imprimir_a:
print chr$("A")
JMP Exit_PL
Unidad:
CMP digito1, 39h ; validar si es 9%
JE Imprimir_o 
CMP digito1, 38h ; validar si es 8%
JE Imprimir_s 
CMP digito1, 37h ; validar si es 7.7%
JE Imprimir_s 
CMP digito1, 36h ; validar si es 6.6%
JE Imprimir_n 
CMP digito1, 35h ; validar si es 5.5%
JE Imprimir_i 
CMP digito1, 34h ; validar si es 4.8%
JE Imprimir_u 
CMP digito1, 33h ; validar si es 3.8%
JE Imprimir_t 
CMP digito1, 32h ; validar si es 2.7%
JE Imprimir_m 
CMP digito1, 31h ; validar si es 1.5%
JE Imprimir_y
CMP digito1, 30h ; validar si es 0.6%
JE Imprimir_j
JMP Exit_PL
Imprimir_o:
print chr$("O")
JMP Exit_PL
Imprimir_s:
print chr$("S")
JMP Exit_PL
Imprimir_n:
print chr$("N")
JMP Exit_PL
Imprimir_i:
print chr$("I")
JMP Exit_PL
Imprimir_u:
print chr$("U")
JMP Exit_PL
Imprimir_t:
print chr$("T")
JMP Exit_PL
Imprimir_m:
print chr$("M")
JMP Exit_PL
Imprimir_y:
print chr$("Y, B")
JMP Exit_PL
Imprimir_j:
print chr$("J")
JMP Exit_PL
Exit_PL:
RET
POSIBLE_LETRA ENDP

RECORRER_MATRIZ PROC Near
   XOR AX, AX
   XOR BX, BX 
   XOR CX, CX
   LEA EBX, matriz
   MOV AH, 0
   MOV num_recorrido, 0 ;contador para recorrer la matriz
   Ciclo_R:
   MOV AL, [EBX]
   INC EBX
   INC num_recorrido
   MOV CX, num_recorrido
   CMP CX, num       ; posicion de la matriz desada
   JG Salir_recorrer
   JMP Ciclo_R

Salir_recorrer:
 MOV letra_cifrada, AL      ; nueva letra cifrada
 INVOKE StdOut, ADDR letra_cifrada
RET
RECORRER_MATRIZ ENDP

IMPRIMIR_MATRIZ PROC Near ; Ejemplo para imprimir la matriz 
    XOR AX, AX
	XOR BX, BX 
	XOR CX, CX
    LEA EDI, matriz
	MOV AH, 0
	ciclo:
	MOV BL, [EDI]
	INC EDI
	MOV Ej_imprimir, BL
	INVOKE StdOut, ADDR Ej_imprimir
	INC Count_impri
	MOV CX, Count_impri
	CMP CX, 2A4h
    JE Exit_Imprimir
	JMP ciclo
Exit_Imprimir:
RET
IMPRIMIR_MATRIZ ENDP

Generate_Matrix PROC Near
;limpiar registro
   XOR AX,AX
   XOR BX,BX
   XOR DX,DX 
   MOV X, 00h
   MOV Y, 00h
   MOV Y_Aux, 00h
   LEA EDI, matriz
 Cycle_Rows:                        ; CICLO FILAS
   ;SIGUIENTE FILA
   Cycle_Columns:                   ;CICLO COLUMNAS
   Mapeo X, Y, Rows, Columns, 1     ; El resultado queda en AL [fila, columna]
   MOV Position, AL
   ADD Position, 41h
   XOR EBX,EBX
   MOV BL, Position 
   MOV [EDI], EBX
   INC EDI 
   INC Y
   MOV CL, Y
   CMP CL, Columns
   JL Cycle_Columns
   CMP Position, 5Ah                           ;Validar si ya llego a Z
   JE again_char

   Next_row:                                  ; moverse a la siguiente fila
   MOV Y_Aux, 00h 
   INC count_row
   MOV BL, count_row
   MOV Y, BL
   MOV X, 00h
   INC Count
   MOV CL, Count
   CMP CL, Rows
   JL Cycle_Rows
   JMP EXIT_Generate
   again_char:                                ; Volver a la primera letra del abecedario
    CMP count_row, 00h
	JE Next_row
    Mapeo X, Y_Aux, Rows, Columns, 1         ; El resultado queda en AL [fila, columna]
   MOV Position, AL
   ADD Position, 41h
   XOR EBX,EBX
   MOV BL, Position 
   MOV [EDI], EBX
   INC EDI 
   INC Y_Aux
   MOV CL, Y_Aux
   CMP CL, count_row
   JL again_char
   JMP Next_row

 EXIT_Generate:   ;Salir de generador de codigo
   RET 
Generate_Matrix ENDP

SEPARAR PROC NEAR
	MOV Aux_, 0
	CMP BX, 64h
	JGE CENTENAS
	MOV digito3,30h
	JMP EVALUARDECENAS	
CENTENAS:
	INC Aux_
	Sub BX,	64H
	CMP BX, 64H
	JGE CENTENAS
	MOV DL, Aux_
	ADD DL, 30H
	MOV digito3, DL
	mov Aux_,0
EVALUARDECENAS:
	INVOKE StdOut, ADDR digito3
	MOV digito2, 00h
	cmp BX, 0AH
	JGE DECENAS
CEROD:
	MOV digito2, 30h
	JMP EVALUARSIMPLES	
DECENAS:
	INC Aux_
	Sub BX,	0AH
	CMP BX, 0AH
	JGE DECENAS
	MOV DL, Aux_
	ADD DL, 30H
	MOV digito2, DL
	mov Aux_,0
EVALUARSIMPLES:
	INVOKE StdOut, ADDR digito2
	cmp BX, 01H
	JGE SIMPLES
CEROS:
	MOV digito1, 30h
	JMP VOLVER
SIMPLES:
	INC Aux_
	Sub BX,	01H
	CMP BX, 00H
	JG SIMPLES
	MOV DL, Aux_
	ADD DL, 30H
	MOV digito1, DL
VOLVER:
	INVOKE StdOut, ADDR digito1
RET
SEPARAR ENDP

EXIT_Main:
INVOKE StdOut, ADDR Tab
;finalizar proyecto
INVOKE ExitProcess,0 
END main