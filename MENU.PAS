
uses supergfx, games, help2;

{$I block.pas}
{$I consts.pas}

type
    mapa_gry = array[1..12, 1..21] of byte;
    zapis = record
                  m : mapa_gry;
                  ilosc : byte;
            end;

var
   i, j, x, y, xx, yy, yy_, nr, ilelev, licz : integer;
   pal : tpalette;
   znak : char;
   poz : string;
   n : array[1..99] of ^string; {tablica nazw map}
   f : file of zapis;
   mapa : zapis;
   ludek, exitlevel, live_is, exit_to_menu, die, not_ : boolean;
   sc : real;
   nrl, nrlevelu, lives, ods, nrn, l_, l, l2, lawa, ilosc_marchewek,
   levelexit : byte;

procedure ustaw_gracza; forward;

procedure ustaw_def;
begin
     randomize;
     ustaw_gracza;
     l:=0;
     l2:=0;
     mapa.m[(y div 15),(x div 15)]:=8;
     nr:=1;
     nrn:=0;
     l_:=5;
     sc:=15;
     poz:='prawo';
     ludek:=true;
     lawa:=55;
     ods:=0;
     die:=false;
     ilosc_marchewek:=mapa.ilosc;
     exit_to_menu:=false;
end;

procedure put_block(x, y : integer; nr : byte);
var
   i, j : integer;
begin
     for i:= 1 to 15 do
     for j:= 1 to 15 do
     if klocki[nr,i,j]=0 then
     begin
          putpixel(j+x,i+y,klocki[8,i,j])
     end else putpixel(j+x,i+y,klocki[nr,i,j]);
end;

procedure put_block_(x, y : integer; nr : byte);
var
   i, j : integer;
begin
     for i:= 1 to 15 do
     for j:= 1 to 15 do
     if klocki[nr,i,j]<>0 then putpixel(j+x,i+y,klocki[nr,i,j]);
end;

procedure put_player(x, y : integer; nr : byte);
var
   i, j : integer;
begin
     if ludek then
     begin
          for i:= 1 to 15 do
          for j:= 1 to 15 do if gracz[nr,i,j]<>0 then putpixel(j+x,i+y,gracz[nr,i,j]);
     end;
end;

procedure put_player_shadow(x, y : integer; nr : byte);
var
   i, j : integer;
begin
     if ludek then
     begin
          for i:= 1 to 15 do
          for j:= 1 to 15 do if gracz[nr,i,j]<>0 then putpixel(j+x,i+y,22);
     end;
end;

procedure rysuj_mape;
var
   i, j : integer;
   los : byte;
