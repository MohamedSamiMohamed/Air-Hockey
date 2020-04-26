                                      ;drawing two bars on the right and left side of screen
;INCLUDE firstTaskMacro.inc ;this macro draw a bar with width=10 column , height =66 row with specific color
DrawMastra MACRO column,row,color
         LOCAL return,DRAW
         MOV CX,column ;moving the start column in CX
         MOV DX,row    ;moving the start row in DX
         MOV AL,color  ;moving color of the bar in AL
         MOV AH,0CH
         push row      ;keeping the original value of the row in stack to return back to the main proc with it 
         add row,30   ;here it means to draw from the value of row to the value of row +60 ; it means to draw 60 row in specific place in the screen

return:  INT 10H
         INC CX        ; we increment CX to draw pixel in the first row in all columns from cloumn to column+10 so here the number of column drawn is 10
         CMP CX,column+10
         JNZ return
         JZ  DRAW      ;if the current row is filled with pixels in all its columns so go to increme nt the row and start again in the new row

DRAW:    MOV CX,column ;moving the initial value of columns
         INC DX        ;go to the next row
         CMP DX,row    ;comparing with the updated value of row"row + 60"
         JNZ return
         pop row       ;here we return back the original value of row 
ENDM DrawMastra    
 
;---------------------------------------------------------------------------------------------------------- 
         
Goal MACRO                
    local goal2,goal1,returns,DisplayScore,ToEscape1,Next,next2,dummy39,dummy40
 pusha 
 pushf
 push ax   
 push dx
    
            mov ah,1                ;Check if any player press F4 to exit the game
            int 16H           
            cmp ah,3EH   
            jz  DisplayScore
            jmp next
DisplayScore:                       ;End the game and Displays the scores
            
            call GameOver
            mov Score1,0
            mov Score2,0 
            ;cmp level ,2 
            ;je start1         
            jmp Scene2            

next:    
    jnz next2    ;Clear the Buffer
    MOV AH,0
    int 16h
next2:           ;Check if the ball in any goal
    cmp cx,315 
    jz goal1  
    cmp cx,316  
    jz goal1
    Cmp cx,5
    jz goal2 
    cmp cx,6
    jz goal2
    jmp returns
      
        goal1:         ;Goal For player one 
        inc Score1     ;Increment the score
        mov ah,2
        mov dh,13h
        mov dl,Score1X
        int 10h
        mov dl,Score1
        add dl,'0'
        mov ah,2
        int 21h  
        pop dx    
        pop ax
        cmp Score1,5  ;Check if any score reaches 5 to end the game
        jz  dummy40  
        jmp Start2      
        
        goal2:        ;GoalFor player 2
        inc Score2  
        mov ah,2
        mov dh,13h
        mov dl,Score2X
        int 10h
        mov dl,Score2
        add dl,'0'
        mov ah,2
        int 21h         ;display the score in the screen
        pop dx
        pop ax
        cmp Score2,5
        jz dummy40  
        jmp Start1   
        
dummy40:jmp DisplayScore

returns:
pop dx
pop ax 
popf
popa  

ENDM Goal          



;--------------------------------------------------------------------------------------------------------
Delay MACRO        ;Make delay to control the ball velocity
           local decDelay,IntJmp 
    push ax
    push cx 
    push dx   
    cmp level ,2
    je decDelay
      
    MOV CX, 00H       
    MOV DX, 3910H
    MOV AH, 86H
    jmp IntJmp
decDelay:      ; abdalla added this label in 18-12-2019 
Mov cx ,00H 
Mov Dx ,2600H
Mov Ah,86H
 
IntJmp:INT 15H  ; abdalla added this label in 18-12-2019  
    pop dx
    pop cx
    pop ax
 
         ENDM Delay
   
;---------------------------------------------------------------------------------------------------------  

;Check the key pressed by the user to move the mastra

KEYCHECK MACRO scan
    local displayscore,mmdouh,recieve,send,again,UP1,DUMMY16,DUMMY15,DUMMY2,DUMMY1,check,startS,Down1,black2,start2,UP2,black3,start3,DOWN2,start3,start4,black4,exit,dummy35,dummy36 
    push cx
    push dx 
    pushf
    pusha  

recieve:   
jnz send
mov dx , 3FDH		; Line Status Register
in al , dx 
test al , 1
jz dummy15 
mov dx , 03F8H
in al , dx 

cmp al,11h
jz  DUMMY35
cmp al,1fh
jz  DUMMY36 
CMP al,18h
jz  dummy1
CMP al,26h
JZ  dummy2 
cmp al,12h
jz displayscore
cmp al , 14h 
jnz send
call minichatting 


send:



AGAIN:
mov dx,3FDH 		; Line Status Register
In al , dx 	;Read Line Status
test al , 00100000b
                    ;Not empty
mov dx , 3F8H		; Transmit data register
        ; put the data into al 
mov al,scan        
out dx , al   
  delay
cmp scan,11h
jz  DUMMY35
cmp scan,1fh
jz  DUMMY36 
CMP scan,18h
jz  dummy1
CMP scan,26h
JZ  dummy2 
cmp scan,12h
jz displayscore 
cmp Scan , 14h  
jnz dummy15
call minichatting 
jmp DUMMY15 


            
DUMMY1:JMP UP2
DUMMY2:JMP DOWN2
dummy35:jmp Up1
dummy36:jmp down1
DisplayScore:                       ;End the game and Displays the scores
popa
popf
pop dx
pop cx
            call GameOver
            mov Score1,0
            mov Score2,0          
            jmp Scene2 
            

UP1:       CMP row1,0    ;check the upper of the bar in the top of the screen or not
           JZ  DUMMY15   ;if yes go to wait input from user other than going up
           JNZ startS
         

DUMMY15:JMP exit

startS:  DrawMastra 0,row1,0    ;drawing the blue bar again with black color
         sub row1,2             ;the button entered is 'w' so i will decrement the start row of the blue bar by 2
         sub MiddleMastra1,2    ;change th value of middlemastra1            
         DrawMastra 0,row1,1    ;drawing the bar again with different start row value
         JMP Dummy15         
;-----------------------------;
Down1:   CMP row1,116           ;check if the bottom of the bar reached the lower bound of the screen
         JnZ  start2
         jmp dummy15            ;if yes go to wait input from user other than going down

start2: DrawMastra 0,row1,0     ;drawing the blue bar with black color         
         add row1,2             ; the button entered is 's' so i will increment the start row of the blue bar by2  
         add MiddleMastra1,2    ;change th value of middlemastra11
         DrawMastra 0,row1,1    ;drawing the blue bar again with different start row value
         JMP Dummy16 
;-----------------------------;             
UP2:     CMP row2,0             ;check the upper of the bar in the top of the screen or not
         JZ  DUMMY16            ;if yes go to wait input from user other than going up
         jnz start3
         
DUMMY16: JMP exit

start3:  DrawMastra 310,row2,0    ;drawing the yellow again with black color          
         sub row2,2               ;the button entered is up so i will decrement the start row of the yellow bar by 2    
         sub middlemastra2,2      ;change th value of middlemastra2           
         DrawMastra 310,row2,0Eh  ;drawing the yellow bar again with different start row value
         jmp exit
