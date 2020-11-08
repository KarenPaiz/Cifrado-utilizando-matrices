Imprime MACRO caracter 
	add caracter,41h
	invoke StdOut, ADDR caracter
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

msg_value  DB "Ingresar mensaje: ",0
msg_key    DB "Ingresar clave:   ",0
Tab        DB  0Ah
value      DB 10 DUP(0),0
key        DB 10 DUP(0),0
Count      DB 0,0
count_row   DB 0,0
X          DB 0,0
Y          DB 0,0
Y_Aux      DB 0,0
Position   DB 0,0 
.DATA?
 Option_  DB ?
.CONST ; Constantes
;CONTADORES
Rows    DB 1Ah,0
Columns DB 1Ah,0
.CODE 
main:
   ;Generar Matriz
   CALL Generate_Matrix

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

Option_2:

Option_3:

Option_4:

Encrypt_1 PROC Near
 


Encrypt_1 ENDP


Generate_Matrix PROC Near
;limpiar registro
   XOR AX,AX
   XOR BX,BX
   XOR DX,DX 
   MOV X, 00h
   MOV Y, 00h
   MOV Y_Aux, 00h
 Cycle_Rows:                        ; CICLO FILAS
   INVOKE StdOut, ADDR Tab
   Cycle_Columns:                   ;CICLO COLUMNAS
   Mapeo X, Y, Rows, Columns, 1     ; El resultado queda en AL [fila, columna]
   MOV Position, AL

   Imprime Position

   INC Y
   MOV CL, Y
   CMP CL, Columns
   JL Cycle_Columns
   CMP Position, 5Ah
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

   Imprime Position

   INC Y_Aux
   MOV CL, Y_Aux
   CMP CL, count_row
   JL again_char
   JMP Next_row

 EXIT_Generate:                                  ;Salir de generador de codigo
Generate_Matrix ENDP


EXIT_Main:
INVOKE StdOut, ADDR Tab
;finalizar proyecto
INVOKE ExitProcess,0 
END main