begin
     for i:= 1 to 21 do
     for j:= 1 to 12 do
     begin
          {aniamacja lawy}
          if (mapa.m[j,i]=9) then
          begin
               l:=l+1;
               los:=random(5)+1;
                if (j=(y div 15)+1) and (i=(x div 15)) and ludek then live_is:=true;
                if (j=(y div 15)-1) and (i=(x div 15)) and ludek then live_is:=true;
                if (j=(y div 15)) and (i=(x div 15)-1) and ludek then live_is:=true;
                if (j=(y div 15)) and (i=(x div 15)+1) and ludek then live_is:=true;
               if los=1 then if (mapa.m[j-1,i]in[1,8]) and (l>130) then begin if j>1 then mapa.m[j-1,i]:=9; l:=0; end;
               if los=2 then if (mapa.m[j+1,i]in[1,8]) and (l>130) then begin if j<12 then mapa.m[j+1,i]:=9; l:=0; end;
               if los=3 then if (mapa.m[j,i-1]in[1,8]) and (l>130) then begin if i>1 then mapa.m[j,i-1]:=9; l:=0; end;
               if los=4 then if (mapa.m[j,i+1]in[1,8]) and (l>130) then begin if i<21 then mapa.m[j,i+1]:=9; l:=0; end;
          end;
          {pozycje items}
          if (mapa.m[j,i]=2) then
          begin
               l:=l+2;
               if (mapa.m[j+1,i]=8) and (l>3) then
               begin
                    l:=0;
                    if (j=(y div 15)-1) and (i=(x div 15)) and ludek then
                    begin
                         j:=j-1;
                         mapa.m[j+1,i]:=2;
                    end else
                    begin
                         mapa.m[j,i]:=8;
                         mapa.m[j+1,i]:=2;
                    end;
                    if (j=(y div 15)-3) and (i=(x div 15)) and ludek then
                    begin
                         ludek:=false;
                         live_is:=true;
                    end;
               end;
               if (mapa.m[j,i]=8) and (l>3) then
               begin
                    l:=0;
                    if (j=(y div 15)-1) and (i=(x div 15)) then begin j:=j-1; mapa.m[j+1,i]:=2; end else
                    begin
                         mapa.m[j,i]:=8;
                         mapa.m[j,i+1]:=2;
                    end;
               end;
          end;
          if (mapa.m[j,i]=3) then
          begin
               l2:=l2+2;
               if (mapa.m[j+1,i]=8) and (l2>3) then
               begin
                    l2:=0;
                    if (j=(y div 15)-1) and (i=(x div 15)) and ludek then
                    begin
                         j:=j-1;
                         mapa.m[j+1,i]:=3;
                    end else
                    begin
                         mapa.m[j,i]:=8;
                         mapa.m[j+1,i]:=3;
                    end;
                    if (j=(y div 15)-3) and (i=(x div 15)) and ludek then
                    begin
                         ludek:=false;
                         live_is:=true;
                    end;
               end;
          end;
          {rysowanie mapy}
          if mapa.m[j,i]<>0 then put_block(15*i-14,15*j-15,mapa.m[j,i]);
          {otwieranie drzwi gdy niema marchewek}
          if (ilosc_marchewek=0) and (mapa.m[j,i]=4) then mapa.m[j,i]:=5;
     end;
end;

procedure ustaw_gracza;
var
   i, j : integer;
   xx, yy : integer;
   los : byte;
begin
     for i:= 1 to 21 do
     for j:= 1 to 12 do
     begin
          if (mapa.m[j,i]=15) then
          begin
               x:=i*15;
               y:=j*15;
          end;
     end;
end;

function granice_up(x, y : integer) : boolean;
begin
     if mapa.m[y,x]in[2,4..7,10..14] then granice_up:=false;
end;

function granice_down(x, y : integer) : boolean;
begin
     if mapa.m[y,x]in[2,4..7,10..14] then granice_down:=false;
end;

function granice_right(x, y : integer) : boolean;
begin
     if mapa.m[y,x]in[6,4..7,10..14] then granice_right:=false;
end;

function granice_left(x, y : integer) : boolean;
begin
     if mapa.m[y,x]in[6,4..7,10,10..14] then granice_left:=false;
end;

procedure obroc_obrazki_strzalek;
begin
     for i:= 1 to 15 do
     for j:= 1 to 15 do klocki[12,j,i]:=klocki[11,i,j];
     for i:= 1 to 15 do
     for j:= 15 downto 1 do klocki[13,i,16-j]:=klocki[11,i,j];
     for i:= 1 to 15 do
     for j:= 15 downto 1 do klocki[14,16-j,i]:=klocki[11,i,j];
end;

procedure zjadaj_marchewki;
begin
     if (not keydown[leftscan] and not keydown[upscan] and not keydown[downscan])
     and (mapa.m[y div 15,(x div 15)+1]=3) and keydown[rightscan] then
     begin
          ilosc_marchewek:=ilosc_marchewek-1;
     end;
     if (not keydown[rightscan] and not keydown[upscan] and not keydown[downscan])
     and (mapa.m[y div 15,(x div 15)-1]=3) and keydown[leftscan] then
     begin
          ilosc_marchewek:=ilosc_marchewek-1;
     end;
     if (not keydown[leftscan] and not keydown[rightscan] and not keydown[downscan])
     and (mapa.m[(y div 15)-1,x div 15]=3) and keydown[upscan] then
     begin
          ilosc_marchewek:=ilosc_marchewek-1;
     end;
     if (not keydown[leftscan] and not keydown[upscan] and not keydown[rightscan])
     and (mapa.m[(y div 15)+1,x div 15]=3) and keydown[downscan] then
     begin
          ilosc_marchewek:=ilosc_marchewek-1;
     end;
