.386
.model flat,stdcall   
option casemap:none  ;��Сд����

;����win32api��
include windows.inc
include gdi32.inc
include user32.inc
include kernel32.inc
includelib gdi32.lib
includelib user32.lib
includelib kernel32.lib

;ȫ�ֱ�����
	.data 
szBuffer1 db 14 dup(0)   ;�����һ�������ַ���
iResult1  dd 0			;��һ����(����atoi)
iPointer1 dd 0			;��һ���ַ�����ĩβ���
szBuffer2 db 14 dup(0)   ;�ڶ�����
iResult2  dd 0
iPointer2 dd 0
szBuffer  db 14 dup(0)   ;�ı�����ı�
iSignal   dd  0   ; �Ӽ��˳� 0 ,1,2,3 ����Ӽ��˳�
iState1   dd 0     ;��ǰ�Եڼ��������в���         
iState2   dd 0		;�Ƿ��Ѿ������� ��ֹ 0000111������������

;δ��ʼ��ȫ�ֱ�����
	.data?
hInstance dd ?   ;ʵ��
hWinMain  dd ?		;������
hEditBox  HWND ?	;editbox���
ps PAINTSTRUCT <>	
hdc HDC ?         ;����dc
hdcmem HDC ?		;����λͼ���ڴ�dc

	.const    ;������
poEditBox  POINT <35,20>      ;EDIT BOX  ������ť��λ��
szEdit	   db 'edit',0		;class name
poButton   POINT <30,150>    ;0
		   POINT <30,120>	;1
		   POINT	<60,120>	;2
		   POINT	<90,120>	;3
		   POINT	<30,90>		;4
		   POINT	<60,90>		;5
	       POINT	<90,90>		;6	
		   POINT	<30,60>	;7
		   POINT	<60,60>		;8
	       POINT	<90,60>		;9
		   POINT	<120,60>	;+
		   POINT    <120,90>	;-
		   POINT    <120,120>	;*
		   POINT    <120,150>	;/
		   POINT    <150,150>   ;=
;��ʾ�ڰ�ť���ַ�		   
szButtonName db '0',0
			 db '1',0
			 db '2',0
			 db '3',0
			 db '4',0
			 db '5',0
			 db '6',0
			 db '7',0
			 db '8',0
			 db '9',0
			 db '+',0
			 db '-',0
			 db '*',0
			 db '/',0
			 db '=',0
szButton db 'button',0,0  ;button����
szBitFileName db '1.bmp',0 ;�ļ���
ID_BUTTON dd 0ff00h ;0     ;buttonID
		 dd	0ff01h	;1
		 dd	0ff02h  ;2
		 dd	0ff03h	;3
		 dd	0ff04h	;4
		 dd	0ff05h	;5	
		 dd	0ff06h	;6
		 dd	0ff07h	;7
		 dd	0ff08h	;8
         dd	0ff09h	;9
		 dd 0ff10h  ;+
		 dd 0ff11h  ;-
		 dd 0ff12h  ;*
		 dd 0ff13h  ;/
		 dd 0ff14h  ;=
ID_EDITBOX dd 0ffffh    ;EDITBOX ID
szClassName db 'MyClass1',0,0  ;��������
szText db '�򵥵ļ�����',0   ;���ڱ���

	.code
_strlen proc uses ecx ebx esi,lpString  ;�����ַ������� lpString ָ��
	mov ecx,0  ;����
	mov ebx,0
	mov esi,lpString 
	mov al,[esi+ebx]
	.while al !=0
		inc ecx
		inc ebx
		mov al,[esi+ebx]
	.endw
	mov eax,ecx
	ret
_strlen endp

_square proc uses ecx edx ebx,N;�� 10�� n�η�
	mov ecx,N
	.if ecx == 0
		mov eax,1
		ret
	.elseif ecx == 1
		mov eax,10
		ret
	.endif
	
	mov ecx,N
	dec ecx
	mov eax,10
	mov ebx,0
	mov bl,10
	@@:
		mul ebx
		loop @b
	
	ret
_square endp

_atoi proc uses ecx esi ebx edx ,lpString   ;�ַ���ת��Ϊ���� ���ص� eax
	local @count;    ;����
	local @result;	;������
	local @temp     ; �м����
	mov  eax,0
	mov  @result,eax 
	mov  @count,eax
	invoke _strlen,lpString 
	mov ecx,eax   ;ecx�����ַ�������
	
	dec ecx
	mov esi,lpString
	@@:
		mov ebx,0
		.if ecx>20   ;overflowʵ�����Ǽ��� exc<0�����
			jmp end1
		.endif
		mov bl,[esi+ecx]  ;blΪascii��
		sub bl,30h
		invoke _square,@count ;����10��n�η�
		mov @temp,eax
		mov edx,0
		mul ebx
		add  @result,eax  ;�ۼ�
		inc @count
		dec ecx
		jmp @b
		
		
	end1:	mov eax,@result
	ret
