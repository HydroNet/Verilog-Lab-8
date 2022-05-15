# Verilog-Lab-8
 Introduction
In this lab, you will develop assembly programs with subroutines. You will continue to
practice the ARM7TDMI instructions. The objectives are:
 to learn how to write and call subroutines in separate files
 to perform subroutine calls between ARM Assembly and C
 to understand and implement switch debouncing
2 Lab Preparation
Please prepare the lab (e.g., read this section, write the needed code, assemble them
to eliminate any syntax error) before you come to the laboratory. If possible, you may run
your code with RealView Microcontroller Development Kit (RMDK) simulator.    This will
help you to complete the required task on time.  
2.1 MULTIPLE‐REGISTER TRANSFER
LDM and STM instructions can transfer multiple registers between memory and
processor in a single instruction, where “M” stands for “multiple”. For example, a single
LDM instruction can load up to 16 registers with memory contents, rather than using 16
individual LDR instructions. These two instructions are more efficient than several single
transfers. It is normally used for moving blocks of data, and also used for performing stack
operations.  
The syntax of the LDM instruction is
LDM<suffix>    rn!,  {destination register list}   
where rn contains the starting address of memory locations. Suffix for LDM could be  
 IA  – Increment After
 IB – Increment Before
 DA – Decrement After
 DB – Decrement Before
The syntax of the STM instruction is similar:
STM<suffix>    rn!,  {source register list}   
   The following illustrates how the multiple‐register transfer instructions work. For
example, we have instruction
LDMIA    r0!, {r1‐r3}
where register r0 holds the memory address, and three consecutively‐stored 32‐bit
numbers will be loaded from this memory location to register r1, r2, and r3, respectively.
The register r0 will automatically increment by 4 after each load. A detailed operation is
illustrated in Figure 1.  
California State University, Northridge ECE425L
ECE Department By: Xiaojun Geng
2 
Figure 1. LDMIA – loading data from memory to registers with option “increment after”. 
2.2 CALLING SUBROUTINES
Subroutines are small blocks of code which are written to complete short tasks, and
are called by other programs to execute. Calling subroutines in a large program helps
make your code well organized and easy to read. It also allows reuse of software and
helps reduce the size of software.  
To call a subroutine, we use BL (branch and link) instruction, for example
BL   my_subroutine  ;my_subroutine points to the first line of a subroutine
This instruction transfers the branch target (i.e., the starting address of your subroutine)
into the program counter PC, and transfers the return address (i.e., the address of the
next instruction after branch in the calling program) into the link register LR. For this
reason, the last instruction of a subroutine should perform the following data transfer:
LR  PC
You may use MOV instruction for such transfer:
MOV   pc, lr
To write a subroutine, we need to pay attention to data transferring as well.
Operations in a subroutine may alter register values, which may not be expected or
aware by the calling program. For all those corrupted registers, the original values need
to be saved in the beginning of a subroutine, and restored in the end of a subroutine.
Also, subroutines could be nested; in other words, a subroutine could call another
subroutine. When this occurs, the link register will be overwritten by the second BL
instruction. Therefore, the link register needs to be saved in the beginning of a
subroutine. A problem arises: “where to save the corrupted registers and link register”?
The answer is the stack.    
2.3 STACK OPERATIONS
The Stack is a data structure with last‐in‐first‐out feature. It could grow downwards
(common) or upwards in memory. Address of the top of the stack is stored in the Stack
Pointer, i.e., register sp or r13. There are two types of stack operations:
 Push, which stores a data item on the stack and can be implemented with a
STR or STM
 Pop, which load registers with the stack contents and can be implemented
