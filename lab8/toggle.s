;TOGGLE FILE (TOGGLE.S)
;TASK3
	GLOBAL 	TOGGLE
	IMPORT Reset_Handler
	IMPORT DELAY
PINSEL0	EQU	0XE002C000	
IO0DIR	EQU	0XE0028008
IO0PIN	EQU	0XE0028000	
DELAY_SWITCH 	EQU	200000
	AREA	myCODE,CODE,READONLY

TOGGLE
	LDR r4,=PINSEL0
	LDR r5, [r4]	;Read
	BIC	r5,r5,#0x30000000	;MODIFY BITS 28-29 FOR PIN 14
	BIC	r5,r5,#0x00FF	;MODIFY BITS 16-23 FOR PINS 8-11
	STR r5,[r4]	;Write
	
	LDR r4,=IO0DIR
	LDR r5, [r4]	;Read
	BIC	r5,r5,#0x4000	;MODIFY BIT 14, MAKE INPUT
	ORR	r5,r5,#0xF00;MODIFY PINS 8-11 TO BE OUTPUTS
	STR r5,[r4]	;Write
	
	LDR r7,=0xF00	;affect LEDs 8-11 only
	LDR	r4,=IO0PIN
	LDR r5, [r4]	;Read
	ORR	r5,r5,r7	;INITIAL TURN OFF
	STR r5,[r4]	;Write
	
PUSHCHECK			;check if pin 14 is pushed
	LDR	r5,[r4]	;IO0PIN contents
	AND	r6,r5,#0x4000	;READS 14 BIT IN ADDRESS
	CMP	r6,#0x4000	;check pin 14
	BEQ	PUSHCHECK
	LDR	r0,=DELAY_SWITCH
	BL	DELAY	;prevent bouncing

PUSHRELEASE
	LDR	r5,[r4]	;IO0PIN contents
	AND	r6,r5,#0x4000	;READS 14 BIT IN ADDRESS
	CMP	r6,#0x4000	;check pin 14; 1-Off 0-On
	BNE	PUSHRELEASE
	LDR	r0,=DELAY_SWITCH
	BL	DELAY	;prevent bouncing
	AND	r6,r5,#0xF00	;reads pins 8-11 only
	CMP	r6,#0xF00	;check if off
	BNE	TURNOFF
	BIC	r6,r5,#0xF00	;certain bits stay zero while rest remain the same
	STR	r6,[r4]
	B	PUSHCHECK
	
TURNOFF	ORR	r6,r5,#0XF00	;when on, turn off
	STR	r6,[r4]
	B	PUSHCHECK
STOP	B	STOP
	END