;-----------------------------;                   
DOWN2:   CMP row2,116              ;check if the bottom of the bar reached the lower bound of the screen
         JZ exit
start4:  DrawMastra 310,row2,0     ;drawing the yellow again with black color   
         add row2,2                ; the button entered is down so i will increment the start row of the yellow bar by 2     
         add middlemastra2,2       ;change th value of middlemastra2
         DrawMastra 310,row2,0Eh   ;drawing the yellow bar again with different start row value 

exit:
popa
popf
pop dx
pop cx    


ENDM KEYCHECK                          

;----------------------------------------------------------------------------------------------------

            .model small
            .386                 ;To Use popa in Drawball Proc.
            .stack 64 
            .data

UName        db  26        ;MAX NUMBER OF CHARACTERS ALLOWED (25).
             db  ?         ;NUMBER OF CHARACTERS ENTERED BY USER.
             db  26 dup(0) ;CHARACTERS ENTERED BY USER.
StartSTR     db  "Enter your Name:$"
ContinueSTR  db  "Press ENTER to Continue$"
ChatingSTR   db  "*To start chatting press F1$"
StartGameSTR db  "*To start Ping Pong game press F2$"
ExitSTR      db  "*To end the program press ESC$"
DashLine     db  "--------------------------------------------------------------------------------$"           
NameSTR      db  "'s score:$"
PlayerName   db  "Player2's score:$"         
Invite       db  "wants to play with"
DashLine2    db  "----------------------------------------$"
ExitGameStr  db  " -To Exit the game Press F4$"
Game1        db  " __            __$"
Game2        db  "/ _  ^   /\/\ |__$"
Game3        db  "\__>/-\ /    \|__$"
Over1        db  "         __   _$"
Over2        db  "/\ \  / |__  |_>  $"
Over3        db  "\/  \/  |__  | \ $"
Celbration1  db  "-_-_-_-_-_-_-_-_-_$"
Celbration2  db  "_-_-_-_-_-_-_-_-_-$"
WonWord      db  " is the winner !!$" 
dash         db "|$"
row1         DW  50         ;first row in first mastra
row2         DW  50         ;second row in second mastra
X            dw  100        ;Start x position of the ball in the first serve   
Y            dw  50         ;Start y position of the ball in the second serve
X2           dw  220        ;Start x position of the ball in the first serve
Y2           dw  50         ;Start y position of the ball in the second serve
Score1       db  0          ;Player1 Score
Score2       db  0          ;Player2 score 
MiddleMastra1 dw 65         ;The position of the mid of the first mastra
MiddleMastra2 dw 65         ;The position of the mid of the second mastra
Score1X       db ?          ;X component of the location to display score1 in it
Score2X       db ?          ;X component of the location to display score2 in it
i            dw ?           ;Used in the eqation of the ball
j            dw ?           ;Used in the eqation of the ball
ballcolor    db ?           ;Determine the ball color
var1         dw ?           ;Used in draw the ball
var2         dw ?           ;Used in draw the ball
temp         dw ?           ;Used in draw the ball                  
inCursor     DW      0000h
outCursor    DW      0D00h 
Level db 1 
prKey db ?  
Player2Name      db  26 dup('$');Player 2 name          
Check        db  00H,00H  
inCursorz     DW      1500h
outCursorz    DW      1600h  
Fixin        dw     ? 
Fixout       dw     ?
            .code
main:
            mov ax, @data
            mov ds, ax 
            mov dx,3fbh 			; Line Control Register
           
            mov al,10000000b		;Set Divisor Latch Access Bit
            out dx,al
            
            ;Set LSB byte of the Baud Rate Divisor Latch register.
            
            mov dx,3f8h			
            mov al,0ch			
            out dx,al
            
            ;Set MSB byte of the Baud Rate Divisor Latch register.
            
            mov dx,3f9h
            mov al,00h
            out dx,al
            
            ;Set port configuration
            mov dx,3fbh
            mov al,00011011b
            out dx,al     
                        
             
            ;Open Text Mode  
            mov ah,0
            mov al,03h
            int 10h 
            
            ;Draw 1st Window
            mov ah,2
            mov dx,0A12h ;move cursor
            int 10h
            ;1st string enter name
            mov ah ,09h
            mov dx, offset StartSTR
            int 21h
            ;move cursor down
            mov ah,2
            mov dx,0E11h
            int 10h 
            ;2nd string to continue
            mov ah,09h
            mov dx,offset ContinueSTR
            int 21h
            ;move cursor to middle bet them
here:            mov ah,2
            mov dx,0C22h
            int 10h            

            ;CAPTURE STRING FROM KEYBOARD.                                    
            mov ah, 0Ah             ;SERVICE TO CAPTURE STRING FROM KEYBOARD.
            mov dx, offset UName
            int 21h                 

            ;CHANGE CHR(13) BY '$'.
            mov si, offset UName + 1 ;NUMBER OF CHARACTERS ENTERED.
            mov cl, [ si ]          ;MOVE LENGTH TO CL.
            mov ch, 0               ;CLEAR CH TO USE CX. 
            inc cx                  ;TO REACH CHR(13).
            add si, cx              ;NOW SI POINTS TO CHR(13).
            mov al, '$'
            mov [ si ], al 
            cmp Uname[2],"$"
            jz here        ;REPLACE CHR(13) BY '$'.        
            call sender          ;send names to both user
            
                        
            
            
            ;2nd Sceane 
Scene2:            
            mov ah,0      ;clear  screan by close and open it 
            mov al,03h
            int 10h
            int 10H 
            
            ;Print the 3 strings
            mov ah,2
            mov dx,0A12H
            int 10h
            
            mov ah,09H
            mov dx, offset ChatingSTR
            int 21h
            
            mov ah,2
            mov dx,0C12h
            int 10h
            
            mov ah,09H
            mov dx,offset StartGameSTR
            int 21h
            
            Mov ah,2
            mov dx,0E12H
            int 10H
            
            Mov ah,09H
            mov dx,offset ExitSTR
            int 21H

            Mov ah,2
            mov dx,1600H
            int 10H
            
            Mov ah,09H
            mov dx,offset DashLine
            int 21H
            
            

WaitForInput:                    ;Take input from the user to go to Chatting, playing or Exit
            mov ah,0
            int 16h
            cmp ah,3Bh
            jz  StartChat
            cmp ah,3Ch
            jz  StartGame
            cmp ah,01h
            jz  ToEscape
            jmp WaitForInput
            
StartChat:  
            call Chatting        ; Go to Chatting Proc. 


StartGame:                       ;Go to Playing Proc.
            
            call PlayGame
            
                       
ToEscape :  jmp Escape           ;Exit the program

Escape:                 
            mov ah, 4ch
            int 21h
            HLT  
            
;----------------------------------------------------------------------------------------------------            
            
GameOver  Proc                   ;Display The Scores Window after the match
            mov ah,0
            mov al,13H
            int 10H
            int 10H