with a LDR or LDM
California State University, Northridge ECE425L
ECE Department By: Xiaojun Geng
3 
The two multiple‐register transfer instructions introduced in Section 2.1 can be used
to implement stack operations, where the first operand rn will be sp or r13. For example,
in the beginning of a subroutine, if the values of registers r4 – r6 and the link register
need to be saved, we write
STMDB  sp!,  {r4‐r6, lr}
Before the end of the subroutine, we need to restore the values of registers r4 – r6 and
load the return address in link register (lr) to the program counter (pc) with code:
LDMIA  sp!,  {r4‐r6, pc}
The above two instructions together perform a full‐descending stack, where the stack
pointer point to the last item in the stack (full), and the stack grows from high address to
low address (descending). For simplicity, programmers could write the above two
instructions equivalently as
STMFD  sp!,  {r4‐r6, lr}
and
    LDMFD  sp!,  {r4‐r6, pc}
These two instructions should be the first and the last instructions of a subroutine. Note
that the above instructions also implement the data transfer LR  PC. A complete
example of calling subroutines can be found on page 156 of the textbook.  
2.4 THE ARM APPLICATION PROCEDURE CALL STANDARD  
The ARM Application Procedure Call Standard (AAPCS) for the ARM architecture
defines how subroutines can be independently written, separately complied, and
assembled to work together. Some parts of the specification are listed below, which can
be found on page 160 of the textbook:
 The first four registers r0 – r3 are used to pass argument values into a subroutine
and to return a result value from a function.
 The registers r4 – r8, r10, and r11 are normally used to hold the values of a
routine’s local variables.
 The ARM and THUMB C and C++ compilers always use a full descending stack.
 Stacks must be eight‐byte aligned, and the ARM and THUMB C and C++ compilers
always use a full descending stack.
Although your program may work without conforming to the above specification, it is
a good practice to have these specifications in mind. In particularly, when calling between
C, C++, and assembly language is needed, assembly language modules must conform to
the appropriate AAPCS standard.  
2.5 CALLING SUBROUTINES IN SEPARATE FILES  
In this experiment, you will write and call subroutines in separate files. Grouping
code having different functionalities in separate files helps to make our project organized,
easy to read, and easy to edit. It also helps to reduce the code size.   
California State University, Northridge ECE425L
ECE Department By: Xiaojun Geng
4 
An example of calling subroutines from a different file has been implemented in
previous lab experiments. The user program you created before has been assigned with a
label user_code, which can be treated as a subroutine in ARM assembly. In order for
user_code to be found by a different program file, we need to declare the subroutine
name (i.e., the label) as a global variable. That is,  
GLOBAL   user_code ;GLOBAL  is an Assembler directive
The user_code is then called by our startup code. To do so, the startup code needs to
provide the assembler with this name that is not defined in the current assembly.
IMPORT or EXTERN directive can be used for this purpose, for example,
IMPORT   user_code ;IMPORT is an Assembler directive
IMPORT directive imports the symbol unconditionally, while EXTERN imports the symbol
only if it is referred to in the current assembly.  
Figure 2. Linker Control.
2.6 CALLING SUBROUTINES IN C
In this lab, you need to write a delay subroutine in ARM assembly which wastes time
in a loop. The delay needs to be general so that the delay constant for duration can be
controlled by the calling program. In addition, you need to write a general delay
subroutine in C language during your pre‐lab preparation, and save in a file named
California State University, Northridge ECE425L
ECE Department By: Xiaojun Geng
5 
delay.c. When your ARM assembly program calls this C function, the arguments are
passed through registers r0 – r3. More specially, the first argument is passed with r0, the
second with r1, and so on. If more arguments are required, the stack is used for
parameter passing.  
In the case where a µVision project contains files in different languages, for example,
assembly and C, the RealView linker used by the µVision IDE will make C code as the entry
point of the execution. In this lab, the startup code in assembly language should always
be the entry point. To make this happen, the configuration of the linker, as illustrated in
Figure 2, is needed, where “‐‐first mystarup.o” needs to be written in “Misc Controls” box.
8‐byte stack alignment is required for complier to link the machine code of mixed‐
language programs. To ensure that, the assembler directive PRESERVE8 needs to be used
in the assembly files where a C or C++ function is called.
By default, the processor inserts wait states when accessing the ROM. They are
necessary when operating at high speed. However, when operating at 12 MHz, they are
not necessary.
To take out the wait states, which will make calculating delay loop times far easier,
insert the following code into your startup file:
;MEMORY ACCELORATOR REGISTERS
MAMCR    EQU   0xE01FC000
MAMTIM   EQU   0xE01FC004
;Initialize MAM
         LDR   R1,=MAMCR
         MOV   R0,#0x0
         STR   R0,[R1] ; Turn off MAM
         LDR   R2,=MAMTIM
         MOV   R0,#0x1
         STR   R0,[R2] ; Set MAM fetch to one clock cycle
         MOV   R0,#0x2
         STR   R0,[R1] ; Fully enable MAM
