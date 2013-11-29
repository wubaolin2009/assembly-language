.386
.model flat,stdcall   
option casemap:none  ;大小写区分

;包含win32api库
include windows.inc
include gdi32.inc
include user32.inc
include kernel32.inc
includelib gdi32.lib
includelib user32.lib
includelib kernel32.lib

;全局变量区
	.data 
szBuffer1 db 14 dup(0)   ;储存第一个数的字符串
iResult1  dd 0			;第一个数(调用atoi)
iPointer1 dd 0			;第一个字符串的末尾序号
szBuffer2 db 14 dup(0)   ;第二个数
iResult2  dd 0
iPointer2 dd 0
szBuffer  db 14 dup(0)   ;文本框的文本
iSignal   dd  0   ; 加减乘除 0 ,1,2,3 代表加减乘除
iState1   dd 0     ;当前对第几个数进行操作         
iState2   dd 0		;是否已经有输入 防止 0000111这样的数出现

;未初始的全局变量区
	.data?
hInstance dd ?   ;实例
hWinMain  dd ?		;窗体句柄
hEditBox  HWND ?	;editbox句柄
ps PAINTSTRUCT <>	
hdc HDC ?         ;窗口dc
hdcmem HDC ?		;载入位图的内存dc

	.const    ;常量区
poEditBox  POINT <35,20>      ;EDIT BOX  各个按钮的位置
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
;显示在按钮的字符		   
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
szButton db 'button',0,0  ;button类名
szBitFileName db '1.bmp',0 ;文件名
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
szClassName db 'MyClass1',0,0  ;窗体类名
szText db '简单的计算器',0   ;窗口标题

	.code
_strlen proc uses ecx ebx esi,lpString  ;计算字符串长度 lpString 指针
	mov ecx,0  ;计数
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

_square proc uses ecx edx ebx,N;求 10的 n次方
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

_atoi proc uses ecx esi ebx edx ,lpString   ;字符串转换为整数 翻回到 eax
	local @count;    ;计数
	local @result;	;保存结果
	local @temp     ; 中间变量
	mov  eax,0
	mov  @result,eax 
	mov  @count,eax
	invoke _strlen,lpString 
	mov ecx,eax   ;ecx保存字符串长度
	
	dec ecx
	mov esi,lpString
	@@:
		mov ebx,0
		.if ecx>20   ;overflow实际上是计算 exc<0的情况
			jmp end1
		.endif
		mov bl,[esi+ecx]  ;bl为ascii码
		sub bl,30h
		invoke _square,@count ;计算10的n次方
		mov @temp,eax
		mov edx,0
		mul ebx
		add  @result,eax  ;累加
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
	mov @num,eax   ;  看正负
	and @num,80000000h
	.if @num ==0   ;正数
	.else    ;负数取补码
		neg eax
		mov[esi+ebx],byte ptr '-'  ;写入负号
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
			push edx    ;余数入栈
			inc ecx
			.if eax<10
				push eax
				inc ecx
				jmp endl
			.endif
			
			
		jmp @b

		endl:    ;出栈
			pop eax
			add eax,30h  ;to ascii
			mov [esi+ebx],al ;写到字符串中
			inc ebx
			loop endl

		
		mov [esi+ebx],byte ptr 0 ;字符串中止符号
	
	
	ret
_itoa endp

_PrintResult proc uses ebx edx    ;打出最近的结果
	mov eax,iSignal   ;最近的符号
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

	invoke _itoa,eax,offset szBuffer  ;将结果写到buffer中
	invoke SetWindowText,hEditBox,offset szBuffer   ;写入结果

	ret
_PrintResult endp

 _FuncKey proc uses esi,iNum   ;+ - * / = 按下时调用
	mov eax,iNum
	.if eax <=3    ;+ - * /
		.if iState1 == 0    ;第一个输入符号
			mov iSignal,eax
			mov iState1,1   ;以后该对第二个数进行操作了
		.endif
	.elseif eax == 4    ;=
		invoke _PrintResult
		mov iState1,0    ;以后该对第一个数进行操作了
		mov iPointer1,0  ;重置计算器
		lea esi,szBuffer1
		mov eax,0
		mov [esi],eax    ;写入字符串中止
		
		mov iPointer2,0
		lea esi,szBuffer2
		mov eax,0
		mov [esi],eax    ;中止符

	.endif
	ret
_FuncKey endp					 
			