;Write a big Game Over Word            
            mov ah,2
            mov dx,060AH
            int 10H
            
            Mov ah,9
            mov dx,offset Game1
            int 21H
            
            mov ah,2
            mov dx,070AH
            int 10H
            
            Mov ah,9
            mov dx,offset Game2
            int 21H
            
            mov ah,2
            mov dx,080AH
            int 10H
            
            Mov ah,9
            mov dx,offset Game3
            int 21H
            
            mov ah,2
            mov dx,0C0AH
            int 10H
            
            Mov ah,9
            mov dx,offset Over1
            int 21H
            
            mov ah,2
            mov dx,0D0AH
            int 10H
            
            Mov ah,9
            mov dx,offset Over2
            int 21H
            
            mov ah,2
            mov dx,0E0AH
            int 10H
            
            Mov ah,9
            mov dx,offset Over3
            int 21H
            
            Mov ah,2
            mov dx,120AH
            int 10H  
;Compare Score1 And Score2 to know the winner            
            mov ah,Score1
            cmp ah,Score2            
            jl  Player2Won
            Mov ah,9
            mov dx,offset Uname+2
            int 21H 
            jmp win  
            
            
Player2Won: 
            Mov ah,9
            mov dx,offset Player2Name
            int 21H
            
win:                                    
            mov dx,offset WonWord       ;print the winner string
            int 21H
            
            mov ah,2
            mov dx,1420H
            int 10H
;print players name            
            mov ah,9
            mov dx,offset Player2Name
            int 21H
            
            mov ah,2
            mov dx,1401H
            int 10H
            
            mov ah,9
            mov dx,offset Uname+2
            int 21H
            
            mov bx,5
            
Celebrate:                    ;print the Scores of the two players and draw a dancing line XD
            mov ah,2
            mov dx,140Ah
            int 10H
            
            mov ah,9
            mov dx,offset Celbration1
            int 21H
            
            MOV CX, 08H       ;wait 0.5 second
            MOV DX, 2155H
            MOV AH, 86H
            INT 15H
            
            mov ah,2
            mov dx,140Ah
            int 10H
            
            mov ah,9
            mov dx,offset Celbration2
            int 21H
            
            MOV CX, 07H       ;wait 0.5 second
            MOV DX, 2155H
            MOV AH, 86H
            INT 15H 
;Display the score            
            cmp bx,5
            jg hena1
            mov ah,2
            mov dx,1303H
            int 10H
            mov ah,9
            mov dx,offset dash
            int 21H
            mov ah,2
            mov dx,1322H
            int 10H
            mov ah,9
            mov dx,offset dash
            int 21H
            cmp bx,4
            jg hena1
            mov ah,2
            mov dx,1203H
            int 10H
            mov ah,9
            mov dx,offset dash
            int 21H
            mov ah,2
            mov dx,1222H
            int 10H
            mov ah,9
            mov dx,offset dash
            int 21H
            cmp bx,3
            jg lol
            mov ah,2
            mov dx,1103H
            int 10H
            mov ah,9
            mov dx,offset dash
            int 21H
            mov ah,2
            mov dx,1122H
            int 10H
            mov ah,9
            mov dx,offset dash
            int 21H 
            cmp bx,2
hena1:      jg lol
            mov ah,2
            mov dx,1003H
            int 10H
            mov dl,Score1
            mov dh,0
            add dl,'0'
            int 21H
            mov dx,1022H
            int 10H
            mov dl,Score2
            add dl,'0'
            int 21H           
lol:            
            dec bx
            cmp bx,0
            jnz jumper 
            cmp level,1 
            je Level2
            dec level  
            ret
jumper:     jmp Celebrate
            ret         
 Level2:
 inc level
 ret             
            
   GameOver         EndP

;--------------------------------------------------------------------------------------------------     
   
DrawBall proc            ;Draw the Ball 
    pusha 
    mov i,cx
    mov j,dx
    
mov ax , i 
sub ax ,4 
mov cx ,ax      ; this is the vetex of the square that contain the circle
mov ax , j 
sub ax ,4  
mov dx ,ax        ; (156,96) is the upper most left vetex of the square 
mov bx ,i  ; the mid of the x axis  
mov di, j   ; the mid of the y axis  
mov al, 5     ; 
mov ah, 0ch   ; those line of the interrupt   

;; this code start from the upper most left vertex of the square and applies 
; the equation of the circle on each  pixel if this pixel is in the circle or 
;; inside it it will be drawn and if it is outside it it won't . 
; this code will check all the pixels in each line and it will stop when
; it reach the most right pixel then it will begin from the most left 
; piexel in the new line and it will stop when it reaches the lower most 
; right pixel in the square 
loop1: 

    ; the pixel will be stored in dx and cx  for drawing it 
    cmp dx ,di ; it compare betwwen the dl and bh .
    jB dl_less ; if the dl is less than the bh so the next label will be excuted
    
    mov ax , dx  ; the same steps in dl_less except exchageing the vlaues of 
    sub dx , di 
    mov di,ax 
    mov ax ,dx
    mov dx,di
     
    mov di ,j  
    push dx
    mul ax
    pop dx 
    mov var1,ax  
    ; the pervious steps will be excuted one time in each line of pixels
    ; this is constant while we looping in the x axis 
    loop2:    
    cmp cx,bx     
    ; then the next code is the same as the prev one 
    jb cl_less    
    ; it calculate the the (x-alpha)^2 
    mov ax ,cx 
    sub cx ,bx 
    mov bx,ax
    mov ax,cx 
    mov cx,bx 
    mov bx,j 
    push dx 
    mul ax  
    pop dx 
    mov var2,ax
    claculate:   
    ;this label calculate the (x-alpha)^2-(y-b)^2 
    ;and put the value in ax  
    mov bx,var1
    mov ax ,var2  
    add ax,bx
    mov di,j
    mov bx ,i  
    cmp ax ,16    
    ;if the value is less than or equal a^2 this means
    ;that this pixel is in the circle or on it so it should be drawn 
    jBe Draw  
    after_draw:inc cx ; mov to the next pixel
    push ax 
    mov ax ,i
    add ax ,4 
    mov temp , ax 
    pop ax   
    cmp cx,temp   
    ;check if the next pixel in the square or not 
    jB loop2   
    ;if it is in the square then do the pevious code on it 
    ;if it is outside the sqaure then take the next line of pixels 
    ;starting from the most left pixel 
    inc dx          
    push ax 
    mov ax ,j
    add ax ,4 
    mov temp , ax      
    mov ax , i 
    sub ax ,4 
    mov cx ,ax 
    pop ax 
    ;increament the dl to take the next line of pixels 
    cmp dx,temp   
    ;if the dl greater than the lower most right pixel
    ;so the system will stop the circle is drawn successfully . 
    jb loop1     
    popa
    ret
    
;-----------------------------------------------------------------------  
; this label executed if the dl is less than bh
dl_less:
push ax  
mov ax , dx
; this line stores the value of dl in al 
xchg dx ,di 
; exchanging  the vlaues to avoid the negative numbers 
; remmember that dl is less than bh so this label excuted to get the 
; vlaue of (dl-bh)^2 so the values should be exchanged to void the negative 
; numbers 
sub dx , di
; then subtracting dl and bh   
mov di,ax 
; then mov the value of al(the value of old dl )
mov ax ,dx
; then mob the vlaue of the subtraction to al to be multiblied by 
; its self to be sqaured 
mov dx,di 
; the give the dl its old value 
mov di ,j 
; give the bh its old vlaue (it is constant vlaue must be in bh) 
push dx 
mul ax  
pop dx 
; then square the value of al  
mov var1,ax 
; then but the vlaue in var1 and it is the (y-B)^2 in the circle 
;equation 
pop ax  
jmp loop2 
 
