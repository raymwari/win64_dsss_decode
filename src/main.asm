section .data
  file_name db "out.mp3", 0
  OF_PROMPT equ 0x00002000
  MAX_JPEG_SIZE equ 966656
  MAX_BIN_SIZE equ 9666560

section .bss
  ofstruct resb 136
  file_read_buf resb MAX_JPEG_SIZE
  read resb 1
  bin_buf resb MAX_BIN_SIZE

section .text
  extern ExitProcess, OpenFile
  extern ReadFile, ecode
  extern CloseHandle, extract
  global _main
  _main:
    push rbp
    sub rsp, 40

    mov rcx, file_name
    lea rdx, ofstruct
    mov r8d, OF_PROMPT
    call OpenFile
    test rax, rax 
    jz ecode 
    mov rsi, rax

    mov rcx, rsi
    lea rdx, file_read_buf
    mov r8, MAX_JPEG_SIZE
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
  