end;

procedure przejdz_przez_teleport;
begin
     if (not keydown[leftscan] and not keydown[upscan] and not keydown[downscan])
     and keydown[rightscan] and (mapa.m[y div 15,x div 15+1]=11) then
     begin
          if mapa.m[y div 15,x div 15+2]in[2,4..7,9,10] then else x:=x+15;
     end;
     if (not keydown[rightscan] and not keydown[upscan] and not keydown[downscan])
     and keydown[leftscan] and (mapa.m[y div 15,x div 15-1]=13) then
     begin
          if mapa.m[y div 15,x div 15-2]in[2,4..7,9,10] then else x:=x-15;
     end;
     if (not keydown[leftscan] and not keydown[rightscan] and not keydown[upscan])
     and keydown[downscan] and (mapa.m[y div 15+1,x div 15]=12) then
     begin
          if mapa.m[y div 15+2,x div 15]in[2,4..7,9,10] then else y:=y+15;
     end;
     if (not keydown[leftscan] and not keydown[rightscan] and not keydown[downscan])
     and keydown[upscan] and (mapa.m[y div 15-1,x div 15]=14) then
     begin
          if mapa.m[y div 15-2,x div 15]in[2,4..7,9,10] then else begin y:=y-15; end;
     end;
end;

procedure wczytaj_mape(name : string);
begin
     assign(f,name);
     reset(f);
     read(f,mapa);
     close(f);
end;

procedure ustaw_level;
{$S-}
var
   f : file of string;
   i : byte;
begin
     assign(f,'maps\maps.dat');
     reset(f);
     for i:= 1 to 99 do read(f,n[i]^);
     close(f);
     {$S+}
end;

procedure koniec_levelu;

procedure scale(x, y, nr, ile : integer);
var
   scx, scy : real;
   i, j, xx, yy : byte;
   a, b : integer;
begin
     scx:=15/ile;
     for i:=1 to ile do
     for j:=1 to ile do
     begin
          xx:=round(scx*i);
          yy:=round(scx*j);
          if xx>0 then if yy>0 then if gracz[nr,yy,xx]<>0 then putpixel(x+i,y+j,gracz[nr,yy,xx]);
     end;
end;

begin
     for yy_:= 8 downto 1 do
     begin
          nrn:=nrn+1;
          sc:=sc-0.5;
          if nrn=1 then l_:=5;
          if nrn=2 then begin l_:=6; nrn:=0; end;
          scale((x-1)-round(sc),y-24+yy_,l_,round(sc+1));
          printfontxy(15+ods,187,28,numstr(ilosc_marchewek));
          pokazgrafike2;
          delay(30);
          rysuj_mape;
     end;
end;

procedure gratulacje;
var
   i, j : integer;
