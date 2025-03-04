; BLINK LIGHTS (RANDOM) BY RICKY BRYCE
; FOR SC126 Z180 COMPUTER
; 01 JAN 2025
; IE: SLR180 RAND.CCC/F (TO ASSEMBLE ON DRIVE C
;                        WITH FULL LISTING)

     ORG 100H	; CP/M PROGRAMS BEGIN AT 0100H

;---------------------------------------------
;+-------------- DEFINITIONS ----------------+
;---------------------------------------------

PA     EQU     01H	; PORT A
PB     EQU     02H	; PORT B
PC     EQU     03H	; PORT C
PD     EQU     04H	; PORT D
PE     EQU     0DH	; PORT E

;---------------------------------------------
;+---------- iNITIALIZE VALUES --------------+
;---------------------------------------------

INIT:
     XOR A              ; INITIALIZE ACCUMULTAOR

;---------------------------------------------
;+------------- MAIN ROUTINE ----------------+
;---------------------------------------------
MAIN:
     CALL RAND          ; CALL RANDOM GENERATOR
     OUT PA,A           ; WRITE TO PORT A
     CALL PREDELAY1     ; CALL DELAY LOOP
     CALL RAND          ; CALL RANDOM GENERATOR
     OUT PB,A           ; WRITE TO PORT B
     CALL PREDELAY1     ; CALL DELAY LOOP
     CALL RAND          ; CALL RANDOM GENERATOR
     OUT PC,A           ; WRITE TO PORT C
     CALL PREDELAY1     ; CALL DELAY LOOP
     CALL RAND          ; CALL RANDOM GENERATOR
     OUT PD,A           ; WRITE TO PORT D
     CALL PREDELAY1     ; CALL DELAY LOOP
     CALL RAND          ; CALL RANDOM GENERATOR
     OUT PE,A           ; WRITE TO PORT E
     CALL PREDELAY1     ; CALL DELAY LOOP
     JP MAIN

;---------------------------------------------
;+-------- CREATE "RANDOM" NUMBER -----------+
;---------------------------------------------

RAND:
     LD HL,RANDSD     ; LOAD HL WITH MEMORY LOCATION
     LD A,(HL)        ; LOAD A WITH RANDOM SEED
     LD B,A           ; LOAD B FROM A
     RRCA             ; ROTATE RIGHT WITH CARRY
     XOR B            ; GENERATE SEMI RANDOM VALUE
     ADD 1BH          ; PREVENT LOCKUP IF ZERO OF FF
     LD (HL),A        ; STORE NEW RANDOM SEED
     PUSH AF          ; BACKUP AF
     CALL GETCONSOLE  ; CHECK FOR CONTROL-C TO EXIT
     POP AF           ; RESTORE AF
     RET              ; RETURN FROM SUBROUTINE

;---------------------------------------------
;+-------------- DELAY LOOP -----------------+
;---------------------------------------------

PREDELAY1:           ; (INITIALIZE OUTER LOOP)
     LD HL,SPEEDVAL  ; SET UP HL WITH SPEEDVAL MEMORY LOCATION
     LD B,(HL)       ; LOAD B WITH SPEEDVAL (MEMORY)

DELAY1:              ; (((OUTER DELAY LOOP)))
PREDELAY2:           ; (INITIALIZE MIDDLE LOOP)
     PUSH BC         ; BACKUP BC
     LD HL,SPEEDVAL  ; SET UP HL WITH SPEEDVAL MEMORY LOCATION
     LD B,(HL)       ; LOAD B WITH SPEEDVAL (MEMORY)

DELAY2:              ; (((MIDDLE DELAY LOOP)))
PREDELAY3:           ; (INITIALIZE INNER LOOP)
     PUSH BC         ; BACKUP BC
     LD B,10H        ; LOAD B WITH 0AH

