;Hamza Ahmad 
;22i-1003 
;************************************************ C O A L  L A B  P R O J E C T *************************************************************************************

INCLUDE Irvine32.inc
include macros.inc 

.data

ground1 db "|",0
midw1 db "|",0 
midw2 db "-",0
food db "*"
delayTime dd 1
ghost db "&"

title1 db ".______      ___       ______ .___  ___.      ___      .__   __.",0 
title2 db "|   _  \    /   \     /      ||   \/   |     /   \     |  \ |  |",0 
title3 db "|  |_)  |  /  ^  \   |  ,----'|  \  /  |    /  ^  \    |   \|  |",0 
title4 db "|   ___/  /  /_\  \  |  |     |  |\/|  |   /  /_\  \   |  . `  |" ,0
title5 db "|  |     /  _____  \ |  `----.|  |  |  |  /  _____  \  |  |\   |" ,0
title6 db "| _|    /__/     \__\ \______||__|  |__| /__/     \__\ |__| \__|" ,0 

xArray db  500 dup(?)
yArray db  500 dup(?) 
xindices dd 0 
yindices dd 0  
xth db 0
xFlag db 0 
yFlag db 0 
collisionFlag db 0 

foodxArray db 500 dup (?) 
foodyArray db 500 dup (?) 
foodxindices dd 0 
foodyindices dd 0

ghostx db 100
ghosty db 7  

ghost2x db 3
ghost2y db 24

patrol db 0 
patrol2 db 0

sentinalVal db 5 
sentinalVal2 db 10
atLevel db 1
optionNumber db 1


temp db ? 
tempCounter dd ?

strScore db "Your score is: ",0
score db 0

xPos db 3 ;player spawn
yPos db 3
xCoinPos db ?
yCoinPos db ?

inputChar db ?
pname db ? 

.code
main PROC  
cmp atLevel,2 
je startGame
   BackToMenu: 
   call Menu
    call levels
    mov xPos,3 
    mov yPos,3
    startGame:
    call DrawPlayer 
    ;call CreateRandomCoin
    ;call Randomize

     mov score,0

    gameLoop:  
    mov eax,0 
    cmp atLevel,2 
    je ghosttime 
    jmp gogame
    ghosttime:    
    call ghostschmovement  
    mov eax,black(black*16) 
    call settextcolor
    call ghostschmovement2

      
    gogame:
        mov eax,white (black * 16)
        call SetTextColor
        
        mov al,score
        cmp al,sentinalVal2 
        je endgame

        cmp al,sentinalVal
        je changeLevel 
        jmp samelevel
        changeLevel: 
        call levels 
         mov xPos,3 
        mov yPos,3 
        mov dl,0 
        mov dh,0 
        call gotoxy 
        mov eax,black(black*16) 
        call settextcolor 
        mWrite<"                           ",0>
        call DrawPlayer  

       samelevel: 

       
        ; draw score: 

        mov dl,0
        mov dh,0
        call Gotoxy
        mov edx,OFFSET strScore
        call WriteString  
        mov eax, lightGreen 
        call settextcolor 
        mov al,score
        call WriteInt
        comment %
        ; gravity logic:
        gravity:
        cmp yPos,27
        jg onGround
        ; make player fall:
        call UpdatePlayer
        inc yPos
        call DrawPlayer
        mov eax,0
        call Delay
        jmp gravity  
        onGround:
        %
        

        ; get user key input: 
        ;mov eax,50 
        ;call delay
        call Readkey
        jz gameLoop
        mov inputChar,al

        ; exit game if user types 'x':
        cmp inputChar,"x"
        je exitGame

        cmp inputChar,"w"
        je moveUp

        cmp inputChar,"s"
        je moveDown

        cmp inputChar,"a"
        je moveLeft

        cmp inputChar,"d"
        je moveRight 

        cmp inputChar,27 
        je backtomenu 

         cmp inputChar,"k"
        jne keepgoing 
        call skipLevel

        keepgoing:

        mov collisionFlag,0 

        moveUp:
        ; allow player to jump:  
        cmp yPos,2
        je gameLoop  
        mov bl,yPos
        dec yPos  
        call checkCollisions 
        cmp collisionFlag,1 
        je collisionUp 
        
        mov yPos,bl
      
        call UpdatePlayer 
        dec yPos
        call DrawPlayer
        call checkFood
        call ghostcollide
        
        jmp gameLoop

        collisionUp:   
        mov yPos,bl
        jmp gameLoop

        moveDown:  
        cmp yPos,28 
        je gameLoop 

        mov bl,yPos 
        inc yPos 
        call checkCollisions 
        cmp collisionFlag,1 
        je collisionDown  
        mov yPos,bl
        call UpdatePlayer
        inc yPos
        call DrawPlayer 
        call checkFood
        call ghostcollide
        jmp gameLoop 

        collisionDown: 
        mov yPos,bl
        jmp gameLoop

        moveLeft: 
        cmp xPos,1 
        je gameLoop 
        
        mov ebx,0 
        mov bl,xPos 
        dec xPos 
        call checkCollisions 
        cmp collisionFlag,1 
        je collisionLeft  
        call ghostcollide

        mov xPos,bl
        call UpdatePlayer
        dec xPos
        call DrawPlayer 
        call checkFood 
        call ghostcollide

        jmp gameLoop 

        collisionLeft: 
        mov xPos,bl
        jmp gameLoop

        moveRight:  
        cmp xPos,118 
        je gameLoop 
        mov bl,xPos 
        inc xPos 
        call checkCollisions 
        cmp collisionFlag,1 
        je collisionRight   

        mov xPos,bl
        call UpdatePlayer
        inc xPos
        call DrawPlayer
        call ghostcollide
        call checkFood
        
        jmp gameLoop

        collisionRight: 
        mov xPos,bl 

    jmp gameLoop
    
    exitGame:
    exit
