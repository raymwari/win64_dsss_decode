section .data
  spread_factor equ 15
  seed equ 0x2000
  m_const equ 101
  a_const equ 17 
  header_offet equ 192
  max_buf equ 96

section .bss
  written resb 1
  out_string resb 96
  rec_string resb 96
  result resb 12

section .text
  extern bin_buf, read, out
  extern GetStdHandle, WriteConsoleA
  extract:
    mov rsi, bin_buf
    mov rdi, out_string
    mov rcx, max_buf

    mov r8, [read]
    mov r11, 0
    toencloop:
      mov r9, spread_factor
      modulate:
        mov r10, seed
        add r10, r11
        imul r10, m_const
        add r10, a_const
        mov rax, r10
        xor rdx, rdx
        div r8
        cmp rdx, header_offet
        jge skip
        add rdx, header_offet

        skip:      
          mov r12b, [rsi + rdx]
          xor rdx, rdx
          xor r10, r10
          mov [rdi], r12b
          inc rdi
          dec r9
          cmp r9, 0
          jne modulate      

      inc r11
      dec rcx
      cmp rcx, 0
      jne toencloop 

    mov rbx, max_buf
    mov rsi, out_string
    mov rdi, rec_string
    recover:
      mov rcx, spread_factor
      xor rdx, rdx
      rec_loop:
        mov al, [rsi]
        cmp al, '0'
        je ignore
        inc rdx

        ignore:
          inc rsi
          dec rcx
          test rcx, rcx
          jnz rec_loop
         
      cmp rdx, 11
      jg write_one
      mov byte [rdi], '0'
      jmp next

      write_one:
        mov byte [rdi], '1'

      next:
        inc rdi
        dec rbx
        test rbx, rbx
        jnz recover

    mov rsi, rec_string
    mov rdi, result
    mov rdx, max_buf
    unbin:
      mov al, 0
      mov rcx, 8
      reconstruct:
        mov bl, [rsi]
        shl al, 1
        cmp bl, '1'
        jne writezero
        or al, 1

        writezero:
          inc rsi
          dec rcx
          test rcx, rcx
          jnz reconstruct

      mov [rdi], al
      inc rdi
      dec rdx
      test rdx, rdx
      jnz unbin

    mov ecx, -11
    call GetStdHandle
    mov rcx, rax     
    mov rdx, result        
    mov r8, 12
    lea r9, written 
    call WriteConsoleA   

    jmp out 