begin
     delay(80);
     printfontxy(15+ods,187,28,numstr(ilosc_marchewek));
     for i:= 1 to 60 do
     for j:= 1 to 40 do
     begin
          putpixel(i*2+100,j*2+60,1);
          putpixel(i*2+101,j*2+61,1);
     end;
     printfontxy(130,65,14,'GRATULACJE');
     if nrlevelu<10 then
     begin
          putpixel(148,85,10);
          putpixel(147,84,10);
          printfontxy(105,85,10,'UKONCZONYCH LEVELI=0'+numstr(nrlevelu-1));
     end
     else printfontxy(105,85,10,'UKONCZONYCH LEVELI='+numstr(nrlevelu));
     if (levelexit-1)-nrlevelu+1=0 then printfontxy(105,95,10,'ZOSTA[O=0')
     else
     begin
     if ((levelexit-1)-nrlevelu<10) or ((levelexit-1)-nrlevelu=0) and ((levelexit-1)-nrlevelu<>0) then
     printfontxy(105,95,10,'ZOSTA[O=0'+numstr((levelexit-1)-nrlevelu))
     else printfontxy(105,95,10,'ZOSTA[O='+numstr((levelexit-1)-nrlevelu));
     end;
     if levelexit-1<10 then printfontxy(105,105,10,'WSZYSTKICH LEVELI=0'+numstr(levelexit-1))
     else printfontxy(105,105,10,'WCZYSTKICH LEVELI='+numstr(levelexit-1));
     printfontxy(132,120,42,'KONIEC GRY');
     printfontxy(132,121,43,'KONIEC GRY');
     printfontxy(132,122,44,'KONIEC GRY');
     printfontxy(160,134,15,'ENTER KEY');
     putpixel(212,139,15);
     putpixel(215,139,15);
     putpixel(218,139,15);
     pokazgrafike2;
     repeat until keydown[entscan];
     exit_to_menu:=true;
end;

procedure rysuj_mape_przed;
var
   i, j, l : integer;
begin
     l:=0;
     repeat
           l:=l+1;
           i:=random(21)+1;
           j:=random(12)+1;
           put_block(15*i-14,15*j-15,mapa.m[j,i]);
           put_player(x-15,y-15,nr);
           printfontxy(15+ods,187,28,numstr(ilosc_marchewek));
           pokazgrafike2;
     until (l=2000) or keydown[1];
end;

procedure gra;
begin
obroc_obrazki_strzalek;
nrlevelu:=1;
ustaw_level;
exit_to_menu:=false;
for ilelev:= 1 to 99 do
begin
     if n[ilelev]^='..end..' then levelexit:=ilelev;
