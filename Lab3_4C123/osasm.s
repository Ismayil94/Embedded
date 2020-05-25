;/*****************************************************************************/
; OSasm.s: low-level OS commands, written in assembly                       */
; Runs on LM4F120/TM4C123/MSP432
; Lab 3 starter file
; March 2, 2016




        AREA |.text|, CODE, READONLY, ALIGN=2
        THUMB
        REQUIRE8
        PRESERVE8

        EXTERN  RunPt            ; currently running thread
        EXPORT  StartOS
        EXPORT  SysTick_Handler
        IMPORT  Scheduler


SysTick_Handler                ; 1) Saves R0-R3,R12,LR,PC,PSR
    CPSID   I                  ; 2) Prevent interrupt during switch
	PUSH 	{R4-R11} 			   ; 3) Save remaining regs R4-R11 (callee’s responsibility; due to APCS)
	LDR 	R0, =RunPt 			   ; 4) R0=pointer to RunPt (address of RunPt), old thread
	LDR 	R1, [R0] 			   ; R1 = RunPt (address of actual TCB)
	STR 	SP, [R1] 			   ; 5) Save SP into TCB (first 32 bit word within TCB)
    
	;LDR 	R1, [R1,#4] 		   ; 6) R1 = RunPt->next is read from 2nd 32-bit word in TCB; which is stored at the start address of TCB + 4
	;STR 	R1, [R0] 			   ; RunPt = R1
	
	PUSH 	{R0, LR}
	BL 		Scheduler
	POP 	{R0, LR}
	LDR 	R1, [R0]
	
	LDR 	SP, [R1] 			   ; 7) new thread SP; SP = RunPt->sp;
	POP 	{R4-R11} 			   ; 8) restore regs R4-11
	CPSIE   I                  ; 9) tasks run with interrupts enabled
    BX      LR                 ; 10) restore R0-R3,R12,LR,PC,PSR

StartOS
   ;YOU IMPLEMENT THIS (same as Lab 2)
	LDR 	R0, =RunPt 			   ; currently running thread (address of R0)
	LDR 	R1, [R0] 			   ; R1 = value of RunPt
	LDR 	SP, [R1] 			   ; new thread SP; SP = RunPt->sp;
	POP 	{R4-R11} 			   ; restore regs R4 ... R11
	POP 	{R0-R3} 			   ; restore regs R0 ... R3
	POP 	{R12}
	ADD 	SP, SP, #4 			   ; discard LR from initial stack
	POP 	{LR} 				   ; start location of first thread
	ADD 	SP, SP, #4 			   ; discard PSR
    CPSIE   I                  ; Enable interrupts at processor level
    BX      LR                 ; start first thread

    ALIGN
    END