_SetTextNum proc uses eax ebx esi edi ecx edx,iNum  ;按下数字键调用
	local @state1   ;第几个操作数
	local @state2  ;是否输入过别的数字
	mov eax,iState1  ;将寄存器写入局部变量
	mov @state1,eax	
	mov eax,iState2
	mov @state2,eax	

	.if  @state1 == 0      ;看当前是对第几个操作数进行操作 1
		.if iPointer1 == 12 ;超界返回
			ret
		.endif
		lea esi,szBuffer1  ;设置字符串传送原指针
	.else                 ;对第2个操作数操作
		 .if iPointer2==12 ;返回 
			ret
		 .endif
		 lea esi,szBuffer2  
	.endif
	
	;处理输入 即 在原来的字符串上增加数字
	lea edi,szBuffer;设置edi
	;在当前字符串后写入数字
	
	.if @state1 == 0 ;如果是第一个操作数
		mov ebx,iNum
		mov al,szButtonName[ebx*2] ;载入相应键的字符
		mov ebx,iPointer1
		lea edx,szBuffer1[ebx]
		
		mov [edx],al
		inc edx
		mov [edx],byte ptr 0  ;最后一位为零
	
		inc iPointer1
		mov ecx,iPointer1   ;传输长度
		inc ecx
		mov iState2,1
	.else              ;第二个操作数
		mov ebx,iNum
		mov al,szButtonName[ebx*2]
		mov ebx,iPointer2
		lea edx,szBuffer2[ebx]
		
		mov [edx],al
		inc edx		
		mov [edx],byte ptr 0  ;最后一位为零
		inc iPointer2
		mov ecx,iPointer2  
		inc ecx ;为了把 0 也拷贝
		mov iState2,1
	.endif

	;传输字符串到szBuffer并显示

	cld 
	rep movsb   ;传送
	invoke SetWindowText,hEditBox,offset szBuffer ;写字符
	ret
_SetTextNum  endp


_ProcWinMain proc uses ebx edi esi,hWnd,uMsg,wParam,lParam  ;消息处理函数
	local @iButton   ;button ID
    local @hBitmap:HBITMAP 
	mov eax,uMsg
	.if eax == WM_PAINT
		invoke BeginPaint,hWnd,offset ps
		mov hdc,eax
		invoke CreateCompatibleDC,hdc
		mov hdcmem,eax
		
		invoke LoadImage,NULL, offset szBitFileName, IMAGE_BITMAP, 0, 0, LR_LOADFROMFILE  ;载入位图
		mov @hBitmap,eax
		invoke SelectObject,hdcmem,@hBitmap
		invoke BitBlt,hdc,0,0,640,480,hdcmem,0, 0, SRCCOPY   ;画到窗口 dc
		invoke DeleteObject,@hBitmap
		invoke DeleteDC,hdcmem 
		invoke EndPaint,hWnd,offset ps
	.elseif eax == WM_CLOSE
	
		invoke DestroyWindow,hWinMain
		invoke PostQuitMessage,NULL
	.elseif eax == WM_CREATE
			
	;初始话按钮
	mov ebx,0h
	.while ebx<30
	    lea esi,szButtonName[ebx]
		invoke CreateWindowEx, WS_EX_OVERLAPPEDWINDOW, offset szButton, esi, WS_CHILD or WS_VISIBLE or BS_DEFPUSHBUTTON ,poButton[ebx*4].x, poButton[ebx*4].y, 30, 30, hWnd,ID_BUTTON[ebx*2], hInstance, NULL
		add ebx,2
	.endw
	;初始画editbox
	invoke CreateWindowEx, WS_EX_CLIENTEDGE, offset szEdit, NULL, WS_CHILD or WS_VISIBLE or ES_RIGHT or ES_READONLY, poEditBox.x, poEditBox.y, 130, 20, hWnd,ID_EDITBOX, hInstance, NULL
	mov hEditBox,eax
	
	.elseif eax == WM_COMMAND
		mov eax,wParam
		mov @iButton,eax
		and @iButton,000000ffh
		.if @iButton < 0fh    ;是数字
		;调用 SetTextNum 函数 参数为 函数ID
			invoke _SetTextNum,@iButton
		;各种功能键 只传入最后4位
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

_WinMain proc              ;主函数
	local @stWndClass:WNDCLASSEX
	local @stMsg:MSG
	invoke GetModuleHandle,NULL   ;获得实例
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
	invoke RegisterClassEx,addr @stWndClass   ;注册窗口类
	invoke CreateWindowEx,NULL,\
						offset szClassName,\
						offset szText,\
						WS_OVERLAPPED  or WS_SYSMENU or WS_MINIMIZEBOX,\
						100,100,200,220,NULL,NULL,hInstance,\
						NULL       ;显示窗口
	mov hWinMain,eax
	invoke ShowWindow,hWinMain,SW_SHOWNORMAL
	invoke UpdateWindow,hWinMain
	
.while TRUE      ;消息循环
	invoke GetMessage,addr @stMsg,NULL,0,0
.break  .if eax == 0
	invoke TranslateMessage,addr @stMsg
	invoke DispatchMessage,addr @stMsg
	
.endw
	ret
_WinMain endp

start:      ;程序入口
	call _WinMain
	invoke ExitProcess,NULL
end start

