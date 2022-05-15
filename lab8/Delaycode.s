;delay file
	GLOBAL DELAY
	IMPORT	user_code2
	IMPORT	TOGGLE
	IMPORT	TOGGLE_ALL
	AREA	myCODE,CODE,READONLY
	
DELAY	
	STMEA	SP!,{r4-r9,LR}
	MRS	r1,CPSR	;protects flags from "calling program"
LOOP1	SUBS	r0,r0,#0x1	;decrement loop
	BNE	LOOP1
	MSR	CPSR_F,r1	;restore flags
	LDMEA	SP!,{r4-r9,PC}		;loads values to protect
STOP	B	STOP	
	END