;----------------------------------------------------------------------
; the same as the dl_less but it it check the cl 
cl_less:
push ax 
mov ax ,cx        
xchg bx,cx 
sub cx ,bx 
mov bx,ax
mov ax,cx 
mov cx,bx 
mov bx,i  
push dx 
mul ax  
pop dx 
mov var2,ax
pop ax   
jmp claculate   

;----------------------------------------------------------------------
Draw:
push ax 
mov al,ballcolor 
mov ah,0ch 
int 10h 
pop ax 
jmp after_draw 

popa
ret

        
DrawBall endp                                                                            

;----------------------------------------------------------------------------------------

PlayGame     PROC            ;Handle All The Angles the ball can move with (45,-45,30,-30,0) And All Collisions With the walls and Mastra

;Initialize playing Page,Status bar and chatting space
                      
            mov ah,0
            mov al,13H
            int 10H
            int 10H
            
            mov ah,2
            mov dx,1200H
            int 10h
            
            mov ah,9
            mov dx,offset DashLine2
            int 21H
            
            mov ah,2
            mov dx,1300H
            int 10h
            
            mov ah,9
            mov dx,offset Uname+2       ;player 1 name
            int 21h
            mov dx,offset NameSTR
            int 21h    
            
            mov ah,3
            mov bh,0
            int 10h
            mov Score1X,dl              ;Store the cursor position to display score in it later
            
            mov ah,2
            mov dl,'0'                  ;in the begining score=0
            int 21h
            
            mov ah,2
            mov dx,1317H
            int 10H
            
            mov ah,9
            mov dx,offset Player2Name   ;Player 2 name
            int 21H
            mov dx,offset NameSTR
            int 21H 
            
            mov ah,3
            mov bh,0
            int 10h     
            mov Score2X,dl             ;Store the cursor position to display score in it later
            
            mov ah,2
            mov dl,'0'                 ;in the begining score=0
            int 21h                    
            
            mov ah,2
            mov dx,1400H
            int 10H
                        
            mov ah,9
            mov dx,offset Dashline2
            int 21H
            
            mov ah,2
            mov dx,1700H
            int 10H
            
            mov ah,9
            mov dx,offset Dashline2
            int 21H
            
            mov ah,2
            mov dx,1800H
            int 10H
            
            mov ah,9
            mov dx,offset ExitGameStr
            int 21H                      
            
DrawMastra 0,row1,1        ;first call of macro to draw the first bar starting from column 0 and row 70 and the color is blue
DrawMastra 310,row2,0Eh    ;second call of macro to draw the second bar starting from column 310 and row 70 and the color is yellow     
         
GetSpace:  
    mov dx , 3FDH		; Line Status Register
    in al , dx 
    test al , 1 
    jz tanii
    mov dx , 03F8H
    in al , dx
    cmp al,32
    jz start1                 ;Waiting for space key to start the game
tanii:
    mov ah,1
    int 16h  
    jz GetSpace
    mov ah,0
    int 16h
    cmp al,32
    jnz GetSpace        
    jmp  XY

DUMMY4: JMP drawN45

Ang45:                         ;initialize ball position if this is the start angle
    mov si,offset x
    mov di,offset y   

    mov cx,[SI] ;Column
    mov dx,[Di] ;Row 
    mov ballcolor,2            ;draw a green ball
    call DrawBall   
     
draw45:                        ;Make the ball move with angle 45 with positive x
    Delay    
    mov ballcolor,0            ;draw a black ball on the old one
    call drawball   
    inc cx
    inc dx   
    cmp dx,142                 ;Hit the bottom 
    jz DUMMY4           
    Goal                       ;Macro Checks if there is a goal
    mov ballcolor,2
    call drawball     
    MOV AH,1                   ;Take input from user without pausing
    INT 16h
    KEYCHECK AH                ;Macro th check the key pressed
    jz cont2 
    MOV AH,0                   ;Clear Buffer if not empty
    int 16h
Cont2: 
    cmp cx,305                 ;to check if the ball hits the right mastra (Upper part,lower part, midlle)
    jne dummy20
    mov ax ,MiddleMastra2
    add ax,5
    mov bx,middlemastra2 
    sub bx,5 
    cmp dx,bx
    jl up45
    cmp dx,ax
    jg down45
    jle Mid45
    jmp draw45      
up45:                         ;the ball hits the upper part from the mastra
   cmp dx,row2        
   jl dummy20
   jmp mid30
down45:                       ;the ball hits the lower part from the mastra
   mov ax ,row2
   add ax,30
   cmp dx,ax
   jg dummy20
   jmp mid30   
    
dummy20 : jmp draw45
dummy26 : jmp midN45 
 
AngMid45:                     ;initialize ball position if this is the start angle
    mov si,offset x2
    mov di,offset y2   
    mov cx,[SI] ;Column
    mov dx,[Di] ;Row  
    mov ballcolor,2
    call drawball  

Mid45:                       ;Make The Ball Move with Angle 45 with Negative x
    Delay 
    mov ballcolor,0
    call drawball      
    dec cx 
    inc dx  
    cmp dx,142
    jz dummy26   
    Goal
    mov ballcolor,2
    call drawball    
    MOV AH,1   
    INT 16h 
    KEYCHECK AH 
    jz cont22 
    MOV AH,0
    int 16h
Cont22: 
    cmp cx,15               ;Check if the ball hits the left Mastra (Upper part,lower part, midlle)
    jne dummy21
    mov ax ,MiddleMastra1
    add ax,5
    mov bx,middlemastra1 
    sub bx,5 
    cmp dx,bx
    jl upm45
    cmp dx,ax
    jg downm45
    jle dummy6
    jmp dummy21  
upm45:
   cmp dx,row1        
   jl dummy21
   jmp Ang30
downm45:
   mov ax ,row1
   add ax,30
   cmp dx,ax
   jg dummy21
   jmp Ang30              
   
dummy21: jmp mid45           
DUMMY6 : JMP draw45  
dummy41: jmp angmid45
dummy42: jmp angmidn45
dummy43: jmp angmid0
 
Start2:
 
                             ;Player 2 Starts 
    mov ah, 2ch           ;Get time in Ch,Cl,BH And Make the ball start moving with random angle with negative X
    int 21h
    mov al,dh
    mov ah,0  
    mov bl,3
    div bl  
;    cmp ah,0
 ;   jz dummy41
  ;  cmp ah,1
  ;  jz DUMMY42
   ; cmp ah,2
   ; jz dummy43  
   jmp AngMid0
    
XY:                   ;Player 1 Starts      
    mov dx,3FDH 		; Line Status Register
    In al , dx         	;Read Line Status
    test al , 00100000b
    jz start1                   ;Not empty
    mov dx , 3F8H		; Transmit data register
    mov al,32           ; put the data into al
    out dx , al 
 
       