DELAY3:              ; (((INNER DELAY LOOP)))
     DJNZ DELAY3     ; LOOP BACK IF B!=0

     POP BC          ; RESTORE BC
    DJNZ DELAY2     ; RETURN TO MIDDLE LOOP

     POP BC          ; RESTORE VALUES TO BC
     DJNZ DELAY1     ; JUMP TO DELAY1 (MAINLOOP)
     RET             ; RETURN FROM SUBROUTINE

;---------------------------------------------
;+----------- GET CONSOLE INPUT -------------+
;---------------------------------------------

GETCONSOLE:          ; (((CHECK FOR EXIT CTRL-C)))
     LD C,06H        ; CP/M CONSOLE INPUT
     LD E,0FFH       ; GET CONSOLE INPUT (NO ECHO)
     CALL 5          ; BDOS ROUTINE
     LD HL,CHARRCV   ; LOAL WITH MEMORY FOR RECEIVED CHAR
     LD (HL),A       ; LOAD CHARACTER RECEIVED TO MEMORY
     CP 3            ; CHECK FOR CONTROL-C
     JP Z,EXIT       ; IF CONTROL-C THEN EXIT TO CP/M
     CALL SPEED      ; CHECK FOR SPEED CHANGE
     RET             ; RETURN TO MAIN

SPEED:               ; (((GET SPEED FROM CONSOLE)))
     LD HL,CHARRCV   ; LOAD HL WITH MEMORY LOCATION
     LD A,(HL)       ; LOAD A WITH CHARACTER
     OR A            ; SET FLAGS
     JP Z,CONSOLERET ; RETURN IF NO INPUT (NULL)
     SUB 30H         ; SUBTRACT ASCII OFFSET
     JP Z,CONSOLERET ; DON'T ALLOW ZERO SPEED (FOR DELAY)
     PUSH AF         ; BACKUP AF
     SUB 0AH         ; SUBTRACT AH TO TEST RANGE
     JP M,CONTSPEED  ; CONTINUE IF NEGATIVE (RANGE IS 1-9)
     POP AF          ; RESTORE AF
     JP CONSOLERET   ; FINISHED -- RETURN

CONTSPEED:           ; (((CALCULATE SPEED REFERENCE)))
     POP AF          ; RESTORE AF
     PUSH BC         ; BACKUP BC
     LD B,04H        ; LOOP TO EXECUTE 4X

SPEEDLOOP:           ; (((SET SPEED REFERENCE)))
     ADD A,A         ; ADD A TO ITSELF
     DJNZ SPEEDLOOP  ; ADD A MULTIPLE TIMES
     POP BC          ; RESTORE BC
     LD HL,SPEEDVAL  ; LOAD HL WITH MEMORY WRITE LOCATION
     LD (HL),A       ; LOAD CORRECTED VALUE TO MEMORY
     CALL PRINTCHAR  ; PRINT CHARACTER TO DISPLAY

CONSOLERET:          ; (((RETURN FROM CONSOLE INPUT ROUTINE)))
     RET             ; RETURN FROM SUBROUTINE

PRINTCHAR:           ; ((( ECHO VALID VALUES TO CONSOLE)))
     LD C,02H        ; FUNCTION CODE TO DISPLAY CHARACTER
     LD HL,CHARRCV   ; LOAD HL WITH MEMORY WRITE LOCATION
     LD E,(HL)       ; LOAD E WITH RECEIVED CHARACTER
     CALL 5          ; BDOS CALL
     RET             ; RETURN FROM SUBROUTINE

EXIT:                ; ((( EXIT TO CPM)))
     RST 0           ; EXIT TO CP/M

;---------------------------------------------
;+-------------- DATA BYTES -----------------+
;---------------------------------------------

RANDSD:     DB  0AH  ; SEED FOR RANDOM VALUE
SPEEDVAL:   DB  0AH  ; SPEED VALUE TO USE
CHARRCV:    DB  00H  ; CHARACTER RECEIVED FROM CONSOLE

     END             ; END OF ASSEMBLY CODE
