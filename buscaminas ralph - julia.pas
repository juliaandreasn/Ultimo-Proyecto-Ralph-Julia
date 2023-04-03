program buscaminas ; 
{Julia salazar: 30.540.033}
{Ralph serra: 30.540.109}
uses crt,dos;
const 
	ent=#13;	
	esc=#27; 
	arr=#72;
	izq=#75;
	der=#77; 
	aba=#80; 
type
	celda = record contenido,estado:byte end;
	cuadro = array[1..16,1..30] of celda;
var
	campo:cuadro;               
	accion:char;
	fila,columna,base,alto,minas,libres,bdx,bdy:byte;
	a,b,c,d, nivel,relo:integer;
	opcion,nombre,apellido:string;
	comienzo:boolean; 
	
function x (jj,b:byte):byte; 
	begin 
		x:= 2*jj + b; 
	end;

function y (ii,b:byte):byte; 
	begin 
		y:= ii + b;
	end;

procedure dificultad (caracter:char ;var catetoa,catetob,xmina,libre,ax,by:byte;var inicio:boolean);
{Proceso encargado de la dificultad seleccionada}
begin
	case nivel of
	1:begin catetoa:=8; catetob:=8;   xmina:=2;  ax:=12; by:=5; end; 
	2:begin catetoa:=12; catetob:=12; xmina:=18; ax:=12; by:=5; end; 
	3:begin catetoa:=15; catetob:=14; xmina:=25; ax:=12;  by:=5; end;
	4:begin 
		clrscr;
		writeln(' ==========================================');   
		writeln(' |         Para salir preciones " ESC "   |');
		writeln(' ==========================================');   
	end;
end;
	textcolor (white);
    gotoxy(4,23); write('| MINAS: ',xmina);
	minas:= xmina;
	libre:=catetoa*catetob - xmina; 
	inicio:=false; 
end;

procedure cronometro;
{encargado de llevar el tiempo de la partida}
begin
	if relo = 1 then begin 
		for c:=0 to 24 do
		for b:=0 to 59 do
		for a:=0 to 59 do
		for d:=0 to 100 do	
		begin
		clrscr;
		gotoxy(4,25); writeln( c,' :',b,' :',a,' :',d);
		delay (10);
		end;
	end;
end;

procedure matris(var campo:cuadro; catetoa,catetob:byte);
var i,j:byte;
begin
	for i:=1 to catetob do
	for j:=1 to catetoa do
	begin 
	campo[i,j].contenido:=0; campo[i,j].estado:=1 
	end;
end;

procedure campox(var campo:cuadro; catetoa,catetob,xmina:byte);
{crea el campo junto a la dificultad seleccionada}
{inc: aumenta el valor de la variable }
var d,f,n:byte;
begin
	for n:=1 to xmina do
	begin
	repeat
		d:= Random(catetob)+1;
		f:= Random(catetoa)+1;
		until campo[d,f].contenido in [0..8];
			campo[d,f].contenido:=9;
		if d-1>0 then
	begin
		if (f-1>0)and(campo[d-1,f-1].contenido<>9) 
			then inc (campo[d-1,f-1].contenido);
		if (f+1<=catetoa)and(campo[d-1,f+1].contenido<>9) 
			then inc(campo[d-1,f+1].contenido);
		if campo[d-1,f].contenido<>9 
			then inc(campo[d-1,f].contenido)
	end;
		if d+1<=catetob then
	begin
		if (f-1>0)and(campo[d+1,f-1].contenido<>9) 
			then inc(campo[d+1,f-1].contenido);
			
		if (f+1<=catetoa)and(campo[d+1,f+1].contenido<>9) 
			then inc(campo[d+1,f+1].contenido);
		if campo[d+1,f].contenido<>9 
			then inc(campo[d+1,f].contenido);
	end;
		if (f-1>0)and(campo[d,f-1].contenido<>9) then inc(campo[d,f-1].contenido);
		if (f+1<=catetoa)and(campo[d,f+1].contenido<>9) then inc(campo[d,f+1].contenido);
	end;
end;

procedure mcampo(var campo:cuadro; catetoa,catetob,xmina:byte);
{poceso encargado de colocar las minas en el campo el cual va junto al dificultad y la matris}

var i,j,n:byte;
begin
	for n:=1 to xmina do
	begin
		repeat
			i:= Random(catetob)+1;
			j:= Random(catetoa)+1;
			until campo[i,j].contenido in [0..8];
			campo[i,j].contenido:=9;
		if i-1>0 then
		begin
			if (j-1>0)and(campo[i-1,j-1].contenido<>9) then inc(campo[i-1,j-1].contenido);
			if (j+1<=catetoa)and(campo[i-1,j+1].contenido<>9) then inc(campo[i-1,j+1].contenido);
			if campo[i-1,j].contenido<>9 then inc(campo[i-1,j].contenido);
		end;
			if i+1<=catetob then
		begin
			if (j-1>0)and(campo[i+1,j-1].contenido<>9) then inc(campo[i+1,j-1].contenido);
	        if (j+1<=catetoa)and(campo[i+1,j+1].contenido<>9) then inc(campo[i+1,j+1].contenido);
			if campo[i+1,j].contenido<>9 then inc(campo[i+1,j].contenido);
		end;
			if (j-1>0)and(campo[i,j-1].contenido<>9) then inc(campo[i,j-1].contenido);
			if (j+1<=catetoa)and(campo[i,j+1].contenido<>9) then inc(campo[i,j+1].contenido)
	end;
end;

procedure Caracter(corchete,duda,color:byte);
begin

	case color of
		red:begin textcolor(red); write('[]') end;
		yellow:begin textcolor(color); write('??') end;
	else
		begin
			if (duda+corchete) mod 2 = 0 then textcolor(8) else textcolor(7);
		write('[]');
		end;
	end;	
end;

procedure elcampo(var campo:cuadro;catetoa,catetob,ax,by:byte);
{Procedure encargado de crear el campo segun la dificultad seleccioansda}
var i,x1,x2,y1,y2:byte;
begin
	x1:= X(1,ax)-1;  
	x2:= X(catetoa,ax)+2;  
	y1:=Y(1,by)-1;  
	y2:=Y(catetob,by)+1;
	textcolor(blue);
	for i:=(x1) to (x2) do
	begin 
		gotoxy(i,y1); write('-');
		gotoxy(i,y2); write('-'); 
	end;
	for i:=(y1+1) to (y2-1) do
	begin 
		gotoxy(x1,i); 
		write('|'); 
		gotoxy(x2,i); 
		write('|'); 
	end;
	for i:=1 to catetob do
	for x1:=1 to catetoa do
	begin
		gotoxy(X(x1,bdx),Y(i,bdy));
		Caracter(i,x1,7);
	end;
end;