start1:
    mov ah, 2ch           ;Get time in Ch,Cl,BH And Make the ball start moving with random angle with positive x
    int 21h
    mov al,dh
    mov ah,0  
    mov bl,3
    div bl  
;    cmp ah,0
 ;   jz dummy3
  ;  cmp ah,1
   ; jz DUMMY7
  ;  cmp ah,2
   ; jz dummy5 
   jmp Ang0

dummy3 : jmp Ang45        
dummy5 : jmp AngN45       
DUMMY7 : JMP Ang0
dummy33: jmp Ang30
     
AngN30:                   ;initialize ball position if this is the start angle
    Delay                 ;Double Delay because X heere increments by 2 every frame
    Delay
    mov ballcolor,0
    call drawball        
    add cx,2
    dec dx 
    cmp dx,5
    jz dummy33   
    Goal   
    mov ballcolor,2
    call drawball   
    MOV AH,1   
    INT 16h
    KEYCHECK AH  
    jz cont4
    MOV AH,0   
    INT 16h    
cont4: 
    cmp cx,305
    je again4  
    cmp cx,304
    jne dummy25
again4:    
    mov ax ,MiddleMastra2
    add ax,5
    mov bx,middlemastra2 
    sub bx,5 
    cmp dx,bx
    jl upn30
    cmp dx,ax 
    jg downn30
    jle MidN30
    jmp AngN30 
upn30:
    cmp dx,row2        
    jl dummy25
    jmp mid0
downn30:
    mov ax ,row2
    add ax,30
    cmp dx,ax
    jg dummy25
    jmp mid0      
      
dummy25 : jmp AngN30   
dummy28 : jmp mid30  

MidN30:  
    Delay
    Delay
    mov ballcolor,0
    call drawball       
    sub cx,2
    dec dx     
    cmp dx,5
    jz dummy28 
    Goal
    mov ballcolor,2
    call drawball    
    MOV AH,1    
    INT 16h
    KEYCHECK AH
    jz cont44
    MOV AH,0   
    INT 16h    
cont44: 
    cmp cx,15
    je again44
    cmp cx,16  
    jne dummy29
again44:    
    mov ax ,MiddleMastra1
    add ax,5
    mov bx,middlemastra1 
    sub bx,5 
    cmp dx,bx
    jl upmn30
    cmp dx,ax
    jg downmn30
    jle dummy8
    jmp dummy29
upmn30:
    cmp dx,row1        
    jl dummy29
    jmp draw0
downmn30:
    mov ax ,row1
    add ax,30
    cmp dx,ax
    jg dummy29
    jmp draw0
         
dummy29: jmp midN30        
DUMMY8 : jmp AngN30     
dummy19: jmp Mid0      
    
Ang0:
    mov si,offset x
    mov di,offset y   
    mov cx,[SI] ;Column
    mov dx,[Di] ;Row   
    mov ballcolor,2
    call drawball    
draw0: 
     Delay
     mov ballcolor,0
     call drawball       
     inc cx        
     Goal 
     mov ballcolor,2
     call drawball       
     MOV AH,1   
     INT 16h
     KEYCHECK AH                                             
     jz cont1
     MOV AH,0   
     INT 16h    
cont1:   
     cmp cx,305
     jne dummy18
     mov ax ,MiddleMastra2
     add ax,5
     mov bx,middlemastra2 
     sub bx,5 
     cmp dx,bx
     jl up0  
     cmp dx,ax
     jg down0
     jle Mid0
     jmp draw0    
up0:
     cmp dx,row2        
     jl dummy18
     jmp midn45
down0:         
     mov ax ,row2
     add ax,30
     cmp dx,ax
     jg dummy18
     jmp mid45      
     
dummy18 : jmp dummy9 
  
angmid0:
    mov si,offset x2
    mov di,offset y2   
    mov cx,[SI] ;Column
    mov dx,[Di] ;Row   
    mov ballcolor,2
    call drawball 
Mid0:  Delay
    mov ballcolor,0
    call drawball      
    dec cx     
    Goal
    mov ballcolor,2
    call drawball    
    MOV AH,1   
    INT 16h
    KEYCHECK AH
    jz cont11
    MOV AH,0  
    INT 16h    
cont11:   
    cmp cx,15
    jne dummy17
    mov ax ,MiddleMastra1
    add ax,5
    mov bx,middlemastra1 
    sub bx,5 
    cmp dx,bx
    jl upm0
    cmp dx,ax
    jg downm0
    jle dummy9
    jmp dummy17    
upm0:
   cmp dx,row1        
   jl dummy17
   jmp drawn45
downm0:
   mov ax ,row1
   add ax,30
   cmp dx,ax
   jg dummy17
   jmp draw45    

dummy17: jmp mid0   
DUMMY9: jmp draw0     
DUMMY10: jmp draw45   

AngN45:  
    mov si,offset x
    mov di,offset y   
    mov cx,[SI] ;Column
    mov dx,[Di] ;Row   
    mov ballcolor,2
    call drawball 
    
drawN45: 
    Delay    
    mov ballcolor,0
    call drawball 
    inc cx
    dec dx 
    cmp dx,5
    jz DUMMY10 
    Goal
    mov ballcolor,2
    call drawball 
    MOV AH,1   
    INT 16h       
    KEYCHECK AH 
    jz cont5
    MOV AH,0
    int 16h
Cont5: 
    cmp cx,305
    jne dummy31
    mov ax ,MiddleMastra2
    add ax,5
    mov bx,middlemastra2 
    sub bx,5 
    cmp dx,bx
    jl upn45
    cmp dx,ax 
    jg downn45
    jle MidN45
    jmp drawN45 
upn45:
   cmp dx,row2        
   jl dummy31
   jmp midN30
downN45:
   mov ax ,row2
   add ax,30
   cmp dx,ax
   jg dummy31
   jmp midN30        
  
dummy31 : jmp drawN45
dummy32 : jmp mid45

angmidn45:
    mov si,offset x2
    mov di,offset y2   
    mov cx,[SI] ;Column
    mov dx,[Di] ;Row   
    mov ballcolor,2
    call drawball            
MidN45:  
    Delay
    mov ballcolor,0
    call drawball      
    dec cx 
    dec dx  
    cmp dx,5
    jz dummy32
    Goal
    mov ballcolor,2
    call drawball   
    MOV AH,1   
    INT 16h
    KEYCHECK AH
    jz cont55
    MOV AH,0
    int 16h
Cont55: 
    cmp cx,15
    jne dummy30
    mov ax ,MiddleMastra1
    add ax,5
    mov bx,middlemastra1 
    sub bx,5 
    cmp dx,bx
    jl upmn45
    cmp dx,ax
    jg downmn45
    jle dummy11
    jmp dummy30   
upmn45:
    cmp dx,row1        
    jl dummy30
    jmp Angn30
downmn45:
    mov ax ,row1
    add ax,30
    cmp dx,ax
    jg dummy30
    jmp Angn30
        
dummy30: jmp midn45            
DUMMY11: jmp drawN45    
dummy38: jmp angn30 