end;
if nrlevelu=ilelev then exit_to_menu:=true;
wczytaj_mape('maps\'+n[nrlevelu]^+'.map');
for y:= 0 to 9 do
begin
     line(2,181+y*2,316,181+y*2,17+y);
     line(2,181+y*2-1,316,181+y*2-1,17+y);
end;
lives:=3;
ludek:=true;
bar(89,182,119,198,23);
rectangle(89,182,119,198,29);
for i:= 1 to 3 do put_player_shadow(76+i*10,182,7);
for i:= 1 to lives do put_player(76+i*10,182,7);
nrl:=nrlevelu;
repeat
bar(0,0,320,180,0);
if live_is then
begin
     ludek:=true;
     nrlevelu:=nrl;
     lives:=lives-1;
     delay(50);
     bar(89,182,119,198,23);
     rectangle(89,182,119,198,29);
     for i:= 1 to 3 do put_player_shadow(76+i*10,182,7);
     for i:= 1 to lives do put_player(76+i*10,182,7);
     wczytaj_mape('maps\'+n[nrl]^+'.map');
end;
live_is:=false;
bar(3,182,31,198,23);
rectangle(3,182,31,198,29);
bar(33,182,89,198,23);
rectangle(33,182,89,198,29);
line(78,188,75,192,29);
if levelexit-1<10 then
begin
     printfontxy(73,187,28,'0'+numstr(levelexit-1));
end else printfontxy(73,187,28,numstr(levelexit-1));
if nrlevelu<10 then
begin
     printfontxy(29,187,28,'LEVEL=0'+numstr(nrlevelu));
end else printfontxy(29,187,28,'LEVEL='+numstr(nrlevelu));
line(19,182,19,198,29);
put_block_(3,182,3);
ustaw_def;
if not_ then rysuj_mape_przed;
licz:=60;
repeat
      rysuj_mape;
      if ludek then
      begin
      if keydown[1] then
      begin
           delay(100);
           live_is:=true
      end;
      if poz='prawo' then put_player(x-15,y-15,nr);
      if poz='lewo' then put_player(x-15,y-15,nr+2);
      if poz='gora' then put_player(x-15,y-15,nr+4);
      if poz='dol' then put_player(x-15,y-15,nr+6);
      licz:=licz+1;
      if licz=151 then licz:=150;
      if licz<70 then
      begin
           outtextxy(120,80,1,3,4,'S T A R T',false);
           outtextxy(121,81,1,3,12,'S T A R T',false)
      end else licz:=150;
      if (not keydown[leftscan] and not keydown[upscan] and not keydown[downscan])
      and (mapa.m[y div 15,(x div 15)+1]=2) and keydown[rightscan] then
      begin
           if mapa.m[y div 15,(x div 15)+2]in[1..7,9,10..14] then begin x:=x-15; nr:=2; end else
           mapa.m[y div 15,(x div 15)+2]:=2;
      end;
      if (not keydown[rightscan] and not keydown[upscan] and not keydown[downscan])
      and (mapa.m[y div 15,(x div 15)-1]=2) and keydown[leftscan] then
      begin
           if mapa.m[y div 15,(x div 15)-2]in[1..7,9,10..14] then begin x:=x+15; nr:=2; end else
           mapa.m[y div 15,(x div 15)-2]:=2;
      end;
      if (not keydown[rightscan] and not keydown[leftscan] and not keydown[downscan])
      and (mapa.m[(y div 15)-1,x div 15]=5) and keydown[upscan] then
      begin
           koniec_levelu;
           nrlevelu:=nrlevelu+1;
           nrl:=nrlevelu;
           if nrlevelu=levelexit then
           begin
                gratulacje;
                exit_to_menu:=true
           end else
           begin
                wczytaj_mape('maps\'+n[nrlevelu]^+'.map');
                exitlevel:=true
           end
      end;
      przejdz_przez_teleport;
      zjadaj_marchewki;
      if (not keydown[leftscan] and not keydown[upscan] and not keydown[downscan])
      and keydown[rightscan] and (granice_right(x div 15+1,y div 15)) and (x<21*15) then
      begin
           if (mapa.m[y div 15,(x div 15)+1]=9) then live_is:=true;
           mapa.m[y div 15,(x div 15)+1]:=8;
           poz:='prawo';x:=x+15;nr:=nr+1;if nr=3 then nr:=1
      end;
      if (not keydown[rightscan] and not keydown[upscan] and not keydown[downscan])
      and keydown[leftscan] and (granice_left(x div 15-1,y div 15)) and (x>15) then
      begin
           if (mapa.m[y div 15,(x div 15)-1]=9) then live_is:=true;
           mapa.m[y div 15,(x div 15)-1]:=8;
           poz:='lewo'; x:=x-15; nr:=nr+1; if nr=3 then nr:=1
      end;
      if (not keydown[leftscan] and not keydown[rightscan] and not keydown[downscan])
      and keydown[upscan] and (granice_up(x div 15,y div 15-1)) and (y>15) then
      begin
           if (mapa.m[(y div 15)-1,x div 15]=9) then live_is:=true;
           mapa.m[(y div 15)-1,x div 15]:=8;
           poz:='gora'; y:=y-15; nr:=nr+1; if nr=3 then nr:=1
      end;
      if (not keydown[leftscan] and not keydown[upscan] and not keydown[rightscan])
      and keydown[downscan] and (granice_down(x div 15,y div 15+1)) and (y<12*15) then
      begin
           if (mapa.m[(y div 15)+1,x div 15]=9) then live_is:=true;
           mapa.m[(y div 15)+1,x div 15]:=8;
           poz:='dol'; y:=y+15; nr:=nr+1; if nr=3 then nr:=1
      end;
      end;
      lawa:=lawa+1;
      if lawa=64 then
      begin
           lawa:=50
      end;
      setcolor(234,lawa,18,0);
      setcolor(235,lawa-5,18,0);
      setcolor(236,lawa-11,20,0);
      if ilosc_marchewek<10 then ods:=3;
      if lives=0 then die:=true;
      printfontxy(15+ods,187,28,numstr(ilosc_marchewek));
      pokazgrafike2;
      printfontxy(15+ods,187,23,numstr(ilosc_marchewek));
      delay(20)
until keydown[f10scan] or exitlevel or live_is or exit_to_menu;
if die then begin gratulacje; exit_to_menu:=true; end;
exitlevel:=false;
until keydown[f10scan] or exit_to_menu;
if keydown[f10scan] then gratulacje;
end;

procedure openregilogo(x, y : integer);
var
   ax, ay : integer;
   c : byte;
begin
     if not_ then
     begin
     c:=0;
     for ay:= 1 to 114 do
     for ax:= 1 to 174 do
     begin
          c:=c+1;
          putpixel(ax+x,ay+y-1,regilogo[175*ay+ax]);
          line(ax+x,ay+y-1,ax+x,200,regilogo[175*ay+ax]);
          if c=30 then begin pokazgrafike2; c:=0; end;
     end;
     end else
     begin
     for ax:= 1 to 174 do
     for ay:= 1 to 114 do
     begin
          putpixel(ax+x,ay+y-1,regilogo[175*ay+ax]);
     end;
     end;
     printfontxy(160-(length('M I C H A [  R Y G I E L S K I')*5) div 2,157,26,'M I C H A [  R Y G I E L S K I');
     printfontxy(160-(length('M I C H A [  R Y G I E L S K I')*5) div 2,158,15,'M I C H A [  R Y G I E L S K I');
     printfontxy(160-(length('WWW.RPAGE.PRV.PL')*5) div 2,167,26,'WWW.RPAGE.PRV.PL');
     printfontxy(160-(length('WWW.RPAGE.PRV.PL')*5) div 2,168,14,'WWW\RPAGE\PRV\PL');
     printfontxy(160-(length('REGI007]POCZTA\ONET\PL')*5) div 2,177,26,'REGI007]POCZTA\ONET\PL');
     printfontxy(160-(length('REGI007]POCZTA\ONET\PL')*5) div 2,178,10,'REGI007]POCZTA\ONET\PL');
     printfontxy(160-(length('RPAGE]POCZTA\ONET\PL')*5) div 2,187,26,'RPAGE]POCZTA\ONET\PL');
     printfontxy(160-(length('RPAGE]POCZTA\ONET\PL')*5) div 2,188,10,'RPAGE]POCZTA\ONET\PL');
end;

procedure exitgame;
begin
     settextmode(mode2);
     piszcenterx(11,14,'**********************************');
     piszcenterx(12,14,'*                                *');
     piszcenterx(13,14,'*                                *');
     piszcenterx(14,14,'*                                *');
     piszcenterx(15,14,'*                                *');
     piszcenterx(16,14,'*                                *');
     piszcenterx(17,14,'**********************************');
     piszcenterx(12,12,'FARMER');
     piszcenterx(13,12,'by');
     piszcenterx(14,12,'Michaˆ Rygielski');
     piszcenterx(15,11,'http://rpage.prv.pl');
     piszcenterx(16,11,'email:rpage@poczta.onet.pl');
end;

begin
     initgfx13h;
     for i:= 1 to 99 do new(n[i]);
     loadpal('farmer.pal');
     initnewkeyint;
     delay(100);
     if (paramstr(1)<>'/not') and (paramstr(1)<>'/NOT') then not_:=true else
     not_:=false;
     openregilogo(70,40);
     pokazgrafike2;
     delay(800);
     bar(0,0,320,200,0);
     gra;
     setoldkeyint;
     for i:= 1 to 99 do dispose(n[i]);
     closegfx13h;
     exitgame;
end.