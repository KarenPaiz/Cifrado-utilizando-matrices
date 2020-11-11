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

.386
.model flat, stdcall
Option casemap: none
;INCLUDES
INCLUDE \masm32\include\windows.inc
INCLUDE \masm32\include\kernel32.inc
INCLUDE \masm32\include\masm32.inc
INCLUDE \masm32\include\masm32rt.inc
.DATA
matriz     DB 690 DUP(0), 0
Tab        DB  0Ah, 0
value      DB 100 DUP(0), 0
key        DB 100 DUP(0),0
Count      DB 0,0
count_row   DB 0,0
Count_impri DW 0,0
X          DB 0,0
Y          DB 0,0
Y_Aux      DB 0,0
Position   DB 0,0 
num_recorrido DW 0,0
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
print chr$("  Cifrado utilizando matrices  ")
INVOKE StdOut, ADDR Tab
print chr$(" Ingresar Opcion ")
INVOKE StdOut, ADDR Tab
print chr$(" Opcion 1 ")
INVOKE StdOut, ADDR Tab
print chr$(" Opcion 2 ")
INVOKE StdOut, ADDR Tab
print chr$(" Opcion 3 ")
INVOKE StdOut, ADDR Tab
print chr$(" Opcion 4 ")
INVOKE StdOut, ADDR Tab
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
 JMP EXIT_Main

Option_2:

Option_3:

Option_4:

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


EXIT_Main:
INVOKE StdOut, ADDR Tab
;finalizar proyecto
INVOKE ExitProcess,0 
END main