Ang30:  
    Delay
    Delay
    mov ballcolor,0
    call drawball      
    add cx,2
    inc dx
    cmp dx,142
    jz dummy38      
    Goal
    mov ballcolor,2
    call drawball  
    MOV AH,1   
    INT 16h
    KEYCHECK AH 
    jz cont3
    MOV AH,0    
    INT 16h    
cont3:    
    cmp cx,305
    je again3
    cmp cx,304
    jne dummy22
again3:    
    mov ax ,MiddleMastra2
    add ax,5
    mov bx,middlemastra2 
    sub bx,5 
    cmp dx,bx
    jl up30
    cmp dx,ax
    jg down30
    jle Mid30
    jmp Ang30    
up30:
   cmp dx,row2        
   jl dummy22
   jmp mid0
down30:
   mov ax ,row2
   add ax,30
   cmp dx,ax
   jg dummy22
   jmp mid0   
     
dummy22: jmp Ang30   
dummy27: jmp midN30    

Mid30:  
    Delay
    Delay
    mov ballcolor,0
    call drawball       
    sub cx,2
    inc dx     
    Cmp dx,142
    jz dummy27
    Goal
    mov ballcolor,2
    call drawball   
    MOV AH,1   
    INT 16h 
    KEYCHECK AH
    jz cont33
    MOV AH,0   
    INT 16h    
cont33:    
    cmp cx,15
    je again33
    cmp cx,16
    jne dummy24
again33:    
    mov ax ,MiddleMastra1
    add ax,5
    mov bx,middlemastra1 
    sub bx,5 
    cmp dx,bx
    jl upm30
    cmp dx,ax
    jg downm30
    jle dummy23
    jmp dummy24
upm30:
   cmp dx,row1        
   jl dummy24
   jmp draw0
downm30:
   mov ax ,row1
   add ax,30
   cmp dx,ax
   jg dummy24
   jmp draw0
        
dummy24: jmp mid30   
DUMMY23: jmp Ang30                 


PlayGame ENDP
;-------------------------------------------------------------------------------------  


Chatting    PROC    

        MOV     AX, 3h          ;Text mode
        INT     10h

        ;; Draw a line in the middle:
        MOV     DX, 0C00h       ;To (0, 12)
        MOV     AH, 2           ;Move cursor
        MOV     BH, 0
        INT     10h

        MOV     DL, '='
        MOV     AH, 2
        MOV     CX, 80
PRINT_SEPARATOR:
        INT     21h
        LOOP    PRINT_SEPARATOR
        
        ;; Initialize the transmission protocol
        MOV     DX, 3FBh        ;Line control register
        MOV     AL, 80h         ;Set Divisor Latch Access Bit
        OUT     DX, AL

        MOV     DX, 3F8h        ;Set LSB byte of Baud Rate Divisor
        MOV     AL, 0Ch
        OUT     DX, AL

        MOV     DX, 3F9h        ;Set MSB byte
        MOV     AL, 00h
        OUT     DX, AL

        MOV     DX, 3FBh        ;Set port configuration
        MOV     AL, 1Bh         ;Access RT buffer, Disable Set Break, Even Parity, One Stop bit, 8 bits
        OUT     DX, AL

CONNECTION_ACTIVE:
        call    SendCharacter
        JC      CONNECTION_TERMINATED
        call    ReceiveCharacter
        JNC     CONNECTION_ACTIVE
        
CONNECTION_TERMINATED:  
        ;; Print new line
        mov     ah, 2
        mov     dl, 10
        int     21h
        mov     dl, 13
        int     21h

        jmp Scene2
Chatting    ENDP

;;; =================================================================================
        ;; in AL: character
PrintCharacter_Out      PROC    NEAR
        ;; Print character
        ;; Get cursor location
        ;; Move cursor to next position 
        ;; If bottom is reached, scroll 3 lines up
        ;; Store new cursor position 

        MOV     DX, outCursor
        MOV     AH, 2           ;Move cursor
        MOV     BH, 0
        INT     10h

        CMP     AL, 1           ;Enter
        JE      _ENTER
        CMP     AL, 2           ;Backspace
        JE      _BKSP

        JMP     _STD_CHAR
_ENTER:       
        MOV     byte ptr outCursor, 79
        JMP     _SKIP_CHAR

_BKSP:
        dec     DL
        cmp     DL, 0
        JAE     _SKIP_LINE
        mov     DL, 0
        JMP     _SKIP_LINE
        
_STD_CHAR:      
        MOV     AH, 9           ;Display
        MOV     BH, 0           ;Page 0
        ;; AL has the character already
        MOV     CX, 1h          ;1 time
        MOV     Bl, 09h         ;Light blue fg
        int     10h 
        
_SKIP_CHAR:     
        MOV     DX, outCursor        
        INC     DL              ;Move one character right
        CMP     DL, 80          ;Screen width
        JB      _SKIP_LINE

        MOV     DL, 0
        INC     DH              ;Move one character down
        CMP     DH, 25          ;Screen height
        JB      _SKIP_LINE

SCROLL: 
        MOV     AH, 6           ;Scroll
        MOV     AL, 4           ;4 lines
        MOV     Bl, 09h         ;Light blue fg
        MOV     CX, 0D00h       ;from (0, 13)
        MOV     DX, 184Fh       ;to (24, 79)       
        INT     10h
        
        MOV     AH, 3           ;Cursor location in DL, DH
        MOV     BH, 0
        INT     10h

        MOV     DL, 0           ;Move 3 lines upwards
        SUB     DH, 3
        
_SKIP_LINE:
        MOV     outCursor, DX   ;Store current position
        RET
PrintCharacter_Out      ENDP

;;; =================================================================================
        ;; in AL: character
PrintCharacter_In       PROC    NEAR
        ;; Print character
        ;; Get cursor location
        ;; Move cursor to next position 
        ;; If bottom is reached, scroll 3 lines up
        ;; Store new cursor position 

        MOV     DX, inCursor
        MOV     AH, 2           ;Move cursor
        MOV     BH, 0
        INT     10h
        
        CMP     AL, 1           ;Enter
        JE      _ENTER_I
        CMP     AL, 2           ;Backspace
        JE      _BKSP_I

        JMP     _STD_CHAR_I
_ENTER_I:       
        MOV     byte ptr inCursor, 79
        JMP     _SKIP_CHAR_I

_BKSP_I:
        dec     DL
        cmp     DL, 0
        JAE     _SKIP_LINE_I
        mov     DL, 0
        JMP     _SKIP_LINE_I
        

_STD_CHAR_I:    
        MOV     AH, 9           ;Display
        MOV     BH, 0           ;Page 0
        ;; AL has the character already
        MOV     CX, 1h          ;1 time
        MOV     Bl, 0Eh         ;Light yellow fg
        int     10h 
        
