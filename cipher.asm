.686
.model flat, stdcall
option casemap:none

include \masm32\include\windows.inc
include \masm32\include\kernel32.inc
include \masm32\include\masm32.inc
includelib \masm32\lib\kernel32.lib
includelib \masm32\lib\masm32.lib

.data

;STRING DO MENU (menssagem do menu e da entrada de dado)
menuOutput db "[1] Criptografar", 13, 10, "[2] Descriptografar", 13, 10,"[3] Sair",13, 10,"Informe sua escolha: ",0h

;VARIAVEIS DE ENTRADA
inputEscolha db 16 dup(0)
escolha dd 0

;VARIAVEIS DE PRINT/INPUT
outputHandle dd 0
inputHandle dd 0
console_count dd 0

;STRING DE ENCERRAMENTO
finalOutput db "Programa encerrado!", 0h



.code
start:
    menu:
        ;Menssagem do menu
        invoke GetStdHandle, STD_OUTPUT_HANDLE
        mov outputHandle, eax
        invoke WriteConsole, outputHandle, addr menuOutput, sizeof menuOutput, addr console_count, NULL

        ;Entrada de dado da opção escolhida pelo usuário
        invoke GetStdHandle, STD_INPUT_HANDLE
        mov inputHandle, eax
        invoke ReadConsole, inputHandle, addr inputEscolha, sizeof inputEscolha, addr console_count, NULL
        invoke StrLen, addr inputEscolha

        ;Tratamento de entrada
        mov esi, offset inputEscolha
        proximo:
            mov al, [esi]
            inc esi
            cmp al, 13
            jne proximo
            dec esi
            xor al, al
            mov [esi], al

        ;Convertendo a entrada para um numero inteiro
        invoke atodw, addr inputEscolha
        mov escolha, eax

        cmp escolha, 1
        je criptografar

        cmp escolha, 2
        je descriptografar

        cmp escolha, 3
        je fim

    criptografar:
        ;aqui vai toda a logica de criptografia
        jmp menu

    descriptografar:
        ;aqui vai toda a logica de criptografia
        jmp menu
           
    fim:
        invoke GetStdHandle, STD_OUTPUT_HANDLE
        mov outputHandle, eax
        invoke WriteConsole, outputHandle, addr finalOutput, sizeof finalOutput, addr console_count, NULL
        invoke ExitProcess, 0
end start 
