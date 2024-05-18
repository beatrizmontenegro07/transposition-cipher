;GRUPO:
; BEATRIZ MONTENEGRO MAIA CHAVES
; ANA CECILIA BEZERRA MOTA
; GEORGIANA MARIA BRAGA GRACA

.686
.model flat, stdcall
option casemap:none

include \masm32\include\windows.inc
include \masm32\include\kernel32.inc
include \masm32\include\masm32.inc
includelib \masm32\lib\kernel32.lib
includelib \masm32\lib\masm32.lib


.data?
;CONTADORES PARA LEITURA/ESCRITA DE ARQUIVOS
readCount dd ?
writeCount dd ?

.data

;VARTIAVEIS DE MENU (menssagem do menu e a entrada com a escolha do usuario)
menuOutput db 13, 10, "------- MENU -------", 13, 10, "[1] Criptografar", 13, 10, "[2] Descriptografar", 13, 10,"[3] Sair",13, 10,"Informe sua escolha: ",0h
inputEscolha db 16 dup(0)

;VARIAVEIS DE ENTRADA
escolha dd 0
chaveArray dword 9 dup(0)

;VARIAVEIS DE PRINT/INPUT
outputHandle dd 0
inputHandle dd 0
console_count dd 0

;STRING DE ENCERRAMENTO
finalOutput db 13, 10, "Programa encerrado!", 0h

;OUTPUT DE ARQUIVO
outputArq1 db 13, 10, "Digite o arquivo de entrada (max de 50 caracteres): ", 0h
outputArq2 db "Digite o nome do arquivo de saida(max de 50 caracteres): ", 0h
outputChave db "Digite a chave (8 digitos, 0-7): ", 0h 

;INPUT DE ARQUIVO/CHAVE
inputArqEntrada db 50 dup(0)
inputArqSaida db 50 dup (0)
inputChave db 11 dup(0)

;VARIAVEIS DE ARQUIVO
fileHandleEntrada dd 0
fileHandleSaida dd 0
bufferEntrada db 8 dup(0)
bufferSaida db 8 dup(0)