_SKIP_CHAR_I:   
        MOV     DX, inCursor
        INC     DL              ;Move one character right
        CMP     DL, 80          ;Screen width
        JB      _SKIP_LINE_I

        MOV     DL, 0
        INC     DH              ;Move one character down
        CMP     DH, 12          ;Half-Screen height
        JB      _SKIP_LINE_I

        MOV     AH, 6           ;Scroll
        MOV     AL, 4           ;4 lines
        MOV     BH, 0Eh         ;Light yellow fg
        MOV     CX, 0000h       ;from (0, 0)
        MOV     DX, 0B4Fh       ;to (79, 11)       
        INT     10h
        
        MOV     AH, 3           ;Cursor location in DL, DH
        MOV     BH, 0
        INT     10h

        MOV     DL, 0           ;Move 3 lines upwards
        SUB     DH, 3

_SKIP_LINE_I:
        MOV     inCursor, DX    ;Store current position
        RET
PrintCharacter_In       ENDP

;;; =================================================================================
SendCharacter        PROC    NEAR
        ;; Check that Transmitter Holding Register is Empty
        mov     dx, 03FDh       ;Line Status Register
        in      al, dx          ;Read Line Status
        test    al, 00100000b
        JZ      END_TRANSMISSION        ;Not empty

        ;; Ready to transmit
        mov     dx, 03F8h       ;Transmit data register

        ;; Read and output character if pressed
        mov     ah, 1
        int     16h
        JZ      END_TRANSMISSION

        ;; Pop character from buffer
        mov     ah, 0
        int     16h
        
        cmp     ah, 01h         ;ESC
        JE      TX_TERMINATE
        
        cmp     ah, 1Ch         ;Enter
        JE      TRANSMIT_ENTER

        cmp     ah, 0eh         ;Backspace
        JE      TRANSMIT_BKSP

        JMP     TRANSMIT_STANDARD
        
TRANSMIT_ENTER:
        mov     al, 1
        JMP     TRANSMIT_STANDARD
TRANSMIT_BKSP:  
        mov     al, 2
        JMP     TRANSMIT_STANDARD
TRANSMIT_STANDARD:      
        out     dx, al
        call    PrintCharacter_Out

END_TRANSMISSION:
        CLC
        RET

TX_TERMINATE:
        mov     al, 0
        out     dx, al
        STC
        RET
SendCharacter        ENDP
;;; =================================================================================
ReceiveCharacter     PROC    NEAR
        ;; Check that data is ready
        mov     dx, 03FDh       ;Line Status Register
        in      al, dx          ;Read Line Status
        test    al, 1
        JZ      END_RECEPTION

        ;; Ready to receive
        mov     dx, 03F8h       ;Transmit data register
        in      al, dx

        cmp     al, 0
        JZ      RX_TERMINATE
        
RECEIVE_STANDARD:       
        call    PrintCharacter_In

END_RECEPTION:
        CLC
        RET

RX_TERMINATE:
        STC
        RET
ReceiveCharacter     ENDP 
Sender proc 
        ; mov ax,@data
;         mov ds,ax
;         
         mov ah,0
         mov al,03H
         int 10H  
         
         ;; Initialize the transmission protocol
        MOV     DX, 3FBh        ;Line control register
        MOV     AL, 80h         ;Set Divisor Latch Access Bit
        OUT     DX, AL

        MOV     DX, 3F8h        ;Set LSB byte of Baud Rate Divisor
        MOV     AL, 0Ch
        OUT     DX, AL

        MOV     DX, 3F9h        ;Set MSB byte
        MOV     AL, 00h
        OUT     DX, AL

        MOV     DX, 3FBh        ;Set port configuration
        MOV     AL, 1Bh         ;Access RT buffer, Disable Set Break, Even Parity, One Stop bit, 8 bits
        OUT     DX, AL
;         
;            ;CAPTURE STRING FROM KEYBOARD.                                    
;            mov ah, 0Ah             ;SERVICE TO CAPTURE STRING FROM KEYBOARD.
;            mov dx, offset UName
;            int 21h                 
;
;            ;CHANGE CHR(13) BY '$'.
;            mov si, offset UName + 1 ;NUMBER OF CHARACTERS ENTERED.
;            mov cl, [ si ]          ;MOVE LENGTH TO CL.
;            mov ch, 0               ;CLEAR CH TO USE CX. 
;            inc cx                  ;TO REACH CHR(13).
;            add si, cx              ;NOW SI POINTS TO CHR(13).
;            mov al, '$'
;            mov [ si ], al          ;REPLACE CHR(13) BY '$'
            
       
            
            mov Bx,0002h
            mov di,0
        
again:     

           call SendCharacterX
           call ReceiveCharacterX 
           cmp  word ptr check,0101h
           jnz again 
           
            mov Bx,0002h
            mov di,0
            mov check[0],00h
            mov check[1],00H
again2:     
           call ReceiveCharacterX
           call SendCharacterX
            
           cmp  word ptr check,0101h
           jnz again2  
 
            
            display:
            ;mov ah,2
;            mov dx,0101H
;            int 10h
;
;            mov ah,9
;            mov dx, offset player2Name
;            int 21H 
;            mov ah,4ch
;            int 21H
;            
;            hlt 
            ret
            
Sender     Endp       

SendCharacterX        PROC    NEAR
        cmp check,01H
        jz  END_TRANSMISSIONX
        ;; Check that Transmitter Holding Register is Empty
        mov     dx, 03FDh       ;Line Status Register
        in      al, dx          ;Read Line Status
        test    al, 00100000b
        JZ      END_TRANSMISSIONX        ;Not empty
        ;; Ready to transmit
        mov     dx, 03F8h       ;Transmit data register

        ;; Read and output character if pressed
        mov al, Uname[bx]      
        out  dx, al 
        cmp al,'$'
        jz TX_TERMINATEX 
        inc bx
        ;call    PrintCharacter_Out

END_TRANSMISSIONX:
        CLC
        RET 
TX_TERMINATEX:
        mov check,1
        STC
        RET

SendCharacterX        ENDP
;;; =================================================================================
ReceiveCharacterX     PROC    NEAR 
        cmp check[1],1
        jz  END_RECEPTION
        ;; Check that data is ready
        mov     dx, 03FDh       ;Line Status Register
        in      al, dx          ;Read Line Status
        test    al, 1
        JZ      END_RECEPTIONX

        ;; Ready to receive
        mov     dx, 03F8h       ;Transmit data register
        in      al, dx
         
        mov player2name[di],al  
        cmp al,'$'
        jz RX_TERMINATEX    
        inc di  

END_RECEPTIONX:
        RET    
RX_TERMINATEX:
        mov check[1],1
        RET        

ReceiveCharacterX     ENDP 



miniChatting    PROC    

pusha
        ;; Draw a line in the middle:
        mov ah,2
        mov dx,1500H
        int 10H  
        mov dx , offset UName[2] 
        mov ah,9 
        int 21h 
        mov ah, 3 
        mov bh ,0 
        int 10h 
        mov incursorz,Dx
        mov fixin ,dx   
         mov ah,2
        mov dx,1600H
        int 10H 
                
        mov dx , offset player2name
        mov ah,9 
        int 21h 
        mov ah, 3 
        mov bh ,0 
        int 10h 
        mov outcursorz,Dx 
        mov fixout,dx  
      
      

        ;; Initialize the transmission protocol
        MOV     DX, 3FBh        ;Line control register
        MOV     AL, 80h         ;Set Divisor Latch Access Bit
        OUT     DX, AL

        MOV     DX, 3F8h        ;Set LSB byte of Baud Rate Divisor
        MOV     AL, 0Ch
        OUT     DX, AL

        MOV     DX, 3F9h        ;Set MSB byte
        MOV     AL, 00h
        OUT     DX, AL

        MOV     DX, 3FBh        ;Set port configuration
        MOV     AL, 1Bh         ;Access RT buffer, Disable Set Break, Even Parity, One Stop bit, 8 bits
        OUT     DX, AL

