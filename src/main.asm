section .data
  OF_PROMPT equ 0x00002000
  MAX_FILE_SIZE equ 5242880 ; 5 mb
  MAX_BIN_SIZE equ 52428800 ; 50 mb
  file_name_max equ 255
  conf_file db "config.cfg", 0

section .bss
  ofstruct resb 136
  file_read_buf resb MAX_FILE_SIZE
  read resb 1
  bin_buf resb MAX_BIN_SIZE
  target resb file_name_max
  cfg_buf resb file_name_max

section .text
  extern ExitProcess, OpenFile
  extern ReadFile, ecode
  extern CloseHandle, extract
  global _main
  _main:
    push rbp
    sub rsp, 40

    mov rcx, conf_file
    lea rdx, ofstruct
    mov r8, OF_PROMPT
    call OpenFile
    test rax, rax
    jz ecode

    mov rcx, rax
    lea rdx, cfg_buf
    mov r8, file_name_max
    mov r9, 0
    mov qword [rsp + 32], 0
    call ReadFile
    test rax, rax
    jz ecode

    mov rsi, cfg_buf
    mov rdi, target
    mov rcx, file_name_max
    extg:
      mov byte al, [rsi]
      cmp byte al, 0x0D
      jne extgc
      jmp extgd

      extgc:
        mov byte [rdi], al
        inc rsi
        inc rdi
        dec rcx
        test rcx, rcx
        jnz extg
        
    extgd:    
      ; config.cfg

    mov rcx, target
    lea rdx, ofstruct
    mov r8d, OF_PROMPT
    call OpenFile
    test rax, rax 
    jz ecode 
    mov rsi, rax

    mov rcx, rsi
    lea rdx, file_read_buf
    mov r8, MAX_FILE_SIZE
    lea r9, read
    mov qword [rsp + 32], 0
    call ReadFile
    test rax, rax 
    jz ecode

    jmp decode
    end:
      mov rcx, rsi
      call CloseHandle
      test rax, rax
      jz ecode

      add rsp, 40
      mov rcx, 0
      call ExitProcess

    decode:
      push rsi
      mov rdi, file_read_buf
      mov rdx, [read] 
      
      mov r8, bin_buf
      binloop:
        mov byte al, [rdi]
        mov rcx, 8  
        nextbit:
          test rcx, rcx
          jz nextbyte

          shl al, 1
          jc write_one 
          mov byte [r8], '0'
          inc r8
          dec rcx
          jmp nextbit

          write_one:
            mov byte [r8], '1'
            inc r8          
            dec rcx
            jmp nextbit

        nextbyte:
          inc rdi
          dec rdx
          cmp rdx, 0
          jne binloop

      jmp extract
      
    out:
      pop rsi
      jmp end
  