.code
start:
    invoke GetStdHandle, STD_OUTPUT_HANDLE
    mov outputHandle, eax
    invoke GetStdHandle, STD_INPUT_HANDLE
    mov inputHandle, eax
    menu:
        ;Menssagem do menu 
        invoke WriteConsole, outputHandle, addr menuOutput, sizeof menuOutput, addr console_count, NULL
        
        ;Entrada de dado da opção escolhida pelo usuário
        invoke ReadConsole, inputHandle, addr inputEscolha, sizeof inputEscolha, addr console_count, NULL

        ;Tratamento de entrada do usuário
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

        ;Caso o usuário tenha optado por criptografia
        cmp escolha, 1
        je lerArquivosChave
        
        ;Caso o usuário tenha optado por descriptografia
        cmp escolha, 2
        je lerArquivosChave
        
        ;Caso o usuário tenha optado por sair
        cmp escolha, 3
        je fim

        ;Caso nao tenha sido digitado um numero valido pelo usuario
        jmp menu

    ;Leitura de arquivos de entrada/saida e a chave para realizar a criptografia/descriptografia
    lerArquivosChave:

        ;Perguntar o arquivo de entrada
        invoke WriteConsole, outputHandle, addr outputArq1, sizeof outputArq1 -1, addr console_count, NULL
        
        ;Receber o nome do arquivo de entrada
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
        invoke WriteConsole, outputHandle, addr outputArq2, sizeof outputArq2 -1, addr console_count, NULL
        
        ;Receber o nome do arquivo de saida
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
        invoke WriteConsole, outputHandle, addr outputChave, sizeof outputChave, addr console_count, NULL
        
        ;receber a chave 
        invoke ReadConsole, inputHandle, addr inputChave, sizeof inputChave, addr console_count, NULL
        
        ;tratamento da chave
        ;lógica contida na videoaula de entrada/saida
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
        mov ecx, 8 ;contador para o laço
        conversor:
            xor eax, eax
            mov al, [esi] ;move o caractere atual para al
            sub al, 48 ;converte para o valor correspondente na tabela ascii
            mov [edi], eax ;move o valor para uma posição no array dword chave
            add edi, 4 ;proxima posição no array de dword 
            inc esi ;proximo caractere na string
            dec ecx
            cmp ecx, 0 ;verifica se pecorreu todas as posicoes
            jge conversor ;se não tiver pecorrido tudo, volta pro label conversor

        ;abertura do arquivo de entrada
        invoke CreateFile, addr inputArqEntrada, GENERIC_READ, 0, NULL, OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL, NULL
        mov fileHandleEntrada, eax

        ;criar o arquivo de saida
        invoke CreateFile, addr inputArqSaida, GENERIC_WRITE, 0, NULL, CREATE_ALWAYS, FILE_ATTRIBUTE_NORMAL, NULL
        mov fileHandleSaida, eax

        ;caso o usuário tenha escolhido 1, executa a criptografia
        cmp escolha, 1
        je criptografando

        ;caso o usuário tenha escolhido 2, executa a descriptografia
        cmp escolha, 2
        je descriptografar

    criptografando:

        ;Leitura de 8 em 8 bytes do arquivo
        continuar:
            mov esi, offset bufferEntrada ;aponta para o incio do buffer
            mov ecx, 0
            ;Zerar buffer de entrada
            zerar:
                mov al, [esi] ;move o caractere atual para al
                xor al, al   ;al=0
                mov [esi], al ;move 0 para a posição em que esi esta apontando
                inc esi
                inc ecx
                cmp ecx, 8
                jne zerar

            ;Leitura de 8 bytes do arquivo       
            invoke ReadFile, fileHandleEntrada, addr bufferEntrada, 8, addr readCount, NULL
            
            ;Verifica de o readCount é 0 para encerrar a leitura/escrita
            cmp readCount, 0
            je finalizar

            ;passagem de parâmetros e chamada da função Criptografa
            mov edi, offset bufferEntrada
            mov esi, offset bufferSaida
            mov ecx, offset chaveArray
            push ecx
            push esi
            push edi
            call Criptografa
            
            ;Escrita no arquivo de saida 
            invoke WriteFile, fileHandleSaida, addr bufferSaida, 8, addr writeCount, NULL
            jmp continuar
            
        finalizar:
        ;fechar o arquivo
        invoke CloseHandle, fileHandleEntrada
        invoke CloseHandle, fileHandleSaida
                
        jmp menu

    descriptografar:

        ;leitura de 8 em 8 bytes do arquivo
        continuar_d:
            mov esi, offset bufferEntrada ;aponta para o incio do buffer
            mov ecx, 0
            ;Zerar buffer de entrada
            zerar_d:
                mov al, [esi] ;move o caractere atual para al
                xor al, al   ;al=0
                mov [esi], al ;move 0 para a posição em que esi esta apontando
                inc esi
                inc ecx
                cmp ecx, 8
                jne zerar_d

            ;Leitura de 8 bytes do arquivo       
            invoke ReadFile, fileHandleEntrada, addr bufferEntrada, 8, addr readCount, NULL
            
            ;Verifica de o readCount é 0 para encerrar a leitura/escrita
            cmp readCount, 0
            je finalizar_d

            ;passagem de parâmetros e chamada da função Descriptografa
            mov esi, offset bufferEntrada
            mov edi, offset bufferSaida
            mov ecx, offset chaveArray
            push ecx
            push edi
            push esi
            call Descriptografa
            
            ;Escrita no arquivo de saida 
            invoke WriteFile, fileHandleSaida, addr bufferSaida, 8, addr writeCount, NULL
            jmp continuar_d
            
        finalizar_d:
        ;fechar o arquivo
        invoke CloseHandle, fileHandleEntrada
        invoke CloseHandle, fileHandleSaida
        
        jmp menu
   
    fim:
        ;menssagem e encerramento do programa
        invoke WriteConsole, outputHandle, addr finalOutput, sizeof finalOutput, addr console_count, NULL
        invoke ExitProcess, 0

    Criptografa:
    push ebp
    mov ebp, esp
    
    mov esi, DWORD PTR[ebp+8];movendo endereço de bufferEntrada para esi
    mov edi, DWORD PTR[ebp+12] ;movendo endereço de bufferSaida para edi
    mov ecx, DWORD PTR[ebp+16] ;movendo endereço do array de chaves para ecx

    ;lógica da criptografia:
    ;semelhante à lógica da descriptografia, mas com as seguintes diferenças:
    ;o byte atual do arquivo de entrada é copiado para o registrador dl
    ;o registrador esi atua como ponteiro para a posição do byte na memória
    ;o byte em dl é criptografado usando a chave e escrito na posição de memória indicada por ebx
    ;o registrador ebx funciona como ponteiro para a posição de saída no arquivo
    
    xor eax, eax
    cripto:
        mov ebx, edi
        add ebx, [ecx]
        mov dl, [esi] ;movendo o byte 'esi' para 'dl' em que contém o endereço de memória dos dados originais
        mov [ebx], dl ;escrevendo o byte lido [esi] em uma posição dada pela chave [ecx], que foi somada no endereço de destino ebx
        inc eax
        cmp eax, 8
        je fimcripto
        inc esi
        add ecx, 4
        jmp cripto
    fimcripto:
    mov esp, ebp
    pop ebp
    ret 12


    Descriptografa:
    push ebp
    mov ebp, esp
    
    mov edi, DWORD PTR[ebp+8];movendo endereço de bufferEntrada para edi
    mov esi, DWORD PTR[ebp+12] ;movendo endereço de bufferSaida para esi
    mov ecx, DWORD PTR[ebp+16] ;movendo endereço do array de chaves para ecx

    ;a logica da desciptografia será:
    ;criar um loop que percorre pelos 8 bytes do array de buffersaida e de chave
    ;o endereço de edi sera sempre fixo, apontando para o primeiro caractere do array
    ;no loop, primeiro moveremos o endereço que esta em edi para um outro registrador, para poder manipulá-lo (nesse caso ebx)
    ;depois somaremos ebx ao valor da chave do indice correspondente (se vamos preencher o primeiro caractere do bufferSaida, usaremos o primeio valor de chave)
    ;colocaremos o valor que agora ebx aponta para o caractere para o qual o bufferDeSaida aponta
    ;por ultimo adicionaremos um ao contador(eax) e ao endereço de saida(esi). E adicionaremos 4 para o array da chaves ja que é um array do tipo DWORD
    
    xor eax, eax
    descrip:
        mov ebx, edi 
        add ebx, [ecx] 
        mov dl, [ebx] 
        mov [esi], dl
        inc eax
        cmp eax, 8
        je fimzinho
        inc esi
        add ecx, 4
        jmp descrip
    fimzinho:
    mov esp, ebp
    pop ebp
    ret 12

end start