CONNECTION_ACTIVEz:
        call    SendCharacterz
        JC      CONNECTION_TERMINATEDz
        call    ReceiveCharacterz
        JNC     CONNECTION_ACTIVEz
        
CONNECTION_TERMINATEDz:  
        ;; Print new line
        mov     ah, 2
        mov     dl, 10
        int     21h
        mov     dl, 13
        int     21h

   popa
miniChatting    ENDP    



SendCharacterz        PROC    NEAR
        ;; Check that Transmitter Holding Register is Empty
        mov     dx, 03FDh       ;Line Status Register
        in      al, dx          ;Read Line Status
        test    al, 00100000b
        JZ      END_TRANSMISSIONz        ;Not empty

        ;; Ready to transmit
        mov     dx, 03F8h       ;Transmit data register

        ;; Read and output character if pressed
        mov     ah, 1
        int     16h
        JZ      END_TRANSMISSIONz

        ;; Pop character from buffer
        mov     ah, 0
        int     16h
        
        cmp     ah, 3bh         ;ESC
        JE      TX_TERMINATEz
        
        ;cmp     ah, 1Ch         ;Enter
        ;JE      TRANSMIT_ENTER

        cmp     ah, 0eh         ;Backspace
        JE      TRANSMIT_BKSPz

        JMP     TRANSMIT_STANDARDz
        
TRANSMIT_ENTERz:
        mov     al, 1
        JMP     TRANSMIT_STANDARDz
TRANSMIT_BKSPz:  
        mov     al, 2
        JMP     TRANSMIT_STANDARDz
TRANSMIT_STANDARDz:      
        out     dx, al
        call    PrintCharacter_Outz

END_TRANSMISSIONz:
        CLC
        RET

TX_TERMINATEz:
        mov     al, 0
        out     dx, al
        STC
        RET
SendCharacterz        ENDP
;;; =================================================================================
ReceiveCharacterz     PROC    NEAR
        ;; Check that data is ready
        mov     dx, 03FDh       ;Line Status Register
        in      al, dx          ;Read Line Status
        test    al, 1
        JZ      END_RECEPTIONz

        ;; Ready to receive
        mov     dx, 03F8h       ;Transmit data register
        in      al, dx

        cmp     al, 0
        JZ      RX_TERMINATEz
        
RECEIVE_STANDARDz:       
        call    PrintCharacter_Inz

END_RECEPTIONz:
        CLC
        RET

RX_TERMINATEz:
        STC
        RET 
        
        
        
        
        
ReceiveCharacterz     ENDP 
        ;; in AL: character
PrintCharacter_Outz      PROC    NEAR
        ;; Print character
        ;; Get cursor location
        ;; Move cursor to next position 
        ;; If bottom is reached, scroll 3 lines up
        ;; Store new cursor position 

        MOV     DX, inCursorz
        MOV     AH, 2           ;Move cursor
        MOV     BH, 0
        INT     10h

       ; CMP     AL, 1           ;Enter
;        JE      _ENTER
        CMP     AL, 2           ;Backspace
        JE      _BKSPz

        JMP     _STD_CHARz
;_ENTER:       
;        MOV     byte ptr outCursor, 79
;        JMP     _SKIP_CHAR

_BKSPz:
        dec     DL
        cmp     DL, 0
        JAE     _SKIP_LINEz
        mov     DL, 0
        JMP     _SKIP_LINEz
        
_STD_CHARz:      
        MOV     AH, 9           ;Display
        MOV     BH, 0           ;Page 0
        ;; AL has the character already
        MOV     CX, 1h          ;1 time
        MOV     Bl, 09h         ;Light blue fg
        int     10h 
        
_SKIP_CHARz:     
        MOV     DX,inCursorz        
        INC     DL              ;Move one character right
        CMP     DL, 39          ;Screen width
        JB      _SKIP_LINEz

        MOV     DL, 0
        INC     DH              ;Move one character down
        CMP     DH, 16H          ;Screen height
        JB      _SKIP_LINEz

SCROLLz: 
        MOV     AH, 6           ;Scroll
        MOV     AL, 1           ;4 lines
        MOV     Bl, 09h         ;Light blue fg
        MOV     CX, fixin       ;from (0, 13)
        mov     dh,15H
        mov     dl,40       
        INT     10h
        
        MOV     AH, 3           ;Cursor location in DL, DH
        MOV     BH, 0
        INT     10h 
        
        

        mov dx,fixin
        
_SKIP_LINEz:
        MOV     inCursorz, DX   ;Store current position
        RET
PrintCharacter_Outz      ENDP

;;; =================================================================================
        ;; in AL: character
PrintCharacter_Inz       PROC    NEAR
        ;; Print character
        ;; Get cursor location
        ;; Move cursor to next position 
        ;; If bottom is reached, scroll 3 lines up
        ;; Store new cursor position 

        MOV     DX, outCursorz
        MOV     AH, 2           ;Move cursor
        MOV     BH, 0
        INT     10h
        
 ;       CMP     AL, 1           ;Enter
;        JE      _ENTER_I
        CMP     AL, 2           ;Backspace
        JE      _BKSP_Iz

        JMP     _STD_CHAR_Iz
;_ENTER_I:       
;        MOV     byte ptr inCursor, 79
;        JMP     _SKIP_CHAR_I

_BKSP_Iz:
        dec     DL
        cmp     DL, 0
        JAE     _SKIP_LINE_Iz
        mov     DL, 0
        JMP     _SKIP_LINE_Iz
        

_STD_CHAR_Iz:    
        MOV     AH, 9           ;Display
        MOV     BH, 0           ;Page 0
        ;; AL has the character already
        MOV     CX, 1h          ;1 time
        MOV     Bl, 0Eh         ;Light yellow fg
        int     10h 
        
_SKIP_CHAR_Iz:   
        MOV     DX, outCursorz
        INC     DL              ;Move one character right
        CMP     DL, 39          ;Screen width
        JB      _SKIP_LINE_Iz

        MOV     DL, 0
        INC     DH              ;Move one character down
        CMP     DH, 15H          ;Half-Screen height
        JB      _SKIP_LINE_Iz

        MOV     AH, 6           ;Scroll
        MOV     AL, 1           ;4 lines
        MOV     BH, 0Eh         ;Light yellow fg
        MOV     CX, fixout       ;from (0, 0)
        MOV     Dh, 16h       ;to (79, 11)
        mov     dl,39       
        INT     10h
        
        MOV     AH, 3           ;Cursor location in DL, DH
        MOV     BH, 0
        INT     10h 
        
        

        mov dx,fixout

_SKIP_LINE_Iz:
        MOV     outCursorz, DX    ;Store current position
        RET
PrintCharacter_Inz       ENDP
End main 















            end main