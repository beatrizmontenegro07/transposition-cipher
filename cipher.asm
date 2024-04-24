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

;STRING DE ARQUIVO
outputArq1 db "Digite o arquivo de entrada: ", 0ah, 0h
outputArq2 db "Digite o nome do arquivo de saida(criptografado): ", 0ah, 0h
outputChave db "Digite a chave de criptografia: ", 0ah, 0h 
inputArqEntrada db 20 dup(0)
inputChave db 10 dup(0)
inputArqSaida db 20 dup (0)


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

        ;perguntar o arquivo de entrada
        push STD_OUTPUT_HANDLE
        call GetStdHandle
        mov outputHandle, eax
        invoke WriteConsole, outputHandle, addr outputArq1, sizeof outputArq1 -1, addr console_count, NULL
        
        ;receber o nome do arquivo de entrada
        invoke GetStdHandle, STD_INPUT_HANDLE
        mov inputHandle, eax
        invoke ReadConsole, inputHandle, addr inputArqEntrada, sizeof inputArqEntrada, addr console_count, NULL
        invoke StrLen, addr inputArqEntrada

        ;perguntar o nome do arquivo de saida
        push STD_OUTPUT_HANDLE
        call GetStdHandle
        mov outputHandle, eax
        invoke WriteConsole, outputHandle, addr outputArq2, sizeof outputArq2 -1, addr console_count, NULL
        
        ;receber o nome do arquivo de saida
        invoke GetStdHandle, STD_INPUT_HANDLE
        mov inputHandle, eax
        invoke ReadConsole, inputHandle, addr inputArqSaida, sizeof inputArqSaida, addr console_count, NULL
        invoke StrLen, addr inputArqSaida

        ;perguntar a chave de criptografia
        push STD_OUTPUT_HANDLE
        call GetStdHandle
        mov outputHandle, eax
        invoke WriteConsole, outputHandle, addr outputChave, sizeof outputChave -1, addr console_count, NULL
        
        ;receber o nome do arquivo de saida
        invoke GetStdHandle, STD_INPUT_HANDLE
        mov inputHandle, eax
        invoke ReadConsole, inputHandle, addr inputChave, sizeof inputChave, addr console_count, NULL
        invoke StrLen, addr inputChave
        
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