_atoi endp

_itoa proc uses esi ebx ecx edx,iNum,stOut  ;iNum To String
	local @num
	mov eax,iNum
	mov esi,stOut
		mov ebx,0   
		mov ecx,0
	mov @num,eax   ;  ������
	and @num,80000000h
	.if @num ==0   ;����
	.else    ;����ȡ����
		neg eax
		mov[esi+ebx],byte ptr '-'  ;д�븺��
		inc ebx
	.endif
		.if eax<10    
				push eax
				inc ecx 
				jmp endl
		.endif
	
		@@:
			push ecx
			mov  ecx,10
			mov  edx,0
			
			idiv ecx
			pop ecx
			push edx    ;������ջ
			inc ecx
			.if eax<10
				push eax
				inc ecx
				jmp endl
			.endif
			
			
		jmp @b

		endl:    ;��ջ
			pop eax
			add eax,30h  ;to ascii
			mov [esi+ebx],al ;д���ַ�����
			inc ebx
			loop endl

		
		mov [esi+ebx],byte ptr 0 ;�ַ�����ֹ����
	
	
	ret
_itoa endp

_PrintResult proc uses ebx edx    ;�������Ľ��
	mov eax,iSignal   ;����ķ���
	.if eax == 0      ;+
		invoke _atoi,offset szBuffer1
		mov ebx,eax
		invoke _atoi,offset szBuffer2
		add eax,ebx
	.elseif eax == 1  ;-
		invoke _atoi,offset szBuffer1
		mov ebx,eax
		invoke _atoi,offset szBuffer2
		sub ebx,eax
		mov eax,ebx	
	.elseif eax == 2  ;*
		invoke _atoi,offset szBuffer1
		mov ebx,eax
		invoke _atoi,offset szBuffer2
		mul bx
	.elseif eax == 3  ;/
		invoke _atoi,offset szBuffer1
		mov ebx,eax
		invoke _atoi,offset szBuffer2
		xchg eax,ebx
		mov edx,0
		idiv ebx
	.endif

	invoke _itoa,eax,offset szBuffer  ;�����д��buffer��
	invoke SetWindowText,hEditBox,offset szBuffer   ;д����

	ret
_PrintResult endp

 _FuncKey proc uses esi,iNum   ;+ - * / = ����ʱ����
	mov eax,iNum
	.if eax <=3    ;+ - * /
		.if iState1 == 0    ;��һ���������
			mov iSignal,eax
			mov iState1,1   ;�Ժ�öԵڶ��������в�����
		.endif
	.elseif eax == 4    ;=
		invoke _PrintResult
		mov iState1,0    ;�Ժ�öԵ�һ�������в�����
		mov iPointer1,0  ;���ü�����
		lea esi,szBuffer1
		mov eax,0
		mov [esi],eax    ;д���ַ�����ֹ
		
		mov iPointer2,0
		lea esi,szBuffer2
		mov eax,0
		mov [esi],eax    ;��ֹ��

	.endif
	ret
_FuncKey endp					 
			

_SetTextNum proc uses eax ebx esi edi ecx edx,iNum  ;�������ּ�����
	local @state1   ;�ڼ���������
	local @state2  ;�Ƿ�������������
	mov eax,iState1  ;���Ĵ���д��ֲ�����
	mov @state1,eax	
	mov eax,iState2
	mov @state2,eax	

	.if  @state1 == 0      ;����ǰ�ǶԵڼ������������в��� 1
		.if iPointer1 == 12 ;���緵��
			ret
		.endif
		lea esi,szBuffer1  ;�����ַ�������ԭָ��
	.else                 ;�Ե�2������������
		 .if iPointer2==12 ;���� 
			ret
		 .endif
		 lea esi,szBuffer2  
	.endif
	
	;�������� �� ��ԭ�����ַ�������������
	lea edi,szBuffer;����edi
	;�ڵ�ǰ�ַ�����д������
	
	.if @state1 == 0 ;����ǵ�һ��������
		mov ebx,iNum
		mov al,szButtonName[ebx*2] ;������Ӧ�����ַ�
		mov ebx,iPointer1
		lea edx,szBuffer1[ebx]
		
		mov [edx],al
		inc edx
		mov [edx],byte ptr 0  ;���һλΪ��
	
		inc iPointer1
		mov ecx,iPointer1   ;���䳤��
		inc ecx
		mov iState2,1
	.else              ;�ڶ���������
		mov ebx,iNum
		mov al,szButtonName[ebx*2]
		mov ebx,iPointer2
		lea edx,szBuffer2[ebx]
		
		mov [edx],al
		inc edx		
		mov [edx],byte ptr 0  ;���һλΪ��
		inc iPointer2
		mov ecx,iPointer2  
		inc ecx ;Ϊ�˰� 0 Ҳ����
		mov iState2,1
	.endif

	;�����ַ�����szBuffer����ʾ

	cld 
	rep movsb   ;����
	invoke SetWindowText,hEditBox,offset szBuffer ;д�ַ�
	ret
