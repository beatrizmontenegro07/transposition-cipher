.686
.model flat, stdcall
option casemap:none

include \masm32\include\windows.inc
include \masm32\include\kernel32.inc
include \masm32\include\masm32.inc
include \masm32\include\msvcrt.inc
includelib \masm32\lib\kernel32.lib
includelib \masm32\lib\masm32.lib
includelib \masm32\lib\msvcrt.lib ;LEMBRAR DE TIRAR DEPOIS
include \masm32\macros\macros.asm ;LEMBRAR DE TIRAR DEPOIS


.data?
readCount dd ?
writeCount dd ?

.data

;VARTIAVEIS DE MENU (menssagem do menu e entrada com a escolha do usuario)
menuOutput db 13, 10, "------- MENU -------", 13, 10, "[1] Criptografar", 13, 10, "[2] Descriptografar", 13, 10,"[3] Sair",13, 10,"Informe sua escolha: ",0h
inputEscolha db 16 dup(0)

;VARIAVEIS DE ENTRADA
escolha dd 0
chaveArray dword 8 dup(0)

;VARIAVEIS DE PRINT/INPUT
outputHandle dd 0
inputHandle dd 0
console_count dd 0

;STRING DE ENCERRAMENTO
finalOutput db 13, 10, "Programa encerrado!", 0h

;OUTPUT DE ARQUIVO
outputArq1 db 13, 10, "Digite o arquivo de entrada (max de 50 caracteres): ", 0h
outputArq2 db "Digite o nome do arquivo de saida(max de 50 caracteres): ", 0h
outputChave db "Digite a chave (max 8 digitos, 0-7): ", 0h 

;INPUT DE ARQUIVO/CHAVE
inputArqEntrada db 50 dup(0)
inputArqSaida db 50 dup (0)
inputChave db 8 dup(0)

;VARIAVEIS DE ARQUIVO
fileHandleEntrada dd 0
fileHandleSaida dd 0
bufferEntrada db 8 dup(0)


