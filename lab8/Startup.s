	GLOBAL	Reset_Handler
	IMPORT 	user_code2
	IMPORT	TOGGLE
	IMPORT	TOGGLE_ALL
	
Mode_USR 	EQU	0x10
I_Bit		EQU	0x80
F_Bit		EQU	0x40

USR_Stack_Size	EQU	0x00000100
SRAM			EQU	0x40000000
Stack_Top		EQU	SRAM+USR_Stack_Size

;MEMORY ACCEL0RATOR REGISTERS
MAMCR			EQU	0XE01FC000
MAMTIM			EQU	0xE01FC004
	
			AREA	RESET,CODE,Readonly
			ENTRY
			ARM
VECTORS
			LDR	PC,Reset_Addr
			LDR	PC,Undef_Addr
			LDR	PC,SWI_Addr
			LDR	PC,PAbt_Addr
			LDR	PC,DAbt_Addr
			NOP
			LDR	PC,IRQ_Addr
			LDR	PC,FIQ_Addr

	
Reset_Addr	DCD	Reset_Handler
Undef_Addr	DCD	UndefHandler
SWI_Addr	DCD	SWIHandler
PAbt_Addr	DCD	PAbtHandler
DAbt_Addr	DCD	DAbtHandler
			DCD	0
IRQ_Addr	DCD IRQHandler
FIQ_Addr	DCD	FIQHandler

SWIHandler	B	SWIHandler
PAbtHandler	B	PAbtHandler
DAbtHandler	B	DAbtHandler
IRQHandler	B	IRQHandler
FIQHandler	B	FIQHandler
UndefHandler	B	UndefHandler

Reset_Handler
	;INITIALIZE MAM
	LDR	r1,=MAMCR
	MOV r0,#0X0
	STR r0,[r1];TURN OFF MAM
	LDR	r2,=MAMTIM
	MOV r0,#0x1
	STR	r0,[r2];SET MAM FETCH TO ONE CLOCK CYCLE 
	MOV r0,#0x2
	STR	r0,[r1];FULLY ENABLE MAM
	
;Enter User Mode with interrupts enabled
	MOV r14,#Mode_USR
	BIC	r14,r14,#(0xC0)
	MSR	cpsr_c,r14
;initialize the stack, full descending 
	LDR	SP,=Stack_Top
;load start address of user code into PC
	LDR pc,=user_code2
	B	user_code2
		END		