main ENDP

DrawPlayer PROC
    ; draw player at (xPos,yPos):
    mov eax,yellow ;(blue*16)
    call SetTextColor
    mov dl,xPos
    mov dh,yPos
    call Gotoxy
    mov al,"C"
    call WriteChar 
    ret
DrawPlayer ENDP

UpdatePlayer PROC
    mov dl,xPos
    mov dh,yPos
    call Gotoxy
    mov al," "
    call WriteChar
    ret
UpdatePlayer ENDP

DrawFood PROC  
    mov esi, offset foodxArray 
    mov edi,offset foodyArray 
    mov foodxindices,0 
    mov foodyindices,0 

;middle food 1
    mov bl,1
    mov temp, 0   
    mov ecx,3
    mfoodRow1: 
    mov tempCounter,ecx
    mov ecx,4
    mov dl, 64
    mov temp,dl
    mfoodCol1:
    mov dl, temp
    mov dh, 8
    add dh,bl
    call Gotoxy 
    mov [esi],dl 
    mov [edi],dh
    mov edx,OFFSET food
    mov eax,delayTime 
    call delay
    call WriteString 
    inc esi 
    inc edi 
    inc foodxindices 
    inc foodyindices
    add temp,3
    loop mfoodCol1
    add bl,2 
    mov ecx,tempCounter
    loop mfoodRow1 

    ;middle food 2
    mov bl,1
    mov temp, 0   
    mov ecx,3
    mfoodRow2: 
    mov tempCounter,ecx
    mov ecx,4
    mov dl, 49
    mov temp,dl
    mfoodCol2:
    mov dl, temp
    mov dh, 16
    add dh,bl
    call Gotoxy
      mov [esi],dl 
    mov [edi],dh
    mov edx,OFFSET food 
    mov eax,delayTime 
    call delay
    call WriteString 
     inc esi 
    inc edi 
    inc foodxindices 
    inc foodyindices
    add temp,3
    loop mfoodCol2 
    add bl,2 
    mov ecx,tempCounter
    loop mfoodRow2 

    ;top food 1
    mov bl,1
    mov temp, 0   
    mov ecx,2
    tfoodRow1: 
    mov tempCounter,ecx
    mov ecx,6
    mov dl, 27
    mov temp,dl
    tfoodCol1:
    mov dl, temp
    mov dh, 1
    add dh,bl
    call Gotoxy 
      mov [esi],dl 
    mov [edi],dh
    mov edx,OFFSET food 
    mov eax,delayTime 
    call delay
    call WriteString 
     inc esi 
    inc edi 
    inc foodxindices 
    inc foodyindices
    add temp,3
    loop tfoodCol1
    add bl,2 
    mov ecx,tempCounter
    loop tfoodRow1 

     ;top food 2
    mov bl,1
    mov temp, 0   
    mov ecx,2
    tfoodRow2: 
    mov tempCounter,ecx
    mov ecx,6
    mov dl, 78
    mov temp,dl
    tfoodCol2:
    mov dl, temp
    mov dh, 1
    add dh,bl
    call Gotoxy
      mov [esi],dl 
    mov [edi],dh
    mov edx,OFFSET food
    mov eax,delayTime 
    call delay
    call WriteString  
     inc esi 
    inc edi 
    inc foodxindices 
    inc foodyindices
    add temp,3
    loop tfoodCol2
    add bl,2 
    mov ecx,tempCounter 
    loop tfoodRow2


     ;bottom food 1
    mov bl,1
    mov temp, 0   
    mov ecx,2
    bfoodRow1: 
    mov tempCounter,ecx
    mov ecx,6
    mov dl, 28
    mov temp,dl
    bfoodCol1:
    mov dl, temp
    mov dh, 25
    add dh,bl
    call Gotoxy 
      mov [esi],dl 
    mov [edi],dh
    mov edx,OFFSET food 
    mov eax,delayTime 
    call delay
    call WriteString 
     inc esi 
    inc edi 
    inc foodxindices 
    inc foodyindices
    add temp,3
    loop bfoodCol1
    add bl,2 
    mov ecx,tempCounter
    loop bfoodRow1 

     ;bottom food 2
    mov bl,1
    mov temp, 0   
    mov ecx,2
    bfoodRow2: 
    mov tempCounter,ecx
    mov ecx,6
    mov dl, 79
    mov temp,dl
    bfoodCol2:
    mov dl, temp
    mov dh, 25
    add dh,bl
    call Gotoxy 
      mov [esi],dl 
    mov [edi],dh
    mov edx,OFFSET food
    mov eax,delayTime 
    call delay
    call WriteString  
     inc esi 
    inc edi 
    inc foodxindices 
    inc foodyindices
    add temp,3
    loop bfoodCol2
    add bl,2 
    mov ecx,tempCounter
    loop bfoodRow2 

     ;side food 1
    mov bl,1
    mov temp, 0   
    mov ecx,3
    sfoodRow1: 
    mov tempCounter,ecx
    mov ecx,5
    mov dl, 6
    mov temp,dl
    sfoodCol1:
    mov dl, temp
    mov dh, 12
    add dh,bl
    call Gotoxy 
      mov [esi],dl 
    mov [edi],dh
    mov edx,OFFSET food
    mov eax,delayTime 
    call delay
    call WriteString  
     inc esi 
    inc edi 
    inc foodxindices 
    inc foodyindices
    add temp,3
    loop sfoodCol1
    add bl,2 
    mov ecx,tempCounter
    loop sfoodRow1
 
    
     ;side food 2
    mov bl,1
    mov temp, 0   
    mov ecx,3
    sfoodRow2: 
    mov tempCounter,ecx
    mov ecx,5
    mov dl, 100
    mov temp,dl
    sfoodCol2:
    mov dl, temp
    mov dh, 12
    add dh,bl
    call Gotoxy
    mov edx,OFFSET food 
      mov [esi],dl 
    mov [edi],dh
    mov eax,delayTime 
    call delay
    call WriteString 
     inc esi 
    inc edi 
    inc foodxindices 
    inc foodyindices
    add temp,3
    loop sfoodCol2
    add bl,2 
    mov ecx,tempCounter
    loop sfoodRow2
    ret 
DrawFood ENDP


CreateRandomCoin PROC
    mov eax,55
    inc eax
    call RandomRange
    mov xCoinPos,al
    mov yCoinPos,27
    ret
CreateRandomCoin ENDP 


;***************************************************************** W A L L S ********************************************************************************** 

DrawWalls PROC  
mov esi,offset xArray 
mov edi, offset yArray

   ; mov eax,lightBlue+(lightBlue*16)
   ; call SetTextColor   

     ;middle wall 1 (vertical)
    mov ecx,15
    mov dh, 8
    mov temp,dh
    middleWall1:
    mov dl,61
    mov dh, temp
    call Gotoxy
    mov [esi],dl  
    mov edx,OFFSET midw1 
        mov eax,delayTime
    call delay
    call WriteString 
     mov bl,temp
    mov [edi],bl
    inc esi  
    inc edi
    inc xindices 
    inc yindices
    inc temp
    loop middleWall1 
    
;middle wall 2 (horizontal)
    
    mov ecx,31
    mov dl, 46
    mov temp,dl
    middleWall2:
    mov dl, temp
    mov dh, 15
    call Gotoxy
    mov [edi],dh
    mov edx,OFFSET midw2 
        mov eax,delayTime
    call delay
    call WriteString 
     mov bl,temp
    mov [esi],bl 
    inc esi  
    inc edi
    inc xindices 
    inc yindices
    inc temp
    loop middleWall2

;middle wall 3 (vertical)
    mov ecx,7
    mov dh, 15
    mov temp,dh
    middleWall3:
    mov dl,76
    mov dh, temp
    call Gotoxy
    mov [esi],dl  
    mov edx,OFFSET midw1 
        mov eax,delayTime
    call delay
    call WriteString
    mov bl,temp
    mov [edi],bl
    inc esi  
    inc edi
    inc xindices 
    inc yindices
    dec temp
    loop middleWall3 

;middle wall 4 (vertical)
    mov ecx,7
    mov dh, 15
    mov temp,dh
    middleWall4:
    mov dl,46
    mov dh, temp
    call Gotoxy
    mov [esi],dl  
    mov edx,OFFSET midw1 
        mov eax,delayTime
    call delay
    call WriteString
    mov bl,temp
    mov [edi],bl
    inc esi  
    inc edi
    inc xindices 
    inc yindices
    inc temp
    loop middleWall4 

;side wall 1 (horizontal)
    mov ecx,24
    mov dl, 1
    mov temp,dl
    sideWall1: 
    mov dl, temp
    mov dh, 10
    mov [edi],dh
    call Gotoxy
    mov edx,OFFSET midw2 
        mov eax,delayTime
    call delay
    call WriteString 
    mov bl,temp
    mov [esi],bl 
    inc esi  
    inc edi
    inc xindices 
    inc yindices
    inc temp 
    loop sidewall1 

;side wall 2 (horizontal)
    mov ecx,24
    mov dl, 1
    mov temp,dl
    sideWall2: 
    mov dl, temp
    mov dh, 20
    call Gotoxy
    mov [edi],dh
    mov edx,OFFSET midw2 
        mov eax,delayTime
    call delay
    call WriteString 
    mov bl,temp
    mov [esi],bl 
    inc esi  
    inc edi
    inc xindices 
    inc yindices
    inc temp 
    loop sidewall2 

;side wall 3 (horizontal)
    mov ecx,23
    mov dl, 118
    mov temp,dl
    sideWall3: 
    mov dl, temp
    mov dh, 10
    call Gotoxy
    mov [edi],dh
    mov edx,OFFSET midw2 
        mov eax,delayTime
    call delay
    call WriteString 
     mov bl,temp
    mov [esi],bl 
    inc esi  
    inc edi
    inc xindices 
    inc yindices
    dec temp 
    loop sidewall3 

;side wall 4 (horizontal)
    mov ecx,23
    mov dl, 118
    mov temp,dl
    sideWall4: 
    mov dl, temp
    mov dh, 20
    call Gotoxy
    mov [edi],dh
    mov edx,OFFSET midw2  
    mov eax,delayTime
    call delay
    call WriteString 
    mov bl,temp
    mov [esi],bl 
    inc esi  
    inc edi
    inc xindices 
    inc yindices
    dec temp 
    loop sidewall4
    

    ;bottom wall 1 (vertical)
    mov ecx,4
    mov dh, 28
    mov temp,dh
    bottomWall3: 
        mov dl,46
        mov dh, temp
        call Gotoxy
        mov [esi],dl  
        mov edx,OFFSET midw1 
        mov eax,delayTime
        call delay
        call WriteString 
        mov bl,temp
        mov [edi],bl
        inc esi  
        inc edi
        inc xindices 
        inc yindices
        dec temp 
    loop bottomWall3 
    
    ;bottom wall 4 (horizontal)
    mov ecx,20
    mov dl, 46
    mov temp,dl
    bottomWall2: 
    mov dl, temp
    mov dh, 25
    call Gotoxy
    mov [edi],dh
    mov edx,OFFSET midw2 
    mov eax,delayTime
    call delay
    call WriteString 
    mov bl,temp
    mov [esi],bl 
    inc esi  
    inc edi
    inc xindices 
    inc yindices
    dec temp 
    loop bottomwall2   
     
    
;bottom wall 2 (vertical)
    mov ecx,4
    mov dh, 28
    mov temp,dh
    bottomWall4:
    mov dl,76
    mov dh, temp
    call Gotoxy
     mov [esi],dl  
    mov edx,OFFSET midw1 
        mov eax,delayTime
    call delay
    call WriteString 
     mov bl,temp
    mov [edi],bl
    inc esi  
    inc edi
    inc xindices 
    inc yindices
    dec temp
    loop bottomWall4

      ;bottom wall 3 (horizontal)
    mov ecx,20
    mov dl, 76
    mov temp,dl
    bottomWall1:
    mov dl, temp
    mov dh, 25
    call Gotoxy
    mov [edi],dh
    mov edx,OFFSET midw2 
        mov eax,delayTime
    call delay
    call WriteString 
      mov bl,temp
    mov [esi],bl 
    inc esi  
    inc edi
    inc xindices 
    inc yindices
    inc temp
    loop bottomwall1  



    ;top wall 1 (vertical)
    mov ecx,4
    mov dh, 2
    mov temp,dh
    topWall3:
    mov dl,24
    mov dh, temp
    call Gotoxy
     mov [esi],dl  
    mov edx,OFFSET midw1 
        mov eax,delayTime
    call delay
    call WriteString 
     mov bl,temp
    mov [edi],bl
    inc esi  
    inc edi
    inc xindices 
    inc yindices
    inc temp
    loop topWall3
     
    ;top wall 3 (horizontal)
    mov ecx,20
    mov dl, 25
    mov temp,dl
    topWall1:
    mov dl, temp
    mov dh, 5
    call Gotoxy
    mov [edi],dh
    mov edx,OFFSET midw2 
        mov eax,delayTime
    call delay
    call WriteString 
    mov bl,temp
    mov [esi],bl 
    inc esi  
    inc edi
    inc xindices 
    inc yindices
    inc temp
    loop topWall1  
    
;top wall 2 (vertical)
    mov ecx,4
    mov dh, 2
    mov temp,dh
    topWall4:
    mov dl,96
    mov dh, temp
    call Gotoxy
       mov [esi],dl  
    mov edx,OFFSET midw1 
        mov eax,delayTime
    call delay
    call WriteString 
     mov bl,temp
    mov [edi],bl
    inc esi  
    inc edi
    inc xindices 
    inc yindices
    inc temp
    loop topWall4


;top wall 4 (horizontal)
    mov ecx,21
    mov dl, 96
    mov temp,dl
    topWall2:
    mov dl, temp
    mov dh, 5
    call Gotoxy
    mov [edi],dh
    mov edx,OFFSET midw2 
        mov eax,delayTime
    call delay
    call WriteString 
     mov bl,temp
    mov [esi],bl 
    inc esi  
    inc edi
    inc xindices 
    inc yindices
    dec temp
    loop topWall2 

    comment %
    ;side wall 5 (vertical)
    mov ecx,5
    mov dh, 13
    mov temp,dh
    sideWall5:
    mov dl,10
    mov dh, temp
    call Gotoxy
      mov [esi],dl  
    mov edx,OFFSET midw1 
        mov eax,delayTime
    call delay
    call WriteString 
     mov bl,temp
    mov [edi],bl
    inc esi  
    inc edi
    inc xindices 
    inc yindices
    inc temp
    loop sideWall5 

;side wall 6 (vertical)
    mov ecx,5
    mov dh, 13
    mov temp,dh
    sideWall6:
    mov dl,107
    mov dh, temp
    call Gotoxy
      mov [esi],dl  
    mov edx,OFFSET midw1
        mov eax,delayTime
    call delay
    call WriteString 
     mov bl,temp
    mov [edi],bl
    inc esi  
    inc edi
    inc xindices 
    inc yindices
    inc temp
    loop sideWall6 
    %
   


    ret 
DrawWalls ENDP 

;***************************************************************** T I T L E ********************************************************************************** 

DrawTitle PROC   
call clrscr 
mov dl,102
mov dh,0 
call gotoxy 
mov eax,gray 
call setTextColor
mWrite<"powered by MASM-86",0>

mov dl,0
mov dh,28
call gotoxy 
mWrite<"Hamza Mir",0> 
inc dh  
call gotoxy
mWrite<"22i-1003",0> 

mov eax, yellow
call setTextColor
mov dl,30
mov dh, 7
mov bl,dh 
inc bl
call Gotoxy 
mov edx,OFFSET title1 
    mov eax,delayTime
    call delay
call WriteString  

mov dl,30 
mov dh,bl 
inc bl
call Gotoxy
mov edx,OFFSET title2 
    mov eax,delayTime
    call delay
call WriteString  

mov dl,30 
mov dh, bl 
inc bl
call Gotoxy
mov edx,OFFSET title3 
    mov eax,delayTime
    call delay
call WriteString  
 
mov dl,30
mov dh, bl 
inc bl
call Gotoxy
mov edx,OFFSET title4 
    mov eax,delayTime
    call delay
call WriteString  
 
mov dl,30
mov dh, bl 
inc bl
call Gotoxy
mov edx,OFFSET title5
    mov eax,delayTime
    call delay
call WriteString   
mov dl,30 
mov dh, bl 
inc bl
call Gotoxy
mov edx,OFFSET title6 
    mov eax,delayTime
    call delay
call WriteString  

mov dl,48
mov dh,15 
call gotoxy 
mov eax,white 
call settextcolor  
mov eax,1000
call delay
;call Waitmsg 
;call clrscr  
ret
DrawTitle ENDP

DrawCeiling PROC 
mov ecx,120
    mov dl, 0
    mov temp,dl
    ceiling:
    mov dl, temp
    mov dh, 1
    call Gotoxy
    mov edx,OFFSET midw2
        mov eax,delayTime
    call delay
    call WriteString
    inc temp
    loop ceiling 
ret
DrawCeiling ENDP 

DrawFloor PROC 
mov ecx,120
    mov dl, 119 
    mov temp,dl
    floor:
    mov dl, temp
    mov dh, 29
    call Gotoxy
    mov edx,OFFSET midw2
        mov eax,delayTime
    call delay
    call WriteString
    dec temp
    loop floor
ret
DrawFloor ENDP



Options PROC 
mov optionNumber,1
mov eax,white
call setTextColor  
panel:
mov dl,56
mov dh,14 
call gotoxy  
call gotoxy
mov eax,100
mWrite<">",0>
mWrite<"Start Game",0> 
mov dl,55
mov dh,15  
call gotoxy
mov eax,100
call delay
mov eax,lightBlue
call setTextColor
mWrite<"Instructions",0> 
mov dl,56
mov dh,16 
call gotoxy 
mov eax,100
call delay
mWrite<"Highscores",0> 
mov dl,58
mov dh,17
call gotoxy 
mov eax,100
call delay
mWrite<"Exit",0> 


inputLoop:
mov eax,0
mov dl,60 
mov dh,20 
call gotoxy 
call readchar
cmp al,13 
je EnterPressed  
cmp al,'w' 
je upKeyPressed 
cmp al,'s'  
je downKeyPressed  
cmp al,27 
je Menu



upKeyPressed: 
cmp optionNumber,1 
je updateColors
dec optionNumber
jmp updateColors 

downKeyPressed: 
cmp optionNumber,4 
je updateColors
inc optionNumber

updateColors:  

mov eax,black+(black*16) 
call settextcolor 
mov ecx,4  
mov dh,14
mov bl,dh
clearPanel: 
mov dl,55 
mov dh,bl
call gotoxy 
mWrite<"                    ",0> 
inc bl
loop clearPanel 


cmp optionNumber,1 
je option1 

cmp optionNumber,2 
je option2

cmp optionNumber,3 
je option3 

cmp optionNumber,4 
je option4 

option1: 


mov eax,white
call setTextColor  
mov dl,56
mov dh,14 
call gotoxy  
mWrite<">",0>
mWrite<"Start Game",0> 
mov dl,55
mov dh,15  
call gotoxy
mov eax,lightBlue
call setTextColor
mWrite<"Instructions",0> 
mov dl,56
mov dh,16 
call gotoxy
mWrite<"Highscores",0> 
mov dl,58
mov dh,17 
call gotoxy
mWrite<"Exit",0>  
jmp inputLoop 

option2: 

mov eax,lightBlue
call setTextColor  
mov dl,56
mov dh,14 
call gotoxy  
mWrite<"Start Game",0> 
mov dl,55
mov dh,15  
call gotoxy
mov eax,white
call setTextColor 
mWrite<">",0>
mWrite<"Instructions",0> 
mov dl,56
mov dh,16 
call gotoxy 
mov eax,lightBlue
call setTextColor 
mWrite<"Highscores",0> 
mov dl,58
mov dh,17 
call gotoxy
mWrite<"Exit",0> 
jmp inputLoop 

option3:  

mov eax,lightBlue
call setTextColor  
mov dl,56
mov dh,14 
call gotoxy  
mWrite<"Start Game",0> 
mov dl,55
mov dh,15  
call gotoxy
mWrite<"Instructions",0> 
mov dl,56
mov dh,16 
call gotoxy
mov eax,white
call setTextColor 
mWrite<">",0>
mWrite<"Highscores",0> 
mov dl,58
mov dh,17 
call gotoxy 
mov eax,lightBlue
call setTextColor
mWrite<"Exit",0> 
jmp inputLoop

option4:  

mov eax,lightBlue
call setTextColor  
mov dl,56
mov dh,14 
call gotoxy  
mWrite<"Start Game",0> 
mov dl,55
mov dh,15  
call gotoxy 
mWrite<"Instructions",0> 
mov dl,56
mov dh,16 
call gotoxy
mWrite<"Highscores",0> 
mov dl,58
mov dh,17 
call gotoxy
mov eax,white
call setTextColor
mWrite<">",0>
mWrite<"Exit",0> 
jmp inputLoop

EnterPressed: 
cmp optionNumber,2 
je Instructions
cmp optionNumber,4 
je Menu 
ret
Options ENDP
;*************************************************************** M E N U ***********************************************************************************
Menu PROC 
mov eax,black+(black*16) 
call settextcolor 
call clrscr
call DrawTitle  
call waitmsg 
mov eax,black+(black*16) 
call settextcolor 
mov dl,48
mov dh,15 
call gotoxy 
mWrite<"                              ",0>
call Options 
call PlayerName  
mov eax,black+(black*16) 
call settextcolor 
call clrscr
ret
Menu ENDP  
;************************************************************** P L A Y E R  N A M E **************************************************************************

PlayerName PROC
call panelBlack
mov eax,cyan 
call settextcolor 
mov dl,53
mov dh,14
call gotoxy 
mov eax,1000 
call delay
mWrite<"ENTER YOUR NAME",0>  
add dl,4
inc dh   
call gotoxy
mov eax,white 
call settextcolor
mov edx,offset pname
mov ecx,255
call readstring   
ret
PlayerName ENDP

;************************************************************** W A T E R  M A R K S **************************************************************************
Watermarks PROC 
mov dl,102
mov dh,0 
call gotoxy 
mov eax,gray 
call setTextColor
mWrite<"powered by MASM-86",0>
mov dl,0
mov dh,28
call gotoxy 
mWrite<"Hamza Mir",0> 
inc dh  
call gotoxy
mWrite<"22i-1003",0>
ret
Watermarks ENDP 

;*************************************************************** I N S T R U C T I O N S ***********************************************************************
Instructions PROC 

call panelBlack 

mov dl,56 
mov dh,14 
call gotoxy 
mov eax, white 
call settextcolor 
mWrite<"INSTRUCTIONS",0> 

mov eax,gray 
call settextcolor 

mov dl, 50 
mov dh, 16
call gotoxy
mov eax,100 
call delay
mWrite<"Navigate the maze for coins!",0>
mov dl,61 
add dh,2 
call gotoxy 
mov eax,100 
call delay
mWrite<"^"> 
inc dh 
call gotoxy 
mov eax,100
call delay 
mWrite<"W",0> 
inc dh
call gotoxy 
mov eax,100
call delay
mWrite<"S",0> 
inc dh 
call gotoxy 
mov eax,100
call delay 
mWrite<"v",0>
mov dl,56 
dec dh
call gotoxy 
mov eax,100 
call delay
mWrite<"<A",0> 
mov dl,65 
call gotoxy 
mov eax,100 
call delay
mWrite<"D>",0> 
 

mov eax,white
call settextcolor
mov dl,50
mov dh, 25
call gotoxy  
mov eax,1000 
call delay
mWrite<"<-Back            Next->",0> 
inc dh
call gotoxy  
mov eax,gray 
call settextcolor
mWrite <" (Esc)           (Enter)",0>
mov dl, 60 
mov dh ,30
call gotoxy 
tutorial:
call readchar 
cmp al,27
je goToOptions
cmp al, 13 
je gotoinstructions
jmp Instructions
gotoinstructions: 
call panelblack
mov dl,56 
mov dh,14 
call gotoxy 
mov eax, white 
call settextcolor 
mWrite<"INSTRUCTIONS",0> 
mov eax,gray
call settextcolor 
mov dl,20
mov dh, 16 
call gotoxy 
mov eax,100 
call delay
mWrite<"[",0> 
mov eax,yellow
call settextcolor 
mWrite<"C",0>
mov eax,gray
call settextcolor 
mWrite<"]",0> 

mov dl,10 
mov dh,17 
call gotoxy  
mov eax,100 
call delay
mwrite<"This is your character!",0> 
inc dh 
call gotoxy  
mov eax,100 
call delay
mwrite<"Move through the mazes ",0> 
inc dh 
call gotoxy  
mov eax,100 
call delay
mwrite<"using the W-A-S-D keys",0>

mov eax,gray
call settextcolor 
mov dl,60 
mov dh, 16 
call gotoxy 
mov eax,100 
call delay
mWrite<"[",0> 
mov eax,green
call settextcolor 
mWrite<"*",0>
mov eax,gray
call settextcolor 
mWrite<"]",0>

mov dl,55 
mov dh,17 
call gotoxy  
mov eax,100 
call delay
mwrite<"Collect coins!",0>  
mov dl,50
inc dh 
call gotoxy  
mov eax,100 
call delay
mwrite<"Advance through the levels",0> 
inc dh 
call gotoxy  
mov eax,100 
call delay
mwrite<"by increasing your score",0> 

mov eax,gray
call settextcolor 
mov dl,100
mov dh, 16 
call gotoxy 
mov eax,100 
call delay
mWrite<"[",0> 
mov eax,black(white*16)
call settextcolor 
mWrite<"&",0>
mov eax,gray
call settextcolor 
mWrite<"]",0>

mov dl,98 
mov dh,17 
call gotoxy  
mov eax,100 
call delay
mwrite<"Ghosts!",0>  
mov dl,90
inc dh 
call gotoxy  
mov eax,100 
call delay
mwrite<"Enemies guard the coins",0> 
mov dl,88
inc dh 
call gotoxy  
mov eax,100 
call delay
mwrite<"Find your way around them!",0> 

mov eax,white
call settextcolor
mov dl,50
mov dh, 25
call gotoxy  
mov eax,1000 
call delay
mWrite<"<-Back            Next->",0> 
inc dh
call gotoxy  
mov eax,gray 
call settextcolor
mWrite <" (Esc)           (Enter)",0>
mov dl, 60 
mov dh ,29
call gotoxy 
call readchar  
cmp al,27 
je Instructions

goToOptions: 
call panelBlack
jmp Options 
ret
Instructions ENDP

panelBlack PROC uses ebx edx
mov eax,black+(black*16) 
call settextcolor 
mov dh,14 
mov bl,dh 
mov ecx, 14
clearPanel:
mov dl,0
mov dh,bl
call gotoxy 
mWrite<"                                                                                                                                                         ",0> 
inc bl 
loop clearPanel 
ret
panelBlack ENDP


exitPressed PROC  
mov eax,black(black*16) 
call settextcolor 
call clrscr
exit
exitPressed ENDP 

;**************************************************************** C O L L I S I O N ******************************************************************************
checkCollisions PROC  uses eax ebx ecx edx esi edi 

mov esi, offset xArray 
mov edi, offset yArray 
mov xth,0
mov collisionFlag,0
mov al,xPos  
mov dl,yPos
mov ecx,xindices 
mov xFlag,0 
mov yFlag,0 


xCheck:  
mov xFlag,1
mov ebx,0
cmp al,[esi] 
jne notx 
mov dl,yPos  
mov bl, xth
cmp dl,[edi+ebx] 
je yFound
notx: 
mov xFlag,0
inc esi 
inc xth
loop xCheck

cmp xFlag,1 
jne finishCheck
yFound:  
mov collisionFlag,1
finishCheck:
ret
checkCollisions ENDP
;*************************************************************** S C O R I N G ******************************************************************** 

checkFood PROC  uses eax ebx ecx edx esi edi
mov esi, offset foodxArray 
mov edi, offset foodyArray 
mov xth,0
mov collisionFlag,0
mov al,xPos  
mov dl,yPos
mov ecx,foodxindices 
mov xFlag,0 
mov yFlag,0 

xCheck:  
mov xFlag,1
mov ebx,0
cmp al,[esi] 
jne notx 
mov dl,yPos  
mov bl, xth
cmp dl,[edi+ebx] 
je yFound
notx: 
mov xFlag,0
inc esi 
inc xth
loop xCheck

cmp xFlag,1 
jne finishCheck
yFound: 
mov al,120
mov [esi],al 
mov [edi+ebx],al
inc score
finishCheck:
ret
checkFood ENDP 

;************************************************************* L E V E L S ********************************************************************** 

Levels PROC 
mov score,al 

cmp al,sentinalVal 
je setLevel  
jmp startoflevel
setLevel: 
mov atLevel,2


startoflevel: 
cmp atLevel,2
je changeMaze 
jmp thismaze
changeMaze:  

;    call resetArrays 
inc score
    mov eax, cyan(black*16)  
    call settextcolor 
    mov dl,0
    mov dh,14 
    call gotoxy 
    mWrite<"                                                                                                                                        "> 
    inc dh 
    call gotoxy
    mWrite<"                                                     LEVEL 1 COMPLETE                                                                   "> 
    inc dh 
    call gotoxy
    mWrite<"                                                                                                                                        "> 

    mov dl,48
    inc dh 
    call gotoxy 
    mov eax, white(black*16)  
    call settextcolor 
    mov eax,1000 
    call delay
    call readchar
mov eax,red +(red*16)
call SetTextColor 
jmp nowdraw
thismaze:
mov eax,blue +(blue*16)
call SetTextColor
 nowdraw:
    call DrawCeiling 
    
    mov ecx,27
    mov dh,2
    mov temp,dh
    rightBoundary:
    mov dh,temp
    mov dl,119
    call Gotoxy
    mov edx,OFFSET ground1 
    mov eax,delayTime
    call delay
    call WriteString
    inc temp
    loop rightBoundary 

    call DrawFloor

    mov ecx,27
    mov dh,28
    mov temp,dh
    l2:
    mov dh,temp
    mov dl,0
    call Gotoxy
    mov edx,OFFSET ground1 
    mov eax,delayTime
    call delay
    call WriteString
    dec temp
    loop l2 

    cmp atLevel,2 
    je redwalls  
    jmp bluewalls
    redwalls:  

    mov eax,lightmagenta+(lightmagenta*16) 
    call settextcolor 

    jmp okdraw 
    bluewalls: 
    mov eax,lightBlue+(lightBlue*16) 
    call settextcolor
    okdraw: 
    call DrawWalls 

    cmp atLevel,2 
    je changeFoodcolor 
    jmp samecolor 
    changefoodcolor: 
    mov eax,cyan 
    call settextcolor 
    jmp drawit
    samecolor: 
    mov eax,white
    call settextcolor
    drawit:
    call DrawFood    
ret
Levels ENDP 


;******************************************************************************************************************************************************************


;************************************************************** C O O R D I N A T E S  A R R A Y S ********************************************************************* 

resetArrays PROC 
mov esi,offset xArray 
mov edi,offset yArray 
mov ecx,500 
mov eax,120
clearWalls: 
mov [esi],al 
mov [edi],al 
inc esi 
inc edi 
loop clearWalls 

mov esi,offset foodxArray 
mov edi,offset foodyArray 
mov ecx,500
clearfood: 
mov [esi],al 
mov [edi],al 
inc esi 
inc edi 
loop clearfood 

mov xindices,0
mov yindices,0
mov foodxindices,0
mov foodyindices,0

ret
resetArrays ENDP
;************************************************************** L E V E L  H A C K  ********************************************************************* 


skipLevel PROC
        mov score,87 
        ret
        skipLevel ENDP

;***********************************************************************************************************************************  
ghostschmovement PROC  
cmp ghostx,2 
je change2right 

cmp ghostx,115
je change2left  

jmp startmovin

change2Left: 
mov patrol,0
jmp startmovin

change2right: 
mov patrol,1 


startmovin: 
cmp patrol,1
je moveRight 

cmp patrol,0 
je moveLeft 

moveRight: 
call updateghost 
inc ghostx
call drawghost
jmp done 

moveLeft:
call updateghost 
dec ghostx
call drawghost
done:
ret
ghostschmovement ENDP
DrawGhost PROC
    
    mov eax,black(white*16)
    call SetTextColor
    mov dl,ghostx
    mov dh,ghosty
    call Gotoxy
    mov eax,0 
    call delay 
    mWrite<"&",0>
    ret
DrawGhost ENDP

UpdateGhost PROC
mov eax,black(black*16)    
mov dl,ghostx
    mov dh,ghosty
    call Gotoxy
    mov eax,100 
    call delay
    mWrite<" ",0>
    ret 

UpdateGhost ENDP  


;***************************************************************************************************************************************************************** 

ghostschmovement2 PROC  
cmp ghost2x,2 
je change2right

cmp ghost2x,115
je change2left

jmp startmovin

change2Left: 
mov patrol2,0
jmp startmovin

change2right: 
mov patrol2,1 


startmovin: 
cmp patrol2,1
je moveRight 

cmp patrol2,0 
je moveLeft 

moveRight: 
call UpdateGhost2 
inc ghost2x
call drawghost2
jmp done 

moveLeft:
call UpdateGhost2 
dec ghost2x
call drawghost2
done:
ret
ghostschmovement2 ENDP
DrawGhost2 PROC
    
    mov eax,black(white*16)
    call SetTextColor
    mov dl,ghost2x
    mov dh,ghost2y
    call Gotoxy
    mov eax,0 
    call delay 
    mWrite<"&",0>
    ret
DrawGhost2 ENDP

UpdateGhost2 PROC
mov eax,black(black*16)    
mov dl,ghost2x
    mov dh,ghost2y
    call Gotoxy
    mov eax,100 
    call delay
    mWrite<" ",0>
    ret 

UpdateGhost2 ENDP  

;***************************************************************************************************************************************************************** 


ghostCollide PROC 
mov dl,xPos 
mov dh,yPos 

cmp dl,ghostx 
je xfound 
jmp done
xfound: 
cmp dh,ghosty 
je killed 
jmp done

killed: 

mov eax,black(black*16) 
call settextcolor 
call clrscr 
mov eax, red 
call settextcolor  
mov dl,60 
mov dh,15 
call gotoxy
mWrite<"you died"> 
inc dl 
call gotoxy 
call readchar 
jmp main
done:
ret
ghostCollide ENDP

;*********************************************************************************************************************************** 
endgame PROC 
mov eax,black(black*16) 
call settextcolor 
call clrscr

mov dl,52
mov dh,14 
call gotoxy 

mov eax,white(red*16)
call settextcolor 
mwrite<"  G A M E  O V E R  ",0>  
mov dl,60 
mov dh,15 
call gotoxy 
mov edx,offset pname 
call writestring
add dh,2 
call gotoxy 
mov eax,white 
call settextcolor 
mov dl,48 
mov dh,16 
call gotoxy
call waitmsg
call menu
ret
endgame ENDP

;*********************************************************************************************************************************** 


END main