_SetTextNum  endp


_ProcWinMain proc uses ebx edi esi,hWnd,uMsg,wParam,lParam  ;��Ϣ������
	local @iButton   ;button ID
    local @hBitmap:HBITMAP 
	mov eax,uMsg
	.if eax == WM_PAINT
		invoke BeginPaint,hWnd,offset ps
		mov hdc,eax
		invoke CreateCompatibleDC,hdc
		mov hdcmem,eax
		
		invoke LoadImage,NULL, offset szBitFileName, IMAGE_BITMAP, 0, 0, LR_LOADFROMFILE  ;����λͼ
		mov @hBitmap,eax
		invoke SelectObject,hdcmem,@hBitmap
		invoke BitBlt,hdc,0,0,640,480,hdcmem,0, 0, SRCCOPY   ;�������� dc
		invoke DeleteObject,@hBitmap
		invoke DeleteDC,hdcmem 
		invoke EndPaint,hWnd,offset ps
	.elseif eax == WM_CLOSE
	
		invoke DestroyWindow,hWinMain
		invoke PostQuitMessage,NULL
	.elseif eax == WM_CREATE
			
	;��ʼ����ť
	mov ebx,0h
	.while ebx<30
	    lea esi,szButtonName[ebx]
		invoke CreateWindowEx, WS_EX_OVERLAPPEDWINDOW, offset szButton, esi, WS_CHILD or WS_VISIBLE or BS_DEFPUSHBUTTON ,poButton[ebx*4].x, poButton[ebx*4].y, 30, 30, hWnd,ID_BUTTON[ebx*2], hInstance, NULL
		add ebx,2
	.endw
	;��ʼ��editbox
	invoke CreateWindowEx, WS_EX_CLIENTEDGE, offset szEdit, NULL, WS_CHILD or WS_VISIBLE or ES_RIGHT or ES_READONLY, poEditBox.x, poEditBox.y, 130, 20, hWnd,ID_EDITBOX, hInstance, NULL
	mov hEditBox,eax
	
	.elseif eax == WM_COMMAND
		mov eax,wParam
		mov @iButton,eax
		and @iButton,000000ffh
		.if @iButton < 0fh    ;������
		;���� SetTextNum ���� ����Ϊ ����ID
			invoke _SetTextNum,@iButton
		;���ֹ��ܼ� ֻ�������4λ
		.elseif eax ==  0ff10h
			and  @iButton,0000000fh
			invoke _FuncKey,@iButton
		.elseif eax ==  0ff11h
			and  @iButton,0000000fh
			invoke _FuncKey,@iButton
		.elseif eax ==  0ff12h
			and  @iButton,0000000fh
			invoke _FuncKey,@iButton
		.elseif eax ==  0ff13h
			and  @iButton,0000000fh
			invoke _FuncKey,@iButton
		.elseif eax ==  0ff14h
			and  @iButton,00000000fh
			invoke _FuncKey,@iButton
		.endif			
		xor eax,eax
	
	.else 
		invoke DefWindowProc,hWnd,uMsg,wParam,lParam	
		ret
	.endif
		xor eax,eax
		ret
_ProcWinMain endp

_WinMain proc              ;������
	local @stWndClass:WNDCLASSEX
	local @stMsg:MSG
	invoke GetModuleHandle,NULL   ;���ʵ��
	mov hInstance,eax
	invoke RtlZeroMemory,addr @stWndClass,sizeof @stWndClass
	invoke LoadCursor,0,IDC_ARROW
	mov @stWndClass.hCursor,eax
	push hInstance
	pop @stWndClass.hInstance
	mov @stWndClass.cbSize,sizeof WNDCLASSEX
	mov @stWndClass.style,CS_HREDRAW or CS_VREDRAW
	mov @stWndClass.lpfnWndProc,offset _ProcWinMain
	mov @stWndClass.hbrBackground,COLOR_BACKGROUND
	mov @stWndClass.lpszClassName,offset szClassName
	invoke RegisterClassEx,addr @stWndClass   ;ע�ᴰ����
	invoke CreateWindowEx,NULL,\
						offset szClassName,\
						offset szText,\
						WS_OVERLAPPED  or WS_SYSMENU or WS_MINIMIZEBOX,\
						100,100,200,220,NULL,NULL,hInstance,\
						NULL       ;��ʾ����
	mov hWinMain,eax
	invoke ShowWindow,hWinMain,SW_SHOWNORMAL
	invoke UpdateWindow,hWinMain
	
.while TRUE      ;��Ϣѭ��
	invoke GetMessage,addr @stMsg,NULL,0,0
.break  .if eax == 0
	invoke TranslateMessage,addr @stMsg
	invoke DispatchMessage,addr @stMsg
	
.endw
	ret
_WinMain endp

start:      ;�������
	call _WinMain
	invoke ExitProcess,NULL
end start

