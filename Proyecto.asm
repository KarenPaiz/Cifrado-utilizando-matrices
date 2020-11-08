ImprimeNumero MACRO numero 
	add numero,41h
	invoke StdOut, ADDR numero
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
value      DB 1 DUP(0),0
key        DB 1 DUP(0),0
X          DB 0,0
Y          DB 0,0
Position   DB 0,0 
.DATA?
 Option_  DB ?
.CONST ; Constantes
;CONTADORES
Rows    DB 1Ah,0
Columns DB 1Ah,0
.CODE 
main:
print chr$("  Cifrado utilizando matrices  ")
INVOKE StdOut, ADDR Tab
print chr$(" Ingresar Opcion ")
print chr$(" Opcion 1 ")
INVOKE StdOut, ADDR Tab
print chr$(" Opcion 2 ")
INVOKE StdOut, ADDR Tab
print chr$(" Opcion 3 ")
INVOKE StdOut, ADDR Tab
print chr$(" Opcion 4 ")
INVOKE StdOut, ADDR Tab
INVOKE StdIn, ADDR Option_, 10
SUB Option_, 30h 
CMP Option_, 01h
JE Option_1
JMP EXIT_Main

Option_1:
CALL Generate_Matrix


Generate_Matrix PROC Near
;limpiar registro
   XOR AX,AX
   XOR BX,BX
   XOR DX,DX 
   MOV X, 00h
 Cycle_Rows: ; CICLO FILAS
   MOV Y, 00h
   INVOKE StdOut, ADDR Tab
   Cycle_Columns: ;CICLO COLUMNAS
   Mapeo X, Y, Rows, Columns, 1     ; El resultado queda en AL [fila, columna]
   MOV Position, AL
   ImprimeNumero Position

   INC Y
   MOV CL, Y
   CMP CL, Columns
   JL Cycle_Columns
   ; ELSE
   INC X 
   MOV CL, X
   CMP CL, Rows
   JL Cycle_Rows
 
Generate_Matrix ENDP


EXIT_Main:
INVOKE StdOut, ADDR Tab
;finalizar proyecto
INVOKE ExitProcess,0 
END main