%macro	syscall1 2
	mov	ebx, %2
	mov	eax, %1
	int	0x80
%endmacro

%macro	syscall3 4
	mov	edx, %4
	mov	ecx, %3
	mov	ebx, %2
	mov	eax, %1
	int	0x80
%endmacro

%macro  exit 1
	syscall1 1, %1
%endmacro

%macro  write 3
	syscall3 4, %1, %2, %3
%endmacro

%macro  read 3
	syscall3 3, %1, %2, %3
%endmacro

%macro  open 3
	syscall3 5, %1, %2, %3
%endmacro

%macro  lseek 3
	syscall3 19, %1, %2, %3
%endmacro

%macro  close 1
	syscall1 6, %1
%endmacro

%define	STK_RES	200
%define	RDWR	2
%define	SEEK_END 2
%define SEEK_SET 0

%define ENTRY		24
%define PHDR_start	28
%define	PHDR_size	32
%define PHDR_memsize	20	
%define PHDR_filesize	16
%define	PHDR_offset	4
%define	PHDR_vaddr	8
	
global _start

section .text
align 16
_start:	
	push	ebp
	mov		ebp, esp
	sub		esp, STK_RES            ; Set up ebp and reserve space on the stack for local storage

	mov 	edx, OutStrSz
	call 	getpos
getpos:
	pop 	ecx
	add 	ecx, OutStrOffset
	mov 	ebx, 1

	write 	ebx, ecx, edx

VirusExit:
   	exit 0          	; Termination if all is OK and no previous code to jump to
         	            ; (also an example for use of above macros)
	
FileName:		db "ELFexec", 0
OutStrOffset: 	equ $ - getpos
OutStr:			db "The lab 9 proto-virus strikes!", 10, 0
OutStrSz: 		equ $ - OutStr
Failstr:        db "perhaps not", 10 , 0
	
PreviousEntryPoint: dd VirusExit
virus_end:


