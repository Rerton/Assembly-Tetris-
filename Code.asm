.386
.model flat, StdCall
.stack 4096
ExitProcess proto, dwExitCode:dword

GetTickCount PROTO STDCALL

GetStdHandle PROTO : DWORD
GetKeyboardState PROTO : PTR BYTE
WriteConsoleA PROTO : DWORD, : DWORD, : DWORD, : DWORD, : DWORD
AllocConsole Proto
Sleep PROTO : DWORD

GetAsyncKeyState PROTO : DWORD
SetConsoleCursorPosition PROTO: WORD, : WORD

GetTickCount PROTO STDCALL

STD_OUTPUT_HANDLE equ - 11

.data
bytesWritten dd ?
board db 1234 dup(0)
MovBlocks dd 9 dup(0)
ShapesGen db 1,5,1,4,1,3,2,4  
db 1,3,1,4,2,4,2,3 
db 1,4,2,4,3,4,4,4   
db 1,4,2,4,3,4,3,5   
db 1,4,2,4,3,4,3,3   
db 1,5,1,4,2,3,2,4   
db 1,3,1,4,2,5,2,4
test1 db 50 dup(0)
shapes db 49,48,47,92    ,47,48,92,91,  48,92,136,180  ,48,92,136,137,  48,92,136,135 ,49,48,91,92, 47,48,93,92
ofx dd 1
seed dd 0
menu db 0
mx dd 20
my dd 18
TittleScreen db 13 dup(" ")
db "_TETRIS_",10,13
db "-Rertons version 1.0",10,13
db "[press F to start]",10,13
db "[Control with side arrows <>]",10,13
db "[<,> change map width]    ",10,13
db "[U,D change map height]    ",10,13
db "[q,e change game speed]    ",10,13
ts equ $ - TittleScreen
ScoreC db "Score:    "
speed dd 200
Score dd 0
.code
main proc

cmp menu,0
jz MainMenu
game:

mov ecx, 28
GenShapes :
	movzx eax, ShapesGen[ecx * 2 - 2]
	mov ebx, 4
	imul ebx, eax
	imul eax, mx
	add eax, ebx
	movzx ebx, ShapesGen[ecx * 2 - 1]
	add eax, ebx
	mov shapes[ecx - 1], al

	dec ecx
	jnz GenShapes

mov edi, 0
mov bl, 10
mov board[edi], bl
inc edi
mov bl, 13
mov board[edi], bl
inc edi

mov ecx, 2
add ecx,mx
TopBorder:
	mov bl, "_"
	mov board[edi], bl
	inc edi
	dec ecx
	jnz TopBorder
mov bl, 13
mov board[edi], bl
inc edi
mov bl, 10
mov board[edi], bl
inc edi

mov ebx, my
mov ch, bl
YMajor:
	mov bl, "|"
	mov board[edi], bl
	inc edi

	mov edx,mx
	mov cl, dl
	XLine :
		mov bl, " "
		mov board[edi], bl
		inc edi

		dec cl
		jnz XLine

	mov bl, "|"
	mov board[edi], bl
	inc edi

	mov bl, 13
	mov board[edi], bl
	inc edi
	mov bl, 10
	mov board[edi], bl
	inc edi

	dec ch
	jnz YMajor

mov ecx, 2
add ecx,mx
BottomBorder:
	mov bl, "N"
	mov board[edi], bl
	inc edi
	dec ecx
	jnz BottomBorder
mov bl, 13
mov board[edi], bl
inc edi
mov bl, 10
mov board[edi], bl
inc edi



call GetTickCount
mov ebx,8
xor edx,edx
div ebx
mov eax,edx
mov ebx,4
mul ebx
dec eax
mov MovBlocks[0], 4
mov ecx, 4
Ready:
	movzx ebx,shapes[ecx+eax]
	add ebx,ofx
	mov board[ebx],"#"
	mov MovBlocks[ecx*4], ebx
	dec ecx
	jnz Ready


MainLoop:
	invoke sleep, speed

	mov ebx,my
	mov ch,bl
	CheckLines:
		mov ebx, mx
		mov cl,bl
		CheckLine:
			movzx eax,ch
			imul eax,mx
			movzx ebx,ch
			imul ebx,4
			add eax,ebx

			movzx ebx,cl
			add eax,ebx
			add eax,2
			cmp board[eax],"O"
			jne NotFull
			dec cl
			jnz CheckLine
		inc Score
		push cx

		movzx eax, ch
		imul eax, mx
		movzx ebx, ch
		imul ebx, 4
		add eax, ebx
		add eax, 3
		mov edi,eax

		mov ebx, mx
		mov cl,bl
		DeleteLine:
			mov board[edi]," "
			inc edi
			dec cl
			jnz DeleteLine
		
		dec ch
		MoveDownY:
			mov ebx,mx
			mov cl, bl

			movzx eax, ch
			imul eax, mx
			movzx ebx, ch
			imul ebx, 4
			add eax, ebx
			add eax, 3
			mov edi,eax

			MoveDownX:
				mov al, board[edi]
				mov ebx, edi
				add ebx, mx
				add ebx, 4
				inc edi

				mov board[ebx],al
				
				dec cl
				jnz MoveDownX

			dec ch
			jnz MoveDownY

		pop cx
		NotFull:
		dec ch
		jnz CheckLines

	invoke GetAsyncKeyState, 37
	test ax, 8000h
	jz checkD
		mov ecx,4
		CheckSidesA:
			mov eax, MovBlocks[ecx * 4]
			dec eax
			mov bl, board[eax]
			cmp bl," "
			jne check2
				jmp procced
			check2:
				cmp bl, "#"
				jne Colision
			procced:
			dec ecx
			jnz CheckSidesA
		mov ecx,4
		MoveSideA:
			mov eax, MovBlocks[ecx * 4]
			dec eax
			mov MovBlocks[ecx * 4],eax
			mov board[eax], '#'
			mov board[eax+1], ' '
			dec ecx
			jnz MoveSideA
		cmp ofx,0
		je Colision
		dec ofx
		jmp Colision
	checkD:
	invoke GetAsyncKeyState, 39
	test ax, 8000h
	jz Colision
	mov ecx,4
	CheckSidesD:
		mov eax, MovBlocks[ecx * 4]
		inc eax
		mov bl, board[eax]
		cmp bl," "
		jne check3
			jmp procced2
		check3:
			cmp bl, "#"
			jne Colision
		procced2:
		dec ecx
		jnz CheckSidesD
	mov ecx,4
	MoveSideD:
		mov eax, MovBlocks[ecx * 4]
		inc eax
		mov MovBlocks[ecx * 4],eax
		mov board[eax], '#'
		mov board[eax-1], ' '
		dec ecx
		jnz MoveSideD
	mov eax,mx
	sub eax,3
	cmp ofx,eax
	je Colision
	inc ofx

	Colision:
	mov eax, MovBlocks[0]
	test eax,eax
	jz MainLoop
		mov ch,al
		mov cl,al

		mov edi,0
		CheckCol:
			movzx ebx, ch
			imul ebx,4
			mov eax, MovBlocks[ebx]
			add eax, mx
			add eax, 4
			cmp board[eax]," "
			je ContinueMoving
				cmp board[eax], "#"
				je ContinueMoving
					mov ecx,MovBlocks[0]
					Place:
						mov ebx,ecx
						imul ebx,4
						mov eax, MovBlocks[ebx]
						mov board[eax], "O"
						dec ecx
						jnz Place
					movzx ebx, board[eax]
					mov ecx,4
					ClearMB:
						mov eax,0
						mov MovBlocks[ecx*4],eax
						dec ecx
						jnz ClearMB

					mov MovBlocks[0], 4
					mov ecx, 4
					mov eax,seed
					imul eax,173557
					add eax,171
					mov seed,eax
					mov ebx,7
					xor edx,edx
					div ebx
					mov eax,edx
					imul eax,4
					dec eax
					New:
						movzx ebx,shapes[ecx+eax]
						add ebx,ofx
						movzx edi, board[ebx]
						cmp edi,"O"
						je lose
						mov board[ebx],"#"
						mov MovBlocks[ecx*4], ebx
						dec ecx
						jnz New

					jmp MainLoop

			ContinueMoving:
			add edi,4
			dec ch
			jnz CheckCol

		MoveBlocks:
			movzx ebx,cl
			imul ebx,4
			mov eax, MovBlocks[ebx]
			mov board[eax]," "
			add eax,4
			add eax,mx
			mov MovBlocks[ebx],eax
			mov board[eax],"#"
			dec cl
			jnz MoveBlocks

		mov eax,Score
		mov ecx,3
		mov ebx,10
		Score2Str:

			xor edx,edx
			div ebx
			add dl,"0"
			mov ScoreC[ecx+5],dl
			jmp dd1

			dd1:
			dec ecx
			jnz Score2Str


		call AllocConsole
		push STD_OUTPUT_HANDLE
		call GetStdHandle
		mov ebx, eax

		mov ax, 0      
		mov dx, 0      
		shl edx, 8
		or eax, edx

		push eax
		push ebx
		call SetConsoleCursorPosition

		push 0
		push OFFSET bytesWritten
		push 1232
		push offset board
		push ebx
		call WriteConsoleA

		call AllocConsole
		push STD_OUTPUT_HANDLE
		call GetStdHandle
		mov ebx, eax

		mov ecx,mx
		mov ax, cx
		add ax,4
		mov dx, 0     
		shl edx, 8
		or eax, edx

		push eax
		push ebx
		call SetConsoleCursorPosition

		push 0
		push OFFSET bytesWritten
		push 9
		push offset ScoreC
		push ebx
		call WriteConsoleA

	jmp MainLoop

MainMenu:

mov eax,mx
mov ecx,2
mov ebx,10
MapXStr:
	test eax,eax
	jz nothing
		xor edx,edx
		div ebx
		add dl,"0"
		mov TittleScreen[ecx+119],dl
		jmp aa
	nothing:
		mov TittleScreen[ecx+119]," "
	aa:
	dec ecx
	jnz MapXStr

mov eax,my
mov ecx,2
mov ebx,10
MapYStr:
	test eax,eax
	jz nothing2
		xor edx,edx
		div ebx
		add dl,"0"
		mov TittleScreen[ecx+147],dl
		jmp bb
	nothing2:
		mov TittleScreen[ecx+147]," "
	bb:
	dec ecx
	jnz MapYStr

mov eax,speed
mov ecx,3
mov ebx,10
SpeedStr:
	test eax,eax
	jz nothing3
		xor edx,edx
		div ebx
		add dl,"0"
		mov TittleScreen[ecx+176],dl
		jmp cc
	nothing3:
		mov TittleScreen[ecx+176]," "
	cc:
	dec ecx
	jnz SpeedStr

call AllocConsole
push STD_OUTPUT_HANDLE
call GetStdHandle
mov ebx, eax

mov ax, 0
mov dx, 4
shl edx, 16
or eax, edx

push eax
push ebx
call SetConsoleCursorPosition

push 0
push OFFSET bytesWritten
push ts
push offset TittleScreen
push ebx
call WriteConsoleA

WaitForKey:
	invoke sleep, 50
	invoke GetAsyncKeyState, 70
	test ax, 8000h
	jnz game

	invoke sleep, 50
	invoke GetAsyncKeyState, 37
	test ax, 8000h
	jz CheckFD
		cmp mx,6
		je WaitForKey
		dec mx
		jmp MainMenu
	CheckFD:
	invoke GetAsyncKeyState, 39
	test ax, 8000h
	jz CheckFW
		cmp mx, 40
		je WaitForKey
		inc mx
		jmp MainMenu
	CheckFW:
	invoke GetAsyncKeyState, 38
	test ax, 8000h
	jz CheckFS
		cmp my, 26
		je WaitForKey
		inc my
		jmp MainMenu
	CheckFS:
	invoke GetAsyncKeyState, 40
	test ax, 8000h
	jz CheckFQ
		cmp my, 10
		je WaitForKey
		dec my
		jmp MainMenu
	CheckFQ:
	invoke GetAsyncKeyState, 81
	test ax, 8000h
	jz CheckFE
		cmp speed, 40
		je WaitForKey
		mov eax,speed
		sub eax,5
		mov speed,eax
		jmp MainMenu
	CheckFE:
	invoke GetAsyncKeyState, 69
	test ax, 8000h
	jz WaitForKey
		cmp speed, 300
		je WaitForKey
		mov eax, speed
		add eax, 5
		mov speed, eax
		jmp MainMenu

lose:
invoke ExitProcess, 0
main ENDP
END main