2.7 SWITCH DEBOUNCING   
In this lab, the push‐button switch connected to P0.14 on the Education broad will be
read, more than once by the processor. In such case, we need to consider to do switch
debouncing.  
Due to mechanical characteristics, switches tend to bounce back and forth when it is
pressed; in other words, they make and break contacts multiple times before they settle.
Comparing to the processor speed, the bounce is quite slow; if the processor reads the
switch input, one press appears like multiple presses. Figure 3 depicts a typical input
signal due to a switch press. Similar behavior appears when the switch is released.  
California State University, Northridge ECE425L
ECE Department By: Xiaojun Geng
6 
Figure 3. Switch bounce produced on a switch press.
In this lab experiment, we will need to debounce the switch. Debouncing is necessary
because when a key is pressed or released, the contacts of the switch being open and
closed repeatedly for several milliseconds. This in turn causes your input to bounce
between Low (switch is closed and shorted to ground) and High (switch is open and pull‐
up resistor pulls input high). Solutions to debouncing are available in both hardware and
software. Software approach will be used for this experiment.  
To remove the effect of switch bouncing, we simply put in a time delay to allow the
switch to settle after it has been pressed, before the next reading. In this lab, you need to
examine how much time delay to insert with an oscilloscope and to observe what will
happen without switch debouncing being implemented in your program.  
3 Procedures and Tasks
For each of the following tasks, you need to  
 Create and assemble your code to implement the task BEFORE coming to the lab.
 Simulate your code and verify the result with the simulator.
 Download the machine code in HEX file to the LPC2148 microcontroller, and verity
the result after execution.
 Demonstrate the results to the lab instructor before you leave the lab.
Task 1: Write a complete program to create a running LED using the 8 LEDs connected to
pin P0.8 – P0.15.  More specifically, light up one LED at a time, from P0.8 to P0.15, with a
short delay in between, and then repeat. The delay needs to be generated by calling an
ARM assembly subroutine which is in a separate file.  
Task 2: Repeat the Task 1 by calling a delay function written in C programming language.
The delay function needs to be in a separate file.    
Task 3: Write a complete program to initially keep the 4 LEDs off which are connected to
pin P0.8, P0.9, P0.10, and P0.11, and toggle them on and off every time when the
pushbutton P0.14 is pressed. More specifically, turn on LEDs when switch is pressed, turn
off when pressed again, and then repeat. Also observe the consequence of your program
when the switch debouncing delay is removed, and discuss about it in your report.
California State University, Northridge ECE425L
ECE Department By: Xiaojun Geng
7 
Note: (1) For all the configurations, when you set or clear selected register bits, make sure
that the rest of unrelated bits keep unchanged; and (2) Increase readability of your code
by grouping instructions into subroutines, such as, LED_setup, Delay, etc.
Task 4: Write a complete program to initially keep the 8 LEDs off which are connected to
pin P0.8 – P0.15, and toggle the 8 LEDs on and off every time when the pushbutton P0.14
is pressed. More specifically, turn on LEDs when switch is pressed, turn off when pressed
again, and then repeat. Explain what happens to the LED on P0.14.  
4 Requirements:
A. It is very important to complete your pre‐lab.  You are required to show your
assembly code on paper for all the tasks.
B. Lab report is DUE right before the next lab time. The report should include your
names, experiment objectives, experiment problems, the print‐out of your work,
and explanation and discussion.
C. Demonstrate your results to the instructor before you leave. Failure to do so will
result in zero point for performance