{dec: disminuye el valor de la variable}
procedure Derecha {#77} (var campo:cuadro; var f,c,xc:byte);
begin 
	if c < xc then inc(c) else c:=1 
end;
procedure Izquierda {#27} (var campo:cuadro; var f,c,xc:byte);
begin 
	if 1 < c then dec(c) else c:= xc 
end;
procedure Arriba {#72} (var campo:cuadro; var f,c,xf:byte);
begin 
	if 1 < f then dec(f) else f:=xf 
end;
procedure Abajo {#80}(var campo:cuadro; var f,c,xf:byte);
begin 
	if f < xf then inc(f) else f:=1 
end;

procedure Numero(num:byte);
{Mustra los numenos dentro de cada caracter}
begin
	case num of
	1..6: textcolor(num+darkgray);
	7: textcolor(LightGray);
	8: textcolor(white)
	end;
	write(num)
end;

procedure Libera(var campo:cuadro; a,b:byte; var catetoa,catetob,libre:byte);
begin
	dec(libre);
	campo[a,b].estado:=0;
	gotoxy(X(b,bdx),Y(a,bdy));
	if campo[a,b].contenido <> 0 then Numero(campo[a,b].contenido)
else
	begin
	   write(' ');
	   if(0 <b-1)and(campo[a,b-1].estado in[1,3])then 
			Libera(campo,a,b-1,catetoa,catetob, libre);
	   	   
	   if(b+1 <=catetoa)and(campo[a,b+1].estado in[1,3])then 
			Libera(campo,a,b+1,catetoa, catetob,libre);
	   
	   if(a+1<=catetob)and(campo[a+1,b].estado in[1,3])then 
			Libera(campo,a+1,b,catetoa,catetob,libre);
	   
	   if(0<a-1)and(campo[a- 1,b].estado in[1,3])then 
			Libera(campo,a-1,b,catetoa,catetob,libre);
	   
	   if(0<b-1)and(0< a-1)and(campo[a-1,b-1].estado in[1,3])then 
			Libera(campo,a-1,b-1,catetoa, catetob,libre);
	   
	   if(0<b-1)and(a+1<= catetob)and(campo[a+1,b-1].estado in[1,3])then 
			Libera(campo,a+1,b-1,catetoa,catetob,libre);
	   
	   if(b+1<=catetoa)and(0< a -1)and(campo[a-1,b+1].estado in[1,3])then
			Libera(campo,a-1,b+1,catetoa,catetob, libre);
	   
	   if(b+1<=catetoa)and(a+1 <= catetob)and(campo[a+1,b+1].estado in[1,3])then 
			Libera(campo,a+1,b+1,catetoa, catetob, libre) end;
end;

procedure Inicio;
{Durante el juego puedes presioonar (1) lo cual iniciara esa misma partida desde el principio}
begin
	dificultad(accion,base,alto,minas,libres,bdx,bdy,comienzo);
	matris(campo,base,alto);
	campox(campo,base,alto,minas);
	elcampo(campo,base,alto,bdx,bdy);
	textcolor(red); 
	fila:=alto div 2; columna:=base div 2;
	gotoxy(X(columna,bdx),Y(fila,bdy));
end;

procedure Textos; 
{textos de todo el tableroa}
begin
clrscr;
	gotoxy (15,1); write('BUSCAMINAS');
	gotoxy(3,4); write('------------------------------------------------');
	gotoxy(3,3); write('| JUGADOR: ',nombre+' ',apellido,'                               |'); 
	gotoxy(3,2); write('------------------------------------------------');
	gotoxy(3,21); write('------------------------------------------------');
	gotoxy(3,25); write('------------------------------------------------');
	gotoxy(4,22); write('| J U G A R                                    |');
	gotoxy(68,23); write('Marcar | 5 | ');
	gotoxy(65,26); write('| Utilizar las flechas del teclado  |');
	gotoxy(65,27); write('| para desplazarse dentro del campo |');
	gotoxy(4,26); write('------------------------------------------------');
	gotoxy(4,27); write('| Para volver a jugar presione | 1 |           |');
	gotoxy(4,28); write('| Para seleccionar otro nivel presione | ESC | |');
	gotoxy(4,29); write('------------------------------------------------');
	gotoxy(68,22); write('Presionar mina | ENTER |');
	
	gotoxy(4,23); write('| MINAS:                                       |');
	gotoxy(4,24); write('| TIEMPO: ', c,' :',b,' :',a,' :',d,'                           |');
	gotoxy(25,22); write('Record:');	
end;

procedure marca;
{Funcion cuando presiona (5) se marca (??, [] o vuelve a ser un caracter normal)}
begin
	if campo[fila,columna].estado <> 0 then
	case campo[fila,columna].estado of
	  1:if minas > 0 then
		 begin
			  dec(minas);
			  campo[fila,columna].estado:=2;
			  caracter(fila,columna,red);		  
		 end;
	  2:begin
			 inc(minas);
			 campo[fila,columna].estado:=3;
			 caracter(fila,columna,yellow);
		end;
		
	  3:begin 
			campo[fila,columna].estado:=1;
			caracter(fila,columna,lightgray); 
		end;
	 end;
end;

procedure Marcar; 
{Funcion cuando se gana la partida muestra todos los caracteres con minas en rojo}
var fil,col:byte;
begin
	for fil:=1 to alto do
	for col:=1 to base do
    if (campo[fil,col].contenido = 9)and(campo[fil,col].estado <> 2)then
    begin
		gotoxy(x(col,bdx),Y(fil,bdy));
		Caracter(fil,col,red)
    end;
end;

procedure Perder (fil,col:byte);
{Funcion cuando pierde la partida muestra todos los minas (<>) en rojo}
var q,w:byte;
begin
	q:=fila; 
	w:=col; 
	textcolor(red);
	for fila:=1 to alto do
	for col:=1 to base do
	if (campo[fila,col].contenido=9)and( (fila<>q) or (col<>w) ) then
	begin 
		gotoxy(X(col,bdx),Y(fila,bdy));
		textcolor (red);
		write('<>');
	end;
end;

procedure Enter;
{Despues de cadar Enter cada caracter es diferecte dependiendo del 
resultado se ejecutan las diferentes funciones}
begin
 relo:=1;
	if not comienzo then 
	begin 
		comienzo:=true; 
	end;
	if (campo[fila,columna].estado <> 2)
	and(campo[fila,columna].estado <> 0) then
case campo[fila,columna].contenido of 
	0..8:begin
			if campo[fila,columna].contenido = 0
			then Libera(campo,fila,columna,base,alto,libres)
			else begin
			  dec(libres); campo[fila,columna].estado:=0;
			  Numero(campo[fila,columna].contenido)
		end;
			if libres = 0 then
		begin
			Marcar;
			
		end;
      end;	
    9: begin
         textcolor(red); 
         write('<>'); 
         Perder (fila,columna);
		 end;
	   end;
	end;

procedure boton; 
{procedure de las acciones disponibles dentro del juego}
begin
	case accion of
	 '1': begin 		
			inicio; 
		  end;
	 ent: Enter;
	 izq: Izquierda(campo,fila,columna,base);
	 der: Derecha(campo,fila,columna,base);
	 arr: Arriba(campo,fila,columna,alto);
	 aba: Abajo(campo,fila,columna,alto);
	 '5': marca;
	end;
end;

begin
	writeln(' ===============================================================================================');
	writeln(' |                                        Ingrese su nombre                                    |');
	writeln(' ===============================================================================================');
	write(' |---> ');
	readln(nombre);
	writeln(' ===============================================================================================');
	writeln(' |                                       Ingrese su apellido                                   |');
	writeln(' ===============================================================================================');
	write(' |---> ');
	readln(apellido);
repeat
clrscr;
 	writeln(' ===============================================================================================');
	writeln('                                       B I E N V E N I D O                                      ');
 	writeln(' ===============================================================================================');
	writeln(' =                                         BUSCAMINAS                                          =');
	writeln(' ===============================================================================================');
	writeln(' =                              SELECCIONE SU NIVEL DE PREFERENCIA                             =');   
	writeln(' ===============================================================================================');    
	writeln(' | [1] PRINCIPIANTE |');
	writeln(' ====================');  
	writeln(' | [2] INTERMEDIO   |');
	writeln(' ===================='); 
	writeln(' | [3] EXPERTO      |');
	writeln(' ===================='); 
	writeln(' | [4] SALIR        |');
	writeln(' ===================='); 
	write (' '); 
	readln (nivel);
	while (nivel <> 1) and (nivel <> 2) and (nivel <> 3)and (nivel <> 4) do
	begin
				writeln('No ha seleccionado ninguna opcion');
				readln (nivel)
	end;
		accion:='1';
		textos; 
		Inicio;
	repeat
	if keypressed then 
		begin accion:= readkey; boton;
	end;
		gotoxy(X(columna,bdx),Y(fila,bdy));
	until accion = esc;
	clrscr;
	textcolor(white);
	writeln(' ===============================================================================================');
	writeln(' >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>><<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<');
	writeln(' ===============================================================================================');
	writeln(' |                             Si desea continuar presione "ENTER"                             |');
	writeln(' ===============================================================================================');
	writeln(' |                             si desea salir presione "N"                                     |');	
	writeln(' ===============================================================================================');
	writeln(' >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>><<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<');		
	writeln(' ===============================================================================================');
	write  (' |---> ');				
	readln (opcion);
	 until (opcion = 'n') or (opcion = 'N') 
end.

