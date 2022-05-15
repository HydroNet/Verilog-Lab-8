	GLOBAL user_code2
	IMPORT	Reset_Handler
	IMPORT	DELAY
	IMPORT delay_C
PINSEL0	EQU	0XE002C000	
IO0DIR	EQU	0XE0028008
IO0PIN	EQU	0XE0028000
IO0SET	EQU	0XE0028004
IO0CLR	EQU	0XE002800C
DELAY_LED	EQU	300000
	AREA	myCODE,CODE,READONLY
	
user_code2
;TASK1	AND TASK2
	LDR r4,=PINSEL0
	LDR	r5,=IO0DIR
	LDR r6,=IO0SET
	LDR	r7,=IO0CLR
	
	LDR r8,=0xFFFF
	LDR	r9,[r4]	;PINSEL0
	AND	r9,r9,r8
	STR r9,[r4]
	
	LDR r8,=0xFF00
	LDR	r9,[r5]	;IO0DIR
	ORR	r9,r9,r8
	STR r9,[r5]
	
	STR	r8,[r6]	;TURN LEDs OFF
LOOP1	LDR	r8,=0x100	;bit to be clearned and LED on
		MOV	r9,#0x8	;amount of iterations
RUN_LEDS	LDR	r0,=DELAY_LED
		STR	r8,[r7]	;TURN ON LED
		PRESERVE8
		BL	delay.c
		;BL	DELAY	;BRACH LINK TO SUBROUTINE
		STR	r8,[r6]	;TURN OFF LED
		LSL	r8,r8,#0x1	;CHANGE VALUE TO AFFECT NEXT BIT AND LED
		SUBS	r9,r9,#0x1
		BNE	RUN_LEDS	;LOOP ITERATION
		B	LOOP1	;
STOP	B	STOP
	END 