.code
start:
    menu:
        ;Menssagem do menu
        invoke GetStdHandle, STD_OUTPUT_HANDLE
        mov outputHandle, eax
        invoke WriteConsole, outputHandle, addr menuOutput, sizeof menuOutput, addr console_count, NULL
        
        ;Entrada de dado da op��o escolhida pelo usu�rio
        invoke GetStdHandle, STD_INPUT_HANDLE
        mov inputHandle, eax
        invoke ReadConsole, inputHandle, addr inputEscolha, sizeof inputEscolha, addr console_count, NULL

        ;Tratamento de entrada do usu�rio
        ;L�gica contida na videoaula de entrada/saida
        mov esi, offset inputEscolha
        proximoMenu:
            mov al, [esi]
            inc esi
            cmp al, 13
            jne proximoMenu
            dec esi
            xor al, al
            mov [esi], al

        ;Convertendo a entrada para um numero inteiro
        invoke atodw, addr inputEscolha
        mov escolha, eax

        ;Caso o usu�rio tenha optado por criptografia
        cmp escolha, 1
        je lerArquivosChave
        
        ;Caso o usu�rio tenha optado por descriptografia
        cmp escolha, 2
        je lerArquivosChave
        
        ;Caso o usu�rio tenha optado por sair
        cmp escolha, 3
        je fim

        ;Caso nao tenha sido digitado um numero valido pelo usuario
        jmp menu

    ;Leitura de arquivos de entrada/saida e a chave para realizar a criptografia/descriptografia
    lerArquivosChave:

        ;Perguntar o arquivo de entrada
        invoke GetStdHandle, STD_OUTPUT_HANDLE
        mov outputHandle, eax
        invoke WriteConsole, outputHandle, addr outputArq1, sizeof outputArq1 -1, addr console_count, NULL
        
        ;Receber o nome do arquivo de entrada
        invoke GetStdHandle, STD_INPUT_HANDLE
        mov inputHandle, eax
        invoke ReadConsole, inputHandle, addr inputArqEntrada, sizeof inputArqEntrada, addr console_count, NULL

        ;Tratamento do arquivo de entrada
        mov esi, offset inputArqEntrada
        proximoEntrada:
            mov al, [esi]
            inc esi
            cmp al, 13
            jne proximoEntrada
            dec esi
            xor al, al
            mov [esi], al
        

        ;Perguntar o nome do arquivo de saida
        invoke GetStdHandle, STD_OUTPUT_HANDLE
        mov outputHandle, eax
        invoke WriteConsole, outputHandle, addr outputArq2, sizeof outputArq2 -1, addr console_count, NULL
        
        ;Receber o nome do arquivo de saida
        invoke GetStdHandle, STD_INPUT_HANDLE
        mov inputHandle, eax
        invoke ReadConsole, inputHandle, addr inputArqSaida, sizeof inputArqSaida, addr console_count, NULL
       

        ;Tratamento do arquivo de saida
        mov esi, offset inputArqSaida
        proximoSaida:
            mov al, [esi]
            inc esi
            cmp al, 13
            jne proximoSaida
            dec esi
            xor al, al
            mov [esi], al
        
        ;perguntar a chave
        invoke GetStdHandle, STD_OUTPUT_HANDLE
        mov outputHandle, eax
        invoke WriteConsole, outputHandle, addr outputChave, sizeof outputChave, addr console_count, NULL
        
        ;receber a chave 
        invoke GetStdHandle, STD_INPUT_HANDLE
        mov inputHandle, eax
        invoke ReadConsole, inputHandle, addr inputChave, sizeof inputChave, addr console_count, NULL
        

        ;tratamento da chave
        mov esi, offset inputChave
        proximoChave:
            mov al, [esi]
            inc esi
            cmp al, 48
            jl terminaChave
            cmp al, 58
            jl proximoChave
        terminaChave:
            dec esi
            xor al, al
            mov [esi], al

        ;Convertendo a string para um array do tipo dword
        mov esi, offset inputChave ;aponta para o inicio do input da chave (string)
        mov edi, offset chaveArray ;aponta para o inicio do vetor do tipo dword
        mov ecx, 8 ;contador para o la�o
        conversor:
            xor eax, eax
            mov al, [esi] ;move o caractere atual para al
            sub al, 48 ;converte para o valor correspondente na tabela ascii
            mov [edi], eax ;move o valor para uma posi��o no array dword chave
            add edi, 4 ;proxima posi��o no array de dword 
            inc esi ;proximo caractere na string
            dec ecx
            cmp ecx, 0 ;verifica se pecorreu todas as posicoes
            jge conversor ;se n�o tiver pecorrido tudo, volta pro label conversor


        ;verificando se a convers�o ocorreu corretamente
        ;mov esi, offset chaveArray
        ;mov ecx, 8
        ;imprimir:
        ;    mov ebx, [esi]
        ;    push ecx
        ;    printf("%d\n", ebx)
        ;    pop ecx
        ;    add esi, 4
        ;    loop imprimir
            
        ;abertura do arquivo de entrada
        invoke CreateFile, addr inputArqEntrada, GENERIC_READ, 0, NULL, OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL, NULL
        mov fileHandleEntrada, eax

        ;criar o arquivo de saida
        invoke CreateFile, addr inputArqSaida, GENERIC_WRITE, 0, NULL, CREATE_ALWAYS, FILE_ATTRIBUTE_NORMAL, NULL
        mov fileHandleSaida, eax

         
        ;caso o usu�rio tenha escolhido 1, executa a criptografia
        cmp escolha, 1
        je criptografando

        ;caso o usu�rio tenha escolhido 2, executa a descriptografia
        cmp escolha, 2
        je descriptografar

    criptografando:
        ;Aqui vai toda a logica de criptografia
        ;Leitura de 8 em 8 bytes
        continuar:
            mov esi, offset bufferEntrada ;aponta para o incio do buffer
            mov ecx, 0
            ;Zerar buffer de entrada
            zerar:
                mov al, [esi] ;move o caractere atual para al
                xor al, al   ;al=0
                mov [esi], al ;move 0 para a posi��o em que esi esta apontando
                inc esi
                inc ecx
                cmp ecx, 8
                jne zerar

            ;Leitura de 8 bytes do arquivo       
            invoke ReadFile, fileHandleEntrada, addr bufferEntrada, 8, addr readCount, NULL
            ;Verifica de o readCount � 0 para encerrar a leitura/escrita
            cmp readCount, 0
            je finalizar
            ;Escrita no arquivo de saida 
            invoke WriteFile, fileHandleSaida, addr bufferEntrada, 8, addr writeCount, NULL
            jmp continuar
            
        finalizar:
        ;fechar o arquivo
        invoke CloseHandle, fileHandleEntrada
        invoke CloseHandle, fileHandleSaida
                
        jmp menu

    descriptografar:
        ;aqui vai toda a logica de descriptografia
        jmp menu
           
    fim:
        ;menssagem e encerramento do programa
        invoke GetStdHandle, STD_OUTPUT_HANDLE
        mov outputHandle, eax
        invoke WriteConsole, outputHandle, addr finalOutput, sizeof finalOutput, addr console_count, NULL
        invoke ExitProcess, 0
end start 